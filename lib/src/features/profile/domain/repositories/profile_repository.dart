import 'package:flutter_base/src/core/index.dart';

/// Profile repository interface
/// Defines all profile-related operations
abstract class ProfileRepository {
  /// Get current user profile
  /// Throws: [AppException] on error
  Future<User> getUserProfile();
}
