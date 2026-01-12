# Quick Start Guide

## ⚡ 5 Phút Setup

### 1. Clone & Install
```bash
git clone <repo>
cd flutter_base
flutter pub get
```

### 2. Run
```bash
flutter run
```

### 3. Test (Auth Feature)
- Nhấn "Login"
- Email: `eve.holt@reqres.in` (bất kỳ password)
- Xem debug console → curl command sẽ appear

---

## 📌 Key Features

### ✅ Exception Pattern
- Datasource: throw exceptions
- Repository: transform models
- BLoC: catch & emit states

### ✅ Multiple HTTP Clients
```
appClient → Your main API
authClient → ReqRes.in public API
```

### ✅ Auto cURL Extraction
1. Copy từ debug console
2. `Cmd+Shift+B` → "Clean Flutter cURL"
3. Paste & run terminal

### ✅ Global Error Handler
- Automatic error UI display
- Short/long error handling
- Centralized logging

---

## 🗂️ Folder Structure

```
lib/src/features/
├── auth/
│   ├── data/
│   │   ├── datasources/auth_remote_datasource.dart
│   │   ├── models/authenticate_model.dart
│   │   └── repositories/auth_repository_impl.dart
│   ├── domain/
│   │   ├── entities/authenticate.dart
│   │   ├── repositories/auth_repository.dart
│   │   └── usecases/login_usecase.dart
│   └── presentation/
│       ├── blocs/login/login_bloc.dart
│       ├── pages/login_page.dart
│       └── dependencies.dart  ← DI setup
│
├── home/
│   ├── data/...
│   ├── domain/...
│   └── presentation/
│       └── dependencies.dart
│
└── your_feature/  ← Add new feature here
    ├── data/
    ├── domain/
    └── presentation/
        └── dependencies.dart
```

---

## 🚀 Add New Feature (Template)

### Step 1: Create Files
```bash
mkdir -p lib/src/features/my_feature/{data,domain,presentation}/{datasources,models,repositories,entities,usecases,blocs,pages}
```

### Step 2: Create `dependencies.dart`
```dart
class MyFeatureDependencies {
  static void registerDependencies() {
    _registerDataSources();
    _registerRepositories();
    _registerUseCases();
    _registerBlocs();
  }
  
  static void _registerDataSources() { /* ... */ }
  static void _registerRepositories() { /* ... */ }
  static void _registerUseCases() { /* ... */ }
  static void _registerBlocs() { /* ... */ }
  
  static Widget buildMyPage() { /* ... */ }
}
```

### Step 3: Register in `injection_container.dart`
```dart
MyFeatureDependencies.registerDependencies();
```

### Step 4: Add Route
```dart
GoRoute(
  path: '/my-feature',
  pageBuilder: (_, __) => NoTransitionPage(
    child: MyFeatureDependencies.buildMyPage(),
  ),
),
```

---

## 🧪 Run Tests

```bash
# All tests
flutter test

# Specific file
flutter test test/src/features/auth/data/repositories/auth_repository_impl_test.dart

# Coverage
flutter test --coverage
```

---

## 🐛 Debug Tips

### View Request/Response
Debug console sẽ auto-show:
- Request: URL, method, headers
- cURL command: copy-able format
- Response: status, body

### Extract & Test cURL
```
flutter: ║ curl -X POST "https://..." \
flutter: ║ -H "header: value" \
flutter: ║ -d "{...}"

↓ (Cmd+Shift+B "Clean Flutter cURL")

$ curl -X POST "https://..." \
  -H "header: value" \
  -d "{...}"
```

### Check Errors
- Global Error Handler captures all `AppException`
- Auto display in SnackBar/Dialog
- Check console logs: `appLogger.e('message')`

---

## 📖 Learn More

See [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) for:
- Detailed architecture
- Error handling patterns
- Testing examples
- Troubleshooting

---

## ✨ Common Tasks

### Change API Base URL
`lib/src/injection_container.dart`:
```dart
final appDioInstance = DioClientBuilder()
    .setBaseUrl('https://your-api.com')  // ← Change here
    .build();
```

### Change Auth Client URL
`lib/src/injection_container.dart`:
```dart
final authDioInstance = DioClientBuilder()
    .setBaseUrl('https://your-public-api.com')  // ← Change here
    .build();
```

### Add Custom Error Handler
`lib/src/error_handler.dart`:
```dart
if (exception is CustomException) {
  _showCustomError(ctx);
}

static void _showCustomError(BuildContext context) {
  // Your custom handling
}
```

---

Enjoy! 🚀
