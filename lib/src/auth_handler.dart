import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/src/router/router.dart';
import 'package:go_router/go_router.dart';

/// ========== CASE 1: String, String (Current Implementation) ==========
/// - TRefreshRequest = String (just refreshToken)
/// - TRefreshResponse = String (just accessToken)
///
/// Usage:
/// ```dart
/// class AuthHandler extends AuthEventHandler<String, String> {
///   @override
///   String buildRefreshTokenRequest(String refreshToken) => refreshToken;
///
///   @override
///   Future<String?> refreshTokenRequest(String request) async {
///     final response = await dio.post('/auth/refresh',
///       data: {'refresh_token': request}
///     );
///     return response.data['access_token'] as String?;
///   }
///
///   @override
///   String? extractAccessTokenFromResponse(String? response) => response;
/// }
/// ```

/// ========== CASE 2: Model, Model (Alternative for Complex Cases) ==========
/// If your API returns more data (expiresIn, newRefreshToken, etc.),
/// consider using models:
///
/// ```dart
/// // Define Request Model
/// class RefreshTokenRequest {
///   final String refreshToken;
///   final String? deviceId;
///   final String? appVersion;
///
///   RefreshTokenRequest({
///     required this.refreshToken,
///     this.deviceId,
///     this.appVersion,
///   });
///
///   Map<String, dynamic> toJson() => {
///     'refresh_token': refreshToken,
///     if (deviceId != null) 'device_id': deviceId,
///     if (appVersion != null) 'app_version': appVersion,
///   };
/// }
///
/// // Define Response Model
/// class RefreshTokenResponse {
///   final String accessToken;
///   final String? newRefreshToken;
///   final int expiresIn;
///
///   RefreshTokenResponse({
///     required this.accessToken,
///     this.newRefreshToken,
///     this.expiresIn = 3600,
///   });
///
///   factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
///     return RefreshTokenResponse(
///       accessToken: json['access_token'] as String,
///       newRefreshToken: json['new_refresh_token'] as String?,
///       expiresIn: json['expires_in'] as int? ?? 3600,
///     );
///   }
/// }
///
/// // Then use like:
/// class AuthHandler extends AuthEventHandler<RefreshTokenRequest, RefreshTokenResponse> {
///   @override
///   RefreshTokenRequest buildRefreshTokenRequest(String refreshToken) {
///     return RefreshTokenRequest(
///       refreshToken: refreshToken,
///       deviceId: deviceManager.deviceId,
///       appVersion: appInfo.version,
///     );
///   }
///
///   @override
///   Future<RefreshTokenResponse?> refreshTokenRequest(RefreshTokenRequest request) async {
///     final response = await dio.post('/auth/refresh', data: request.toJson());
///     return RefreshTokenResponse.fromJson(response.data);
///   }
///
///   @override
///   String? extractAccessTokenFromResponse(RefreshTokenResponse? response) {
///     if (response?.newRefreshToken != null) {
///       tokenStorage.saveRefreshToken(response!.newRefreshToken!);
///     }
///     tokenStorage.saveTokenExpiry(
///       DateTime.now().add(Duration(seconds: response?.expiresIn ?? 3600))
///     );
///     return response?.accessToken;
///   }
/// }
/// ```

class AuthHandler extends AuthEventHandler<String, String> {
  @override
  Future<void> onParsedNewToken(String newToken) {
    AppLogger.i('Token refreshed');
    return Future.value();
  }

  @override
  Future<void> onSessionExpired() {
    final context = rootNavigatorKey.currentContext;

    if (context == null) {
      AppLogger.e('No context available for refresh token request');
      return Future.value(null);
    }
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Có lỗi xảy ra'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your session has expired. Please log in again to continue using the app.',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await appStorage.deleteValue(AppStorageKey.accessToken);
              await appStorage.deleteValue(AppStorageKey.refreshToken);
              if (context.mounted) {
                context.pushReplacement(RouteName.signIn.path);
              }
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Future<String?> refreshTokenRequest(String refreshToken) {
    // TODO: implement refreshTokenRequest here
    throw UnimplementedError();
  }

  @override
  String buildRefreshTokenRequest(String refreshToken) {
    return refreshToken;
  }

  @override
  String? extractAccessTokenFromResponse(String? response) {
    return response;
  }
}
