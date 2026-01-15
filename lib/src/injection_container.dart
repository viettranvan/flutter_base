import 'package:app_core/app_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_base/src/auth_handler.dart';
import 'package:flutter_base/src/core/index.dart';
import 'package:flutter_base/src/features/auth/dependencies.dart';
import 'package:flutter_base/src/features/home/presentation/dependencies.dart';
import 'package:flutter_base/src/features/profile/presentation/dependencies.dart';

final sl = GetIt.instance;

/// Named instances for different HTTP clients
/// Use these names when registering/retrieving different HttpClients
class HttpClientNames {
  static const String appClient = 'app_client'; // Main app API
  static const String authClient = 'auth_client'; // Auth/Public APIs
}

Future<void> setup() async {
  // await dotenv.load();

  // Initialize TokenStorage before registering HTTP clients
  final tokenStorage = DefaultTokenStorage(appStorage);
  await tokenStorage.initialize();

  // Create AppCoreConfig based on environment and build mode
  final coreConfig = AppCoreConfig(
    environment: EnvConfig.getEnvironment(),
    isDebugMode: kDebugMode,
  );

  // Initialize file logging with environment-based configuration
  await initFileLogging(coreConfig: coreConfig);

  // Register named HTTP clients
  _registerHttpClients(coreConfig, tokenStorage);

  // Feature injections
  AuthDependencies.registerDependencies();
  HomeDependencies.registerDependencies();
  ProfileDependencies.registerDependencies();
}

/// Register all HTTP client instances with their respective base URLs
/// Uses the app_core DI utilities for cleaner configuration
/// Logging is automatically determined by AppCoreConfig based on environment and build mode
void _registerHttpClients(AppCoreConfig coreConfig, TokenStorage tokenStorage) {
  // Main App Client - with authentication
  registerHttpClient(
    name: HttpClientNames.appClient,
    coreConfig: coreConfig,
    config: HttpClientConfig(
      baseUrl: EnvConfig.getJsonPlaceholderUrl(),
      tokenStorage: tokenStorage,
      authHandler: null, // Set your AuthEventHandler if needed
    ),
  );

  // Auth/Public Client - without authentication
  registerHttpClient(
    name: HttpClientNames.authClient,
    coreConfig: coreConfig,
    config: HttpClientConfig(
      baseUrl: EnvConfig.getDummyJsonUrl(),
      tokenStorage: tokenStorage, // No auth required
      authHandler: AuthHandler(),
    ),
  );
}
