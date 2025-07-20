part of 'user_profile_cubit.dart';

/// Base class for all user profile states.
abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object> get props => [];
}

/// Initial state before any profile action.
class UserProfileInitial extends UserProfileState {}

/// State when a profile operation is in progress.
class UserProfileLoading extends UserProfileState {}

/// State when a profile operation is successful.
class UserProfileSuccess extends UserProfileState {}

/// State when a profile operation fails.
class UserProfileError extends UserProfileState {
  final String message;

  /// [message] describes the error.
  const UserProfileError(this.message);

  @override
  List<Object> get props => [message];
}

/// State when a profile is loaded successfully.
class UserProfileLoaded extends UserProfileState {
  final UserProfileModel profile;
  const UserProfileLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}
