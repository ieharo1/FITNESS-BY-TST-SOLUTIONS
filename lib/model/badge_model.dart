import 'package:flutter/material.dart';

enum AchievementType {
  firstWorkout,
  weekStreak,
  twoWeekStreak,
  monthStreak,
  tenWorkouts,
  fiftyWorkouts,
  hundredWorkouts,
  firstRoutine,
}

class Achievement {
  final AchievementType type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int requiredValue;

  const Achievement({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredValue,
  });

  static List<Achievement> get allAchievements => [
    const Achievement(
      type: AchievementType.firstWorkout,
      name: 'Primer Entrenamiento',
      description: 'Completaste tu primer entrenamiento',
      icon: Icons.fitness_center,
      color: Colors.blue,
      requiredValue: 1,
    ),
    const Achievement(
      type: AchievementType.tenWorkouts,
      name: 'Diez Entrenamientos',
      description: 'Completaste 10 entrenamientos',
      icon: Icons.stars,
      color: Colors.purple,
      requiredValue: 10,
    ),
    const Achievement(
      type: AchievementType.fiftyWorkouts,
      name: 'Atleta',
      description: 'Completaste 50 entrenamientos',
      icon: Icons.emoji_events,
      color: Colors.amber,
      requiredValue: 50,
    ),
    const Achievement(
      type: AchievementType.hundredWorkouts,
      name: 'Campeón',
      description: 'Completaste 100 entrenamientos',
      icon: Icons.military_tech,
      color: Colors.orange,
      requiredValue: 100,
    ),
    const Achievement(
      type: AchievementType.weekStreak,
      name: 'Semana',
      description: '7 días consecutivos entrenando',
      icon: Icons.local_fire_department,
      color: Colors.red,
      requiredValue: 7,
    ),
    const Achievement(
      type: AchievementType.twoWeekStreak,
      name: 'Dos Semanas',
      description: '14 días consecutivos entrenando',
      icon: Icons.whatshot,
      color: Colors.deepOrange,
      requiredValue: 14,
    ),
    const Achievement(
      type: AchievementType.monthStreak,
      name: 'Mes',
      description: '30 días consecutivos entrenando',
      icon: Icons.workspace_premium,
      color: Colors.amber,
      requiredValue: 30,
    ),
  ];

  static Achievement? getAchievementForWorkoutCount(int count) {
    for (var achievement in allAchievements.reversed) {
      if (count >= achievement.requiredValue && 
          (achievement.type == AchievementType.tenWorkouts || 
           achievement.type == AchievementType.fiftyWorkouts || 
           achievement.type == AchievementType.hundredWorkouts)) {
        return achievement;
      }
    }
    if (count >= 1) {
      return allAchievements.first;
    }
    return null;
  }

  static Achievement? getAchievementForStreak(int streak) {
    for (var achievement in allAchievements.reversed) {
      if (achievement.requiredValue <= streak &&
          (achievement.type == AchievementType.weekStreak ||
           achievement.type == AchievementType.twoWeekStreak ||
           achievement.type == AchievementType.monthStreak)) {
        return achievement;
      }
    }
    return null;
  }
}
