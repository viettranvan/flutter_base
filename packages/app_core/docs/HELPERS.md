# Helpers & Extensions Documentation

## 📌 Tổng Quan

**Helpers Module** cung cấp:
- 📝 String extensions (13+ methods)
- 🎨 BuildContext extensions (20+ methods)
- 🔌 Dio Options extensions
- 🎯 Debouncer utility
- 📋 App logger

---

## 📂 Cấu Trúc

```
helpers/
├── app_logger.dart                    # Logging utility
├── debouncer.dart                     # Debounce utility
├── extensions/
│   ├── string_extensions.dart         # String helpers
│   ├── context_extensions.dart        # BuildContext helpers
│   ├── dio_options_extensions.dart    # Dio utilities
│   └── index.dart
└── index.dart
```

---

## 📝 String Extensions

### Validation Methods

```dart
// Check if empty/blank
String email = "";
if (email.isEmpty) { }           // true
if (email.isBlank) { }           // true (also whitespace)

// Validation
if ("test@gmail.com".isValidEmail) { }      // true
if ("https://example.com".isValidUrl) { }   // true
if ("12345".isNumeric) { }                   // true
if ("abc".isAlpha) { }                       // true
if ("abc123".isAlphaNumeric) { }             // true
```

### Transformation Methods

```dart
// Capitalize
"hello world".capitalize();           // "Hello world"

// Remove whitespace
"h e l l o".removeWhitespace();       // "hello"

// Limit length
"hello world".limitLength(5);         // "hello..."
"hello world".limitLength(5, "→");    // "hello→"

// Truncate decimals
"3.14159".truncateDecimals(2);        // "3.14"
```

### Usage Example

```dart
class AuthValidator {
  String? validateEmail(String email) {
    if (email.isEmpty) return 'Email is required';
    if (!email.isValidEmail) return 'Invalid email format';
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password too short';
    if (!password.containsAny(['A', 'a', '0', '@'])) {
      return 'Password must contain uppercase, lowercase, number, special char';
    }
    return null;
  }
}
```

### Complete List

```dart
// isEmpty / isNotEmpty
"".isEmpty                    // true
"hello".isNotEmpty            // true

// isBlank / isNotBlank (includes whitespace)
"   ".isBlank                 // true
"hello".isNotBlank            // true

// Capitalization
"hello".capitalize()          // "Hello"
"HELLO".lowercase()           // "hello"

// Validation
"test@gmail.com".isValidEmail
"https://example.com".isValidUrl
"12345".isNumeric
"abc".isAlpha
"abc123".isAlphaNumeric

// Transformation
"hello world".removeWhitespace()
"hello world".limitLength(10, "...")
"3.14159".truncateDecimals(2)

// Checking
"hello".contains("ell")
"hello".startsWith("he")
"hello".endsWith("lo")

// Replacement
"hello world".replaceAll("world", "Flutter")
"hello".padLeft(10, " ")
"hello".padRight(10, " ")
```

---

## 🎨 BuildContext Extensions

### Screen Information

```dart
context.screenWidth              // Device width
context.screenHeight             // Device height
context.screenSize               // Size(width, height)
context.isPortrait              // Is portrait?
context.isLandscape             // Is landscape?
context.isTablet                // Is tablet?
context.isSmallScreen           // Small device?
context.aspectRatio             // Width / Height
```

### Keyboard Information

```dart
context.isKeyboardVisible        // Keyboard shown?
context.keyboardHeight           // Keyboard height in pixels
context.bottomInset              // Safe area bottom (notches)
```

### Theme & Colors

```dart
context.theme                    // ThemeData
context.isDarkMode              // Is dark theme?
context.colorScheme             // ColorScheme
context.primaryColor            // Primary color
context.backgroundColor         // Background color
context.textTheme               // TextTheme
```

### Navigation

```dart
context.pop()                           // Navigator.pop()
context.pushNamed('/profile')           // Push named route
context.pushNamedAndRemoveUntil(        // Replace route
  '/login',
  (route) => false,
)
context.maybePop()                      // Pop if can pop
```

### Dialogs & Notifications

```dart
// SnackBar
context.showSnackBar('Hello!')
context.showSnackBar(
  'Error',
  backgroundColor: Colors.red,
  duration: Duration(seconds: 3),
)

// Dialog messages
context.showMessage('Info', 'This is a message')
context.showError('Error', 'Something went wrong')
context.showSuccess('Success', 'Operation completed')

// Toast
context.showToast('Quick notification')
```

### Usage Example

```dart
class ResponsiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (context.isPortrait)
            // Portrait layout
            PortraitLayout()
          else
            // Landscape layout
            LandscapeLayout(),

          SizedBox(height: context.screenHeight * 0.1),

          if (context.isTablet)
            // Tablet-specific widget
            TabletSpecificWidget(),

          if (context.isKeyboardVisible)
            SizedBox(height: context.keyboardHeight),
        ],
      ),
    );
  }
}

class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  void submitForm() {
    if (validateForm()) {
      context.showSnackBar('Submitted successfully!');
      context.pushNamed('/success');
    } else {
      context.showError('Validation Failed', 'Please check your inputs');
    }
  }

  bool validateForm() {
    // validation logic
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.isKeyboardVisible 
          ? context.keyboardHeight 
          : 0,
      ),
      child: Column(
        children: [
          TextField(),
          ElevatedButton(
            onPressed: submitForm,
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

### Complete List

```dart
// Screen
context.screenWidth
context.screenHeight
context.screenSize
context.isPortrait
context.isLandscape
context.isTablet
context.isSmallScreen
context.aspectRatio

// Keyboard
context.isKeyboardVisible
context.keyboardHeight
context.bottomInset

// Theme
context.theme
context.isDarkMode
context.colorScheme
context.primaryColor
context.backgroundColor
context.textTheme

// Navigation
context.pop()
context.pushNamed(route)
context.pushNamedAndRemoveUntil(route, predicate)
context.maybePop()

// Notifications
context.showSnackBar(message)
context.showMessage(title, message)
context.showError(title, message)
context.showSuccess(title, message)
context.showToast(message)
```

---

## 🔌 Dio Options Extensions

### DioOptionsX Extensions

```dart
// Create new Options with custom timeout
final options = Options()
  .withTimeout(
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 60),
  );

// Add Bearer token
final authOptions = options
  .withBearerToken('access_token');

// Add custom headers
final headerOptions = authOptions
  .withHeaders({'X-Custom': 'value'});

// Set content type
final contentOptions = headerOptions
  .withContentType('application/json');

// Merge with another Options
final merged = options.mergeWith(Options(
  extra: {'timeout': 60},
));

// Accept all status codes
final relaxedOptions = options
  .acceptAllStatusCodes();
```

### ResponseX Extensions

```dart
final response = await httpClient.get('/users');

// Check if successful (2xx)
if (response.isSuccessful) {
  // Process data
}

// Get data as Map
final userMap = response.dataAsMap;
if (userMap != null) {
  String name = userMap['name'];
}

// Get data as List
final userList = response.dataAsList;
if (userList != null) {
  for (var user in userList) {
    print(user['name']);
  }
}

// Get nested value by path
String? email = response.getValueByPath<String>('user.profile.email');
int? age = response.getValueByPath<int>('user.profile.age');
List<String>? tags = response.getValueByPath<List<String>>('tags');
```

### Usage Example

```dart
class UserAdapter {
  final httpClient = GetIt.I<HttpClient>();

  Future<User> getUser(String id) async {
    try {
      final response = await httpClient.get(
        '/users/$id',
        options: Options()
          .withTimeout(Duration(seconds: 60))
          .withHeaders({'Accept': 'application/json'}),
      );

      if (response.isSuccessful) {
        final userData = response.dataAsMap;
        return User.fromJson(userData!);
      }

      throw Exception('Failed to load user');
    } on AppException catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final response = await httpClient.get(
        '/users',
        options: Options().withTimeout(Duration(seconds: 30)),
      );

      if (response.isSuccessful) {
        final users = response.dataAsList;
        return users!
          .map((json) => User.fromJson(json))
          .toList();
      }

      throw Exception('Failed to load users');
    } on AppException catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getConfig() async {
    try {
      final response = await httpClient.get('/config');

      if (response.isSuccessful) {
        // Get nested value safely
        String? apiUrl = response.getValueByPath<String>('api.url');
        int? timeout = response.getValueByPath<int>('api.timeout');
        
        return {
          'api_url': apiUrl,
          'timeout': timeout,
        };
      }

      return null;
    } on AppException catch (e) {
      rethrow;
    }
  }
}
```

---

## ⏱️ Debouncer Utility

```dart
class Debouncer {
  final Duration delay;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.delay});

  void call(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void cancel() => _timer?.cancel();
}

// Usage in SearchField
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final _debouncer = Debouncer(delay: Duration(milliseconds: 500));

  SearchBloc() : super(SearchInitial()) {
    on<SearchQueryChangedEvent>((event, emit) {
      _debouncer(() {
        // This executes only after user stops typing for 500ms
        add(PerformSearchEvent(event.query));
      });
    });

    on<PerformSearchEvent>((event, emit) async {
      // Actual search logic
      emit(SearchLoading());
      try {
        final results = await searchAdapter.search(event.query);
        emit(SearchSuccess(results));
      } on AppException catch (e) {
        emit(SearchError(e.message));
      }
    });
  }

  @override
  Future<void> close() {
    _debouncer.cancel();
    return super.close();
  }
}
```

---

## 📋 AppLogger Utility

```dart
class AppLogger {
  static void debug(String message) {
    // Log debug message
  }

  static void info(String message) {
    // Log info message
  }

  static void warning(String message) {
    // Log warning
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    // Log error with stack trace
  }
}

// Usage
AppLogger.info('User logged in');
AppLogger.warning('Token expiring soon');
AppLogger.error('Failed to load users', exception, stackTrace);
```

---

## 🔗 Mối Liên Kết Với Các Module Khác

```
Helpers Module
├── String Extensions
│   ├─ Used by: Project validators, formatters
│   ├─ Used by: Error message processing
│   └─ Example: email.isValidEmail
│
├── Context Extensions
│   ├─ Used by: UI widgets, screens
│   ├─ Used by: Responsive layouts
│   ├─ Used by: Notification handling
│   └─ Example: context.showError('Failed', e.message)
│
├── Dio Options Extensions
│   ├─ Used by: Project Adapter layer
│   ├─ Used by: Interceptors [HTTP]
│   └─ Example: Options().withBearerToken(token)
│
├── Debouncer
│   ├─ Used by: Search BLoCs
│   ├─ Used by: Text input handlers
│   └─ Example: _debouncer(() => search())
│
└── AppLogger
    ├─ Used by: Interceptors [HTTP]
    ├─ Used by: Project service layer
    └─ Example: AppLogger.error('API failed', error)
```

---

## 💻 Complete Integration Example

```dart
// main.dart
void main() async {
  // Initialize storage & DI
  final tokenStorage = DefaultTokenStorage(
    appStorage: AppSharedPreferences(),
  );
  await tokenStorage.initialize();

  setupAppCoreDI(
    baseUrl: 'https://api.example.com',
    tokenStorage: tokenStorage,
    authHandler: MyAuthHandler(),
  );

  runApp(MyApp());
}

// User adapter using extensions
class UserAdapter {
  final httpClient = GetIt.I<HttpClient>();

  Future<List<User>> getUsers() async {
    try {
      final response = await httpClient.get('/users');
      
      if (response.isSuccessful) {
        final users = response.dataAsList;
        return users!.map((json) => User.fromJson(json)).toList();
      }

      throw Exception('Failed to load');
    } on ValidationException catch (e) {
      AppLogger.error('Validation error', e);
      rethrow;
    }
  }
}

// Search field using debouncer
class SearchField extends StatefulWidget {
  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _debouncer = Debouncer(delay: Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (query) {
        if (query.isBlank) {
          context.showMessage('Empty', 'Enter search term');
          return;
        }

        _debouncer(() {
          // Perform search
        });
      },
    );
  }

  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }
}

// Responsive widget using context extensions
class UserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.isTablet ? 24 : 16),
      child: context.isPortrait
        ? UserListPortrait()
        : UserListLandscape(),
    );
  }
}

// Error handling using string extensions
class ErrorWidget extends StatelessWidget {
  final String message;

  const ErrorWidget(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          // Truncate long error messages
          Text(message.limitLength(100)),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
```

---

## 🧪 Testing

```dart
test('String.isValidEmail validates emails correctly', () {
  expect('test@gmail.com'.isValidEmail, true);
  expect('invalid.email'.isValidEmail, false);
  expect('test@domain.co.uk'.isValidEmail, true);
});

test('String.limitLength truncates correctly', () {
  expect('hello world'.limitLength(5), 'hello...');
  expect('hello'.limitLength(10), 'hello');
  expect('hello world'.limitLength(5, '→'), 'hello→');
});

test('Response.isSuccessful checks status code', () {
  final success = Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
  );
  final error = Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 404,
  );

  expect(success.isSuccessful, true);
  expect(error.isSuccessful, false);
});

test('Debouncer delays action execution', () async {
  int callCount = 0;
  final debouncer = Debouncer(delay: Duration(milliseconds: 100));

  debouncer(() => callCount++);
  debouncer(() => callCount++);
  debouncer(() => callCount++);

  expect(callCount, 0);

  await Future.delayed(Duration(milliseconds: 150));
  expect(callCount, 1);  // Only last call executed
});
```

---

**See Also**:
- [HTTP Module](./HTTP.md) - Uses Dio extensions
- [Integration Guide](./INTEGRATION.md) - Using helpers in project
