import 'package:dartz/dartz.dart';
import 'package:flutter_base/src/core/index.dart';
import 'package:flutter_base/src/features/auth/auth_index.dart';

class LoginUsecase {
  final AuthRepository _authRepository;

  LoginUsecase(this._authRepository);

  Future<Either<Failure, Authenticate>> call({
    required String email,
    required String password,
  }) async {
    return _authRepository.login(email, password);
  }
}
