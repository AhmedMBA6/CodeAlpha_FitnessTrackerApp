import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Base class for all authentication states.
abstract class AuthState extends Equatable {
    @override
    List<Object?> get props => [];
}

/// Initial state before any authentication action.
class AuthInitial extends AuthState {}

/// State when authentication is in progress.
class AuthLoading extends AuthState {}

/// State when authentication is successful.
class AuthSuccess extends AuthState {
  final User user;
  final bool isNewUser;

  /// [user] is the authenticated user. [isNewUser] is true if just signed up.
  AuthSuccess(this.user, {this.isNewUser = false});

  @override
  List<Object?> get props => [user];
}

/// State when the user is unauthenticated.
class AuthUnauthenticated extends AuthState {}

/// State when an authentication error occurs.
class AuthError extends AuthState {
  final String message;

  /// [message] describes the error.
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
