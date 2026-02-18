import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/goals_viewmodel.dart';
import '../../../model/badge_model.dart';
import '../../theme/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logros'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Consumer<GoalsViewModel>(
        builder: (context, goalsViewModel, child) {
          final workoutCount = goalsViewModel.workoutCount;
          final currentStreak = goalsViewModel.streak?.currentStreak ?? 0;

          final earnedAchievements = <Achievement>[];
          
          if (workoutCount >= 1) {
            earnedAchievements.add(Achievement.allAchievements[0]);
          }
          if (workoutCount >= 10) {
            earnedAchievements.add(Achievement.allAchievements[1]);
          }
          if (workoutCount >= 50) {
            earnedAchievements.add(Achievement.allAchievements[2]);
          }
          if (workoutCount >= 100) {
            earnedAchievements.add(Achievement.allAchievements[3]);
          }
          if (currentStreak >= 7) {
            earnedAchievements.add(Achievement.allAchievements[4]);
          }
          if (currentStreak >= 14) {
            earnedAchievements.add(Achievement.allAchievements[5]);
          }
          if (currentStreak >= 30) {
            earnedAchievements.add(Achievement.allAchievements[6]);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsCard(workoutCount, currentStreak),
                const SizedBox(height: 24),
                const Text(
                  'Tus Logros',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: Achievement.allAchievements.length,
                  itemBuilder: (context, index) {
                    final achievement = Achievement.allAchievements[index];
                    final isEarned = earnedAchievements.contains(achievement);
                    return _buildAchievementCard(achievement, isEarned);
                  },
                ),
              ],
            ),
          );
        },
        ),
      ),
    );
  }

  Widget _buildStatsCard(int workouts, int streak) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Icon(Icons.fitness_center, color: AppTheme.primaryColor, size: 32),
                const SizedBox(height: 8),
                Text(
                  '$workouts',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('Entrenamientos', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            Container(width: 1, height: 60, color: Colors.grey.shade300),
            Column(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
                const SizedBox(height: 8),
                Text(
                  '$streak',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const Text('Días de racha', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isEarned) {
    return Card(
      color: isEarned ? null : Colors.grey.shade200,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              achievement.icon,
              size: 40,
              color: isEarned ? achievement.color : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isEarned ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isEarned ? Colors.grey : Colors.grey.shade400,
              ),
            ),
            if (isEarned) ...[
              const SizedBox(height: 4),
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
