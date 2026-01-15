/// Contract for handling authentication events
/// Project implements these to define token refresh & session expiry behavior
///
/// Generic Types:
/// - TRefreshRequest: Request data type sent to BE (can include refreshToken, deviceId, etc.)
/// - TRefreshResponse: Response data type from BE
///
/// Usage Example (Simple):
/// ```dart
/// // Project A: Simple refresh with only refreshToken
/// class SimpleAuthHandler implements AuthEventHandler<String, String> {
///   final Dio dio;
///   SimpleAuthHandler(this.dio);
///
///   @override
///   String buildRefreshTokenRequest(String refreshToken) => refreshToken;
///
///   @override
///   Future<String?> refreshTokenRequest(String request) async {
///     final response = await dio.post('/auth/refresh',
///       data: {'refresh_token': request}
///     );
///     return response.data['access_token'];
///   }
///
///   @override
///   String? extractAccessTokenFromResponse(String? response) => response;
///
///   @override
///   Future<void> onParsedNewToken(String newToken) async {
///     print('Token refreshed');
///   }
///
///   @override
///   Future<void> onSessionExpired() async {
///     await tokenStorage.clearTokens();
///     navigateToLogin();
///   }
/// }
/// ```
///
/// Usage Example (Complex):
/// ```dart
/// class RefreshRequest {
///   final String refreshToken;
///   final String deviceId;
///   RefreshRequest(this.refreshToken, this.deviceId);
///   Map<String, dynamic> toJson() => {...};
/// }
///
/// class RefreshResponse {
///   final String accessToken;
///   final String? newRefreshToken;
///   RefreshResponse.fromJson(Map json) : ...;
/// }
///
/// class ComplexAuthHandler implements AuthEventHandler<RefreshRequest, RefreshResponse> {
///   @override
///   RefreshRequest buildRefreshTokenRequest(String refreshToken) {
///     return RefreshRequest(refreshToken, deviceManager.id);
///   }
///
///   @override
///   Future<RefreshResponse?> refreshTokenRequest(RefreshRequest request) async {
///     final response = await dio.post('/auth/refresh', data: request.toJson());
///     return RefreshResponse.fromJson(response.data);
///   }
///
///   @override
///   String? extractAccessTokenFromResponse(RefreshResponse? response) {
///     if (response?.newRefreshToken != null) {
///       tokenStorage.saveRefreshToken(response!.newRefreshToken!);
///     }
///     return response?.accessToken;
///   }
/// }
/// ```
abstract class AuthEventHandler<TRefreshRequest, TRefreshResponse> {
  /// Build request object from refresh token
  /// Interceptor calls this to prepare data for refreshTokenRequest
  ///
  /// Project can:
  /// - Add additional data (deviceId, userId, appVersion, etc.)
  /// - Transform refreshToken into custom request object
  /// - For simple case: just return the refreshToken as-is
  TRefreshRequest buildRefreshTokenRequest(String refreshToken);

  /// Refresh access token using refresh token
  /// Called by AuthInterceptor when 401 detected
  ///
  /// Should:
  /// - Call BE refresh endpoint with request data
  /// - Return response on success
  /// - Return null or throw on failure (interceptor will handle)
  Future<TRefreshResponse?> refreshTokenRequest(TRefreshRequest request);

  /// Extract access token from refresh response
  /// Interceptor calls this to get the token and save it
  ///
  /// Project can:
  /// - Extract accessToken from response
  /// - Update newRefreshToken to storage if provided
  /// - Handle expiresIn or other metadata
  /// - Return the access token string to be saved
  String? extractAccessTokenFromResponse(TRefreshResponse? response);

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
