import 'package:flutter_base/src/features/auth/auth_index.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<Authenticate> login(String email, String password) async {
    // ✅ Datasource đã handle exceptions
    // Just transform model to entity
    final userModel = await datasource.login(email, password);
    return userModel.toEntity();
  }
}
