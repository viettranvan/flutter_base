# Flutter Base - Development Guide

Hướng dẫn chi tiết để phát triển project này.

## 📋 Mục lục

1. [Project Setup](#project-setup)
2. [Architecture](#architecture)
3. [Feature Development](#feature-development)
4. [Testing](#testing)
5. [Debugging & Tools](#debugging--tools)
6. [Troubleshooting](#troubleshooting)

---

## 🚀 Project Setup

### Yêu cầu
- Flutter >= 3.0
- Dart >= 3.0
- VS Code với Flutter extension

### Clone & Setup

```bash
# Clone project
git clone <repo>
cd flutter_base

# Get dependencies
flutter pub get

# Run app
flutter run
```

### Folder Structure

```
lib/
├── main.dart                 # Entry point
├── src/
│   ├── core/                 # Core utilities, constants, error handling
│   ├── features/             # Feature modules
│   │   ├── auth/
│   │   ├── home/
│   │   └── ...
│   ├── injection_container.dart  # DI setup
│   └── router/               # Navigation
└── generated/                # Generated code (l10n, etc)
```

---

## 🏗️ Architecture

### Clean Architecture + BLoC Pattern

```
Feature Module
├── data/
│   ├── datasources/          # Remote/Local API calls
│   ├── models/               # Data models
│   └── repositories/         # Business logic bridge
├── domain/
│   ├── entities/             # Business entities
│   ├── repositories/         # Abstract interfaces
│   └── usecases/             # Business logic
└── presentation/
    ├── blocs/                # State management
    ├── pages/                # UI pages
    └── dependencies.dart     # Feature DI setup
```

### Exception Handling Pattern

**Datasource Layer** (xử lý errors):
```dart
Future<Model> fetchData() async {
  try {
    final response = await httpClient.get('/endpoint');
    
    // Validate status code
    if (response.statusCode == null || response.statusCode! ~/ 100 != 2) {
      throw ServerException(message: 'Error', statusCode: response.statusCode);
    }
    
    // Validate data format
    if (data is! Map) throw GenericException(message: 'Invalid format');
    
    // Parse & handle errors
    try {
      return Model.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;  // Bubble up AppException
      throw GenericException(message: 'Parsing error: ${e.toString()}');
    }
  } on AppException {
    rethrow;  // Ensure AppException is thrown
  } catch (e) {
    throw GenericException(message: 'Unexpected error: ${e.toString()}');
  }
}
```

**Repository Layer** (không catch, chỉ transform):
```dart
Future<Entity> fetchData() async {
  // Datasource đã handle exceptions
  // Chỉ cần transform model -> entity
  final model = await datasource.fetchData();
  return model.toEntity();
}
```

**BLoC Layer** (catch & emit state):
```dart
FutureOr<void> _onFetch(FetchEvent event, Emitter<State> emit) async {
  emit(Loading());
  try {
    final data = await usecase.call();
    emit(Loaded(data: data));
  } on AppException catch (e) {
    appLogger.e('Error: ${e.message}');
    GlobalErrorHandler.handle(e);  // Show UI error
    emit(Error(message: e.message));
  }
}
```

---

## 📱 Feature Development

### 1. Tạo Feature Mới

```bash
mkdir -p lib/src/features/my_feature/{data,domain,presentation}
```

### 2. Setup Dependencies

Tạo file `lib/src/features/my_feature/presentation/dependencies.dart`:

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter_base/src/injection_container.dart';
import 'package:flutter_base/src/features/my_feature/auth_index.dart';

class MyFeatureDependencies {
  static final GetIt _sl = GetIt.instance;

  static void registerDependencies() {
    _registerDataSources();
    _registerRepositories();
    _registerUseCases();
    _registerBlocs();
  }

  static void _registerDataSources() {
    _sl.registerLazySingleton<MyDataSource>(
      () => MyDataSourceImpl(
        httpClient: _sl<HttpClient>(instanceName: HttpClientNames.appClient),
      ),
    );
  }

  static void _registerRepositories() {
    _sl.registerLazySingleton<MyRepository>(
      () => MyRepositoryImpl(_sl()),
    );
  }

  static void _registerUseCases() {
    _sl.registerLazySingleton(() => MyUseCase(_sl()));
  }

  static void _registerBlocs() {
    _sl.registerFactory(() => MyBloc(_sl()));
  }

  static Widget buildMyPage() {
    final bloc = _sl<MyBloc>();
    return BlocProvider.value(
      value: bloc,
      child: const MyPage(),
    );
  }
}
```

### 3. Register Feature

Thêm vào `lib/src/injection_container.dart`:

```dart
// Feature injections
AuthDependencies.registerDependencies();
HomeDependencies.registerDependencies();
MyFeatureDependencies.registerDependencies();  // ← NEW
```

### 4. Add Route

Thêm vào `lib/src/router/router.dart`:

```dart
GoRoute(
  path: '/my-feature',
  name: RouteName.myFeature.name,
  pageBuilder: (context, state) =>
      NoTransitionPage(child: MyFeatureDependencies.buildMyPage()),
),
```

---

## 🧪 Testing

### Repository Test

```dart
test('should return Entity when datasource succeeds', () async {
  // arrange
  when(() => mockDatasource.fetchData()).thenAnswer((_) async => model);

  // act
  final result = await repository.fetchData();

  // assert
  expect(result, entity);
  verify(() => mockDatasource.fetchData()).called(1);
});

test('should throw AppException when datasource throws', () async {
  // arrange
  when(() => mockDatasource.fetchData())
      .thenThrow(ServerException(message: 'Error', statusCode: 500));

  // act & assert
  expect(
    () => repository.fetchData(),
    throwsA(isA<ServerException>()),
  );
});
```

### BLoC Test

```dart
blocTest<MyBloc, MyState>(
  'emits [Loading, Loaded] when fetch succeeds',
  build: () {
    when(() => mockUsecase.call()).thenAnswer((_) async => entity);
    return bloc;
  },
  act: (bloc) => bloc.add(FetchEvent()),
  expect: () => [Loading(), Loaded(data: entity)],
);
```

---

## 🔧 Debugging & Tools

### 1. Clean Flutter cURL Task

**Tự động extract & copy curl command từ debug console**

**Cách dùng:**
1. Copy bất cứ dòng nào từ debug console chứa curl command
2. Chạy task: `Cmd+Shift+B` (macOS) hoặc `Ctrl+Shift+B` (Linux/Windows)
3. Paste curl vào terminal: `Cmd+V` / `Ctrl+V`

**Output:**
```
📱 OS Detected: Darwin
✓ Using macOS clipboard (pbpaste/pbcopy)
📋 Reading from clipboard...
✓ Clipboard read (245 chars)
🔍 Extracting curl command...
✓ Curl command extracted
📝 Copying to clipboard using: pbcopy

✅ SUCCESS! Clean cURL copied to clipboard
📌 You can now paste it with Cmd+V or Ctrl+V
```

### 2. HTTP Logging

**Tự động log request/response + curl command**

Debug console sẽ show:

```
╔ Request ║ POST 
║  https://dummyjson.com/auth/login

╔ cURL Command (Triple-click to select all)
║
║ curl -X POST \
║ "https://dummyjson.com/auth/login" \
║ -H "content-type: application/json" \
║ -d "{\"username\":\"emilys\",\"password\":\"emilyspass\"}"
║
╚

╔ Response ║ POST ║ Status: 200 OK
║  https://dummyjson.com/auth/login

╔ Body
║
║ {
║     "accessToken": "eyJhbGc...",
║     "refreshToken": "eyJhbGc...",
║     ...
```

**Tip:** Triple-click dòng curl để select toàn bộ command

### 3. Error Handler

**Global error handling với UI feedback**

- **Short errors** (≤100 chars) → SnackBar
- **Long errors** (>100 chars) → Dialog scrollable
- **Custom errors** → Handle bằng `GlobalErrorHandler.handle()`

---

## 🚨 Troubleshooting

### 1. "GetIt: Object/factory with type X is not registered"

**Nguyên nhân:** Dependency chưa được register

**Giải pháp:**
```dart
// 1. Kiểm tra dependencies.dart có register chưa
static void _registerDependencies() { ... }

// 2. Feature được add vào injection_container.dart chưa
MyFeatureDependencies.registerDependencies();

// 3. Register lúc nào: lúc app startup trong setup()
```

### 2. Curl command không được copy

**Nguyên nhân:** Clipboard không support hoặc script lỗi

**Giải pháp:**
1. Check output từ task "Clean Flutter cURL"
2. Nếu show error, copy curl thủ công từ debug console
3. Ensure clipboard tool có: `pbcopy` (macOS), `wl-copy` (Linux), v.v.

### 3. Exception không được handle

**Nguyên nhân:** BLoC không catch AppException

**Giải pháp:**
```dart
try {
  final result = await usecase.call();
  emit(Loaded(data: result));
} on AppException catch (e) {  // ← Catch AppException
  appLogger.e('Error: ${e.message}');
  emit(Error(message: e.message));
}
```

### 4. Router không hoạt động

**Nguyên nhân:** Route chưa add hoặc BlocProvider chưa wrap

**Giải pháp:**
```dart
// 1. Add route vào router.dart
GoRoute(
  path: '/my-path',
  pageBuilder: (context, state) =>
      NoTransitionPage(child: MyFeatureDependencies.buildMyPage()),
),

// 2. buildMyPage() phải return widget được wrap BlocProvider
static Widget buildMyPage() {
  final bloc = _sl<MyBloc>();
  return BlocProvider.value(value: bloc, child: MyPage());
}
```

---

## 📚 Best Practices

### 1. Dependency Injection
- ✅ Register tất cả dependencies ở startup
- ✅ Use named instances cho multiple HttpClient
- ❌ Tránh tạo object trong BLoC

### 2. Error Handling
- ✅ Throw AppException từ datasource
- ✅ Catch ở BLoC layer
- ❌ Không catch & ignore errors

### 3. Testing
- ✅ Mock external dependencies
- ✅ Test happy path + error cases
- ❌ Không test implementation details

### 4. Code Organization
- ✅ Feature-based folder structure
- ✅ Clear layer separation
- ❌ Không mix business logic & UI

---

## 🎯 Next Steps

1. **Clone project & run** `flutter run`
2. **Check debug console** - xem HTTP logging format
3. **Copy curl** từ debug output, run "Clean Flutter cURL" task
4. **Add feature mới** - follow template ở mục Feature Development
5. **Write tests** - reference test examples
6. **Deploy** - setup CI/CD

---

Happy coding! 🚀
