import 'package:flutter_base/src/features/auth/auth_index.dart';

class LoginUsecase {
  final AuthRepository _authRepository;

  LoginUsecase(this._authRepository);

  /// Login with email and password
  /// Throws: [AppException] on error
  Future<Authenticate> call({
    required String email,
    required String password,
  }) async {
    return _authRepository.login(email, password);
  }
}
