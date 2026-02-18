import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../repository/goals_repository.dart';
import '../../repository/auth_repository.dart';
import '../../model/goals_model.dart';

enum GoalsLoadingState { initial, loading, loaded, saving, error }

class GoalsViewModel extends ChangeNotifier {
  final GoalsRepository _goalsRepository = GoalsRepository();
  final AuthRepository _authRepository = AuthRepository();

  GoalsLoadingState _state = GoalsLoadingState.initial;
  GoalsModel? _goals;
  StreakModel? _streak;
  List<AchievementModel> _achievements = [];
  String? _errorMessage;
  StreamSubscription? _goalsSubscription;
  StreamSubscription? _streakSubscription;
  StreamSubscription? _achievementsSubscription;
  String? _currentUserId;

  GoalsLoadingState get state => _state;
  GoalsModel? get goals => _goals;
  StreakModel? get streak => _streak;
  List<AchievementModel> get achievements => _achievements;
  String? get errorMessage => _errorMessage;

  void loadGoals(String userId) {
    _currentUserId = userId;
    _state = GoalsLoadingState.loading;
    notifyListeners();

    _goalsSubscription?.cancel();
    _goalsSubscription = _goalsRepository.getGoalsStream(userId).listen(
      (data) {
        _goals = data;
        _state = GoalsLoadingState.loaded;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _state = GoalsLoadingState.error;
        notifyListeners();
      },
    );

    _streakSubscription?.cancel();
    _streakSubscription = _goalsRepository.getStreakStream(userId).listen(
      (data) {
        _streak = data;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
      },
    );

    _achievementsSubscription?.cancel();
    _achievementsSubscription = _goalsRepository.getAchievementsStream(userId).listen(
      (data) {
        _achievements = data;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
      },
    );
  }

  Future<bool> saveGoals({
    required GoalType goalType,
    required double targetWeight,
    required double currentWeight,
    DateTime? targetDate,
    int workoutsPerWeek = 3,
    bool reminderWorkout = true,
    bool reminderMeasurements = true,
  }) async {
    final userId = _authRepository.currentUserId;
    if (userId == null) {
      _errorMessage = 'Usuario no autenticado';
      notifyListeners();
      return false;
    }

    _state = GoalsLoadingState.saving;
    notifyListeners();

    try {
      final goals = GoalsModel(
        id: userId,
        userId: userId,
        goalType: goalType,
        targetWeight: targetWeight,
        currentWeight: currentWeight,
        startDate: DateTime.now(),
        targetDate: targetDate,
        workoutsPerWeek: workoutsPerWeek,
        reminderWorkout: reminderWorkout,
        reminderMeasurements: reminderMeasurements,
      );

      await _goalsRepository.saveGoals(goals);
      _goals = goals;
      _state = GoalsLoadingState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = GoalsLoadingState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateStreakOnWorkout() async {
    final userId = _authRepository.currentUserId;
    if (userId != null) {
      await _goalsRepository.updateStreakOnWorkout(userId);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _goalsSubscription?.cancel();
    _streakSubscription?.cancel();
    _achievementsSubscription?.cancel();
    super.dispose();
  }
}
