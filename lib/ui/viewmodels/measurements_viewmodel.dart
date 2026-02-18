import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../repository/measurements_repository.dart';
import '../../repository/auth_repository.dart';
import '../../model/measurements_model.dart';

enum MeasurementsLoadingState { initial, loading, loaded, saving, error }

class MeasurementsViewModel extends ChangeNotifier {
  final MeasurementsRepository _measurementsRepository = MeasurementsRepository();
  final AuthRepository _authRepository = AuthRepository();

  MeasurementsLoadingState _state = MeasurementsLoadingState.initial;
  List<MeasurementsModel> _measurements = [];
  MeasurementsModel? _latestMeasurement;
  String? _errorMessage;
  StreamSubscription? _measurementsSubscription;
  String? _currentUserId;

  MeasurementsLoadingState get state => _state;
  List<MeasurementsModel> get measurements => _measurements;
  MeasurementsModel? get latestMeasurement => _latestMeasurement;
  String? get errorMessage => _errorMessage;

  void loadMeasurements(String userId) {
    _currentUserId = userId;
    _state = MeasurementsLoadingState.loading;
    notifyListeners();

    _measurementsSubscription?.cancel();
    _measurementsSubscription = _measurementsRepository.getUserMeasurementsStream(userId).listen(
      (data) {
        _measurements = data;
        _latestMeasurement = data.isNotEmpty ? data.first : null;
        _state = MeasurementsLoadingState.loaded;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _state = MeasurementsLoadingState.error;
        notifyListeners();
      },
    );
  }

  Future<bool> addMeasurement({
    required double weight,
    double? waist,
    double? chest,
    double? arm,
    double? leg,
    double? hips,
    double? shoulders,
    String? notes,
  }) async {
    final userId = _authRepository.currentUserId;
    if (userId == null) {
      _errorMessage = 'Usuario no autenticado';
      notifyListeners();
      return false;
    }

    _state = MeasurementsLoadingState.saving;
    notifyListeners();

    try {
      final measurement = MeasurementsModel(
        id: '',
        userId: userId,
        weight: weight,
        waist: waist,
        chest: chest,
        arm: arm,
        leg: leg,
        hips: hips,
        shoulders: shoulders,
        date: DateTime.now(),
        notes: notes,
      );

      await _measurementsRepository.addMeasurement(measurement);
      _state = MeasurementsLoadingState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = MeasurementsLoadingState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMeasurement(MeasurementsModel measurement) async {
    try {
      await _measurementsRepository.updateMeasurement(measurement);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMeasurement(String measurementId) async {
    try {
      await _measurementsRepository.deleteMeasurement(measurementId);
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
    _measurementsSubscription?.cancel();
    super.dispose();
  }
}
