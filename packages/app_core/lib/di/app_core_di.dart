import 'package:app_core/app_core.dart';

/// Setup app_core dependencies in GetIt
/// Call this once in main() before app initialization
///
/// Usage Example:
/// ```dart
/// void main() async {
///   // Initialize storage
///   final tokenStorage = DefaultTokenStorage(
///     appStorage: AppSharedPreferences(),
///   );
///   await tokenStorage.initialize();
///
///   // Setup DI
///   setupAppCoreDI(
///     baseUrl: 'https://api.example.com',
///     tokenStorage: tokenStorage,
///     authHandler: MyAuthHandler(),
///     addLoggingInterceptor: true,     // Optional
///   );
///
///   runApp(MyApp());
/// }
///
/// // Later in any layer, access HttpClient
/// final httpClient = GetIt.I<HttpClient>();
/// final tokenStorage = GetIt.I<TokenStorage>();
/// ```
void setupAppCoreDI({
  required String baseUrl,
  required TokenStorage tokenStorage,
  required AuthEventHandler authHandler,
  bool addLoggingInterceptor = true,
}) {
  final getIt = GetIt.instance;

  // Register TokenStorage
  getIt.registerSingleton<TokenStorage>(tokenStorage);

  // Register AuthEventHandler
  getIt.registerSingleton<AuthEventHandler>(authHandler);

  // Build Dio with DioClientBuilder
  final dio = DioClientBuilder().setBaseUrl(baseUrl).build();

  // Add AuthInterceptor
  dio.interceptors.add(
    AuthInterceptor(
      tokenStorage: tokenStorage,
      authHandler: authHandler,
    ),
  );

  // Add LoggingInterceptor if needed
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

/// Reset DI (useful for testing)
void resetAppCoreDI() {
  final getIt = GetIt.instance;
  if (getIt.isRegistered<HttpClient>()) {
    getIt.unregister<HttpClient>();
  }
  if (getIt.isRegistered<TokenStorage>()) {
    getIt.unregister<TokenStorage>();
  }
  if (getIt.isRegistered<AuthEventHandler>()) {
    getIt.unregister<AuthEventHandler>();
  }
  if (getIt.isRegistered<Dio>()) {
    getIt.unregister<Dio>();
  }
}
