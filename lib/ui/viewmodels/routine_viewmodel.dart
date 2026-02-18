import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../repository/routine_nutrition_repository.dart';
import '../../repository/auth_repository.dart';
import '../../model/routine_model.dart';

enum RoutineLoadingState { initial, loading, loaded, saving, error }

class RoutineViewModel extends ChangeNotifier {
  final RoutineRepository _routineRepository = RoutineRepository();
  final AuthRepository _authRepository = AuthRepository();

  RoutineLoadingState _state = RoutineLoadingState.initial;
  List<RoutineModel> _routines = [];
  RoutineModel? _selectedRoutine;
  String? _errorMessage;
  StreamSubscription? _routinesSubscription;
  String? _currentUserId;

  RoutineLoadingState get state => _state;
  List<RoutineModel> get routines => _routines;
  RoutineModel? get selectedRoutine => _selectedRoutine;
  String? get errorMessage => _errorMessage;

  void loadRoutines(String userId) {
    _currentUserId = userId;
    _state = RoutineLoadingState.loading;
    notifyListeners();

    _routinesSubscription?.cancel();
    _routinesSubscription = _routineRepository.getUserRoutinesStream(userId).listen(
      (data) {
        _routines = data;
        _state = RoutineLoadingState.loaded;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _state = RoutineLoadingState.error;
        notifyListeners();
      },
    );
  }

  void selectRoutine(RoutineModel routine) {
    _selectedRoutine = routine;
    notifyListeners();
  }

  Future<bool> createRoutine({
    required String name,
    String? description,
    required List<RoutineExercise> exercises,
    int estimatedMinutes = 60,
    String difficulty = 'intermediate',
    List<int> weekDays = const [1, 3, 5],
  }) async {
    final userId = _authRepository.currentUserId;
    if (userId == null) {
      _errorMessage = 'Usuario no autenticado';
      notifyListeners();
      return false;
    }

    _state = RoutineLoadingState.saving;
    notifyListeners();

    try {
      final routine = RoutineModel(
        id: '',
        userId: userId,
        name: name,
        description: description,
        exercises: exercises,
        estimatedMinutes: estimatedMinutes,
        difficulty: difficulty,
        weekDays: weekDays,
        createdAt: DateTime.now(),
      );

      await _routineRepository.createRoutine(routine);
      _routines.insert(0, routine.copyWith(id: routine.userId));
      _state = RoutineLoadingState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = RoutineLoadingState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRoutine(RoutineModel routine) async {
    try {
      await _routineRepository.updateRoutine(routine);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRoutine(String routineId) async {
    try {
      await _routineRepository.deleteRoutine(routineId);
      _routines.removeWhere((r) => r.id == routineId);
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
    _routinesSubscription?.cancel();
    super.dispose();
  }
}
