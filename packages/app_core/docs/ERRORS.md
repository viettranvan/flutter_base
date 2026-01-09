# Errors Module Documentation

## 📌 Tổng Quan

**Errors Module** cung cấp:
- 🛡️ Exception hierarchy (7 loại)
- 🔄 DioException → AppException mapping
- 🎯 Consistent error handling
- 📊 Field-level validation errors

---

## 📂 Cấu Trúc

```
errors/
├── app_exception.dart    # Exception hierarchy (7 types)
├── error_mapper.dart     # DioException → AppException mapper
└── index.dart
```

---

## 🏗️ AppException Hierarchy

**Base Class**:
```dart
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}
```

**7 Concrete Types**:

### 1. NetworkException
```dart
class NetworkException extends AppException {
  NetworkException(String message) 
    : super(message, null);
}

// Khi nào?
// - No internet connection
// - Connection timeout
// - Socket exception
```

### 2. AuthException
```dart
class AuthException extends AppException {
  AuthException(String message, [int? statusCode]) 
    : super(message, statusCode);
}

// Khi nào?
// - 401 Unauthorized (token expired)
// - 403 Forbidden
// - Session expired
```

### 3. ServerException
```dart
class ServerException extends AppException {
  ServerException(String message, [int? statusCode]) 
    : super(message, statusCode);
}

// Khi nào?
// - 500 Internal Server Error
// - 502 Bad Gateway
// - 503 Service Unavailable
```

### 4. ValidationException
```dart
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  ValidationException(
    String message, [
    int? statusCode,
    this.fieldErrors,
  ]) : super(message, statusCode);
}

// Khi nào?
// - 400 Bad Request (validation error)
// - Field-level error messages
// 
// fieldErrors format:
// {
//   'email': ['Email must be valid'],
//   'password': ['Password must be at least 8 characters'],
// }
```

### 5. NotFoundException
```dart
class NotFoundException extends AppException {
  NotFoundException(String message) 
    : super(message, 404);
}

// Khi nào?
// - 404 Not Found
// - Resource doesn't exist
```

### 6. ForbiddenException
```dart
class ForbiddenException extends AppException {
  ForbiddenException(String message) 
    : super(message, 403);
}

// Khi nào?
// - 403 Forbidden
// - User doesn't have permission
```

### 7. GenericException
```dart
class GenericException extends AppException {
  GenericException(String message, [int? statusCode]) 
    : super(message, statusCode);
}

// Khi nào?
// - Unmapped errors
// - Unknown error types
// - Fallback exception
```

---

## 🔄 Error Mapping

### error_mapper.dart

```dart
AppException mapDioException(DioException dioException) {
  switch (dioException.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return NetworkException('Connection timeout');

    case DioExceptionType.badCertificate:
      return NetworkException('Invalid SSL certificate');

    case DioExceptionType.unknown:
      return NetworkException('No internet connection');

    case DioExceptionType.badResponse:
      return _mapStatusCode(dioException.response);

    default:
      return GenericException(
        dioException.message ?? 'Unknown error',
        dioException.response?.statusCode,
      );
  }
}
```

### Status Code Mapping

```
200-299  →  Success (không map)
400      →  ValidationException (với field errors)
401      →  AuthException
403      →  ForbiddenException
404      →  NotFoundException
5xx      →  ServerException
```

### Validation Error Extraction

```dart
// Backend response format
{
  "error": "Validation failed",
  "errors": {
    "email": ["Email is required", "Email must be valid"],
    "password": ["Password must be at least 8 characters"]
  }
}

// Extracted by error_mapper
ValidationException(
  message: 'Validation failed',
  statusCode: 400,
  fieldErrors: {
    'email': ['Email is required', 'Email must be valid'],
    'password': ['Password must be at least 8 characters'],
  }
)
```

---

## 💻 Usage Examples

### 1. Basic Error Handling

```dart
try {
  final response = await httpClient.get('/users');
  // Process response
} on AuthException catch (e) {
  print('Auth error: ${e.message}');
  // Navigate to login
} on NetworkException catch (e) {
  print('Network error: ${e.message}');
  // Show offline message
} on ServerException catch (e) {
  print('Server error: ${e.statusCode} - ${e.message}');
  // Show server error message
} on AppException catch (e) {
  print('Error: ${e.message}');
  // Handle generic error
}
```

### 2. Validation Error Handling

```dart
try {
  final response = await httpClient.post(
    '/users',
    data: userJson,
  );
} on ValidationException catch (e) {
  print('Validation failed: ${e.message}');
  
  if (e.fieldErrors != null) {
    e.fieldErrors!.forEach((field, errors) {
      print('$field: ${errors.join(", ")}');
      // Show error on field
    });
  }
} on AppException catch (e) {
  print('Error: ${e.message}');
}
```

### 3. In BLoC

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final authAdapter = AuthAdapter();

  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      try {
        emit(AuthLoading());
        final user = await authAdapter.login(
          event.email,
          event.password,
        );
        emit(AuthSuccess(user));
      } on ValidationException catch (e) {
        emit(AuthError(e.message, fieldErrors: e.fieldErrors));
      } on NetworkException catch (_) {
        emit(AuthError('No internet connection'));
      } on AuthException catch (e) {
        emit(AuthError(e.message));
      } on ServerException catch (e) {
        emit(AuthError('Server error: ${e.statusCode}'));
      } on AppException catch (e) {
        emit(AuthError(e.message));
      }
    });
  }
}
```

### 4. Error Recovery

```dart
class ApiRepository {
  final httpClient = GetIt.I<HttpClient>();

  Future<T> callWithRetry<T>(
    Future<Response> Function() apiCall,
    T Function(Response) onSuccess, {
    int maxRetries = 3,
  }) async {
    int retries = 0;

    while (retries < maxRetries) {
      try {
        final response = await apiCall();
        return onSuccess(response);
      } on NetworkException {
        retries++;
        if (retries >= maxRetries) rethrow;
        await Future.delayed(Duration(seconds: 2 * retries));
      } on AuthException {
        rethrow;  // Don't retry auth errors
      } on ServerException catch (e) {
        if (e.statusCode == 503) {
          // Service unavailable - retry
          retries++;
          if (retries >= maxRetries) rethrow;
          await Future.delayed(Duration(seconds: 5));
        } else {
          rethrow;
        }
      }
    }

    throw GenericException('Failed after $maxRetries retries');
  }
}
```

---

## 🔗 Mối Liên Kết Với Các Module Khác

```
Errors Module
├── AppException [Base]
│   ├─ Inherited by: 7 concrete exception types
│   └─ Thrown by: error_mapper
│
├── error_mapper.mapDioException() [Mapper]
│   ├─ Called by: Interceptor or caller
│   ├─ Input: DioException
│   ├─ Output: AppException
│   │
│   ├─ Uses:
│   │  ├─ DioException [Dio]
│   │  ├─ Status code mapping
│   │  └─ Field error extraction
│   │
│   └─ Caught by: Project BLoC/ViewModel
│
├── Thrown at:
│   ├─ HTTP Layer
│   │  └─ AuthInterceptor (onError)
│   │  └─ Caller after httpClient.xxx()
│   │
│   ├─ Project Adapter layer
│   │  └─ Catch and rethrow to BLoC
│   │
│   └─ BLoC/ViewModel
│      └─ Catch by type and handle
│
└─ Part of:
   └─ setupAppCoreDI() error handling strategy
```

---

## 📊 Error Flow Diagram

```
┌──────────────────────────────────────────────────────┐
│          HTTP Request (via HttpClient)              │
└──────────────────────────────────────────────────────┘
                         ↓
     ┌──────────────────────────────────┐
     │  Dio sends request                │
     └──────────────────────────────────┘
                         ↓
         ┌──────────────────────────────┐
         │  Response or Exception?       │
         └──────────────────────────────┘
           ↓                         ↓
      ┌────────┐              ┌─────────────┐
      │ 2xx OK │              │ DioException│
      └────────┘              └─────────────┘
           ↓                         ↓
      Return to caller      ┌─────────────────────┐
                            │ error_mapper.map()  │
                            └─────────────────────┘
                                     ↓
                            ┌─────────────────────┐
                            │ Determine type:     │
                            ├─────────────────────┤
                            │ - timeout? Network  │
                            │ - 400? Validation   │
                            │ - 401? Auth         │
                            │ - 403? Forbidden    │
                            │ - 404? NotFound     │
                            │ - 5xx? Server       │
                            │ - other? Generic    │
                            └─────────────────────┘
                                     ↓
                            ┌──────────────────────┐
                            │ Throw AppException   │
                            │ (concrete type)      │
                            └──────────────────────┘
                                     ↓
                            Caller catches by type:
                            │
                            ├─ on AuthException
                            ├─ on NetworkException
                            ├─ on ValidationException
                            ├─ on ServerException
                            ├─ on NotFoundException
                            ├─ on ForbiddenException
                            └─ on AppException
```

---

## ⚙️ Custom Exception Handling

```dart
// Extend for project-specific needs
class ApiKeyException extends AppException {
  ApiKeyException(String message) 
    : super(message, 401);
}

class RateLimitException extends AppException {
  final int retryAfterSeconds;

  RateLimitException(this.retryAfterSeconds)
    : super('Rate limit exceeded. Retry after $retryAfterSeconds seconds', 429);
}

// Add to error_mapper
AppException _mapStatusCode(Response? response) {
  final statusCode = response?.statusCode ?? 500;
  
  switch (statusCode) {
    case 400:
      return ValidationException(...);
    case 401:
      return AuthException(...);
    case 403:
      return ForbiddenException(...);
    case 404:
      return NotFoundException(...);
    case 429:
      return RateLimitException(...);
    case 500:
    case 502:
    case 503:
      return ServerException(...);
    default:
      return GenericException(...);
  }
}
```

---

## 🧪 Testing

```dart
test('mapDioException maps timeout to NetworkException', () {
  final dioException = DioException(
    requestOptions: RequestOptions(path: '/users'),
    type: DioExceptionType.receiveTimeout,
    message: 'Receive timeout',
  );

  final appException = mapDioException(dioException);
  expect(appException, isA<NetworkException>());
  expect(appException.message, 'Connection timeout');
});

test('mapDioException maps 401 to AuthException', () {
  final dioException = DioException(
    requestOptions: RequestOptions(path: '/users'),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: '/users'),
      statusCode: 401,
      data: {'error': 'Unauthorized'},
    ),
  );

  final appException = mapDioException(dioException);
  expect(appException, isA<AuthException>());
  expect(appException.statusCode, 401);
});

test('mapDioException extracts validation field errors', () {
  final dioException = DioException(
    requestOptions: RequestOptions(path: '/users'),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: '/users'),
      statusCode: 400,
      data: {
        'error': 'Validation failed',
        'errors': {
          'email': ['Email is required'],
          'password': ['Password must be strong'],
        }
      },
    ),
  );

  final appException = mapDioException(dioException) 
    as ValidationException;
  
  expect(appException, isA<ValidationException>());
  expect(appException.fieldErrors, {
    'email': ['Email is required'],
    'password': ['Password must be strong'],
  });
});
```

---

## ⚠️ Common Issues & Solutions

| Issue | Nguyên nhân | Giải pháp |
|-------|-----------|---------|
| Error type không match | Wrong exception mapped | Check status code mapping |
| Field errors null | Response format khác | Check backend response structure |
| Message is null | DioException.message is null | Extract từ response.data |
| Can't catch specific exception | Base exception catch too early | Order catch clauses: specific → general |

---

**See Also**:
- [HTTP Module](./HTTP.md) - Where exceptions are thrown
- [Interceptors](./INTERCEPTORS.md) - Error intercepting
- [Integration Guide](./INTEGRATION.md) - Error handling patterns
