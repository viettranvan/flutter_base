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

  AuthInterceptor({
    required this.tokenStorage,
    this.authHandler,
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

    // Step 2: Handle 401 - token refresh needed
    // TODO: Project implementation should:
    // - Get refresh token from tokenStorage.getRefreshToken()
    // - Call authHandler?.refreshTokenRequest(refreshToken)
    // - Save new token via tokenStorage.saveAccessToken(newToken)
    // - Retry original request with new token
    // - If refresh fails, clear tokens & trigger authHandler?.onSessionExpired()

    // For now, just pass error to project error handler
    handler.next(err);
  }
}
