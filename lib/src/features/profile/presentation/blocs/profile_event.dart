import 'package:equatable/equatable.dart';

/// Events for ProfileBloc
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch user profile
class FetchUserProfileEvent extends ProfileEvent {
  const FetchUserProfileEvent();
}

/// Event to refresh user profile
class RefreshUserProfileEvent extends ProfileEvent {
  const RefreshUserProfileEvent();
}
