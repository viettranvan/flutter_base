import 'package:app_core/app_core.dart';
import 'package:flutter/foundation.dart';

/// Application core configuration
/// Determines logging behavior based on environment and build mode
class AppCoreConfig {
  /// Environment name: 'dev', 'staging', or 'production'
  final String environment;

  /// Whether running in debug mode (kDebugMode)
  final bool isDebugMode;

  /// Custom logging override (if null, uses default logic)
  final bool? loggingOverride;

  const AppCoreConfig({
    required this.environment,
    required this.isDebugMode,
    this.loggingOverride,
  });

  /// Determine if logging interceptor should be added
  /// Logic: Always log except in production
  /// Dev/Staging: Always log (debug/test)
  /// Production: Never log (security & performance)
  bool get shouldLogRequests {
    // If explicitly set, use override
    if (loggingOverride != null) return loggingOverride!;

    // Always log in debug mode
    if (isDebugMode) return true;

    // In release mode: log for dev and staging, never for production
    return environment.toLowerCase() != 'production';
  }

  /// Convenient factory constructors for common use cases
  factory AppCoreConfig.development() => AppCoreConfig(
        environment: 'development',
        isDebugMode: kDebugMode,
      );

  factory AppCoreConfig.staging() => AppCoreConfig(
        environment: 'staging',
        isDebugMode: kDebugMode,
      );

  factory AppCoreConfig.production() => AppCoreConfig(
        environment: 'production',
        isDebugMode: false,
        loggingOverride: false, // Explicitly disable logging
      );
}

/// Configuration for HTTP client registration
class HttpClientConfig {
  final String baseUrl;
  final TokenStorage? tokenStorage;
  final AuthEventHandler? authHandler;
  final bool addLoggingInterceptor;
  final List<Interceptor> customInterceptors;

  const HttpClientConfig({
    required this.baseUrl,
    this.tokenStorage,
    this.authHandler,
    this.addLoggingInterceptor = false,
    this.customInterceptors = const [],
  });
}

/// Setup app_core dependencies in GetIt with support for multiple HTTP clients
/// Call this once in main() before app initialization
///
/// Usage Example 1: Single client with auth and dynamic logging
/// ```dart
/// void main() async {
///   final tokenStorage = DefaultTokenStorage(
///     appStorage: AppSharedPreferences(),
///   );
///   await tokenStorage.initialize();
///
///   setupAppCoreDI(
///     coreConfig: AppCoreConfig(
///       environment: EnvConfig.getEnvironment(),
///       isDebugMode: kDebugMode,
///     ),
///     baseUrl: 'https://api.example.com',
///     tokenStorage: tokenStorage,
///     authHandler: MyAuthHandler(),
///   );
///
///   runApp(MyApp());
/// }
/// ```
///
/// Usage Example 2: Multiple clients with different configs
/// ```dart
/// registerHttpClient(
///   name: 'api_main',
///   coreConfig: coreConfig,
///   config: HttpClientConfig(
///     baseUrl: 'https://api.example.com',
///     tokenStorage: tokenStorage,
///     authHandler: authHandler,
///   ),
/// );
///
/// registerHttpClient(
///   name: 'api_public',
///   coreConfig: coreConfig,
///   config: HttpClientConfig(
///     baseUrl: 'https://public-api.example.com',
///   ),
/// );
///
/// // Access clients
/// final mainClient = GetIt.I<HttpClient>(instanceName: 'api_main');
/// final publicClient = GetIt.I<HttpClient>(instanceName: 'api_public');
/// ```
void setupAppCoreDI({
  required AppCoreConfig coreConfig,
  required String baseUrl,
  TokenStorage? tokenStorage,
  AuthEventHandler? authHandler,
}) {
  final getIt = GetIt.instance;

  // Register AppCoreConfig
  if (!getIt.isRegistered<AppCoreConfig>()) {
    getIt.registerSingleton<AppCoreConfig>(coreConfig);
  }

  // Register TokenStorage if provided
  if (tokenStorage != null) {
    if (!getIt.isRegistered<TokenStorage>()) {
      getIt.registerSingleton<TokenStorage>(tokenStorage);
    }
  }

  // Register AuthEventHandler if provided
  if (authHandler != null) {
    if (!getIt.isRegistered<AuthEventHandler>()) {
      getIt.registerSingleton<AuthEventHandler>(authHandler);
    }
  }

  final config = HttpClientConfig(
    baseUrl: baseUrl,
    tokenStorage: tokenStorage,
    authHandler: authHandler,
    addLoggingInterceptor: coreConfig.shouldLogRequests,
  );

  _registerHttpClient(getIt: getIt, name: null, config: config);
}

/// Register a named HTTP client with custom configuration
/// Allows registering multiple clients with different base URLs or interceptors
void registerHttpClient({
  required String name,
  required AppCoreConfig coreConfig,
  required HttpClientConfig config,
}) {
  final getIt = GetIt.instance;

  // Create config with logging based on AppCoreConfig
  final configWithLogging = HttpClientConfig(
    baseUrl: config.baseUrl,
    tokenStorage: config.tokenStorage,
    authHandler: config.authHandler,
    addLoggingInterceptor:
        config.addLoggingInterceptor || coreConfig.shouldLogRequests,
    customInterceptors: config.customInterceptors,
  );

  // Register TokenStorage if provided and not already registered
  if (configWithLogging.tokenStorage != null) {
    if (!getIt.isRegistered<TokenStorage>(instanceName: name)) {
      getIt.registerSingleton<TokenStorage>(
        configWithLogging.tokenStorage!,
        instanceName: '${name}_tokenStorage',
      );
    }
  }

  // Register AuthEventHandler if provided and not already registered
  if (configWithLogging.authHandler != null) {
    if (!getIt.isRegistered<AuthEventHandler>(instanceName: name)) {
      getIt.registerSingleton<AuthEventHandler>(
        configWithLogging.authHandler!,
        instanceName: '${name}_authHandler',
      );
    }
  }

  _registerHttpClient(getIt: getIt, name: name, config: configWithLogging);
}

/// Internal method to register HTTP client with Dio and interceptors
void _registerHttpClient({
  required GetIt getIt,
  required String? name,
  required HttpClientConfig config,
}) {
  // Build Dio instance
  final dio = DioClientBuilder().setBaseUrl(config.baseUrl).build();

  // Add AuthInterceptor if both tokenStorage and authHandler are provided
  if (config.tokenStorage != null && config.authHandler != null) {
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: config.tokenStorage!,
        authHandler: config.authHandler!,
      ),
    );
  }

  // Add custom interceptors
  for (final interceptor in config.customInterceptors) {
    dio.interceptors.add(interceptor);
  }

  // Add LoggingInterceptor if enabled
  if (config.addLoggingInterceptor) {
    dio.interceptors.add(
      LoggingInterceptor(
        responseBody: true,
        compact: true,
      ),
    );
  }

  // Register HttpClient
  if (name != null) {
    getIt.registerSingleton<HttpClient>(
      DioHttpClient(dioInstance: dio),
      instanceName: name,
    );
    // Register Dio instance with same name for advanced usage
    getIt.registerSingleton<Dio>(dio, instanceName: name);
  } else {
    getIt.registerSingleton<HttpClient>(DioHttpClient(dioInstance: dio));
    getIt.registerSingleton<Dio>(dio);
  }
}

/// Reset all DI registrations (useful for testing)
void resetAppCoreDI() {
  final getIt = GetIt.instance;
  getIt.reset();
}
