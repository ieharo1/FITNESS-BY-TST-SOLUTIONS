import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../repository/user_repository.dart';
import '../../repository/auth_repository.dart';
import '../../model/user_model.dart';

enum ProfileLoadingState { initial, loading, loaded, error, saving }

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final AuthRepository _authRepository = AuthRepository();

  ProfileLoadingState _state = ProfileLoadingState.initial;
  UserModel? _user;
  String? _errorMessage;
  bool _isSaving = false;
  String? _profilePhotoUrl;
  StreamSubscription? _userSubscription;
  String? _currentUserId;

  ProfileLoadingState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;
  String? get profilePhotoUrl => _profilePhotoUrl;

  void loadUser(String userId) {
    _currentUserId = userId;
    _state = ProfileLoadingState.loading;
    notifyListeners();

    _userSubscription?.cancel();

    _userSubscription = _userRepository.getUserStream(userId).listen((user) {
      _user = user;
      _profilePhotoUrl = user?.photoUrl;
      _state = ProfileLoadingState.loaded;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _state = ProfileLoadingState.error;
      notifyListeners();
    });
  }

  void refresh() {
    if (_currentUserId != null) {
      loadUser(_currentUserId!);
    }
  }

  Future<bool> updateProfile({
    required String name,
    required double weight,
    required double height,
    required String goal,
  }) async {
    final userId = _authRepository.currentUserId;
    if (userId == null) {
      _errorMessage = 'Usuario no autenticado';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _state = ProfileLoadingState.saving;
    notifyListeners();

    try {
      // Intentar obtener el usuario primero
      UserModel? existingUser = await _userRepository.getUser(userId);
      
      if (existingUser == null) {
        // Si no existe, crear uno nuevo
        existingUser = UserModel(
          id: userId,
          name: name,
          email: _authRepository.currentUser?.email ?? '',
          weight: weight,
          height: height,
          goal: goal,
          createdAt: DateTime.now(),
        );
        await _userRepository.createUser(existingUser);
      } else {
        // Actualizar el usuario existente
        final updatedUser = existingUser.copyWith(
          name: name,
          weight: weight,
          height: height,
          goal: goal,
        );
        await _userRepository.updateUser(updatedUser);
        _user = updatedUser;
      }
      
      _isSaving = false;
      _state = ProfileLoadingState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSaving = false;
      _state = ProfileLoadingState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfilePhoto(File photoFile) async {
    final userId = _authRepository.currentUserId;
    if (userId == null) return false;

    _isSaving = true;
    _state = ProfileLoadingState.saving;
    notifyListeners();

    try {
      final bytes = await photoFile.readAsBytes();
      if (bytes.length > 700 * 1024) {
        throw Exception('La imagen es muy grande. Usa una de menos de 700 KB.');
      }
      final photoBase64 = base64Encode(bytes);
      
      final existingUser = await _userRepository.getUser(userId);
      if (existingUser != null) {
        final updatedUser = existingUser.copyWith(photoUrl: photoBase64);
        await _userRepository.updateUser(updatedUser);
        _user = updatedUser;
        _profilePhotoUrl = photoBase64;
      } else {
        final newUser = UserModel(
          id: userId,
          name: _authRepository.currentUser?.displayName ?? 'Usuario',
          email: _authRepository.currentUser?.email ?? '',
          createdAt: DateTime.now(),
          photoUrl: photoBase64,
        );
        await _userRepository.createUser(newUser);
        _user = newUser;
        _profilePhotoUrl = photoBase64;
      }
      
      _userSubscription?.cancel();
      _userSubscription = _userRepository.getUserStream(userId).listen((user) {
        _user = user;
        _profilePhotoUrl = user?.photoUrl;
        _state = ProfileLoadingState.loaded;
        notifyListeners();
      });

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSaving = false;
      _state = ProfileLoadingState.error;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
