import 'package:app_core/app_core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_base/src/error_handler.dart';
import 'package:flutter_base/src/features/home/domain/entities/user.dart';
import 'package:flutter_base/src/features/home/domain/usecases/get_users_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUsersUseCase getUsersUseCase;

  UsersBloc({required this.getUsersUseCase}) : super(const UsersInitial()) {
    on<FetchUsersEvent>(_onFetchUsers);
  }

  Future<void> _onFetchUsers(
    FetchUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(const UsersLoading());
    try {
      appLogger.d('Fetching users...');
      final users = await getUsersUseCase.call();
      appLogger.i('Successfully loaded ${users.length} users');
      emit(UsersLoaded(users: users));
    } on AppException catch (e) {
      appLogger.e('App Error: ${e.message}');
      GlobalErrorHandler.handle(e);
      emit(UsersError(message: e.message));
    } catch (e) {
      appLogger.e('Unexpected Error', error: e);
      emit(UsersError(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}
