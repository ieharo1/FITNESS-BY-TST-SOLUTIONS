import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../model/routine_model.dart';

class RoutineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  static const String _collectionName = 'routines';

  Future<String> createRoutine(RoutineModel routine) async {
    try {
      final id = _uuid.v4();
      final routineWithId = routine.copyWith(id: id);
      await _firestore.collection(_collectionName).doc(id).set(routineWithId.toMap());
      return id;
    } catch (e) {
      throw Exception('Failed to create routine: $e');
    }
  }

  Future<void> updateRoutine(RoutineModel routine) async {
    try {
      await _firestore.collection(_collectionName).doc(routine.id).update(routine.toMap());
    } catch (e) {
      throw Exception('Failed to update routine: $e');
    }
  }

  Future<void> deleteRoutine(String routineId) async {
    try {
      await _firestore.collection(_collectionName).doc(routineId).delete();
    } catch (e) {
      throw Exception('Failed to delete routine: $e');
    }
  }

  Stream<List<RoutineModel>> getUserRoutinesStream(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RoutineModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<List<RoutineModel>> getUserRoutines(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => RoutineModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get routines: $e');
    }
  }

  Future<RoutineModel?> getRoutine(String routineId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(routineId).get();
      if (doc.exists) {
        return RoutineModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get routine: $e');
    }
  }
}

class NutritionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'nutrition';

  Future<void> saveNutrition(NutritionModel nutrition) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc(nutrition.userId);
      await docRef.set(nutrition.toMap());
    } catch (e) {
      throw Exception('Failed to save nutrition: $e');
    }
  }

  Stream<NutritionModel?> getNutritionStream(String userId) {
    return _firestore.collection(_collectionName).doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return NutritionModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<NutritionModel?> getNutrition(String userId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(userId).get();
      if (doc.exists) {
        return NutritionModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get nutrition: $e');
    }
  }

  double calculateTMB({
    required double weight,
    required double height,
    required int age,
    required bool isMale,
  }) {
    if (isMale) {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
  }

  double calculateCaloriesWithGoal(double tmb, GoalType goalType) {
    switch (goalType) {
      case GoalType.loseWeight:
        return tmb - 500;
      case GoalType.maintainWeight:
        return tmb;
      case GoalType.gainMuscle:
        return tmb + 500;
    }
  }

  NutritionPlan calculateMacros(double dailyCalories) {
    final protein = (dailyCalories * 0.30) / 4;
    final carbs = (dailyCalories * 0.40) / 4;
    final fat = (dailyCalories * 0.30) / 9;
    return NutritionPlan(
      calories: dailyCalories,
      proteinGrams: protein,
      carbsGrams: carbs,
      fatGrams: fat,
    );
  }
}

enum GoalType { loseWeight, maintainWeight, gainMuscle }

class NutritionPlan {
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;

  NutritionPlan({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });
}
