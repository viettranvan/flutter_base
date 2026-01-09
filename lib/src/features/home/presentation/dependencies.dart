import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/src/features/home/data/datasources/user_remote_datasource.dart';
import 'package:flutter_base/src/features/home/data/repositories/user_repository_impl.dart';
import 'package:flutter_base/src/features/home/domain/usecases/get_users_usecase.dart';
import 'package:flutter_base/src/features/home/presentation/blocs/users/users_bloc.dart';
import 'package:flutter_base/src/features/home/presentation/pages/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class HomeDependencies {
  static Widget setupHome() {
    final sl = GetIt.instance;
    final dio = sl<Dio>();

    final userRemoteDataSource = UserRemoteDataSourceImpl(dio: dio);
    final userRepository = UserRepositoryImpl(
      remoteDataSource: userRemoteDataSource,
    );
    final getUsersUseCase = GetUsersUseCase(repository: userRepository);

    return BlocProvider(
      create: (context) =>
          UsersBloc(getUsersUseCase: getUsersUseCase)
            ..add(const FetchUsersEvent()),
      child: const HomePage(),
    );
  }
}
