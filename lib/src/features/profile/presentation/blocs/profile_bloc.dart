import 'package:app_core/app_core.dart';
import 'package:flutter_base/src/features/profile/profile_index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc for managing profile feature
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final TokenStorage tokenStorage;

  ProfileBloc({required this.getUserProfileUseCase, required this.tokenStorage})
    : super(const ProfileInitial()) {
    on<FetchUserProfileEvent>(_onFetchUserProfile);
    on<RefreshUserProfileEvent>(_onRefreshUserProfile);
    on<LogoutEvent>(_onLogout);
  }

  /// Handle fetch user profile event
  Future<void> _onFetchUserProfile(
    FetchUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    try {
      final userProfile = await getUserProfileUseCase();
      emit(ProfileLoaded(userProfile: userProfile));
    } on AppException catch (e) {
      emit(ProfileError(exception: e));
    } catch (e) {
      emit(
        ProfileError(
          exception: GenericException(
            message: 'Unexpected error: ${e.toString()}',
          ),
        ),
      );
    }
  }

  /// Handle refresh user profile event
  Future<void> _onRefreshUserProfile(
    RefreshUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    // Don't change to loading if already loaded to maintain UI state
    try {
      final userProfile = await getUserProfileUseCase();
      emit(ProfileLoaded(userProfile: userProfile));
    } on AppException catch (e) {
      emit(ProfileError(exception: e));
    } catch (e) {
      emit(
        ProfileError(
          exception: GenericException(
            message: 'Unexpected error: ${e.toString()}',
          ),
        ),
      );
    }
  }

  /// Handle logout event - clears tokens and emits success/error state
  Future<void> _onLogout(LogoutEvent event, Emitter<ProfileState> emit) async {
    try {
      // Clear tokens from storage
      await tokenStorage.clearTokens();

      // Emit success state - UI will navigate to login
      emit(const LogoutSuccess());
    } catch (e) {
      emit(LogoutError(error: e.toString()));
    }
  }
}
