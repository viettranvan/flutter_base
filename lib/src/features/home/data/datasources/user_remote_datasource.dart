import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/exceptions.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getUsers();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await dio.get(ApiEndpoints.users);

      // Check if response is successful (2xx status code)
      if (response.statusCode == null || response.statusCode! ~/ 100 != 2) {
        throw ApiException(
          'Failed to fetch users',
          statusCode: response.statusCode,
        );
      }

      // Validate and parse response data
      final data = response.data;
      if (data is! List) {
        throw ParsingException(
          'Invalid response format',
          originalException: data,
        );
      }

      final users = data.map((json) {
        if (json is! Map<String, dynamic>) {
          throw ParsingException(
            'Invalid user object format',
            originalException: json,
          );
        }
        return UserModel.fromJson(json);
      }).toList();

      return users;
    } on DioException catch (e) {
      throw DioNetworkException(
        'Network error: ${e.message}',
        originalException: e,
      );
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ParsingException(
        'Unexpected error: ${e.toString()}',
        originalException: e,
      );
    }
  }
}
