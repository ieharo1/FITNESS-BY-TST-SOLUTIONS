import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../model/progress_model.dart';

class ProgressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  static const String _collectionName = 'progress';

  Future<String> addProgress(ProgressModel progress) async {
    try {
      final id = _uuid.v4();
      final progressWithId = progress.copyWith(id: id);
      await _firestore.collection(_collectionName).doc(id).set(progressWithId.toMap());
      return id;
    } catch (e) {
      throw Exception('Failed to add progress: $e');
    }
  }

  Future<void> updateProgress(ProgressModel progress) async {
    try {
      await _firestore.collection(_collectionName).doc(progress.id).update(progress.toMap());
    } catch (e) {
      throw Exception('Failed to update progress: $e');
    }
  }

  Future<void> deleteProgress(String progressId) async {
    try {
      await _firestore.collection(_collectionName).doc(progressId).delete();
    } catch (e) {
      throw Exception('Failed to delete progress: $e');
    }
  }

  Stream<List<ProgressModel>> getUserProgressStream(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ProgressModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<List<ProgressModel>> getUserProgress(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs.map((doc) => ProgressModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to get progress: $e');
    }
  }

  Future<ProgressModel?> getLatestProgress(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return ProgressModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get latest progress: $e');
    }
  }

  Stream<ProgressModel?> getLatestProgressStream(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return ProgressModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    });
  }
}
