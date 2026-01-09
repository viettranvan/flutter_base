import 'package:app_core/app_core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_base/src/core/network/exceptions.dart';
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
    } on ApiException catch (e) {
      appLogger.e('API Error: ${e.message} (Status: ${e.statusCode})');
      emit(UsersError(message: 'API Error: ${e.message}'));
    } on DioNetworkException catch (e) {
      appLogger.e('Network Error: ${e.message}');
      emit(UsersError(message: 'Network Error: ${e.message}'));
    } on ParsingException catch (e) {
      appLogger.e('Parsing Error: ${e.message}');
      emit(UsersError(message: 'Failed to parse user data'));
    } catch (e) {
      appLogger.e('Unexpected Error', error: e);
      emit(UsersError(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}
