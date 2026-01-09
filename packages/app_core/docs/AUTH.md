# Auth Module Documentation

## 📌 Tổng Quan

**Auth Module** cung cấp contract (interface) cho xử lý các sự kiện xác thực:
- Refresh token khi 401
- Thông báo token được cập nhật
- Xử lý session expiry

Module này **không chứa implementation** - project cụ thể phải implement lại.

---

## 📂 Cấu Trúc

```
auth/
├── auth_handler.dart      # Abstract interface
└── index.dart            # Export
```

---

## 🏗️ AuthEventHandler Interface

```dart
abstract class AuthEventHandler {
  /// Gọi endpoint refresh token trên backend
  /// Called by: AuthInterceptor when 401
  Future<String?> refreshTokenRequest(String refreshToken);

  /// Sau khi token được refresh thành công
  /// Called by: AuthInterceptor
  Future<void> onParsedNewToken(String newToken);

  /// Session hết hạn - yêu cầu login lại
  /// Called by: AuthInterceptor (nếu refresh fail)
  Future<void> onSessionExpired();
}
```

---

## 📋 Chi Tiết Từng Method

### 1. `refreshTokenRequest(String refreshToken)`

**Mục đích**: Gọi backend để lấy access token mới

**Tham số**:
- `refreshToken` - Refresh token lưu trữ trong TokenStorage

**Return**:
- `Future<String?>` - Access token mới, hoặc `null` nếu fail

**Thời điểm gọi**: Khi AuthInterceptor nhận 401 response

**Ví dụ Implementation**:
```dart
@override
Future<String?> refreshTokenRequest(String refreshToken) async {
  try {
    final dio = GetIt.I<Dio>();
    final response = await dio.post(
      '/auth/refresh',
      data: {
        'refresh_token': refreshToken,
      },
      options: Options(
        // Không thêm interceptor vào refresh request
        extra: {'skipAuthInterceptor': true},
      ),
    );

    if (response.statusCode == 200) {
      return response.data['access_token'] as String;
    }
    return null;
  } catch (e) {
    print('Token refresh failed: $e');
    return null;
  }
}
```

---

### 2. `onParsedNewToken(String newToken)`

**Mục đích**: Thực thi sau khi token được refresh thành công

**Tham số**:
- `newToken` - Access token mới vừa lấy được

**Return**: `Future<void>`

**Thời điểm gọi**: Sau `refreshTokenRequest()` trả về success

**Dùng để**:
- ✅ Cập nhật UI (show toast "Token refreshed")
- ✅ Notify listeners
- ✅ Resume paused requests
- ✅ Analytics/logging

**Ví dụ Implementation**:
```dart
@override
Future<void> onParsedNewToken(String newToken) async {
  // Optionally: update UI
  final appState = GetIt.I<AppStateManager>();
  appState.setTokenRefreshed(true);
  
  // Resume paused requests
  resumePausedRequests();
  
  // Analytics
  AppLogger.info('Token refreshed successfully');
}
```

---

### 3. `onSessionExpired()`

**Mục đích**: Xử lý khi session hết hạn

**Return**: `Future<void>`

**Thời điểm gọi**: Khi token refresh thất bại (>2 lần hoặc refresh endpoint trả 401)

**Dùng để**:
- 🗑️ Clear local data (cache, tokens)
- 🔴 Logout user
- 🚪 Navigate đến login screen
- 🔔 Show notification

**Ví dụ Implementation**:
```dart
@override
Future<void> onSessionExpired() async {
  final tokenStorage = GetIt.I<TokenStorage>();
  final router = GetIt.I<Router>();

  // Clear all tokens
  await tokenStorage.clearTokens();

  // Clear local cache
  await clearAppCache();

  // Clear preferences
  await clearUserPreferences();

  // Navigate to login
  router.go('/login');

  // Show notification
  showSnackBar('Session expired. Please login again.');

  // Analytics
  AppLogger.warning('Session expired - logged out');
}
```

---

## 🔗 Mối Liên Kết Với Các Module Khác

```
AuthEventHandler [Auth Module]
    ↑
    └─── Sử dụng bởi:
         ├─ AuthInterceptor [HTTP]
         │  ├─ Gọi: refreshTokenRequest() khi 401
         │  ├─ Gọi: onParsedNewToken() khi success
         │  └─ Gọi: onSessionExpired() khi fail
         │
         ├─ setupAppCoreDI() [DI Module]
         │  └─ Đăng ký làm singleton GetIt
         │
         └─ Project-specific code
            ├─ Implement lại class này
            ├─ Sử dụng TokenStorage [Storage]
            ├─ Sử dụng HttpClient [HTTP]
            └─ Sử dụng GetIt<Router> để navigate
```

---

## 💡 Best Practices

### 1. Không Thêm Auth Interceptor Vào Refresh Request
```dart
// ❌ WRONG - Sẽ gây infinite loop
final response = await dio.post('/auth/refresh', data: {...});

// ✅ RIGHT - Skip interceptor
final response = await dio.post(
  '/auth/refresh',
  data: {...},
  options: Options(extra: {'skipAuthInterceptor': true}),
);
```

### 2. Timeout Configuration Cho Refresh
```dart
// Refresh request nên có timeout ngắn
final response = await dio.post(
  '/auth/refresh',
  data: {...},
  options: Options(
    receiveTimeout: Duration(seconds: 10),
    extra: {'skipAuthInterceptor': true},
  ),
);
```

### 3. Handle Network Errors
```dart
Future<String?> refreshTokenRequest(String refreshToken) async {
  try {
    // ...
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      // Network timeout - có thể retry
      return null;
    } else if (e.type == DioExceptionType.unknown) {
      // No internet
      return null;
    }
    return null;
  }
}
```

### 4. Prevent Multiple Concurrent Refreshes
```dart
// Use mutex/lock để prevent race condition
class MyAuthHandler implements AuthEventHandler {
  final _refreshLock = Mutex();

  Future<String?> refreshTokenRequest(String refreshToken) async {
    return _refreshLock.protect(() async {
      // Actual refresh logic
    });
  }
}
```

---

## 📊 Flow Diagram

```
Client gọi API
    ↓
AuthInterceptor nhận response
    ├─ 200-299? → Return success
    │
    └─ 401? → Start refresh flow
        ↓
        TokenStorage.getToken() [get refresh token]
        ↓
        authHandler.refreshTokenRequest(refreshToken)
        ├─ Thành công? → newToken
        │   ↓
        │   onParsedNewToken(newToken)
        │   ↓
        │   TokenStorage.save(newToken)
        │   ↓
        │   Retry original request
        │   ↓
        │   Return response
        │
        └─ Thất bại? → null
            ↓
            authHandler.onSessionExpired()
            ↓
            Throw AuthException
```

---

## ⚠️ Common Issues & Solutions

| Issue | Nguyên nhân | Giải pháp |
|-------|-----------|---------|
| Infinite loop refresh | Refresh request cũng thêm AuthInterceptor | Sử dụng `extra: {'skipAuthInterceptor': true}` |
| Token không được lưu | Quên call `tokenStorage.save()` | Gọi trong `onParsedNewToken()` hoặc AuthInterceptor |
| User không logout | `onSessionExpired()` không navigate | Đảm bảo router được register và call `router.go()` |
| Race condition | Nhiều request cùng gọi refresh | Sử dụng mutex/lock |

---

## 🧪 Testing

```dart
test('refreshTokenRequest returns new token on success', () async {
  final handler = MyAuthHandler();
  final newToken = await handler.refreshTokenRequest('old_refresh');
  expect(newToken, isNotNull);
});

test('onSessionExpired clears storage and navigates', () async {
  final handler = MyAuthHandler();
  await handler.onSessionExpired();
  
  final token = await tokenStorage.getToken();
  expect(token, isNull);
  expect(navigator.currentRoute, '/login');
});
```

---

**See Also**: 
- [HTTP Module](./HTTP.md) - AuthInterceptor chi tiết
- [Storage Module](./STORAGE.md) - TokenStorage chi tiết
- [DI Setup](./DI.md) - Cách đăng ký
