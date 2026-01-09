# HTTP Module Documentation

## 📌 Tổng Quan

**HTTP Module** cung cấp HTTP client standardized dựa trên Dio:
- 🌐 Abstract HttpClient interface
- 🚀 DioHttpClient implementation
- 🛠️ DioClientBuilder pattern
- 🚪 Interceptors (auth, logging)
- 📦 API response models

---

## 📂 Cấu Trúc

```
http/
├── http_client.dart              # Abstract interface
├── dio_http_client.dart          # Dio implementation
├── dio_client_builder.dart       # Builder pattern
├── interceptors/
│   ├── auth_interceptor.dart     # Token refresh & 401 handling
│   ├── logging_interceptor.dart  # Request/response logging
│   └── index.dart
├── models/
│   ├── api_response.dart         # Response wrapper
│   └── index.dart
└── index.dart
```

---

## 🏗️ HttpClient Interface

```dart
abstract class HttpClient {
  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onReceiveProgress,
  });

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// DELETE request
  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
  });
}
```

---

## 🏭 DioClientBuilder (Builder Pattern)

Tạo và cấu hình Dio instance:

```dart
final dio = DioClientBuilder()
  .setBaseUrl('https://api.example.com')
  .setConnectTimeout(Duration(seconds: 30))
  .setReceiveTimeout(Duration(seconds: 30))
  .setHeaders({'Custom-Header': 'value'})
  .build();
```

**Chi tiết**:
- `setBaseUrl(String)` - API endpoint base
- `setConnectTimeout(Duration)` - Connection timeout
- `setReceiveTimeout(Duration)` - Response timeout
- `setHeaders(Map)` - Default headers
- `build()` - Return Dio instance

---

## 🚀 DioHttpClient (Implementation)

Wrap Dio instance:

```dart
final httpClient = DioHttpClient(dioInstance: dio);

// Usage
try {
  final response = await httpClient.get('/users');
  print('Status: ${response.statusCode}');
  print('Data: ${response.data}');
} on DioException catch (e) {
  // Handle error
}
```

---

## 🚪 Interceptors

### AuthInterceptor

**Mục đích**: 
- ✅ Tự động thêm Bearer token vào request
- ✅ Xử lý 401 response (token expired)
- ✅ Gọi token refresh
- ✅ Retry request với token mới

**Flow**:
```
Request
  ↓
onRequest()
├─ Get token từ TokenStorage
└─ Thêm vào header: Authorization: Bearer {token}
  ↓
Response
  ├─ 200-399? → Return success
  └─ 401? → onError()
      ├─ Get refreshToken từ TokenStorage
      ├─ Call authHandler.refreshTokenRequest(refreshToken)
      ├─ Save new token: tokenStorage.saveToken(newToken)
      ├─ Call authHandler.onParsedNewToken(newToken)
      ├─ Retry original request dengan new token
      └─ Return retry response
```

**Implementation**:
```dart
// In setupAppCoreDI()
dio.interceptors.add(
  AuthInterceptor(
    tokenStorage: tokenStorage,
    authHandler: authHandler,
  ),
);
```

---

### LoggingInterceptor

**Mục đích**: Log all requests, responses, errors

**Features**:
```dart
LoggingInterceptor(
  requestBody: true,    // Log request body
  responseBody: true,   // Log response body
  compact: true,        // Compact format
)
```

**Output**:
```
→ REQUEST: GET /users
  Body: null
← RESPONSE: 200 /users
  Body: [{"id": 1, "name": "John"}]
✗ ERROR: GET /products
  Message: 401 Unauthorized
  Status: 401
  Body: {"error": "Token expired"}
```

---

## 📦 ApiResponse Model

Wrapper cho HTTP response:

```dart
class ApiResponse {
  final int statusCode;
  final dynamic data;
  final Map<String, dynamic>? headers;
  final dynamic rawError;  // Untuk adapter parsing
}

// Usage
final response = await httpClient.get('/users');
if (response.statusCode == 200) {
  final users = response.data;  // Parsed by adapter
}
```

---

## 🔗 Mối Liên Kết Với Các Module Khác

```
HTTP Module
├── HttpClient [Interface]
│   ├─ Implemented by: DioHttpClient
│   ├─ Sử dụng bởi:
│   │  ├─ Project Adapter layer
│   │  │  └─ Parse response.data & map to domain
│   │  │
│   │  ├─ setupAppCoreDI() [DI]
│   │  │  └─ Đăng ký làm HttpClient singleton
│   │  │
│   │  └─ Project BLoC/ViewModel
│   │     └─ Call methods (get, post, etc)
│   │
│   └─ Sử dụng:
│      └─ Dio [3rd party library]
│
├── DioClientBuilder [Builder]
│   ├─ Sử dụng bởi: setupAppCoreDI()
│   ├─ Tạo: Dio instance
│   └─ Cấu hình: Base URL, timeouts, headers
│
├── Interceptors
│   ├─ AuthInterceptor
│   │  ├─ Sử dụng: TokenStorage [Storage]
│   │  ├─ Sử dụng: AuthEventHandler [Auth]
│   │  ├─ Called on: 401 response
│   │  └─ Retry: Original request
│   │
│   └─ LoggingInterceptor
│      ├─ Logs: All requests/responses/errors
│      └─ Config: In setupAppCoreDI()
│
├── ApiResponse [Model]
│   ├─ Returned by: HttpClient methods
│   ├─ Contains: statusCode, data, headers, rawError
│   └─ Parsed by: Project adapter layer
│
├── ErrorMapping [Errors]
│   ├─ DioException → AppException
│   ├─ Caught by: Interceptor or caller
│   └─ Thrown to: Project BLoC/ViewModel
│
└─ Setup:
   └─ setupAppCoreDI() [DI]
      ├─ Creates: Dio via DioClientBuilder
      ├─ Adds: AuthInterceptor + LoggingInterceptor
      ├─ Wraps: DioHttpClient
      └─ Registers: GetIt<HttpClient>
```

---

## 💻 Complete Usage Example

```dart
// 1. Setup in main()
void main() async {
  setupAppCoreDI(
    baseUrl: 'https://api.example.com',
    tokenStorage: tokenStorage,
    authHandler: myAuthHandler,
    addLoggingInterceptor: true,
  );
  runApp(MyApp());
}

// 2. Create project adapter
class UserAdapter {
  final httpClient = GetIt.I<HttpClient>();

  Future<List<User>> getUsers() async {
    try {
      final response = await httpClient.get('/users');
      
      if (response.statusCode == 200) {
        // Parse and map
        final list = response.data as List;
        return list.map((json) => User.fromJson(json)).toList();
      }
      throw Exception('Failed to load users');
    } on AppException catch (e) {
      rethrow;  // Throw to BLoC
    }
  }

  Future<User> createUser(UserRequest request) async {
    try {
      final response = await httpClient.post(
        '/users',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return User.fromJson(response.data);
      }
      throw Exception('Failed to create user');
    } on AppException catch (e) {
      rethrow;
    }
  }

  Future<User> updateUser(String id, UserRequest request) async {
    try {
      final response = await httpClient.put(
        '/users/$id',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw Exception('Failed to update user');
    } on AppException catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      final response = await httpClient.delete('/users/$id');

      if (response.statusCode != 204) {
        throw Exception('Failed to delete user');
      }
    } on AppException catch (e) {
      rethrow;
    }
  }
}

// 3. Use in BLoC
class UserBloc extends Bloc<UserEvent, UserState> {
  final userAdapter = UserAdapter();

  UserBloc() : super(UserInitial()) {
    on<GetUsersEvent>((event, emit) async {
      try {
        emit(UserLoading());
        final users = await userAdapter.getUsers();
        emit(UserLoaded(users));
      } on AuthException catch (_) {
        emit(UserError('Session expired'));
      } on NetworkException catch (_) {
        emit(UserError('No internet connection'));
      } on AppException catch (e) {
        emit(UserError(e.message));
      }
    });
  }
}
```

---

## 🔐 Security Best Practices

### 1. Token in Authorization Header
```dart
// AuthInterceptor automatically adds:
headers['Authorization'] = 'Bearer $token';
```

### 2. Skip Interceptor for Refresh Endpoint
```dart
// In AuthEventHandler.refreshTokenRequest()
await dio.post(
  '/auth/refresh',
  options: Options(extra: {'skipAuthInterceptor': true}),
);
```

### 3. Timeout Configuration
```dart
DioClientBuilder()
  .setConnectTimeout(Duration(seconds: 30))
  .setReceiveTimeout(Duration(seconds: 30))
  .build();
```

### 4. HTTPS Only
```dart
// Android: Network Security Config
// iOS: App Transport Security

// Validate SSL certificates
dio.options.certificates = {'api.example.com': certificate};
```

---

## ⚙️ Advanced Configuration

### Custom Interceptors
```dart
class CustomInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Modify request
    options.headers['X-Custom'] = 'value';
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Modify response
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle error
    super.onError(err, handler);
  }
}

// Add to Dio
dio.interceptors.add(CustomInterceptor());
```

### Upload with Progress
```dart
final response = await httpClient.post(
  '/upload',
  data: FormData.fromMap({'file': await MultipartFile.fromFile(filePath)}),
  onSendProgress: (count, total) {
    print('Progress: ${(count / total * 100).toStringAsFixed(0)}%');
  },
);
```

### Download with Progress
```dart
final response = await httpClient.get(
  '/download/file.zip',
  onReceiveProgress: (count, total) {
    print('Progress: ${(count / total * 100).toStringAsFixed(0)}%');
  },
);
```

---

## 🧪 Testing

```dart
test('HttpClient sends GET request', () async {
  final mockDio = MockDio();
  final httpClient = DioHttpClient(dioInstance: mockDio);

  when(mockDio.get(any)).thenAnswer((_) async => Response(
    requestOptions: RequestOptions(path: '/users'),
    statusCode: 200,
    data: [{'id': 1, 'name': 'John'}],
  ));

  final response = await httpClient.get('/users');
  expect(response.statusCode, 200);
  expect(response.data, isA<List>());
});

test('AuthInterceptor adds token to header', () async {
  final interceptor = AuthInterceptor(
    tokenStorage: mockTokenStorage,
    authHandler: mockAuthHandler,
  );

  final options = RequestOptions(path: '/api');
  when(mockTokenStorage.getToken()).thenReturn('test_token');

  final handler = MockRequestInterceptorHandler();
  interceptor.onRequest(options, handler);

  expect(options.headers['Authorization'], 'Bearer test_token');
});
```

---

## ⚠️ Common Issues & Solutions

| Issue | Nguyên nhân | Giải pháp |
|-------|-----------|---------|
| Token null in request | TokenStorage not initialized | Call `await tokenStorage.initialize()` |
| 401 infinite loop | Refresh request also adds token | Use `extra: {'skipAuthInterceptor': true}` |
| Timeout errors | Default timeout too short | Increase timeout in DioClientBuilder |
| CORS errors | Browser cross-origin issue | Not applicable to Flutter (no CORS) |
| SSL certificate error | Self-signed certificate | Add certificate validation config |

---

**See Also**:
- [Auth Module](./AUTH.md) - AuthEventHandler (called by AuthInterceptor)
- [Storage Module](./STORAGE.md) - TokenStorage (used by AuthInterceptor)
- [Errors Module](./ERRORS.md) - DioException mapping
- [DI Setup](./DI.md) - setupAppCoreDI configuration
