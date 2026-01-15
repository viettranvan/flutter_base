import 'package:app_core/app_core.dart';
import 'package:flutter_base/src/features/profile/profile_index.dart';

/// Remote data source for profile feature
/// Handles all profile-related API calls
abstract class ProfileRemoteDataSource {
  /// Get current user profile
  /// Throws: [ServerException], [GenericException]
  Future<UserModel> getUserProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final HttpClient httpClient;

  ProfileRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<UserModel> getUserProfile() async {
    try {
      final response = await httpClient.get('/auth/me');

      // Validate status code (2xx is success)
      if (response.statusCode == null || response.statusCode! ~/ 100 != 2) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: ServerException(
            message: response.data?['error'] ?? 'Failed to get user profile',
            statusCode: response.statusCode,
          ),
        );
      }

      // Validate response data structure
      if (response.data is! Map<String, dynamic>) {
        throw GenericException(message: 'Invalid profile response format');
      }

      return UserModel.fromJson(response.data);
    } on AppException {
      // Bubble up AppException (ServerException, GenericException, etc.)
      rethrow;
    } catch (e) {
      // Catch all unhandled exceptions
      throw GenericException(message: 'Failed to get profile: ${e.toString()}');
    }
  }
}
