import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/calories_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../../model/goals_model.dart';

class CaloriesScreen extends StatefulWidget {
  const CaloriesScreen({super.key});

  @override
  State<CaloriesScreen> createState() => _CaloriesScreenState();
}

class _CaloriesScreenState extends State<CaloriesScreen> {
  int _age = 25;
  bool _isMale = true;
  GoalType _selectedGoal = GoalType.maintainWeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      if (authViewModel.currentUserId != null) {
        final caloriesViewModel = context.read<CaloriesViewModel>();
        caloriesViewModel.loadNutrition(authViewModel.currentUserId!);
        
        final profileViewModel = context.read<ProfileViewModel>();
        if (profileViewModel.user != null) {
          _age = 25;
          caloriesViewModel.calculateTmb(
            weight: profileViewModel.user!.weight,
            height: profileViewModel.user!.height,
            age: _age,
            isMale: _isMale,
          );
          caloriesViewModel.setGoal(_selectedGoal);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Calorías'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer2<CaloriesViewModel, ProfileViewModel>(
        builder: (context, caloriesViewModel, profileViewModel, child) {
          final user = profileViewModel.user;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCaloriesCard(caloriesViewModel),
                const SizedBox(height: 24),
                _buildCalculatorCard(caloriesViewModel, user),
                const SizedBox(height: 24),
                _buildMacrosCard(caloriesViewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaloriesCard(CaloriesViewModel caloriesViewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCalorieItem(
                  'TMB',
                  '${caloriesViewModel.tmb.toStringAsFixed(0)}',
                  'kcal/día',
                  AppTheme.primaryColor,
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.grey.shade300,
                ),
                _buildCalorieItem(
                  'Meta Diaria',
                  '${caloriesViewModel.dailyCalories.toStringAsFixed(0)}',
                  'kcal/día',
                  AppTheme.secondaryColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '¿Qué es la TMB?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Son las calorías que tu cuerpo quema en reposo. Es la energía mínima que necesitas para vivir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await caloriesViewModel.saveNutrition();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Calorías guardadas' : 'Error al guardar'),
                        backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                    );
                  }
                },
                child: const Text('Guardar'),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCalculatorCard(CaloriesViewModel caloriesViewModel, user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurar Calorías',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Sexo: '),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Hombre'),
                  selected: _isMale,
                  onSelected: (selected) {
                    setState(() => _isMale = true);
                    if (user != null) {
                      caloriesViewModel.calculateTmb(
                        weight: user.weight,
                        height: user.height,
                        age: _age,
                        isMale: true,
                      );
                      caloriesViewModel.setGoal(_selectedGoal);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Mujer'),
                  selected: !_isMale,
                  onSelected: (selected) {
                    setState(() => _isMale = false);
                    if (user != null) {
                      caloriesViewModel.calculateTmb(
                        weight: user.weight,
                        height: user.height,
                        age: _age,
                        isMale: false,
                      );
                      caloriesViewModel.setGoal(_selectedGoal);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Objetivo: '),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<GoalType>(
                    value: _selectedGoal,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: GoalType.loseWeight, child: Text('Perder peso (-500)')),
                      DropdownMenuItem(value: GoalType.maintainWeight, child: Text('Mantener (0)')),
                      DropdownMenuItem(value: GoalType.gainMuscle, child: Text('Ganar músculo (+500)')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedGoal = value);
                        caloriesViewModel.setGoal(value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => caloriesViewModel.adjustCalories(-100),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '${caloriesViewModel.dailyCalories.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => caloriesViewModel.adjustCalories(100),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacrosCard(CaloriesViewModel caloriesViewModel) {
    final macros = caloriesViewModel.macros;
    if (macros == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribución de Macros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: macros.proteinGrams * 4,
                      title: 'Proteína\n${macros.proteinGrams.toStringAsFixed(0)}g',
                      color: AppTheme.primaryColor,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: macros.carbsGrams * 4,
                      title: 'Carbohidratos\n${macros.carbsGrams.toStringAsFixed(0)}g',
                      color: AppTheme.secondaryColor,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: macros.fatGrams * 9,
                      title: 'Grasas\n${macros.fatGrams.toStringAsFixed(0)}g',
                      color: Colors.orange,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Qué son los macros?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildMacroInfo('Proteína', '${macros.proteinGrams.toStringAsFixed(0)}g', 'Construye músculos, esencial para recuperación'),
                  _buildMacroInfo('Carbohidratos', '${macros.carbsGrams.toStringAsFixed(0)}g', 'Energía principal para tus entrenamientos'),
                  _buildMacroInfo('Grasas', '${macros.fatGrams.toStringAsFixed(0)}g', 'Energía y absorción de vitaminas'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroInfo(String name, String amount, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$name ($amount): ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Expanded(
            child: Text(
              description,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
