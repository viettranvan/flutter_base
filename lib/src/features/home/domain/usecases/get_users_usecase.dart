import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class GetUsersUseCase {
  final UserRepository repository;

  GetUsersUseCase({required this.repository});

  Future<List<User>> call() async {
    return await repository.getUsers();
  }
}
