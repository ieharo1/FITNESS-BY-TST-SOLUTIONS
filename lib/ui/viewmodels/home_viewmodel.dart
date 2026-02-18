import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../repository/auth_repository.dart';
import '../../repository/user_repository.dart';
import '../../repository/workout_repository.dart';
import '../../repository/progress_repository.dart';
import '../../model/user_model.dart';
import '../../model/workout_model.dart';
import '../../model/progress_model.dart';

enum LoadingState { initial, loading, loaded, error }

class HomeViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  final ProgressRepository _progressRepository = ProgressRepository();

  LoadingState _state = LoadingState.initial;
  UserModel? _user;
  int _workoutCount = 0;
  double _latestWeight = 0.0;
  List<WorkoutModel> _recentWorkouts = [];
  String? _errorMessage;

  StreamSubscription? _userSubscription;
  StreamSubscription? _workoutSubscription;
  StreamSubscription? _progressSubscription;

  LoadingState get state => _state;
  UserModel? get user => _user;
  int get workoutCount => _workoutCount;
  double get latestWeight => _latestWeight;
  List<WorkoutModel> get recentWorkouts => _recentWorkouts;
  String? get errorMessage => _errorMessage;

  void initialize(String userId) {
    _state = LoadingState.loading;
    notifyListeners();

    _userSubscription?.cancel();
    _workoutSubscription?.cancel();
    _progressSubscription?.cancel();

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
  }

  void refresh(String userId) {
    initialize(userId);
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _workoutSubscription?.cancel();
    _progressSubscription?.cancel();
    super.dispose();
  }
}
