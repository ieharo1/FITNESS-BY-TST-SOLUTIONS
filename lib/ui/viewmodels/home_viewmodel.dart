import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../repository/auth_repository.dart';
import '../../repository/user_repository.dart';
import '../../repository/workout_repository.dart';
import '../../repository/progress_repository.dart';
import '../../repository/routine_nutrition_repository.dart';
import '../../model/user_model.dart';
import '../../model/workout_model.dart';
import '../../model/progress_model.dart';
import '../../model/routine_model.dart';

enum LoadingState { initial, loading, loaded, error }

class HomeViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  final ProgressRepository _progressRepository = ProgressRepository();
  final RoutineRepository _routineRepository = RoutineRepository();

  LoadingState _state = LoadingState.initial;
  UserModel? _user;
  int _workoutCount = 0;
  double _latestWeight = 0.0;
  List<WorkoutModel> _recentWorkouts = [];
  List<RoutineModel> _routines = [];
  Set<String> _completedRoutinesToday = {};
  String? _errorMessage;

  StreamSubscription? _userSubscription;
  StreamSubscription? _workoutSubscription;
  StreamSubscription? _progressSubscription;
  StreamSubscription? _routinesSubscription;

  LoadingState get state => _state;
  UserModel? get user => _user;
  int get workoutCount => _workoutCount;
  double get latestWeight => _latestWeight;
  List<WorkoutModel> get recentWorkouts => _recentWorkouts;
  List<RoutineModel> get routines => _routines;
  Set<String> get completedRoutinesToday => _completedRoutinesToday;
  String? get errorMessage => _errorMessage;

  int get currentWeekDay {
    return DateTime.now().weekday;
  }

  List<RoutineModel> get todayRoutines {
    return _routines.where((r) => r.weekDays.contains(currentWeekDay)).toList();
  }

  void initialize(String userId) {
    _state = LoadingState.loading;
    notifyListeners();

    _userSubscription?.cancel();
    _workoutSubscription?.cancel();
    _progressSubscription?.cancel();
    _routinesSubscription?.cancel();

    _userSubscription = _userRepository.getUserStream(userId).listen((user) {
      _user = user;
      _state = LoadingState.loaded;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _state = LoadingState.error;
      notifyListeners();
    });

    _workoutSubscription = _workoutRepository.getUserWorkoutsStream(userId).listen((workouts) {
      _workoutCount = workouts.length;
      _recentWorkouts = workouts.take(5).toList();
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      notifyListeners();
    });

    _progressSubscription = _progressRepository.getLatestProgressStream(userId).listen((progress) {
      if (progress != null) {
        _latestWeight = progress.weight;
      }
      notifyListeners();
    });

    _routinesSubscription = _routineRepository.getUserRoutinesStream(userId).listen((routines) {
      _routines = routines;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      notifyListeners();
    });
  }

  Future<void> completeRoutine(RoutineModel routine) async {
    final userId = _authRepository.currentUserId;
    if (userId == null) return;

    if (!_completedRoutinesToday.contains(routine.id)) {
      _completedRoutinesToday.add(routine.id);
      notifyListeners();

      final exercises = routine.exercises.map((e) => <String, dynamic>{
        'name': e.name,
        'sets': e.sets,
        'reps': e.reps,
        'weight': e.weight ?? 0.0,
      }).toList();

      await _workoutRepository.createWorkout(
        WorkoutModel(
          id: '',
          userId: userId,
          date: DateTime.now(),
          type: routine.name,
          exercises: exercises,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  void refresh(String userId) {
    initialize(userId);
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _workoutSubscription?.cancel();
    _progressSubscription?.cancel();
    _routinesSubscription?.cancel();
    super.dispose();
  }
}
