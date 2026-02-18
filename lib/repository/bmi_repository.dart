import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../model/bmi_history_model.dart';

class BmiRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  static const String _collectionName = 'bmi_history';

  Future<String> addBmiRecord(BmiHistoryModel bmi) async {
    try {
      final id = _uuid.v4();
      final bmiWithId = bmi.copyWith(id: id);
      await _firestore.collection(_collectionName).doc(id).set(bmiWithId.toMap());
      return id;
    } catch (e) {
      throw Exception('Failed to add BMI record: $e');
    }
  }

  Stream<List<BmiHistoryModel>> getUserBmiHistoryStream(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BmiHistoryModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<List<BmiHistoryModel>> getUserBmiHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => BmiHistoryModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get BMI history: $e');
    }
  }

  Future<BmiHistoryModel?> getLatestBmi(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return BmiHistoryModel.fromMap(
            snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get latest BMI: $e');
    }
  }

  Stream<BmiHistoryModel?> getLatestBmiStream(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return BmiHistoryModel.fromMap(
            snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    });
  }

  Future<void> deleteBmiRecord(String bmiId) async {
    try {
      await _firestore.collection(_collectionName).doc(bmiId).delete();
    } catch (e) {
      throw Exception('Failed to delete BMI record: $e');
    }
  }
}
