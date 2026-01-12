import 'package:app_core/app_core.dart';
import 'package:flutter_base/src/features/auth/auth_index.dart';
import 'package:flutter_base/src/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:flutter_base/src/injection_container.dart';

/// Dependency management for Auth feature
///
/// This class handles all dependency registration for the Auth feature.
/// It's designed to be extensible for adding new pages and features.
class AuthDependencies {
  static final GetIt _sl = GetIt.instance;

  /// Register all dependencies for the Auth feature
  /// Call this in your main setup or when configuring the auth feature
  static void registerDependencies() {
    _registerDataSources();
    _registerRepositories();
    _registerUseCases();
    _registerBlocs();
  }

  /// Register all data sources
  /// Uses authClient for public/external APIs
  static void _registerDataSources() {
    _sl.registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasource(
        _sl<HttpClient>(instanceName: HttpClientNames.authClient),
      ),
    );
  }

  /// Register all repositories
  static void _registerRepositories() {
    _sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(_sl()));
  }

  /// Register all use cases
  static void _registerUseCases() {
    _sl.registerLazySingleton(() => LoginUsecase(_sl()));
  }

  /// Register all blocs
  static void _registerBlocs() {
    _sl.registerFactory(() => LoginBloc(_sl(), appStorage));
  }
}
