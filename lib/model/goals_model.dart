import 'package:flutter/material.dart';

enum GoalType { loseWeight, maintainWeight, gainMuscle }

class GoalsModel {
  final String id;
  final String userId;
  final GoalType goalType;
  final double targetWeight;
  final double currentWeight;
  final DateTime startDate;
  final DateTime? targetDate;
  final int workoutsPerWeek;
  final bool reminderWorkout;
  final bool reminderMeasurements;
  final DateTime? lastWorkoutReminder;
  final DateTime? lastMeasurementReminder;
  
  GoalsModel({
    required this.id,
    required this.userId,
    required this.goalType,
    required this.targetWeight,
    required this.currentWeight,
    required this.startDate,
    this.targetDate,
    this.workoutsPerWeek = 3,
    this.reminderWorkout = true,
    this.reminderMeasurements = true,
    this.lastWorkoutReminder,
    this.lastMeasurementReminder,
  });

  factory GoalsModel.fromMap(Map<String, dynamic> map, String id) {
    return GoalsModel(
      id: id,
      userId: map['userId'] ?? '',
      goalType: GoalType.values.firstWhere(
        (e) => e.name == map['goalType'],
        orElse: () => GoalType.maintainWeight,
      ),
      targetWeight: (map['targetWeight'] ?? 0.0).toDouble(),
      currentWeight: (map['currentWeight'] ?? 0.0).toDouble(),
      startDate: (map['startDate'] as dynamic)?.toDate() ?? DateTime.now(),
      targetDate: (map['targetDate'] as dynamic)?.toDate(),
      workoutsPerWeek: map['workoutsPerWeek'] ?? 3,
      reminderWorkout: map['reminderWorkout'] ?? true,
      reminderMeasurements: map['reminderMeasurements'] ?? true,
      lastWorkoutReminder: (map['lastWorkoutReminder'] as dynamic)?.toDate(),
      lastMeasurementReminder: (map['lastMeasurementReminder'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'goalType': goalType.name,
      'targetWeight': targetWeight,
      'currentWeight': currentWeight,
      'startDate': startDate,
      'targetDate': targetDate,
      'workoutsPerWeek': workoutsPerWeek,
      'reminderWorkout': reminderWorkout,
      'reminderMeasurements': reminderMeasurements,
      'lastWorkoutReminder': lastWorkoutReminder,
      'lastMeasurementReminder': lastMeasurementReminder,
    };
  }

  GoalsModel copyWith({
    String? id,
    String? userId,
    GoalType? goalType,
    double? targetWeight,
    double? currentWeight,
    DateTime? startDate,
    DateTime? targetDate,
    int? workoutsPerWeek,
    bool? reminderWorkout,
    bool? reminderMeasurements,
    DateTime? lastWorkoutReminder,
    DateTime? lastMeasurementReminder,
  }) {
    return GoalsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalType: goalType ?? this.goalType,
      targetWeight: targetWeight ?? this.targetWeight,
      currentWeight: currentWeight ?? this.currentWeight,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      workoutsPerWeek: workoutsPerWeek ?? this.workoutsPerWeek,
      reminderWorkout: reminderWorkout ?? this.reminderWorkout,
      reminderMeasurements: reminderMeasurements ?? this.reminderMeasurements,
      lastWorkoutReminder: lastWorkoutReminder ?? this.lastWorkoutReminder,
      lastMeasurementReminder: lastMeasurementReminder ?? this.lastMeasurementReminder,
    );
  }

  String get goalLabel {
    switch (goalType) {
      case GoalType.loseWeight:
        return 'Perder peso';
      case GoalType.maintainWeight:
        return 'Mantener peso';
      case GoalType.gainMuscle:
        return 'Ganar músculo';
    }
  }

  double get weightToLose => currentWeight - targetWeight;
  double get progressPercentage {
    if (weightToLose == 0) return 100;
    final total = (currentWeight - targetWeight).abs();
    if (total == 0) return 100;
    final done = (currentWeight - targetWeight).abs();
    return (done / total * 100).clamp(0, 100);
  }
}

class StreakModel {
  final String id;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final int totalWorkouts;
  final int totalMeasurements;
  
  StreakModel({
    required this.id,
    required this.userId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    this.totalWorkouts = 0,
    this.totalMeasurements = 0,
  });

  factory StreakModel.fromMap(Map<String, dynamic> map, String id) {
    return StreakModel(
      id: id,
      userId: map['userId'] ?? '',
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastActivityDate: (map['lastActivityDate'] as dynamic)?.toDate(),
      totalWorkouts: map['totalWorkouts'] ?? 0,
      totalMeasurements: map['totalMeasurements'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate,
      'totalWorkouts': totalWorkouts,
      'totalMeasurements': totalMeasurements,
    };
  }

  StreakModel copyWith({
    String? id,
    String? userId,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    int? totalWorkouts,
    int? totalMeasurements,
  }) {
    return StreakModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalMeasurements: totalMeasurements ?? this.totalMeasurements,
    );
  }
}

class AchievementModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String icon;
  final DateTime? unlockedAt;
  final bool isUnlocked;
  
  AchievementModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  factory AchievementModel.fromMap(Map<String, dynamic> map, String id) {
    return AchievementModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '🏆',
      unlockedAt: (map['unlockedAt'] as dynamic)?.toDate(),
      isUnlocked: map['isUnlocked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'icon': icon,
      'unlockedAt': unlockedAt,
      'isUnlocked': isUnlocked,
    };
  }
}
