// 📁 lib/injection.dart

import 'package:app_core/app_core.dart';
import 'package:flutter_base/src/core/index.dart';
import 'package:flutter_base/src/features/auth/dependencies.dart';
import 'package:flutter_base/src/features/home/presentation/dependencies.dart';

final sl = GetIt.instance;

/// Named instances for different HTTP clients
/// Use these names when registering/retrieving different HttpClients
class HttpClientNames {
  static const String appClient = 'app_client'; // Main app API
  static const String authClient = 'auth_client'; // Auth/Public APIs
}

Future<void> setup() async {
  // await dotenv.load();

  // Register named HTTP clients
  _registerHttpClients();

  // Feature injections
  AuthDependencies.registerDependencies();
  HomeDependencies.registerDependencies();
}

/// Register all HTTP client instances with their respective base URLs
void _registerHttpClients() {
  // Main App Client - for main API
  final appDioInstance = DioClientBuilder()
      .setBaseUrl(EnvConfig.getJsonPlaceholderUrl()) // Your main API
      .build();

  // Auth/Public Client - for public APIs like reqres.in
  final authDioInstance = DioClientBuilder()
      .setBaseUrl(EnvConfig.getDummyJsonUrl()) // Public API
      .build();

  // Add interceptors to main client
  final tokenStorage = DefaultTokenStorage(appStorage);
  appDioInstance.interceptors.add(AuthInterceptor(tokenStorage: tokenStorage));

  // Register with names
  sl.registerLazySingleton<Dio>(
    () => appDioInstance,
    instanceName: HttpClientNames.appClient,
  );

  sl.registerLazySingleton<Dio>(
    () => authDioInstance,
    instanceName: HttpClientNames.authClient,
  );

  // Register HttpClient wrappers
  sl.registerLazySingleton<HttpClient>(
    () => DioHttpClient(dioInstance: appDioInstance),
    instanceName: HttpClientNames.appClient,
  );

  sl.registerLazySingleton<HttpClient>(
    () => DioHttpClient(dioInstance: authDioInstance),
    instanceName: HttpClientNames.authClient,
  );
}
