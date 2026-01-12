import 'package:flutter_base/src/features/auth/auth_index.dart';

abstract class AuthRepository {
  /// Login with email and password
  /// Throws: [AppException] on error
  Future<Authenticate> login(String email, String password);
}
