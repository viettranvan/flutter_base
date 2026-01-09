/// Contract for handling authentication events
/// Project implements these to define token refresh & session expiry behavior
///
/// Usage Example:
/// ```dart
/// class MyAuthHandler implements AuthEventHandler {
///   @override
///   Future<String?> refreshTokenRequest(String refreshToken) async {
///     // Call your BE refresh endpoint
///     final response = await httpClient.post(
///       '/auth/refresh',
///       data: {'refresh_token': refreshToken},
///     );
///
///     // Parse and return new access token
///     return response.data['access_token'];
///   }
///
///   @override
///   Future<void> onParsedNewToken(String newToken) async {
///     // Update token in storage (already saved by interceptor)
///     // Notify listeners, resume paused requests
///     print('Token refreshed: $newToken');
///   }
///
///   @override
///   Future<void> onSessionExpired() async {
///     // Clear local data, navigate to login
///     await tokenStorage.clearTokens();
///     navigateToLogin();
///   }
/// }
/// ```
abstract class AuthEventHandler {
  /// Refresh access token using refresh token
  /// Called by AuthInterceptor when 401 detected
  ///
  /// Should:
  /// - Call BE refresh endpoint with refreshToken
  /// - Return new access token on success
  /// - Return null or throw on failure (interceptor will handle)
  Future<String?> refreshTokenRequest(String refreshToken);

  /// Called after successful token refresh
  ///
  /// Should:
  /// - Update UI (token refreshed notification)
  /// - Resume paused requests
  /// - Notify listeners
  Future<void> onParsedNewToken(String newToken);

  /// Called when token refresh fails or refresh token invalid
  ///
  /// Should:
  /// - Clear stored tokens
  /// - Clear user data
  /// - Navigate to login screen
  /// - Show error message if needed
  Future<void> onSessionExpired();
}
