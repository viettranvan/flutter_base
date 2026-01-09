# Storage Module Documentation

## 📌 Tổng Quan

**Storage Module** cung cấp giải pháp lưu trữ persistent cho:
- 🔐 Access tokens (SecureStorage)
- 🔄 Refresh tokens (SecureStorage)
- 📋 App preferences (SharedPreferences)
- 🎯 General data (AppStorage interface)

---

## 📂 Cấu Trúc

```
storage/
├── token_storage.dart            # Interface cho token
├── token_storage_impl.dart       # Implementation (DefaultTokenStorage)
├── app_storage.dart              # Interface cho general storage
├── app_shared_preferences.dart   # SharedPreferences implementation
└── index.dart
```

---

## 🏗️ Core Interfaces

### 1. TokenStorage Interface

```dart
abstract class TokenStorage {
  /// Lấy access token từ memory cache (sync)
  /// Dùng trong Dio interceptor (synchronous context)
  String? getToken();

  /// Lưu access token vào SecureStorage (async)
  /// Gọi bởi AuthInterceptor sau token refresh
  Future<void> saveToken(String token);

  /// Lấy refresh token từ memory cache (sync)
  String? getRefreshToken();

  /// Lưu refresh token vào SecureStorage (async)
  Future<void> saveRefreshToken(String token);

  /// Xóa tất cả tokens (access + refresh)
  Future<void> clearTokens();

  /// Kiểm tra token có hợp lệ không
  bool hasValidToken();

  /// Khởi tạo - load tokens từ disk vào memory
  Future<void> initialize();
}
```

**Tại sao sync `get()` nhưng async `save()`?**
```
Dio interceptor là synchronous context
↓
Không thể call async getToken()
↓
Solution: Sync get từ memory cache + Async save để persistent
↓
Memory cache được load từ SecureStorage trong initialize()
```

---

### 2. AppStorage Interface

```dart
abstract class AppStorage {
  /// Lưu value với key
  Future<void> setString(String key, String value);
  Future<void> setInt(String key, int value);
  Future<void> setBool(String key, bool value);

  /// Lấy value từ key
  String? getString(String key);
  int? getInt(String key);
  bool? getBool(String key);

  /// Xóa key
  Future<void> remove(String key);

  /// Xóa tất cả
  Future<void> clear();

  /// Kiểm tra key tồn tại
  bool containsKey(String key);
}
```

---

## 💾 Implementation Details

### DefaultTokenStorage

**Khởi tạo**:
```dart
final tokenStorage = DefaultTokenStorage(
  appStorage: AppSharedPreferences(),
);
await tokenStorage.initialize();
```

**Memory Cache vs Persistent Storage**:
```
┌────────────────────────────────────────────┐
│         DefaultTokenStorage                │
├────────────────────────────────────────────┤
│  Memory Cache (RAM - Fast)                 │
│  ├─ _accessToken: String?                  │
│  ├─ _refreshToken: String?                 │
│  └─ get() trả về từ đây (synchronous)     │
│                                            │
│  Persistent Storage (Disk - Secure)        │
│  ├─ SecureStorage:                         │
│  │  ├─ access_token                        │
│  │  └─ refresh_token                       │
│  └─ save() lưu vào đây (asynchronous)     │
└────────────────────────────────────────────┘
```

**Luồng làm việc**:
```dart
// 1. Initialization
await tokenStorage.initialize();
// → Load tokens từ SecureStorage vào memory cache

// 2. Sử dụng (Synchronous)
String? token = tokenStorage.getToken();
// → Lấy từ memory cache ngay lập tức (không await)

// 3. Cập nhật (Asynchronous)
await tokenStorage.saveToken(newToken);
// → 1. Cập nhật memory cache
// → 2. Lưu vào SecureStorage

// 4. Xóa
await tokenStorage.clearTokens();
// → 1. Clear memory cache
// → 2. Xóa từ SecureStorage
```

---

### AppSharedPreferencesImpl

Lưu trữ preferences sử dụng SharedPreferences:

```dart
final appStorage = AppSharedPreferences();

// Set values
await appStorage.setString('user_name', 'John');
await appStorage.setInt('theme_mode', 1);
await appStorage.setBool('is_logged_in', true);

// Get values
String? name = appStorage.getString('user_name');
int? theme = appStorage.getInt('theme_mode');
bool? isLoggedIn = appStorage.getBool('is_logged_in');

// Remove
await appStorage.remove('user_name');

// Clear all
await appStorage.clear();

// Check exists
bool exists = appStorage.containsKey('user_name');
```

---

## 🔗 Mối Liên Kết Với Các Module Khác

```
Storage Module
├── TokenStorage
│   ├─ Sử dụng bởi:
│   │  ├─ AuthInterceptor [HTTP]
│   │  │  ├─ getToken() để thêm vào request header
│   │  │  └─ saveToken() sau refresh
│   │  │
│   │  ├─ AuthEventHandler [Auth]
│   │  │  └─ clearTokens() trong onSessionExpired()
│   │  │
│   │  └─ setupAppCoreDI() [DI]
│   │     └─ Đăng ký làm singleton GetIt
│   │
│   └─ Sử dụng:
│      └─ AppStorage [Storage] để persistent
│
├── AppStorage
│   ├─ Sử dụng bởi:
│   │  ├─ TokenStorage [Storage]
│   │  │  └─ Lưu/load tokens
│   │  │
│   │  ├─ Project-specific code
│   │  │  ├─ Cache user preferences
│   │  │  ├─ Store app settings
│   │  │  └─ Save analytics data
│   │  │
│   │  └─ Helpers [Helpers]
│   │     └─ Caching utilities
│   │
│   └─ Sử dụng:
│      └─ SharedPreferences [3rd party]
│
└─ Khởi tạo:
   └─ main() trước setupAppCoreDI()
```

---

## 📋 Complete Usage Example

```dart
import 'package:app_core/app_core.dart';

void main() async {
  // 1. Tạo storage instances
  final appStorage = AppSharedPreferences();
  final tokenStorage = DefaultTokenStorage(
    appStorage: appStorage,
  );

  // 2. Khởi tạo storage (load từ disk)
  await tokenStorage.initialize();

  // 3. Setup DI (đăng ký storage)
  setupAppCoreDI(
    baseUrl: 'https://api.example.com',
    tokenStorage: tokenStorage,
    authHandler: MyAuthHandler(),
    addLoggingInterceptor: true,
  );

  // 4. Khởi tạo app
  runApp(MyApp());
}

// Trong BLoC/ViewModel
class MyBloc extends Bloc<MyEvent, MyState> {
  final tokenStorage = GetIt.I<TokenStorage>();
  final appStorage = GetIt.I<AppStorage>();

  Future<void> logout() async {
    // Clear all tokens
    await tokenStorage.clearTokens();

    // Clear preferences
    await appStorage.remove('user_theme');
    await appStorage.remove('user_language');

    // Navigate to login
    context.go('/login');
  }

  Future<void> saveUserPreference(String key, String value) async {
    await appStorage.setString(key, value);
  }
}
```

---

## 🔐 Security Considerations

### Token Storage Location

| Storage | Secure? | Speed | Use Case |
|---------|---------|-------|----------|
| Memory | ❌ (Lost on app restart) | ⚡ Fast | Cache |
| SharedPreferences | ❌ (Plain text) | ✅ Fast | Non-sensitive data |
| SecureStorage | ✅ (Encrypted) | 📊 Slower | Tokens, passwords |

### DefaultTokenStorage Strategy

```
┌─────────────────────────────────────────────┐
│  Security Best Practice                     │
├─────────────────────────────────────────────┤
│                                             │
│  1. Sensitive data (tokens)                 │
│     └─ Lưu ở: SecureStorage (encrypted)   │
│                                             │
│  2. Non-sensitive data (user preferences)   │
│     └─ Lưu ở: SharedPreferences (plain)    │
│                                             │
│  3. Temporary runtime cache                 │
│     └─ Lưu ở: Memory (RAM, not persisted)  │
│                                             │
│  4. Old/invalid tokens                      │
│     └─ Action: Xóa ngay khi detect 401     │
│                                             │
└─────────────────────────────────────────────┘
```

### Best Practices

```dart
// ✅ GOOD: Tokens in SecureStorage
await tokenStorage.saveToken(accessToken);  // Auto saves to SecureStorage

// ✅ GOOD: Preferences in SharedPreferences
await appStorage.setString('user_theme', 'dark');

// ❌ BAD: Tokens in SharedPreferences
await appStorage.setString('access_token', accessToken);  // Plain text!

// ✅ GOOD: Clear on logout
await tokenStorage.clearTokens();
await appStorage.clear();

// ❌ BAD: Keep old tokens
// Không giữ old tokens - ngay lập tức xóa
```

---

## 🧪 Testing

```dart
test('TokenStorage saves and retrieves token', () async {
  final storage = DefaultTokenStorage(
    appStorage: MockAppStorage(),
  );
  await storage.initialize();

  await storage.saveToken('new_token');
  expect(storage.getToken(), 'new_token');
});

test('TokenStorage clears all data', () async {
  final storage = DefaultTokenStorage(
    appStorage: MockAppStorage(),
  );
  await storage.saveToken('token');
  await storage.saveRefreshToken('refresh');

  await storage.clearTokens();

  expect(storage.getToken(), isNull);
  expect(storage.getRefreshToken(), isNull);
});

test('AppStorage persists string values', () async {
  final storage = AppSharedPreferences();

  await storage.setString('key', 'value');
  expect(storage.getString('key'), 'value');

  await storage.remove('key');
  expect(storage.getString('key'), isNull);
});
```

---

## ⚠️ Common Issues & Solutions

| Issue | Nguyên nhân | Giải pháp |
|-------|-----------|---------|
| Token null trong interceptor | Quên call `initialize()` | Gọi `await tokenStorage.initialize()` trước setupDI |
| Token không persisted | Lưu vào memory cache chỉ | Phải call `saveToken()` (không chỉ set memory) |
| SecureStorage permission denied | Android/iOS không grant permission | Check AndroidManifest.xml, Info.plist |
| Token không bao giờ update | Lưu vào AppStorage thay vì TokenStorage | Dùng `tokenStorage.saveToken()` |

---

**See Also**:
- [Auth Module](./AUTH.md) - AuthEventHandler uses TokenStorage
- [HTTP Module](./HTTP.md) - AuthInterceptor uses TokenStorage
- [DI Setup](./DI.md) - TokenStorage registration
