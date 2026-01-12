import 'package:app_core/app_core.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getUsers();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final HttpClient httpClient;

  UserRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<List<UserModel>> getUsers() async {
    final response = await httpClient.get(ApiEndpoints.users);

    // Check if response is successful (2xx status code)
    if (response.statusCode == null || response.statusCode! ~/ 100 != 2) {
      throw ServerException(
        message: 'Failed to fetch users',
        statusCode: response.statusCode,
      );
    }

    // Validate and parse response data
    final data = response.data;
    if (data is! List) {
      throw GenericException(message: 'Invalid response format');
    }

    try {
      final users = data.map((json) {
        if (json is! Map<String, dynamic>) {
          throw GenericException(message: 'Invalid user object format');
        }
        return UserModel.fromJson(json);
      }).toList();

      return users;
    } catch (e) {
      // ✅ Nếu là AppException, throw lên (bubble up)
      if (e is AppException) rethrow;
      // Xử lý parsing error (từ UserModel.fromJson)
      throw GenericException(
        message: 'Error parsing user data: ${e.toString()}',
      );
    }
  }
}
