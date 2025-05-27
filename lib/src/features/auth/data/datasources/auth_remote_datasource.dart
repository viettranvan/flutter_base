import 'package:dio/dio.dart';
import 'package:flutter_base/src/features/auth/auth_index.dart';

abstract class LoginRemoteDatasource {
  Future<UserModel> login(String email, String password);
}

class AuthRemoteDatasource {
  AuthRemoteDatasource(this.dio);
  final Dio dio;

  Future<AuthenticateModel> login(String email, String password) async {
    try {
      // Mô phỏng thời gian chờ (API delay)
      await Future.delayed(const Duration(seconds: 1));

      // Dữ liệu mock
      final mockData = {
        "refresh_token": "access-token",
        "token": "refresh-token",
        "user": {
          "id": 10,
          "full_name": "Ryuk Tran",
          "email": "ryuk@handsome.com",
          "phone_number": "+84123123123",
          "created_at": "2025-05-22 10:56:46",
        },
      };

      // Chuyển thành UserModel
      return AuthenticateModel.fromJson(mockData);

      // final response = await dio.post(
      //   '/auth/sign-in',
      //   data: {'email': email, 'password': password},
      // );

      // if (response.statusCode == 200) {
      //   return AuthenticateModel.fromJson(response.data['data']);
      // } else {
      //   throw Exception();
      // }
    } catch (e) {
      rethrow;
    }
  }
}
