import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../repository/user_repository.dart';
import '../../repository/storage_repository.dart';
import '../../repository/auth_repository.dart';
import '../../model/user_model.dart';

enum ProfileLoadingState { initial, loading, loaded, error, saving }

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final StorageRepository _storageRepository = StorageRepository();
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
    if (_user == null) {
      _errorMessage = 'Usuario no encontrado';
      return false;
    }

    _isSaving = true;
    _state = ProfileLoadingState.saving;
    notifyListeners();

    try {
      final updatedUser = _user!.copyWith(
        name: name,
        weight: weight,
        height: height,
        goal: goal,
      );

      await _userRepository.updateUser(updatedUser);
      
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
      final photoUrl = await _storageRepository.uploadProfilePhoto(userId, photoFile);
      _profilePhotoUrl = photoUrl;

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
