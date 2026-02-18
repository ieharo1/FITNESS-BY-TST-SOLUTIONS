import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../model/workout_model.dart';

class WorkoutRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  static const String _collectionName = 'workouts';

  Future<String> createWorkout(WorkoutModel workout) async {
    try {
      final id = _uuid.v4();
      final workoutWithId = workout.copyWith(id: id);
      await _firestore.collection(_collectionName).doc(id).set(workoutWithId.toMap());
      return id;
    } catch (e) {
      throw Exception('Failed to create workout: $e');
    }
  }

  Future<void> updateWorkout(WorkoutModel workout) async {
    try {
      await _firestore.collection(_collectionName).doc(workout.id).update(workout.toMap());
    } catch (e) {
      throw Exception('Failed to update workout: $e');
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _firestore.collection(_collectionName).doc(workoutId).delete();
    } catch (e) {
      throw Exception('Failed to delete workout: $e');
    }
  }

  Future<WorkoutModel?> getWorkout(String workoutId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(workoutId).get();
      if (doc.exists) {
        return WorkoutModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get workout: $e');
    }
  }

  Stream<List<WorkoutModel>> getUserWorkoutsStream(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => WorkoutModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<List<WorkoutModel>> getUserWorkouts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs.map((doc) => WorkoutModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to get workouts: $e');
    }
  }

  Future<int> getWorkoutCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.size;
    } catch (e) {
      throw Exception('Failed to get workout count: $e');
    }
  }

  Stream<List<WorkoutModel>> getRecentWorkoutsStream(String userId, {int limit = 5}) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => WorkoutModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
