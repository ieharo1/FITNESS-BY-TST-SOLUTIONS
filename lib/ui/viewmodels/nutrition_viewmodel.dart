import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../repository/routine_nutrition_repository.dart';
import '../../repository/auth_repository.dart';
import '../../model/routine_model.dart';
import '../../model/goals_model.dart' as goals;

enum NutritionLoadingState { initial, loading, loaded, saving, error }

class NutritionViewModel extends ChangeNotifier {
  final NutritionRepository _nutritionRepository = NutritionRepository();
  final AuthRepository _authRepository = AuthRepository();

  NutritionLoadingState _state = NutritionLoadingState.initial;
  NutritionModel? _nutrition;
  double _tmb = 0;
  double _dailyCalories = 0;
  NutritionPlan? _macros;
  String? _errorMessage;
  StreamSubscription? _nutritionSubscription;
  String? _currentUserId;

  NutritionLoadingState get state => _state;
  NutritionModel? get nutrition => _nutrition;
  double get tmb => _tmb;
  double get dailyCalories => _dailyCalories;
  NutritionPlan? get macros => _macros;
  String? get errorMessage => _errorMessage;

  void calculateTmb({
    required double weight,
    required double height,
    required int age,
    required bool isMale,
  }) {
    _tmb = _nutritionRepository.calculateTMB(
      weight: weight,
      height: height,
      age: age,
      isMale: isMale,
    );
    notifyListeners();
  }

  void setGoal(goals.GoalType goalType) {
    final repoGoal = goalType == goals.GoalType.loseWeight
        ? GoalType.loseWeight
        : goalType == goals.GoalType.gainMuscle
            ? GoalType.gainMuscle
            : GoalType.maintainWeight;
    _dailyCalories = _nutritionRepository.calculateCaloriesWithGoal(_tmb, repoGoal);
    _macros = _nutritionRepository.calculateMacros(_dailyCalories);
    notifyListeners();
  }

  void setCustomCalories(double calories) {
    _dailyCalories = calories.clamp(1000, 5000);
    _macros = _nutritionRepository.calculateMacros(_dailyCalories);
    notifyListeners();
  }

  void loadNutrition(String userId) {
    _currentUserId = userId;
    _state = NutritionLoadingState.loading;
    notifyListeners();

    _nutritionSubscription?.cancel();
    _nutritionSubscription = _nutritionRepository.getNutritionStream(userId).listen(
      (data) {
        _nutrition = data;
        if (data != null) {
          _dailyCalories = data.dailyCalories;
          _macros = _nutritionRepository.calculateMacros(_dailyCalories);
        }
        _state = NutritionLoadingState.loaded;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _state = NutritionLoadingState.error;
        notifyListeners();
      },
    );
  }

  Future<bool> saveNutrition() async {
    final userId = _authRepository.currentUserId;
    if (userId == null) return false;

    _state = NutritionLoadingState.saving;
    notifyListeners();

    try {
      final nutrition = NutritionModel(
        id: userId,
        userId: userId,
        dailyCalories: _dailyCalories,
        proteinGrams: _macros?.proteinGrams ?? 150,
        carbsGrams: _macros?.carbsGrams ?? 200,
        fatGrams: _macros?.fatGrams ?? 65,
        mealsPerDay: 3,
        createdAt: DateTime.now(),
      );

      await _nutritionRepository.saveNutrition(nutrition);
      _nutrition = nutrition;
      _state = NutritionLoadingState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = NutritionLoadingState.error;
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
    _nutritionSubscription?.cancel();
    super.dispose();
  }
}
