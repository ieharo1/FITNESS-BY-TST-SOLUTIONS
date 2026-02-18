import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../repository/workout_repository.dart';
import '../../repository/auth_repository.dart';
import '../../model/workout_model.dart';

enum WorkoutLoadingState { initial, loading, loaded, error, saving }

class WorkoutViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  final AuthRepository _authRepository = AuthRepository();

  WorkoutLoadingState _state = WorkoutLoadingState.initial;
  List<WorkoutModel> _workouts = [];
  String? _errorMessage;
  bool _isSaving = false;
  StreamSubscription? _workoutSubscription;
  String? _currentUserId;

  WorkoutLoadingState get state => _state;
  List<WorkoutModel> get workouts => _workouts;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;

  void loadWorkouts(String userId) {
    _currentUserId = userId;
    _state = WorkoutLoadingState.loading;
    notifyListeners();

    _workoutSubscription?.cancel();

    _workoutSubscription = _workoutRepository.getUserWorkoutsStream(userId).listen((workouts) {
      _workouts = workouts;
      _state = WorkoutLoadingState.loaded;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _state = WorkoutLoadingState.error;
      notifyListeners();
    });
  }

  void refresh() {
    if (_currentUserId != null) {
      loadWorkouts(_currentUserId!);
    }
  }

  Future<bool> addWorkout({
    required String type,
    required DateTime date,
    required List<Map<String, dynamic>> exercises,
  }) async {
    final userId = _authRepository.currentUserId;
    if (userId == null) {
      _errorMessage = 'Usuario no autenticado';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _state = WorkoutLoadingState.saving;
    notifyListeners();

    try {
      final workout = WorkoutModel(
        id: '',
        userId: userId,
        date: date,
        type: type,
        exercises: exercises,
        createdAt: DateTime.now(),
      );

      await _workoutRepository.createWorkout(workout);
      _isSaving = false;
      _state = WorkoutLoadingState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSaving = false;
      _state = WorkoutLoadingState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteWorkout(String workoutId) async {
    try {
      await _workoutRepository.deleteWorkout(workoutId);
      notifyListeners();
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

  @override
  void dispose() {
    _workoutSubscription?.cancel();
    super.dispose();
  }
}
