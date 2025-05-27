import 'package:dartz/dartz.dart';
import 'package:flutter_base/src/core/index.dart';
import 'package:flutter_base/src/features/auth/auth_index.dart';
import 'package:flutter_base/src/features/auth/domain/entities/authenticate.dart';

abstract class AuthRepository {
  Future<Either<Failure, Authenticate>> login(String email, String password);
}
