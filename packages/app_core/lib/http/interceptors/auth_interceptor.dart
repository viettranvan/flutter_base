import 'dart:async';

import 'package:app_core/app_core.dart';

/// Interceptor for handling authentication
/// Responsibilities:
/// 1. Inject Bearer token to every request
/// 2. Detect 401 responses (token expired)
/// 3. Delegate token refresh to AuthEventHandler (project implementation)
///
/// Usage Example:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(
///   AuthInterceptor(
///     tokenStorage: tokenStorage,
///     authHandler: authHandler,
///   ),
/// );
/// ```
class AuthInterceptor extends QueuedInterceptor {
  final TokenStorage tokenStorage;
  final AuthEventHandler? authHandler;
  final Dio dio;

  AuthInterceptor({
    required this.tokenStorage,
    this.authHandler,
    required this.dio,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Step 1: Get access token from storage (sync - from memory cache)
    final token = tokenStorage.getAccessToken();

    // Step 2: Inject Bearer token to Authorization header
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Step 1: Check if error is 401 Unauthorized (token expired)
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Step 2: Check if authHandler is available for token refresh
    if (authHandler == null) {
      handler.next(err);
      return;
    }

    // Step 3: Get refresh token from storage
    final refreshToken = tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      // No refresh token available → session expired
      await authHandler!.onSessionExpired();
      handler.reject(err);
      return;
    }

    try {
      // Step 4a: Project builds request data (can include deviceId, userId, etc.)
      final refreshRequest =
          authHandler!.buildRefreshTokenRequest(refreshToken);

      // Step 4b: Delegate to project implementation to refresh token
      // authHandler calls BE endpoint and returns response
      final refreshResponse =
          await authHandler!.refreshTokenRequest(refreshRequest);

      // Step 4c: Project extracts access token from response
      final newAccessToken =
          authHandler!.extractAccessTokenFromResponse(refreshResponse);

      if (newAccessToken == null || newAccessToken.isEmpty) {
        // Refresh failed → session expired
        await authHandler!.onSessionExpired();
        handler.reject(err);
        return;
      }

      // Step 5: Save new token to storage
      await tokenStorage.saveAccessToken(newAccessToken);

      // Step 6: Notify handler about successful token refresh (for UI updates)
      await authHandler!.onParsedNewToken(newAccessToken);

      // Step 7: Retry the original request with new token
      final requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      try {
        final response = await dio.request<dynamic>(
          requestOptions.path,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
            contentType: requestOptions.contentType,
            responseType: requestOptions.responseType,
            validateStatus: requestOptions.validateStatus,
          ),
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
        );

        // Step 8: Return retried response to caller
        handler.resolve(response);
      } catch (retryErr) {
        // Retry failed - check if still 401 (token really expired)
        if (retryErr is DioException && retryErr.response?.statusCode == 401) {
          await authHandler!.onSessionExpired();
        }

        // Re-throw as DioException if it's not already
        if (retryErr is DioException) {
          handler.reject(retryErr);
        } else {
          final dioException = DioException(
            requestOptions: requestOptions,
            error: retryErr,
            type: DioExceptionType.unknown,
          );
          handler.reject(dioException);
        }
      }
    } catch (e) {
      // Refresh request itself failed or unexpected error
      // Treat as session expired
      await authHandler!.onSessionExpired();
      handler.reject(err);
    }
  }
}
