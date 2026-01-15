import 'package:flutter_base/src/core/index.dart';
import 'package:flutter_base/src/features/profile/profile_index.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> getUserProfile() async {
    // ✅ Datasource already handles exceptions
    // Just transform model to entity
    final userModel = await remoteDataSource.getUserProfile();
    return userModel.toEntity();
  }
}
