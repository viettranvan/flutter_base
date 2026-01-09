import 'package:app_core/app_core.dart';
import 'package:flutter_base/src/features/auth/auth_index.dart';
import 'package:flutter_base/src/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:flutter_base/src/injection_container.dart';

Future<void> initAuthInjection() async {
  sl
    // Data
    ..registerLazySingleton(() => AuthRemoteDatasource(sl()))
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()))
    // Domain
    ..registerLazySingleton(() => LoginUsecase(sl()))
    // Bloc
    ..registerFactory(() => LoginBloc(sl(), appStorage));
}
