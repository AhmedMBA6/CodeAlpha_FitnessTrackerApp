import 'package:codealpha_fitness_tracker_app/features/auth/data/authentication_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';

/// Cubit for managing authentication state and actions.
class AuthCubit extends Cubit<AuthState> {
  final AuthenticationRepository _authenticationRepository;

  /// Creates an [AuthCubit] with the given [AuthenticationRepository].
  AuthCubit(this._authenticationRepository) : super(AuthInitial()) {
    _authenticationRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  /// Attempts to log in with the provided [email] and [password].
  Future<void> emitLoginState(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await _authenticationRepository.loginWithEmailAndPassword(
        email,
        password,
      );
      emit(AuthSuccess(user!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Attempts to sign up with the provided [email] and [password].
  Future<void> emitSignUpState(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await _authenticationRepository.signUpWithEmailAndPassword(
        email,
        password,
      );
      emit(AuthSuccess(user!, isNewUser: true));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Logs out the current user.
  Future<void> emitLogoutState() async {
    await _authenticationRepository.logout();
    emit(AuthUnauthenticated());
  }
}
