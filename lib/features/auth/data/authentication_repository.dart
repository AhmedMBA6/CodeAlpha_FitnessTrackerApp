import 'package:firebase_auth/firebase_auth.dart';

/// Repository for handling authentication logic using FirebaseAuth.
class AuthenticationRepository {
  final FirebaseAuth _auth;

  /// Creates an [AuthenticationRepository].
  /// Optionally accepts a [FirebaseAuth] instance for testing/mocking.
  AuthenticationRepository({FirebaseAuth? firebaseAuth}) : _auth = firebaseAuth ?? FirebaseAuth.instance;

  /// Signs in a user with email and password.
  /// Throws a string error message on failure.
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw "Authentication failed: ${e.message}";
    } catch (e) {
      throw "Something went wrong, please try again";
    }
  }

  /// Registers a user with email and password.
  /// Throws a string error message on failure.
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw "Registration failed: ${e.message}";
    } catch (e) {
      throw 'Something went wrong, Please try again';
    }
  }

  /// Signs out the current user.
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
