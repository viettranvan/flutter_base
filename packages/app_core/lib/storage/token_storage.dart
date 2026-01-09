/// Abstract interface for token storage
/// Implementations use SecureStorage with in-memory cache for sync access.
/// Tokens are cached in memory after being loaded/saved from persistent storage.
abstract class TokenStorage {
  /// Get access token from in-memory cache (synchronous)
  /// Fast, non-blocking - returns cached token
  String? getAccessToken();

  /// Get refresh token from in-memory cache (synchronous)
  /// Fast, non-blocking - returns cached token
  String? getRefreshToken();

  /// Save access token to persistent storage + update cache (asynchronous)
  /// Persists to SecureStorage and updates in-memory cache
  Future<void> saveAccessToken(String token);

  /// Save refresh token to persistent storage + update cache (asynchronous)
  /// Persists to SecureStorage and updates in-memory cache
  Future<void> saveRefreshToken(String token);

  /// Clear all tokens from persistent storage + cache (asynchronous)
  /// Removes from SecureStorage and clears in-memory cache
  Future<void> clearTokens();

  /// Initialize token storage by loading tokens from persistent storage
  /// Must be called before using getAccessToken/getRefreshToken
  /// Loads tokens from storage into in-memory cache
  Future<void> initialize();
}
