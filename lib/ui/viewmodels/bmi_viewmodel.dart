import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../repository/bmi_repository.dart';
import '../../repository/auth_repository.dart';
import '../../model/bmi_history_model.dart';

enum BmiLoadingState { initial, loading, loaded, saving, error }

class BmiViewModel extends ChangeNotifier {
  final BmiRepository _bmiRepository = BmiRepository();
  final AuthRepository _authRepository = AuthRepository();

  BmiLoadingState _state = BmiLoadingState.initial;
  List<BmiHistoryModel> _bmiHistory = [];
  BmiHistoryModel? _latestBmi;
  String? _errorMessage;
  StreamSubscription? _bmiSubscription;
  String? _currentUserId;

  BmiLoadingState get state => _state;
  List<BmiHistoryModel> get bmiHistory => _bmiHistory;
  BmiHistoryModel? get latestBmi => _latestBmi;
  String? get errorMessage => _errorMessage;

  double calculateBmi(double weight, double height) {
    if (weight <= 0 || height <= 0) return 0.0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String getCategory(double bmi) {
    if (bmi < 18.5) return 'Bajo peso';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Sobrepeso';
    if (bmi < 35) return 'Obesidad grado I';
    if (bmi < 40) return 'Obesidad grado II';
    return 'Obesidad grado III';
  }

  void loadBmiHistory(String userId) {
    _currentUserId = userId;
    _state = BmiLoadingState.loading;
    notifyListeners();

    _bmiSubscription?.cancel();
    _bmiSubscription = _bmiRepository.getUserBmiHistoryStream(userId).listen(
      (history) {
        _bmiHistory = history;
        _latestBmi = history.isNotEmpty ? history.first : null;
        _state = BmiLoadingState.loaded;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _state = BmiLoadingState.error;
        notifyListeners();
      },
    );
  }

  Future<bool> saveBmiRecord({
    required double weight,
    required double height,
  }) async {
    final userId = _authRepository.currentUserId;
    if (userId == null) {
      _errorMessage = 'Usuario no autenticado';
      notifyListeners();
      return false;
    }

    _state = BmiLoadingState.saving;
    notifyListeners();

    try {
      final bmi = calculateBmi(weight, height);
      final bmiRecord = BmiHistoryModel(
        id: '',
        userId: userId,
        bmi: bmi,
        weight: weight,
        height: height,
        date: DateTime.now(),
      );

      await _bmiRepository.addBmiRecord(bmiRecord);
      _state = BmiLoadingState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = BmiLoadingState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBmiRecord(String bmiId) async {
    try {
      await _bmiRepository.deleteBmiRecord(bmiId);
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
    _bmiSubscription?.cancel();
    super.dispose();
  }
}
