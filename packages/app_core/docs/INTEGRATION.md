# Integration Guide - Using App Core in Your Project

## 📌 Tổng Quan

Hướng dẫn này giúp bạn tích hợp `app_core` package vào project Flutter của mình.

---

## 🚀 Step-by-Step Integration

### Step 1: Add Dependency

**pubspec.yaml**:
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Add app_core (from packages folder)
  app_core:
    path: packages/app_core
  
  # Or from pub.dev (when published)
  # app_core: ^1.0.0
  
  # Required by app_core
  get_it: ^7.0.0
  dio: ^5.8.0
  flutter_secure_storage: ^9.2.4
  shared_preferences: ^2.5.3
  logger: ^2.0.0
```

---

### Step 2: Initialize in main()

**lib/main.dart**:
```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'my_auth_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize storage
  final tokenStorage = DefaultTokenStorage(
    appStorage: AppSharedPreferences(),
  );
  await tokenStorage.initialize();

  // 2. Setup app_core DI
  setupAppCoreDI(
    baseUrl: 'https://api.example.com',
    tokenStorage: tokenStorage,
    authHandler: MyAuthHandler(),
    addLoggingInterceptor: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
```

---

### Step 3: Implement AuthEventHandler

**lib/core/auth/my_auth_handler.dart**:
```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

class MyAuthHandler implements AuthEventHandler {
  @override
  Future<String?> refreshTokenRequest(String refreshToken) async {
    try {
      // Get Dio instance to avoid auth interceptor
      final dio = GetIt.I<Dio>();

      final response = await dio.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
        options: Options(
          extra: {'skipAuthInterceptor': true},
        ),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'] as String;
        AppLogger.info('Token refreshed successfully');
        return newAccessToken;
      }

      AppLogger.warning('Token refresh failed with status: ${response.statusCode}');
      return null;
    } catch (e, st) {
      AppLogger.error('Token refresh exception', e, st);
      return null;
    }
  }

  @override
  Future<void> onParsedNewToken(String newToken) async {
    // Optionally notify UI that token was refreshed
    AppLogger.info('New token parsed and stored');
    // You can notify listeners here if using Provider/Riverpod
  }

  @override
  Future<void> onSessionExpired() async {
    final tokenStorage = GetIt.I<TokenStorage>();

    // Clear all tokens
    await tokenStorage.clearTokens();

    AppLogger.warning('Session expired - logging out');

    // Navigate to login
    // (You'll need to get your router instance)
    // router.go('/login');
  }
}
```

---

### Step 4: Create Project Adapter Layer

Project adapters convert raw HTTP responses to domain models:

**lib/features/user/data/adapters/user_adapter.dart**:
```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';
import '../models/user_model.dart';

class UserAdapter {
  final _httpClient = GetIt.I<HttpClient>();

  /// Get all users
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _httpClient.get('/users');

      if (response.isSuccessful) {
        final users = response.dataAsList;
        if (users == null) throw Exception('Unexpected response format');

        return users
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
      }

      throw Exception('Failed to fetch users: ${response.statusCode}');
    } on AppException {
      rethrow;  // Re-throw to caller (BLoC/ViewModel)
    } catch (e) {
      throw GenericException('Unexpected error: $e');
    }
  }

  /// Get user by ID
  Future<UserModel> getUser(String id) async {
    try {
      final response = await _httpClient.get('/users/$id');

      if (response.isSuccessful) {
        final userData = response.dataAsMap;
        if (userData == null) throw Exception('Unexpected response format');

        return UserModel.fromJson(userData);
      }

      if (response.statusCode == 404) {
        throw NotFoundException('User not found');
      }

      throw Exception('Failed to fetch user: ${response.statusCode}');
    } on AppException {
      rethrow;
    } catch (e) {
      throw GenericException('Unexpected error: $e');
    }
  }

  /// Create user
  Future<UserModel> createUser(CreateUserRequest request) async {
    try {
      final response = await _httpClient.post(
        '/users',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to create user: ${response.statusCode}');
    } on ValidationException catch (e) {
      rethrow;  // Let caller handle field errors
    } on AppException {
      rethrow;
    } catch (e) {
      throw GenericException('Unexpected error: $e');
    }
  }

  /// Update user
  Future<UserModel> updateUser(String id, UpdateUserRequest request) async {
    try {
      final response = await _httpClient.put(
        '/users/$id',
        data: request.toJson(),
      );

      if (response.isSuccessful) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to update user: ${response.statusCode}');
    } on AppException {
      rethrow;
    } catch (e) {
      throw GenericException('Unexpected error: $e');
    }
  }

  /// Delete user
  Future<void> deleteUser(String id) async {
    try {
      final response = await _httpClient.delete('/users/$id');

      if (!response.isSuccessful) {
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw GenericException('Unexpected error: $e');
    }
  }
}
```

---

### Step 5: Use in BLoC

**lib/features/user/presentation/bloc/user_bloc.dart**:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_core/app_core.dart';
import '../adapters/user_adapter.dart';
import '../models/user_model.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final _userAdapter = UserAdapter();

  UserBloc() : super(UserInitial()) {
    on<GetUsersEvent>(_onGetUsers);
    on<GetUserEvent>(_onGetUser);
    on<CreateUserEvent>(_onCreateUser);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  Future<void> _onGetUsers(GetUsersEvent event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      final users = await _userAdapter.getUsers();
      emit(UserSuccess(users));
    } on NetworkException catch (e) {
      emit(UserError(e.message, 'No internet connection'));
    } on AuthException catch (e) {
      emit(UserError(e.message, 'Please login again'));
    } on ServerException catch (e) {
      emit(UserError(e.message, 'Server error: ${e.statusCode}'));
    } on AppException catch (e) {
      emit(UserError(e.message, 'Error loading users'));
    }
  }

  Future<void> _onGetUser(GetUserEvent event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      final user = await _userAdapter.getUser(event.id);
      emit(UserSuccess([user]));
    } on NotFoundException catch (e) {
      emit(UserError(e.message, 'User not found'));
    } on AppException catch (e) {
      emit(UserError(e.message));
    }
  }

  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoading());
      final user = await _userAdapter.createUser(event.request);
      emit(UserCreated(user));
    } on ValidationException catch (e) {
      // Handle field-level errors
      emit(UserValidationError(e.message, e.fieldErrors ?? {}));
    } on AppException catch (e) {
      emit(UserError(e.message));
    }
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      await _userAdapter.deleteUser(event.id);
      emit(UserDeleted());
    } on AppException catch (e) {
      emit(UserError(e.message));
    }
  }
}
```

---

### Step 6: Use in UI

**lib/features/user/presentation/pages/user_list_page.dart**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_core/app_core.dart';
import '../bloc/user_bloc.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserBloc()..add(GetUsersEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Users')),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserInitial) {
              return const Center(child: Text('No data'));
            }

            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is UserSuccess) {
              return ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  final user = state.users[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    onTap: () {
                      // Navigate to detail page
                    },
                  );
                },
              );
            }

            if (state is UserError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    SizedBox(height: context.screenHeight * 0.02),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: context.screenHeight * 0.03),
                    ElevatedButton(
                      onPressed: () {
                        context.read<UserBloc>().add(GetUsersEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('Unknown state'));
          },
        ),
      ),
    );
  }
}
```

---

### Step 7: Form with Validation

**lib/features/auth/presentation/pages/login_page.dart**:
```dart
import 'package:flutter/material.dart';
import 'package:app_core/app_core.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }
    if (!value!.isValidEmail) {
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Password is required';
    }
    if (value!.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      context.showSnackBar('Logging in...');

      // Call your auth adapter
      // final user = await authAdapter.login(
      //   _emailController.text,
      //   _passwordController.text,
      // );

      // context.showSuccess('Login successful!');
      // context.go('/home');
    } on ValidationException catch (e) {
      context.showError('Validation Error', e.message);
    } on NetworkException catch (_) {
      context.showError('Network Error', 'No internet connection');
    } on AppException catch (e) {
      context.showError('Error', e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          context.isTablet ? 24.0 : 16.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: context.screenHeight * 0.05),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
              ),
              SizedBox(height: context.screenHeight * 0.02),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _validatePassword,
              ),
              SizedBox(height: context.screenHeight * 0.04),
              ElevatedButton(
                onPressed: _handleLogin,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### Step 8: Search with Debouncer

**lib/features/search/presentation/pages/search_page.dart**:
```dart
import 'package:flutter/material.dart';
import 'package:app_core/app_core.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  List<String> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearch);
  }

  void _handleSearch() {
    final query = _searchController.text.trim();

    if (query.isBlank) {
      setState(() => _results = []);
      return;
    }

    _debouncer(() async {
      setState(() => _isLoading = true);

      try {
        // Call your search API
        // _results = await searchAdapter.search(query);
        setState(() => _isLoading = false);
      } on AppException catch (e) {
        context.showError('Search Error', e.message);
      }
    });
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isLoading
                  ? const SizedBox(
                      width: 40,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : null,
              ),
            ),
          ),
          Expanded(
            child: _results.isEmpty
              ? Center(
                  child: Text(_searchController.text.isEmpty 
                    ? 'Start typing to search'
                    : 'No results found'),
                )
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_results[index]),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
```

---

## 📋 Project Structure Example

```
lib/
├── main.dart
├── my_auth_handler.dart
├── config/
│   ├── env.dart                    # Environment config
│   └── router.dart                 # Go Router setup
├── core/
│   ├── auth/
│   │   └── my_auth_handler.dart
│   └── constants/
│       └── api_endpoints.dart
├── features/
│   ├── user/
│   │   ├── data/
│   │   │   ├── adapters/
│   │   │   │   └── user_adapter.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── user_repository.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── user_bloc.dart
│   │       └── pages/
│   │           └── user_list_page.dart
│   │
│   └── auth/
│       ├── data/
│       │   ├── adapters/
│       │   │   └── auth_adapter.dart
│       │   └── models/
│       │       └── auth_response.dart
│       └── presentation/
│           ├── bloc/
│           │   └── auth_bloc.dart
│           └── pages/
│               ├── login_page.dart
│               └── register_page.dart
```

---

## ✅ Checklist

- [ ] Add `app_core` to pubspec.yaml
- [ ] Implement `AuthEventHandler`
- [ ] Call `setupAppCoreDI()` in main()
- [ ] Create adapter layer for your domains
- [ ] Use `HttpClient` from GetIt in adapters
- [ ] Catch `AppException` types in BLoC
- [ ] Handle validation errors with field errors
- [ ] Use string extensions for validation
- [ ] Use context extensions for responsive UI
- [ ] Use debouncer for search/input fields

---

## 🔗 See Also

- [README](./README.md) - Overview
- [Architecture](./ARCHITECTURE.md) - Design patterns
- [Auth Module](./AUTH.md) - Authentication
- [HTTP Module](./HTTP.md) - Network layer
- [Errors Module](./ERRORS.md) - Error handling
- [Helpers](./HELPERS.md) - Utilities & extensions
