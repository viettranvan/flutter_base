import 'package:app_core/app_core.dart';
import 'package:flutter_base/src/features/profile/profile_index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc for managing profile feature
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;

  ProfileBloc({required this.getUserProfileUseCase})
    : super(const ProfileInitial()) {
    on<FetchUserProfileEvent>(_onFetchUserProfile);
    on<RefreshUserProfileEvent>(_onRefreshUserProfile);
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
}
