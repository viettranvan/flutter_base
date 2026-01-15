import 'package:app_core/app_core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_base/src/core/index.dart';

/// States for ProfileBloc
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading state while fetching profile
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Success state with user profile data
class ProfileLoaded extends ProfileState {
  final User userProfile;

  const ProfileLoaded({required this.userProfile});

  @override
  List<Object?> get props => [userProfile];
}

/// Error state
class ProfileError extends ProfileState {
  final AppException exception;

  const ProfileError({required this.exception});

  @override
  List<Object?> get props => [exception];
}

/// Success state when logout is completed
class LogoutSuccess extends ProfileState {
  const LogoutSuccess();
}

/// Error state when logout fails
class LogoutError extends ProfileState {
  final String error;

  const LogoutError({required this.error});

  @override
  List<Object?> get props => [error];
}
