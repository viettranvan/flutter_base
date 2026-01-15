import 'package:flutter_base/src/core/index.dart';
import 'package:flutter_base/src/features/profile/profile_index.dart';

/// Use case for getting user profile
class GetUserProfileUseCase {
  final ProfileRepository repository;

  GetUserProfileUseCase({required this.repository});

  /// Call the use case
  /// Throws: [AppException] on error
  Future<User> call() async {
    return await repository.getUserProfile();
  }
}
