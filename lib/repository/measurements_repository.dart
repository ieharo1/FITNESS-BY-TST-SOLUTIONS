import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../model/measurements_model.dart';

class MeasurementsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  static const String _collectionName = 'measurements';

  Future<String> addMeasurement(MeasurementsModel measurement) async {
    try {
      final id = _uuid.v4();
      final measurementWithId = measurement.copyWith(id: id);
      await _firestore.collection(_collectionName).doc(id).set(measurementWithId.toMap());
      return id;
    } catch (e) {
      throw Exception('Failed to add measurement: $e');
    }
  }

  Future<void> updateMeasurement(MeasurementsModel measurement) async {
    try {
      await _firestore.collection(_collectionName).doc(measurement.id).update(measurement.toMap());
    } catch (e) {
      throw Exception('Failed to update measurement: $e');
    }
  }

  Future<void> deleteMeasurement(String measurementId) async {
    try {
      await _firestore.collection(_collectionName).doc(measurementId).delete();
    } catch (e) {
      throw Exception('Failed to delete measurement: $e');
    }
  }

  Stream<List<MeasurementsModel>> getUserMeasurementsStream(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MeasurementsModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<List<MeasurementsModel>> getUserMeasurements(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => MeasurementsModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get measurements: $e');
    }
  }

  Stream<MeasurementsModel?> getLatestMeasurementStream(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return MeasurementsModel.fromMap(
            snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    });
  }

  Future<MeasurementsModel?> getLatestMeasurement(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return MeasurementsModel.fromMap(
            snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get latest measurement: $e');
    }
  }
}
