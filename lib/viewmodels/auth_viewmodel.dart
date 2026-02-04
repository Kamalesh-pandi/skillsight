import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<User?> get userStream => _authService.user;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.signInWithEmail(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      print('DEBUG: Login Error: $e');
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.registerWithEmail(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      print('DEBUG: Register Error: $e');
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) {
        _setLoading(false);
        return false; // User cancelled
      }
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e);
      _setLoading(false);
      return false;
    } on PlatformException catch (e) {
      print('DEBUG: Google Sign-In Platform Error: ${e.code}, ${e.message}');
      _errorMessage = 'Google Sign-In failed (Code ${e.code}): ${e.message}';
      _setLoading(false);
      return false;
    } catch (e) {
      print('DEBUG: Google Sign-In Error: $e');
      _errorMessage = 'An unexpected error occurred during Google Sign-In: $e';
      _setLoading(false);
      return false;
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'operation-not-allowed':
        return 'Authentication method not enabled.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
