import 'package:app_core/app_core.dart';
import 'package:flutter_base/src/features/auth/auth_index.dart';

abstract class LoginRemoteDatasource {
  Future<UserModel> login(String email, String password);
}

class AuthRemoteDatasource {
  AuthRemoteDatasource(this.httpClient);
  final HttpClient httpClient;

  /// Login using reqres.in public API
  ///
  /// ReqRes API: POST /login
  /// Required fields: email, password
  /// Test credentials:
  /// - email: eve.holt@reqres.in
  /// - password: any value (API doesn't validate)
  ///
  /// Throws: [ServerException], [GenericException]
  Future<AuthenticateModel> login(String userName, String password) async {
    try {
      final response = await httpClient.post(
        '/auth/login',
        data: {'username': userName, 'password': password},
      );

      // Validate status code (2xx is success)
      if (response.statusCode == null || response.statusCode! ~/ 100 != 2) {
        throw ServerException(
          message: response.data?['error'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw GenericException(message: 'Invalid login response format');
      }

      try {
        // Map reqres.in response to AuthenticateModel
        return AuthenticateModel.fromJson({
          'token': data['accessToken'],
          'refresh_token': data['refreshToken'],
          'user': {
            'id': data['id'] ?? 0,
            'full_name': data['username'] ?? '',
            'email': data['email'] ?? '',
            'phone_number': '',
            'created_at': DateTime.now().toString(),
          },
        });
      } catch (e) {
        // Nếu là AppException, throw lên (bubble up)
        if (e is AppException) rethrow;
        // Xử lý parsing error (từ AuthenticateModel.fromJson)
        throw GenericException(
          message: 'Error parsing login response: ${e.toString()}',
        );
      }
    } on AppException {
      // Bubble up AppException (ServerException, GenericException, etc.)
      rethrow;
    } catch (e) {
      // Catch all unhandled exceptions
      throw GenericException(message: 'Login failed: ${e.toString()}');
    }
  }
}
