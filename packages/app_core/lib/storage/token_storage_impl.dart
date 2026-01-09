import 'app_storage.dart';
import 'token_storage.dart';

/// Default TokenStorage implementation using AppStorage (SecureStorage) with in-memory cache
///
/// Architecture:
/// - Tokens are persisted in SecureStorage (encrypted, persistent)
/// - Tokens are cached in memory (fast sync access)
/// - get* methods return cached values (synchronous)
/// - save* methods persist to storage AND update cache (asynchronous)
/// - initialize() loads tokens from storage to cache on startup
///
/// Usage Example:
/// ```dart
/// // 1. Create instance (usually in DI setup)
/// final tokenStorage = DefaultTokenStorage(AppStorage());
///
/// // 2. Initialize on app startup - load tokens from storage
/// await tokenStorage.initialize();
///
/// // 3. Use in AuthInterceptor - sync access, no await needed
/// void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
///   final accessToken = tokenStorage.getAccessToken();  // Sync!
///   if (accessToken != null) {
///     options.headers['Authorization'] = 'Bearer $accessToken';
///   }
///   super.onRequest(options, handler);
/// }
///
/// // 4. After token refresh - save new token (async)
/// final newToken = parseTokenFromResponse(response);
/// await tokenStorage.saveAccessToken(newToken);  // Persists + updates cache
///
/// // 5. On logout - clear tokens (async)
/// await tokenStorage.clearTokens();  // Removes from storage + clears cache
/// ```

class DefaultTokenStorage implements TokenStorage {
  final IAppStorage _storage;

  // In-memory cache for fast synchronous access
  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  DefaultTokenStorage(this._storage);

  @override
  String? getAccessToken() {
    return _cachedAccessToken;
  }

  @override
  String? getRefreshToken() {
    return _cachedRefreshToken;
  }

  @override
  Future<void> saveAccessToken(String token) async {
    // Persist to secure storage
    await _storage.setValue(AppStorageKey.accessToken, token);
    // Update in-memory cache
    _cachedAccessToken = token;
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    // Persist to secure storage
    await _storage.setValue(AppStorageKey.refreshToken, token);
    // Update in-memory cache
    _cachedRefreshToken = token;
  }

  @override
  Future<void> clearTokens() async {
    // Remove from secure storage
    await _storage.deleteValue(AppStorageKey.accessToken);
    await _storage.deleteValue(AppStorageKey.refreshToken);
    // Clear in-memory cache
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
  }

  @override
  Future<void> initialize() async {
    // Load tokens from secure storage into in-memory cache
    _cachedAccessToken = await _storage.getValue(AppStorageKey.accessToken);
    _cachedRefreshToken = await _storage.getValue(AppStorageKey.refreshToken);
  }
}
