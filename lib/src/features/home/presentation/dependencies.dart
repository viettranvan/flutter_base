import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/src/features/home/data/datasources/user_remote_datasource.dart';
import 'package:flutter_base/src/features/home/data/repositories/user_repository_impl.dart';
import 'package:flutter_base/src/features/home/domain/repositories/user_repository.dart';
import 'package:flutter_base/src/features/home/domain/usecases/get_users_usecase.dart';
import 'package:flutter_base/src/features/home/presentation/blocs/users/users_bloc.dart';
import 'package:flutter_base/src/features/home/presentation/pages/index.dart';
import 'package:flutter_base/src/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Dependency management for Home feature
///
/// This class handles all dependency registration and widget setup for the Home feature.
/// It's designed to be extensible for adding new pages and features.
class HomeDependencies {
  static final GetIt _sl = GetIt.instance;

  /// Register all dependencies for the Home feature
  /// Call this in your main setup or when configuring the home feature
  static void registerDependencies() {
    _registerDataSources();
    _registerRepositories();
    _registerUseCases();
    _registerBlocs();
  }

  /// Register all data sources
  static void _registerDataSources() {
    _sl.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(
        httpClient: _sl<HttpClient>(instanceName: HttpClientNames.appClient),
      ),
    );
  }

  /// Register all repositories
  static void _registerRepositories() {
    _sl.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(remoteDataSource: _sl()),
    );
  }

  /// Register all use cases
  static void _registerUseCases() {
    _sl.registerLazySingleton(() => GetUsersUseCase(repository: _sl()));
  }

  /// Register all blocs
  static void _registerBlocs() {
    _sl.registerFactory(() => UsersBloc(getUsersUseCase: _sl()));
  }

  /// Build the Home page with all necessary providers
  static Widget buildHomePage() {
    final usersBloc = _sl<UsersBloc>();

    return BlocProvider.value(
      value: usersBloc..add(const FetchUsersEvent()),
      child: const HomePage(),
    );
  }
}
