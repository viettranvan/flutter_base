# Constants Module Documentation

## 📌 Tổng Quan

**Constants Module** cung cấp:
- 🌐 HTTP constants (timeouts, status codes, headers)
- ⚙️ App configuration constants
- 🔄 Centralized configuration management

---

## 📂 Cấu Trúc

```
constants/
├── app_constants.dart    # HttpConstants + AppConstants
└── index.dart
```

---

## 🏗️ HttpConstants

### Timeouts

```dart
class HttpConstants {
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int sendTimeoutSeconds = 30;

  // Or as Duration objects
  static const Duration connectTimeout = 
    Duration(seconds: connectTimeoutSeconds);
  static const Duration receiveTimeout = 
    Duration(seconds: receiveTimeoutSeconds);
  static const Duration sendTimeout = 
    Duration(seconds: sendTimeoutSeconds);
}

// Usage
DioClientBuilder()
  .setConnectTimeout(HttpConstants.connectTimeout)
  .setReceiveTimeout(HttpConstants.receiveTimeout)
  .build();
```

### HTTP Status Codes

```dart
class HttpConstants {
  // Success
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusAccepted = 202;

  // Client errors
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;

  // Server errors
  static const int statusInternalServerError = 500;
  static const int statusBadGateway = 502;
  static const int statusServiceUnavailable = 503;
}

// Usage in error mapping
if (statusCode == HttpConstants.statusUnauthorized) {
  return AuthException('Token expired');
}
```

### Headers

```dart
class HttpConstants {
  // Content-Type
  static const String contentTypeJson = 'application/json';
  static const String contentTypeForm = 
    'application/x-www-form-urlencoded';
  static const String contentTypeMultipart = 'multipart/form-data';

  // Authorization
  static const String authorizationBearer = 'Bearer';
  static const String authorizationBasic = 'Basic';

  // Header keys
  static const String headerContentType = 'Content-Type';
  static const String headerAuthorization = 'Authorization';
  static const String headerUserAgent = 'User-Agent';
}

// Usage
options.headers[HttpConstants.headerContentType] = 
  HttpConstants.contentTypeJson;

headers[HttpConstants.headerAuthorization] = 
  '${HttpConstants.authorizationBearer} $token';
```

### Response Field Names

```dart
class HttpConstants {
  // Common API response fields
  static const String errorMessageField = 'message';
  static const String errorField = 'error';
  static const String errorsField = 'errors';
  static const String dataField = 'data';
  static const String statusField = 'status';
  static const String codeField = 'code';
}

// Usage in error mapper
String? message = 
  response.data[HttpConstants.errorMessageField];
```

### Retry Configuration

```dart
class HttpConstants {
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Status codes that should trigger retry
  static const List<int> retryableStatusCodes = [408, 429, 500, 502, 503];
}

// Usage
for (int attempt = 0; attempt < HttpConstants.maxRetryAttempts; attempt++) {
  try {
    return await request();
  } catch (e) {
    if (attempt < HttpConstants.maxRetryAttempts - 1) {
      await Future.delayed(HttpConstants.retryDelay);
    }
  }
}
```

---

## 📋 AppConstants

### Upload Configuration

```dart
class AppConstants {
  // File upload
  static const int maxUploadSizeBytes = 10 * 1024 * 1024;  // 10 MB
  static const int maxUploadSizePerFile = 5 * 1024 * 1024; // 5 MB each
  static const int maxFilesPerUpload = 5;

  // Allowed file types
  static const List<String> allowedImageExtensions = 
    ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedDocumentExtensions = 
    ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'];
}

// Usage
if (file.lengthSync() > AppConstants.maxUploadSizeBytes) {
  throw Exception('File too large');
}
```

### Cache Configuration

```dart
class AppConstants {
  // Cache
  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration imageCacheDuration = Duration(days: 7);
  static const int maxCacheItems = 100;
}

// Usage
final cachedData = cache.get('users');
if (cachedData == null || 
    DateTime.now().difference(cachedData.timestamp) > 
    AppConstants.cacheDuration) {
  // Fetch fresh data
}
```

### Session Configuration

```dart
class AppConstants {
  // Session
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const Duration tokenRefreshWindow = Duration(minutes: 5);
}

// Usage
final isExpiringSoon = 
  remainingTime < AppConstants.tokenRefreshWindow;
if (isExpiringSoon) {
  // Refresh token proactively
}
```

---

## 💻 Usage Examples

### 1. In setupAppCoreDI()

```dart
void setupAppCoreDI({...}) {
  final dio = DioClientBuilder()
    .setBaseUrl(baseUrl)
    .setConnectTimeout(HttpConstants.connectTimeout)
    .setReceiveTimeout(HttpConstants.receiveTimeout)
    .build();
  
  dio.options.headers[HttpConstants.headerContentType] = 
    HttpConstants.contentTypeJson;
  
  // ...
}
```

### 2. In Error Mapping

```dart
AppException _mapStatusCode(Response? response) {
  final statusCode = response?.statusCode ?? 500;
  
  switch (statusCode) {
    case HttpConstants.statusBadRequest:
      return ValidationException(...);
    case HttpConstants.statusUnauthorized:
      return AuthException(...);
    case HttpConstants.statusForbidden:
      return ForbiddenException(...);
    case HttpConstants.statusNotFound:
      return NotFoundException(...);
    case HttpConstants.statusInternalServerError:
    case HttpConstants.statusBadGateway:
    case HttpConstants.statusServiceUnavailable:
      return ServerException(...);
    default:
      return GenericException(...);
  }
}
```

### 3. In Project Adapter

```dart
class FileUploadAdapter {
  Future<String> uploadFile(File file) async {
    if (file.lengthSync() > AppConstants.maxUploadSizeBytes) {
      throw ValidationException('File exceeds max size');
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });

    try {
      final response = await httpClient.post(
        '/files/upload',
        data: formData,
      );

      if (response.statusCode == HttpConstants.statusCreated) {
        return response.data['file_url'];
      }
    } on AppException catch (e) {
      if (e.statusCode == HttpConstants.statusBadRequest) {
        // Handle validation error
      }
      rethrow;
    }
  }
}
```

### 4. In Cache Service

```dart
class CacheService {
  final Map<String, CacheItem> _cache = {};

  T? get<T>(String key) {
    final item = _cache[key];
    if (item == null) return null;

    final isExpired = DateTime.now().difference(item.timestamp) > 
      AppConstants.cacheDuration;
    
    if (isExpired) {
      _cache.remove(key);
      return null;
    }

    return item.value as T;
  }

  void set<T>(String key, T value) {
    if (_cache.length >= AppConstants.maxCacheItems) {
      _cache.remove(_cache.keys.first);
    }

    _cache[key] = CacheItem(value, DateTime.now());
  }
}
```

---

## 🔗 Mối Liên Kết Với Các Module Khác

```
Constants Module
├── HttpConstants
│   ├─ Used by:
│   │  ├─ setupAppCoreDI() [DI]
│   │  │  └─ Set timeouts
│   │  │
│   │  ├─ DioClientBuilder [HTTP]
│   │  │  └─ Configure Dio
│   │  │
│   │  ├─ error_mapper [Errors]
│   │  │  └─ Map status codes
│   │  │
│   │  ├─ Interceptors [HTTP]
│   │  │  └─ Check status codes
│   │  │
│   │  └─ Project Adapter layer
│   │     ├─ Check response status
│   │     ├─ Handle specific codes
│   │     └─ Extract field errors
│   │
│   └─ Defines:
│      ├─ Connection parameters
│      ├─ Standard status codes
│      ├─ Standard headers
│      └─ Response fields
│
├── AppConstants
│   ├─ Used by:
│   │  ├─ Project File Service
│   │  │  └─ Validate uploads
│   │  │
│   │  ├─ Project Cache Service
│   │  │  └─ Manage cache ttl
│   │  │
│   │  ├─ Project Auth Service
│   │  │  └─ Handle session timeout
│   │  │
│   │  └─ Project BLoC/ViewModel
│   │     └─ Business logic
│   │
│   └─ Defines:
│      ├─ Upload limits
│      ├─ Cache config
│      └─ Session config
│
└─ Centralized Configuration
   ├─ Easy to update
   ├─ Single source of truth
   ├─ Type-safe
   └─ No magic strings
```

---

## 🎯 Best Practices

### 1. Use Constants Instead of Magic Numbers

```dart
// ❌ BAD
if (response.statusCode == 401) {
  // Handle auth error
}

// ✅ GOOD
if (response.statusCode == HttpConstants.statusUnauthorized) {
  // Handle auth error
}
```

### 2. Keep Related Constants Together

```dart
// ✅ GOOD
class HttpConstants {
  // Success codes grouped
  static const int statusOk = 200;
  static const int statusCreated = 201;

  // Error codes grouped
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
}
```

### 3. Use Duration for Time Values

```dart
// ❌ BAD
static const int timeoutSeconds = 30;
// Then: Duration(seconds: timeoutSeconds)

// ✅ GOOD
static const Duration timeout = Duration(seconds: 30);
// Then: use directly
```

### 4. Document Constants with Examples

```dart
/// Maximum file upload size: 10 MB
/// Validated in FileUploadAdapter before sending
/// If exceeded: returns ValidationException
static const int maxUploadSizeBytes = 10 * 1024 * 1024;
```

---

## 📊 Configuration Hierarchy

```
App Startup
    ↓
Environment Configuration
├─ API Base URL
├─ Feature flags
└─ Environment-specific settings
    ↓
setupAppCoreDI()
├─ Uses: HttpConstants
│  ├─ Timeouts
│  ├─ Default headers
│  └─ Retry config
    ↓
Runtime
├─ HTTP layer uses HttpConstants
│  ├─ Status code handling
│  ├─ Header mapping
│  └─ Error extraction
    ↓
├─ App layer uses AppConstants
│  ├─ Upload validation
│  ├─ Cache management
│  └─ Session handling
```

---

## ⚙️ Environment-Specific Constants

```dart
// lib/constants/app_constants.dart

abstract class AppConfig {
  String get baseUrl;
  bool get enableLogging;
  Duration get requestTimeout;
}

class DevConfig implements AppConfig {
  @override
  String get baseUrl => 'https://dev-api.example.com';
  
  @override
  bool get enableLogging => true;
  
  @override
  Duration get requestTimeout => Duration(seconds: 60);
}

class ProdConfig implements AppConfig {
  @override
  String get baseUrl => 'https://api.example.com';
  
  @override
  bool get enableLogging => false;
  
  @override
  Duration get requestTimeout => Duration(seconds: 30);
}

// Usage
void main() {
  final config = const String.fromEnvironment('ENV') == 'prod'
    ? ProdConfig()
    : DevConfig();

  setupAppCoreDI(
    baseUrl: config.baseUrl,
    // ...
  );
}
```

---

## 🧪 Testing

```dart
test('HttpConstants has correct timeout values', () {
  expect(HttpConstants.connectTimeoutSeconds, 30);
  expect(HttpConstants.receiveTimeoutSeconds, 30);
});

test('HttpConstants status codes are correct', () {
  expect(HttpConstants.statusOk, 200);
  expect(HttpConstants.statusCreated, 201);
  expect(HttpConstants.statusUnauthorized, 401);
  expect(HttpConstants.statusNotFound, 404);
});

test('AppConstants upload limits are reasonable', () {
  expect(AppConstants.maxUploadSizeBytes, 
    isNotNull);
  expect(AppConstants.maxUploadSizeBytes > 0, true);
});
```

---

## ⚠️ Common Issues & Solutions

| Issue | Nguyên nhân | Giải pháp |
|-------|-----------|---------|
| Timeout không áp dụng | Forgot to pass to builder | Use `HttpConstants.connectTimeout` in builder |
| Status code không match | Wrong constant | Use `HttpConstants.statusXxx` |
| Magic strings everywhere | Didn't use constants | Extract to AppConstants |
| Different timeout per endpoint | Default timeout insufficient | Use endpoint-specific Options |

---

**See Also**:
- [HTTP Module](./HTTP.md) - Uses HttpConstants
- [Errors Module](./ERRORS.md) - Uses status code constants
- [DI Setup](./DI.md) - Uses constants for configuration
