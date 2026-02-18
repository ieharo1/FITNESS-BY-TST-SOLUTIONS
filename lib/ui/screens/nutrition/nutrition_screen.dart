import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/nutrition_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../../model/goals_model.dart';
import '../../../repository/routine_nutrition_repository.dart' as repo;

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      if (authViewModel.currentUserId != null) {
        context.read<NutritionViewModel>().loadNutrition(authViewModel.currentUserId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Nutricional'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer2<NutritionViewModel, ProfileViewModel>(
        builder: (context, nutritionViewModel, profileViewModel, child) {
          final nutrition = nutritionViewModel.nutrition;
          final macros = nutritionViewModel.macros;
          final user = profileViewModel.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCaloriesSummaryCard(nutritionViewModel),
                const SizedBox(height: 16),
                _buildMacrosCard(macros),
                const SizedBox(height: 16),
                _buildMealsCard(nutritionViewModel, user),
                const SizedBox(height: 16),
                _buildRecommendationsCard(nutritionViewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaloriesSummaryCard(NutritionViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCalorieItem('Meta Diaria', '${viewModel.dailyCalories.toStringAsFixed(0)}', 'kcal', AppTheme.primaryColor),
                Container(width: 1, height: 50, color: Colors.grey.shade300),
                _buildCalorieItem('TMB', '${viewModel.tmb.toStringAsFixed(0)}', 'kcal', AppTheme.secondaryColor),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await viewModel.saveNutrition();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Plan guardado' : 'Error al guardar'),
                        backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                    );
                  }
                },
                child: const Text('Guardar Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildMacrosCard(repo.NutritionPlan? macros) {
    if (macros == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                const Text('Configura tu plan nutricional'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _showCalculateDialog(),
                  child: const Text('Calcular Macros'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Distribución de Macros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                      value: macros.proteinGrams * 4,
                      title: 'P\n${macros.proteinGrams.toStringAsFixed(0)}g',
                      color: AppTheme.primaryColor,
                      radius: 60,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      value: macros.carbsGrams * 4,
                      title: 'C\n${macros.carbsGrams.toStringAsFixed(0)}g',
                      color: AppTheme.secondaryColor,
                      radius: 60,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      value: macros.fatGrams * 9,
                      title: 'G\n${macros.fatGrams.toStringAsFixed(0)}g',
                      color: Colors.orange,
                      radius: 60,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroLegend('Proteína', '${macros.proteinGrams.toStringAsFixed(0)}g', AppTheme.primaryColor),
                _buildMacroLegend('Carbs', '${macros.carbsGrams.toStringAsFixed(0)}g', AppTheme.secondaryColor),
                _buildMacroLegend('Grasas', '${macros.fatGrams.toStringAsFixed(0)}g', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroLegend(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMealsCard(NutritionViewModel viewModel, user) {
    final meals = 3;
    final caloriesPerMeal = viewModel.dailyCalories ~/ meals;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Distribución de Comidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...List.generate(meals, (index) {
              final mealNames = ['Desayuno', 'Almuerzo', 'Cena'];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mealNames[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('$caloriesPerMeal kcal', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Ver detalles'),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(NutritionViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recomendaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildRecommendationItem(Icons.water_drop, 'Hidratación', 'Bebe al menos 2L de agua al día'),
            _buildRecommendationItem(Icons.timer, 'Horario', 'Come cada 3-4 horas'),
            _buildRecommendationItem(Icons.bedtime, 'Sueño', 'Duerme 7-8 horas'),
            _buildRecommendationItem(Icons.restaurant, 'Proteína', 'Consume proteína en cada comida'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCalculateDialog() {
    final profileViewModel = context.read<ProfileViewModel>();
    final nutritionViewModel = context.read<NutritionViewModel>();
    final user = profileViewModel.user;

    if (user != null && user.weight > 0 && user.height > 0) {
      nutritionViewModel.calculateTmb(
        weight: user.weight,
        height: user.height,
        age: 25,
        isMale: true,
      );
      nutritionViewModel.setGoal(GoalType.maintainWeight);
    }
  }
}
