import 'package:dartz/dartz.dart';
import 'package:flutter_base/src/core/index.dart';
import 'package:flutter_base/src/features/auth/auth_index.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, Authenticate>> login(
    String email,
    String password,
  ) async {
    try {
      final userModel = await datasource.login(email, password);
      final auth = userModel.toEntity();

      return Right(auth);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
