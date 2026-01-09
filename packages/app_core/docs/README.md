# App Core Package Documentation

## 📋 Overview

**App Core** là một package Flutter cơ sở cung cấp kiến trúc tiêu chuẩn, công cụ, và tiện ích cho các dự án Flutter. Nó được thiết kế để có thể tái sử dụng, mở rộng, và dễ dàng tích hợp vào các dự án mới.

### Mục tiêu chính
- ✅ Cung cấp HTTP client chuẩn với Dio
- ✅ Xử lý lỗi nhất quán và toàn diện
- ✅ Quản lý xác thực (authentication) và token
- ✅ Cấu hình Dependency Injection (DI) sẵn sàng
- ✅ Tiện ích (helpers) và extensions tiện dụng
- ✅ Hệ thống logging và debug tools

---

## 🏗️ Cấu trúc Package

```
lib/
├── auth/                          # Xác thực & Xử lý sự kiện
│   ├── auth_handler.dart         # Contract cho auth events
│   └── index.dart
├── storage/                       # Lưu trữ persistent (tokens, preferences)
│   ├── token_storage.dart        # Interface cho lưu token
│   ├── token_storage_impl.dart   # Implementation
│   ├── app_storage.dart          # Interface lưu trữ chung
│   ├── app_shared_preferences.dart # SharedPreferences implementation
│   └── index.dart
├── http/                          # HTTP client & interceptors
│   ├── http_client.dart          # Abstract HTTP interface
│   ├── dio_http_client.dart      # Dio implementation
│   ├── dio_client_builder.dart   # Builder pattern
│   ├── interceptors/
│   │   ├── auth_interceptor.dart # Xử lý 401, refresh token
│   │   ├── logging_interceptor.dart # Request/response logging
│   │   └── index.dart
│   ├── models/
│   │   ├── api_response.dart     # Response wrapper
│   │   └── index.dart
│   └── index.dart
├── errors/                        # Xử lý lỗi & Mapping
│   ├── app_exception.dart        # Exception hierarchy (7 types)
│   ├── error_mapper.dart         # DioException → AppException
│   └── index.dart
├── constants/                     # HTTP & App constants
│   ├── app_constants.dart        # Timeouts, status codes, configs
│   └── index.dart
├── helpers/                       # Utilities & Extensions
│   ├── app_logger.dart           # Logging utility
│   ├── debouncer.dart            # Debounce utility
│   ├── extensions/
│   │   ├── string_extensions.dart    # String utils (13+ methods)
│   │   ├── context_extensions.dart   # BuildContext helpers (20+ methods)
│   │   ├── dio_options_extensions.dart # Dio utils
│   │   └── index.dart
│   └── index.dart
├── di/                            # Dependency Injection
│   ├── app_core_di.dart          # GetIt setup & registration
│   └── index.dart
├── design/                        # Design system (colors, typography, etc)
├── widgets/                       # Reusable UI widgets
├── constants/                     # App-level constants
└── app_core.dart                 # Main export file
```

---

## 🔄 Mối Liên Kết Giữa Các Module

### 1️⃣ **Core Flow: Khởi tạo → Gọi API → Xử lý Response**

```
main()
  ↓
setupAppCoreDI()  [DI Module]
  ├─ Đăng ký TokenStorage [Storage Module]
  ├─ Đăng ký AuthEventHandler [Auth Module]
  ├─ Tạo Dio instance với DioClientBuilder [HTTP Module]
  ├─ Thêm AuthInterceptor [HTTP Module → Auth + Storage]
  ├─ Thêm LoggingInterceptor [HTTP Module]
  ├─ Đăng ký HttpClient [HTTP Module]
  └─ Đăng ký Dio
  ↓
API Call: httpClient.get('/users')  [HTTP Module]
  ↓
Response/Error
  ├─ Success (2xx) → ApiResponse [HTTP Models]
  ├─ 401 (Unauthorized) → AuthInterceptor [HTTP]
  │                    → refreshTokenRequest() [Auth Handler]
  │                    → TokenStorage.save() [Storage]
  │                    → onParsedNewToken() [Auth Handler]
  │                    → Retry request
  ├─ 4xx/5xx → DioException
  │          → error_mapper.mapDioException() [Errors Module]
  │          → AppException [Errors Module]
  └─ Network Error → DioException → AppException
  ↓
Caller gets AppException [Errors Module]
  → Handle by type (NetworkException, AuthException, etc)
```

### 2️⃣ **Dependency Graph**

```
DI (app_core_di.dart)
├── Requires: TokenStorage + AuthEventHandler + baseUrl
├── Creates: Dio instance
│   ├── Uses: DioClientBuilder [HTTP]
│   ├── Adds: AuthInterceptor [HTTP]
│   │   └── Uses: TokenStorage [Storage] + AuthEventHandler [Auth]
│   ├── Adds: LoggingInterceptor [HTTP]
│   └── Wraps in: DioHttpClient [HTTP]
├── Registers: HttpClient, TokenStorage, AuthEventHandler, Dio
└── Ready for: GetIt.I<HttpClient>() access

HTTP Client (DioHttpClient)
├── Wraps: Dio instance
├── Methods: get, post, put, patch, delete
└── Returns: Response (raw) → Caller adapts to domain model

Interceptors
├── AuthInterceptor
│   ├── Listens to: 401 responses
│   ├── Uses: TokenStorage.getToken() [Storage]
│   ├── Calls: AuthEventHandler.refreshTokenRequest() [Auth]
│   ├── Saves: AuthEventHandler.onParsedNewToken() [Auth]
│   └── Retries: Original request
├── LoggingInterceptor
│   └── Logs: All requests/responses/errors
└── DioException Handling
    └── Caught in: Interceptor onError
        → Passed to: Caller

Error Handling
├── DioException caught by: Interceptor or caller
├── Mapped to: AppException by error_mapper
├── Types: NetworkException, AuthException, ServerException, etc
└── Caller: Handles by type, shows UI feedback

Storage (TokenStorage)
├── Sync get(): Retrieves token from memory
├── Async save(): Persists to SecureStorage
├── Used by: AuthInterceptor + AuthHandler
└── Lifecycle: Initialized in main() before setupAppCoreDI()

Auth (AuthEventHandler)
├── Implemented by: Project-specific code
├── Methods: refreshTokenRequest, onParsedNewToken, onSessionExpired
├── Called by: AuthInterceptor
└── Registered in: setupAppCoreDI()
```

### 3️⃣ **Data Flow Chi Tiết**

```
┌─────────────────────────────────────────────────────────┐
│              API CALL REQUEST (GET /users)              │
└─────────────────────────────────────────────────────────┘
                         ↓
            ┌────────────────────────┐
            │  HttpClient.get()      │  [HTTP Module]
            │  (DioHttpClient)       │
            └────────────────────────┘
                         ↓
            ┌────────────────────────┐
            │  Dio.get()             │  [Dio Library]
            │  + Interceptors        │
            └────────────────────────┘
                         ↓
        ┌────────────────────────────────┐
        │  onRequest(RequestOptions)     │  [Chain of Interceptors]
        │  ├─ LoggingInterceptor         │  Logs request
        │  └─ AuthInterceptor            │  Adds Bearer token from
        │     (adds Authorization)       │  TokenStorage.getToken()
        └────────────────────────────────┘
                         ↓
            ┌────────────────────────┐
            │  Send HTTP Request     │
            │  to Server             │
            └────────────────────────┘
                         ↓
     ┌──────────────────────────────────────┐
     │          Response Received           │
     └──────────────────────────────────────┘
            ↓                            ↓
      ┌──────────────┐         ┌──────────────────┐
      │  200 OK      │         │  401 Unauthorized│
      │  (Success)   │         │  (Auth Failed)   │
      └──────────────┘         └──────────────────┘
            ↓                            ↓
    ┌──────────────────┐      ┌─────────────────────────┐
    │ onResponse()     │      │ onError()               │
    │ LoggingInt.      │      │ AuthInterceptor:        │
    │ ✓ Return 200     │      │ 1. Check if 401         │
    └──────────────────┘      │ 2. Get refreshToken from│
            ↓                 │    TokenStorage         │
      ┌──────────────┐        │ 3. Call:                │
      │ Response     │        │    authHandler.         │
      │ → Caller     │        │    refreshTokenRequest()│
      │ (Raw Dio)    │        │ 4. Save new token:      │
      └──────────────┘        │    await tokenStorage   │
                              │    .save()              │
                              │ 5. Call:                │
                              │    authHandler.         │
                              │    onParsedNewToken()   │
                              │ 6. Retry original req   │
                              │    with new token       │
                              └─────────────────────────┘
                                        ↓
                              ┌──────────────────┐
                              │ Retry succeeds?  │
                              └──────────────────┘
                              ↓                 ↓
                          ┌─────┐          ┌──────────┐
                          │ Yes │          │ No (>2x) │
                          └─────┘          └──────────┘
                            ↓                   ↓
                    ┌──────────────┐   ┌─────────────────┐
                    │ Return 200   │   │ authHandler.    │
                    │ Success flow │   │ onSessionExpired│
                    └──────────────┘   │ (Clear, Logout) │
                                       └─────────────────┘
            ↓                                   ↓
      ┌──────────────┐                 ┌──────────────┐
      │   Caller     │                 │   Caller     │
      │ receives     │                 │  receives    │
      │ Response     │                 │  AuthException│
      │ (Success)    │                 │  (Session    │
      │              │                 │   Expired)   │
      └──────────────┘                 └──────────────┘
            ↓                                   ↓
    ┌─────────────────────────────────────────────┐
    │ Project Adapter Layer                       │
    │ ├─ Parse response.data                      │
    │ ├─ Map to domain models                     │
    │ └─ Return success or error to BLoC/ViewModel
    └─────────────────────────────────────────────┘
```

---

## 📚 Tài Liệu Chi Tiết Từng Module

Xem tài liệu chi tiết:

- **[Auth Module](./AUTH.md)** - AuthEventHandler, authentication events
- **[Storage Module](./STORAGE.md)** - TokenStorage, token persistence
- **[HTTP Module](./HTTP.md)** - HttpClient, DioHttpClient, DioClientBuilder
- **[Interceptors](./INTERCEPTORS.md)** - AuthInterceptor, LoggingInterceptor
- **[Errors Module](./ERRORS.md)** - AppException, error mapping
- **[Constants Module](./CONSTANTS.md)** - HTTP & app configuration
- **[Helpers & Extensions](./HELPERS.md)** - String, Context, Dio utilities
- **[DI Setup](./DI.md)** - setupAppCoreDI, GetIt registration
- **[Integration Guide](./INTEGRATION.md)** - Cách tích hợp vào project mới

---

## 🚀 Quick Start

### 1. Khởi tạo Storage
```dart
final tokenStorage = DefaultTokenStorage(
  appStorage: AppSharedPreferences(),
);
await tokenStorage.initialize();
```

### 2. Thực hiện DI Setup
```dart
void main() async {
  setupAppCoreDI(
    baseUrl: 'https://api.example.com',
    tokenStorage: tokenStorage,
    authHandler: MyAuthHandler(),
    addLoggingInterceptor: true,
  );
  runApp(MyApp());
}
```

### 3. Sử dụng HttpClient
```dart
final httpClient = GetIt.I<HttpClient>();
try {
  final response = await httpClient.get('/users');
  // Xử lý thành công
} on AppException catch (e) {
  if (e is AuthException) {
    // Xử lý auth error
  } else if (e is NetworkException) {
    // Xử lý network error
  }
}
```

---

## ✨ Tính năng Chính

### 🔐 Authentication
- Tự động refresh token khi 401
- Hỗ trợ pauseble request queue
- Session expiry handling

### 🛡️ Error Handling
- 7 loại exception cụ thể
- Automatic DioException → AppException mapping
- Field-level validation error extraction

### 📝 Logging & Debug
- Request/response logging
- Error logging
- Customizable log levels

### ⚙️ Configuration
- Timeout configuration
- Retry configuration
- Custom interceptors support

### 🎯 Dependency Injection
- GetIt integration
- Singleton pattern
- Easy service access

### 🔧 Utilities
- 13+ string extensions
- 20+ context extensions
- Dio options utilities
- Debouncer utility

---

## 📦 Dependencies

- **dio**: ^5.8.0 - HTTP client
- **get_it**: ^7.0.0 - Service locator
- **flutter_secure_storage**: ^9.2.4 - Secure token storage
- **shared_preferences**: ^2.5.3 - Local preferences
- **logger**: ^2.0.0 - Logging

---

## 🎓 Tài liệu Liên Quan

- [ARCHITECTURE.md](./ARCHITECTURE.md) - Kiến trúc chi tiết
- [EXAMPLES.md](./EXAMPLES.md) - Ví dụ sử dụng
- [TESTING.md](./TESTING.md) - Hướng dẫn testing
- [API.md](./API.md) - API reference

---

## 📝 Ghi Chú

- Tất cả modules được thiết kế độc lập, dễ mở rộng
- Project cụ thể triển khai `AuthEventHandler` để phù hợp backend
- Error handling toàn bộ chuyển qua `AppException` hierarchy
- Token refresh tự động, không cần intervention từ caller

---

**Last Updated**: January 2026  
**Version**: 1.0.0
