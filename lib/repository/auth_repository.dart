import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<AuthState> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) {
        return AuthState.unauthenticated;
      }
      return AuthState.authenticated;
    });
  }

  User? get currentUser => _auth.currentUser;

  bool get isAuthenticated => _auth.currentUser != null;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<({bool success, String? error})> register({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.sendEmailVerification();
        return (success: true, error: null);
      }
      return (success: false, error: 'Registration failed');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
        default:
          message = e.message ?? 'Registration failed';
      }
      return (success: false, error: message);
    } catch (e) {
      return (success: false, error: e.toString());
    }
  }

  Future<({bool success, String? error})> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return (success: true, error: null);
      }
      return (success: false, error: 'Login failed');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'wrong-password':
          message = 'Wrong password';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        default:
          message = e.message ?? 'Login failed';
      }
      return (success: false, error: message);
    } catch (e) {
      return (success: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<({bool success, String? error})> resetPassword({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return (success: true, error: null);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = e.message ?? 'Failed to send reset email';
      }
      return (success: false, error: message);
    } catch (e) {
      return (success: false, error: e.toString());
    }
  }
}
