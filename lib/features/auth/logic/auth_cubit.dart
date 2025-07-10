import 'package:codealpha_fitness_tracker_app/features/auth/data/authentication_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthenticationRepository _authenticationRepository;
  AuthCubit(this._authenticationRepository) : super(AuthInitial()) {
    _authenticationRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

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

  Future<void> emitLogoutState() async {
    await _authenticationRepository.logout();
    emit(AuthUnauthenticated());
  }
}
