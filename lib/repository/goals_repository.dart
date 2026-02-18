import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../model/goals_model.dart';

class GoalsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Future<String> saveGoals(GoalsModel goals) async {
    try {
      final docRef = _firestore.collection('goals').doc(goals.userId);
      await docRef.set(goals.toMap());
      return goals.userId;
    } catch (e) {
      throw Exception('Failed to save goals: $e');
    }
  }

  Stream<GoalsModel?> getGoalsStream(String userId) {
    return _firestore.collection('goals').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return GoalsModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<GoalsModel?> getGoals(String userId) async {
    try {
      final doc = await _firestore.collection('goals').doc(userId).get();
      if (doc.exists) {
        return GoalsModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get goals: $e');
    }
  }

  Future<String> saveStreak(StreakModel streak) async {
    try {
      final docRef = _firestore.collection('streaks').doc(streak.userId);
      await docRef.set(streak.toMap());
      return streak.userId;
    } catch (e) {
      throw Exception('Failed to save streak: $e');
    }
  }

  Stream<StreakModel?> getStreakStream(String userId) {
    return _firestore.collection('streaks').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return StreakModel.fromMap(doc.data()!, doc.id);
      }
      return StreakModel(id: userId, userId: userId);
    });
  }

  Future<StreakModel?> getStreak(String userId) async {
    try {
      final doc = await _firestore.collection('streaks').doc(userId).get();
      if (doc.exists) {
        return StreakModel.fromMap(doc.data()!, doc.id);
      }
      return StreakModel(id: userId, userId: userId);
    } catch (e) {
      throw Exception('Failed to get streak: $e');
    }
  }

  Future<void> updateStreakOnWorkout(String userId) async {
    final streak = await getStreak(userId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int newStreak = 1;
    int newLongest = streak?.longestStreak ?? 0;
    
    if (streak != null && streak.lastActivityDate != null) {
      final lastDate = DateTime(
        streak.lastActivityDate!.year,
        streak.lastActivityDate!.month,
        streak.lastActivityDate!.day,
      );
      final difference = today.difference(lastDate).inDays;
      
      if (difference == 1) {
        newStreak = streak.currentStreak + 1;
      } else if (difference == 0) {
        newStreak = streak.currentStreak;
      }
    }
    
    if (newStreak > newLongest) {
      newLongest = newStreak;
    }
    
    final updatedStreak = StreakModel(
      id: userId,
      userId: userId,
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastActivityDate: now,
      totalWorkouts: (streak?.totalWorkouts ?? 0) + 1,
      totalMeasurements: streak?.totalMeasurements ?? 0,
    );
    
    await saveStreak(updatedStreak);
  }

  Future<void> unlockAchievement(String userId, String title) async {
    try {
      await _firestore.collection('achievements').doc('${userId}_$title').set({
        'userId': userId,
        'title': title,
        'unlockedAt': DateTime.now(),
        'isUnlocked': true,
      });
    } catch (e) {
      throw Exception('Failed to unlock achievement: $e');
    }
  }

  Stream<List<AchievementModel>> getAchievementsStream(String userId) {
    return _firestore
        .collection('achievements')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AchievementModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
