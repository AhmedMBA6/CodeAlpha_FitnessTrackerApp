import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationRepository {
  final _auth = FirebaseAuth.instance;

  /// [Email Authentication] - Sign-in
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
      throw "Somthing went wrong, please try again";
    }
  }

  /// [Email Authentication] - Sign-up
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
      throw 'Somthing went wrong, Please try again';
    }
  }

  /// [Logout User]
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Listen to auth state changes (for splash or wrapper)
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
