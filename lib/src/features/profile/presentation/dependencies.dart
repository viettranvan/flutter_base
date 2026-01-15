import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/src/features/profile/profile_index.dart';
import 'package:flutter_base/src/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Dependency management for Profile feature
///
/// This class handles all dependency registration for the Profile feature.
class ProfileDependencies {
  static final GetIt _sl = GetIt.instance;

  /// Register all dependencies for the Profile feature
  static void registerDependencies() {
    _registerDataSources();
    _registerRepositories();
    _registerUseCases();
    _registerBlocs();
  }

  /// Register all data sources
  static void _registerDataSources() {
    _sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(
        httpClient: _sl<HttpClient>(instanceName: HttpClientNames.authClient),
      ),
    );
  }

  /// Register all repositories
  static void _registerRepositories() {
    _sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remoteDataSource: _sl()),
    );
  }

  /// Register all use cases
  static void _registerUseCases() {
    _sl.registerLazySingleton(() => GetUserProfileUseCase(repository: _sl()));
  }

  /// Register all blocs
  static void _registerBlocs() {
    _sl.registerFactory(() => ProfileBloc(getUserProfileUseCase: _sl()));
  }

  /// Build the Profile page with all necessary providers
  static Widget buildProfilePage() {
    final profileBloc = _sl<ProfileBloc>();

    return BlocProvider.value(
      value: profileBloc..add(const FetchUserProfileEvent()),
      child: const ProfilePage(),
    );
  }
}
