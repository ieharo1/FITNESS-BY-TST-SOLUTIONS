import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../repository/auth_repository.dart';
import '../../repository/user_repository.dart';
import '../../model/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();

  AuthState _authState = AuthState.initial;
  String? _errorMessage;
  StreamSubscription? _authSubscription;

  AuthState get authState => _authState;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authRepository.isAuthenticated;
  String? get currentUserId => _authRepository.currentUserId;
  dynamic get currentUser => _authRepository.currentUser;

  AuthViewModel() {
    _authSubscription = _authRepository.authStateChanges.listen((state) {
      _authState = state;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _authState = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.register(
      email: email,
      password: password,
    );

    if (result.success && _authRepository.currentUserId != null) {
      final user = UserModel(
        id: _authRepository.currentUserId!,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
      await _userRepository.createUser(user);
      _authState = AuthState.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.error;
      _authState = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _authState = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    if (result.success) {
      _authState = AuthState.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.error;
      _authState = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _authState = AuthState.unauthenticated;
    notifyListeners();
  }

  Future<bool> resetPassword({required String email}) async {
    _errorMessage = null;
    final result = await _authRepository.resetPassword(email: email);
    if (!result.success) {
      _errorMessage = result.error;
      notifyListeners();
    }
    return result.success;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
