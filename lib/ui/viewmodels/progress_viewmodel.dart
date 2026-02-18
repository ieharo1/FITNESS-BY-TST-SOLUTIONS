import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../repository/progress_repository.dart';
import '../../repository/storage_repository.dart';
import '../../repository/auth_repository.dart';
import '../../model/progress_model.dart';

enum ProgressLoadingState { initial, loading, loaded, error, uploading }

class ProgressViewModel extends ChangeNotifier {
  final ProgressRepository _progressRepository = ProgressRepository();
  final StorageRepository _storageRepository = StorageRepository();
  final AuthRepository _authRepository = AuthRepository();

  ProgressLoadingState _state = ProgressLoadingState.initial;
  List<ProgressModel> _progressList = [];
  ProgressModel? _latestProgress;
  String? _errorMessage;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  ProgressLoadingState get state => _state;
  List<ProgressModel> get progressList => _progressList;
  ProgressModel? get latestProgress => _latestProgress;
  String? get errorMessage => _errorMessage;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;

  void loadProgress(String userId) {
    _state = ProgressLoadingState.loading;
    notifyListeners();

    _progressRepository.getUserProgressStream(userId).listen((progress) {
      _progressList = progress;
      _latestProgress = progress.isNotEmpty ? progress.first : null;
      _state = ProgressLoadingState.loaded;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _state = ProgressLoadingState.error;
      notifyListeners();
    });
  }

  Future<bool> addProgress({
    required double weight,
    File? photoFile,
  }) async {
    final userId = _authRepository.currentUserId;
    if (userId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isUploading = true;
    _state = ProgressLoadingState.uploading;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      String? photoUrl;

      if (photoFile != null) {
        _uploadProgress = 0.5;
        notifyListeners();
        
        photoUrl = await _storageRepository.uploadProgressPhoto(userId, photoFile);
        
        _uploadProgress = 0.8;
        notifyListeners();
      }

      final progress = ProgressModel(
        id: '',
        userId: userId,
        weight: weight,
        photoUrl: photoUrl,
        date: DateTime.now(),
      );

      await _progressRepository.addProgress(progress);

      _uploadProgress = 1.0;
      _isUploading = false;
      _state = ProgressLoadingState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isUploading = false;
      _state = ProgressLoadingState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProgress(ProgressModel progress) async {
    try {
      if (progress.photoUrl != null) {
        await _storageRepository.deleteProgressPhoto(progress.photoUrl!);
      }
      await _progressRepository.deleteProgress(progress.id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
