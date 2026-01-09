# Dependency Injection (DI) Setup Documentation

## 📌 Tổng Quan

**DI Module** cung cấp:
- 🔧 One-time setup function `setupAppCoreDI()`
- ✅ GetIt service locator configuration
- 🎯 Singleton registration for core services
- 📦 Ready-to-use HttpClient, TokenStorage, Dio

---

## 📂 Cấu Trúc

```
di/
├── app_core_di.dart              # setupAppCoreDI() function
└── index.dart
```

---

## 🏗️ setupAppCoreDI() Function

```dart
void setupAppCoreDI({
  required String baseUrl,
  required TokenStorage tokenStorage,
  required AuthEventHandler authHandler,
  bool addLoggingInterceptor = true,
}) {
  final getIt = GetIt.instance;

  // Register TokenStorage singleton
  getIt.registerSingleton<TokenStorage>(tokenStorage);

  // Register AuthEventHandler singleton
  getIt.registerSingleton<AuthEventHandler>(authHandler);

  // Build Dio instance
  final dio = DioClientBuilder()
    .setBaseUrl(baseUrl)
    .build();

  // Add AuthInterceptor (token refresh & 401 handling)
  dio.interceptors.add(
    AuthInterceptor(
      tokenStorage: tokenStorage,
      authHandler: authHandler,
    ),
  );

  // Add LoggingInterceptor if enabled
  if (addLoggingInterceptor) {
    dio.interceptors.add(
      LoggingInterceptor(
        requestBody: true,
        responseBody: true,
        compact: true,
      ),
    );
  }

  // Register HttpClient
  getIt.registerSingleton<HttpClient>(
    DioHttpClient(dioInstance: dio),
  );

  // Register Dio directly (for advanced usage)
  getIt.registerSingleton<Dio>(dio);
}
```

---

## 📋 Parameters

| Parameter | Type | Required | Default | Mục đích |
|-----------|------|----------|---------|---------|
| `baseUrl` | String | ✅ | - | API endpoint base URL (e.g., 'https://api.example.com') |
| `tokenStorage` | TokenStorage | ✅ | - | Token storage instance (must be initialized before) |
| `authHandler` | AuthEventHandler | ✅ | - | Auth event handler implementation |
| `addLoggingInterceptor` | bool | ❌ | true | Enable request/response logging |

---

## 📝 Basic Usage

### 1. Initialize in main()

```dart
import 'package:app_core/app_core.dart';

void main() async {
  // 1. Create and initialize storage
  final tokenStorage = DefaultTokenStorage(
    appStorage: AppSharedPreferences(),
  );
  await tokenStorage.initialize();

  // 2. Setup DI
  setupAppCoreDI(
    baseUrl: 'https://api.example.com',
    tokenStorage: tokenStorage,
    authHandler: MyAuthHandler(),
    addLoggingInterceptor: true,
  );

  // 3. Run app
  runApp(MyApp());
}
```

### 2. Implement AuthEventHandler

```dart
class MyAuthHandler implements AuthEventHandler {
  @override
  Future<String?> refreshTokenRequest(String refreshToken) async {
    try {
      // Get Dio instance (no auth interceptor for this)
      final dio = GetIt.I<Dio>();
      
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(extra: {'skipAuthInterceptor': true}),
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

  @override
  Future<void> onParsedNewToken(String newToken) async {
    // Optionally update UI
    print('Token refreshed successfully');
    // Notify listeners if using provider/riverpod
  }

  @override
  Future<void> onSessionExpired() async {
    final tokenStorage = GetIt.I<TokenStorage>();
    final router = GetIt.I<GoRouter>();  // or your router

    // Clear storage
    await tokenStorage.clearTokens();

    // Navigate to login
    router.go('/login');

    // Show notification
    print('Session expired - logged out');
  }
}
```

### 3. Access Services Anywhere

```dart
// In BLoC
class UserBloc extends Bloc<UserEvent, UserState> {
  final httpClient = GetIt.I<HttpClient>();
  final tokenStorage = GetIt.I<TokenStorage>();

  UserBloc() : super(UserInitial()) {
    on<GetUsersEvent>((event, emit) async {
      try {
        emit(UserLoading());
        final response = await httpClient.get('/users');
        emit(UserSuccess(response.data));
      } on AppException catch (e) {
        emit(UserError(e.message));
      }
    });
  }
}

// In ViewModel
class ProfileViewModel extends ChangeNotifier {
  final httpClient = GetIt.I<HttpClient>();
  final tokenStorage = GetIt.I<TokenStorage>();

  Future<void> updateProfile(User user) async {
    try {
      await httpClient.put('/profile', data: user.toJson());
      notifyListeners();
    } on AppException catch (e) {
      // Handle error
    }
  }
}

// In Repository
class UserRepository {
  final httpClient = GetIt.I<HttpClient>();

  Future<List<User>> getUsers() async {
    try {
      final response = await httpClient.get('/users');
      return (response.data as List)
        .map((json) => User.fromJson(json))
        .toList();
    } on AppException catch (e) {
      rethrow;
    }
  }
}

// In Adapter
class FileUploadAdapter {
  final httpClient = GetIt.I<HttpClient>();

  Future<String> uploadFile(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });

      final response = await httpClient.post(
        '/files/upload',
        data: formData,
      );

      return response.data['file_url'];
    } on AppException catch (e) {
      rethrow;
    }
  }
}
```

---

## ⚙️ Advanced Configuration

### Custom Base URL per Endpoint

```dart
class AdvancedHttpClient {
  final httpClient = GetIt.I<HttpClient>();

  Future<Response> getFromCustomUrl(String url, String path) async {
    // Create Dio with custom base URL
    final dio = Dio()
      ..options.baseUrl = url;

    return dio.get(path);
  }
}
```

### Environment-Specific Setup

```dart
void main() async {
  final tokenStorage = DefaultTokenStorage(
    appStorage: AppSharedPreferences(),
  );
  await tokenStorage.initialize();

  final baseUrl = const String.fromEnvironment('ENV') == 'prod'
    ? 'https://api.example.com'
    : 'https://dev-api.example.com';

  final enableLogging = const String.fromEnvironment('ENV') != 'prod';

  setupAppCoreDI(
    baseUrl: baseUrl,
    tokenStorage: tokenStorage,
    authHandler: MyAuthHandler(),
    addLoggingInterceptor: enableLogging,
  );

  runApp(MyApp());
}

// Run with:
// flutter run --dart-define=ENV=prod
```

### Multiple API Endpoints

```dart
// In setupAppCoreDI or separately
void setupMultipleApis() {
  // Main API
  setupAppCoreDI(
    baseUrl: 'https://api.example.com',
    tokenStorage: GetIt.I<TokenStorage>(),
    authHandler: GetIt.I<AuthEventHandler>(),
  );

  // Secondary API
  final getIt = GetIt.instance;
  final dio2 = DioClientBuilder()
    .setBaseUrl('https://api2.example.com')
    .build();
  getIt.registerSingleton<Dio>(dio2, instanceName: 'secondary');

  // Usage
  final primaryDio = GetIt.I<Dio>();
  final secondaryDio = GetIt.I<Dio>(instanceName: 'secondary');
}
```

---

## 🔄 Initialization Flow

```
main() starts
    ↓
Create TokenStorage instance
    ↓
await tokenStorage.initialize()
├─ Load tokens from SecureStorage
└─ Store in memory cache
    ↓
setupAppCoreDI()
├─ Register TokenStorage
├─ Register AuthEventHandler
├─ Create Dio instance via DioClientBuilder
│  ├─ Set baseUrl
│  ├─ Set default timeouts
│  └─ Set default headers
├─ Add AuthInterceptor
│  └─ Uses: TokenStorage + AuthEventHandler
├─ Add LoggingInterceptor (if enabled)
├─ Register HttpClient (wraps Dio)
├─ Register Dio directly
└─ GetIt ready for service access
    ↓
runApp(MyApp())
    ↓
App runs
├─ BLoCs can access GetIt.I<HttpClient>()
├─ ViewModels can access GetIt.I<TokenStorage>()
└─ Services can access GetIt.I<AuthEventHandler>()
```

---

## 🔗 Mối Liên Kết Với Các Module Khác

```
setupAppCoreDI() [DI Module]
├─ Required Inputs:
│  ├─ baseUrl: String
│  │  └─ Used by: DioClientBuilder to configure Dio
│  │
│  ├─ tokenStorage: TokenStorage [Storage Module]
│  │  ├─ Registered: As singleton in GetIt
│  │  └─ Used by: AuthInterceptor
│  │
│  ├─ authHandler: AuthEventHandler [Auth Module]
│  │  ├─ Registered: As singleton in GetIt
│  │  └─ Used by: AuthInterceptor
│  │
│  └─ addLoggingInterceptor: bool
│     └─ Used by: LoggingInterceptor [HTTP]
│
├─ Creates & Registers:
│  ├─ Dio instance (via DioClientBuilder [HTTP])
│  │  ├─ Adds: AuthInterceptor [HTTP]
│  │  │  └─ Uses: TokenStorage [Storage] + AuthEventHandler [Auth]
│  │  └─ Adds: LoggingInterceptor [HTTP]
│  │
│  ├─ HttpClient (wraps Dio [HTTP])
│  │  └─ Used by: Project BLoC/ViewModel
│  │
│  ├─ TokenStorage [Storage]
│  │  └─ Used by: Project code
│  │
│  ├─ AuthEventHandler [Auth]
│  │  └─ Used by: AuthInterceptor
│  │
│  └─ Dio directly
│     └─ Used by: Advanced usage
│
├─ Uses Constants:
│  └─ HttpConstants [Constants]
│     ├─ Default timeouts
│     ├─ Default headers
│     └─ Status codes
│
└─ Throws Errors:
   └─ AppException [Errors]
      └─ Caught by: Project code
```

---

## 🧪 Testing

### Mock DI for Testing

```dart
setUp(() {
  GetIt.instance.reset();
});

test('setupAppCoreDI registers HttpClient', () {
  final mockTokenStorage = MockTokenStorage();
  final mockAuthHandler = MockAuthEventHandler();

  setupAppCoreDI(
    baseUrl: 'https://api.example.com',
    tokenStorage: mockTokenStorage,
    authHandler: mockAuthHandler,
    addLoggingInterceptor: false,
  );

  expect(
    GetIt.I<HttpClient>(),
    isA<DioHttpClient>(),
  );
  expect(
    GetIt.I<TokenStorage>(),
    mockTokenStorage,
  );
});

test('setupAppCoreDI registers AuthEventHandler', () {
  final mockTokenStorage = MockTokenStorage();
  final mockAuthHandler = MockAuthEventHandler();

  setupAppCoreDI(
    baseUrl: 'https://api.example.com',
    tokenStorage: mockTokenStorage,
    authHandler: mockAuthHandler,
  );

  expect(
    GetIt.I<AuthEventHandler>(),
    mockAuthHandler,
  );
});
```

### Test BLoC with DI

```dart
testWidgets('UserBloc uses injected HttpClient', (tester) async {
  // Setup mock DI
  final mockHttpClient = MockHttpClient();
  GetIt.instance.registerSingleton<HttpClient>(mockHttpClient);

  // Setup test response
  when(mockHttpClient.get('/users')).thenAnswer(
    (_) async => Response(
      requestOptions: RequestOptions(path: '/users'),
      statusCode: 200,
      data: [{'id': 1, 'name': 'John'}],
    ),
  );

  // Create BLoC
  final bloc = UserBloc();

  // Add event
  bloc.add(GetUsersEvent());

  // Verify states
  await tester.pumpWidget(BlocBuilder<UserBloc, UserState>(
    bloc: bloc,
    builder: (context, state) {
      if (state is UserSuccess) {
        expect(state.users, hasLength(1));
      }
      return SizedBox();
    },
  ));

  // Cleanup
  await tester.pumpAndSettle();
  GetIt.instance.unregister<HttpClient>();
});
```

---

## ⚠️ Common Issues & Solutions

| Issue | Nguyên nhân | Giải pháp |
|-------|-----------|---------|
| "GetIt not initialized" | setupAppCoreDI() not called | Call in main() before runApp() |
| TokenStorage null | Forgot to initialize storage | Call `await tokenStorage.initialize()` |
| 401 infinite loop | Refresh request includes auth | Use `extra: {'skipAuthInterceptor': true}` |
| Multiple instances registered | Calling setupAppCoreDI() twice | Call only once in main() |
| GetIt<HttpClient> not found | Wrong parameter types | Check parameter types match interface |

---

## 📊 Service Locator Pattern

```
┌──────────────────────────────────────────────┐
│              GetIt Service Locator           │
├──────────────────────────────────────────────┤
│                                              │
│  Singletons (one instance per app):          │
│  ├─ HttpClient → DioHttpClient               │
│  ├─ Dio → Dio instance                       │
│  ├─ TokenStorage → DefaultTokenStorage       │
│  └─ AuthEventHandler → MyAuthHandler         │
│                                              │
└──────────────────────────────────────────────┘
                    ↑
                    │
    Any layer can access via:
    GetIt.I<HttpClient>()
    GetIt.I<TokenStorage>()
    GetIt.I<Dio>()
    GetIt.I<AuthEventHandler>()
```

---

## 🚀 Lifecycle

```
App Launch
    ↓
main()
├─ Initialize storage
│  └─ Load tokens from disk
│
├─ setupAppCoreDI()
│  ├─ Register all services
│  ├─ Create Dio with interceptors
│  └─ Ready for injection
│
└─ runApp()
    ├─ BLoCs created
    │  └─ Access GetIt.I<HttpClient>()
    │
    ├─ API calls made
    │  ├─ AuthInterceptor adds token
    │  ├─ LoggingInterceptor logs
    │  └─ Response/Error handled
    │
    └─ App running
        ├─ Token refresh on 401
        ├─ Session expiry on refresh fail
        └─ Continue until logout
```

---

**See Also**:
- [Auth Module](./AUTH.md) - AuthEventHandler implementation
- [Storage Module](./STORAGE.md) - TokenStorage initialization
- [HTTP Module](./HTTP.md) - HttpClient & interceptors
- [Integration Guide](./INTEGRATION.md) - Complete example
