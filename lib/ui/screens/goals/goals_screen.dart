import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/goals_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../../model/goals_model.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      if (authViewModel.currentUserId != null) {
        context.read<GoalsViewModel>().loadGoals(authViewModel.currentUserId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas y Progreso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer2<GoalsViewModel, ProfileViewModel>(
        builder: (context, goalsViewModel, profileViewModel, child) {
          final goals = goalsViewModel.goals;
          final streak = goalsViewModel.streak;
          final user = profileViewModel.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStreakCard(streak),
                const SizedBox(height: 16),
                _buildGoalCard(goals, user, goalsViewModel),
                const SizedBox(height: 16),
                _buildAchievementsCard(goalsViewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakCard(StreakModel? streak) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.local_fire_department, color: Colors.orange, size: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Racha Actual', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${streak?.currentStreak ?? 0}',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text('días', style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Mejor racha', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('${streak?.longestStreak ?? 0} días', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(GoalsModel? goals, user, GoalsViewModel viewModel) {
    final currentWeight = user?.weight ?? 0.0;
    final targetWeight = goals?.targetWeight ?? currentWeight;
    final progress = currentWeight > 0 && targetWeight > 0
        ? ((currentWeight - targetWeight).abs() / currentWeight * 100).clamp(0, 100)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Meta de Peso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showGoalDialog(viewModel, user),
                ),
              ],
            ),
            if (goals != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWeightInfo('Actual', currentWeight, AppTheme.primaryColor),
                  _buildWeightInfo('Meta', targetWeight, AppTheme.secondaryColor),
                  _buildWeightInfo('Diferencia', (currentWeight - targetWeight).abs(), Colors.orange),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progreso', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text('${progress.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getGoalColor(goals.goalType).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(_getGoalIcon(goals.goalType), color: _getGoalColor(goals.goalType)),
                    const SizedBox(width: 8),
                    Text(goals.goalLabel, style: TextStyle(color: _getGoalColor(goals.goalType), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.flag_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No hay meta establecida'),
                      SizedBox(height: 12),
                      Text('Configura tu objetivo fitness'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showGoalDialog(viewModel, user),
                  child: const Text('Establecer Meta'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeightInfo(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text('${value.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildAchievementsCard(GoalsViewModel viewModel) {
    final achievements = viewModel.achievements;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Logros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (achievements.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.emoji_events_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Aún no hay logros desbloqueados'),
                      SizedBox(height: 4),
                      Text('¡Sigue entrenando para desbloquearlos!', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: achievements.map((a) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(a.icon, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 4),
                      Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _showGoalDialog(GoalsViewModel viewModel, user) {
    final targetController = TextEditingController(text: user?.weight.toString() ?? '70');
    GoalType selectedGoal = GoalType.maintainWeight;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Establecer Meta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<GoalType>(
                value: selectedGoal,
                decoration: const InputDecoration(labelText: 'Objetivo'),
                items: const [
                  DropdownMenuItem(value: GoalType.loseWeight, child: Text('Perder peso')),
                  DropdownMenuItem(value: GoalType.maintainWeight, child: Text('Mantener peso')),
                  DropdownMenuItem(value: GoalType.gainMuscle, child: Text('Ganar músculo')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedGoal = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Peso objetivo (kg)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final target = double.tryParse(targetController.text);
                if (target != null && target > 0) {
                  await viewModel.saveGoals(
                    goalType: selectedGoal,
                    targetWeight: target,
                    currentWeight: user?.weight ?? target,
                  );
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGoalColor(GoalType type) {
    switch (type) {
      case GoalType.loseWeight:
        return Colors.green;
      case GoalType.maintainWeight:
        return Colors.blue;
      case GoalType.gainMuscle:
        return Colors.purple;
    }
  }

  IconData _getGoalIcon(GoalType type) {
    switch (type) {
      case GoalType.loseWeight:
        return Icons.trending_down;
      case GoalType.maintainWeight:
        return Icons.trending_flat;
      case GoalType.gainMuscle:
        return Icons.trending_up;
    }
  }
}
