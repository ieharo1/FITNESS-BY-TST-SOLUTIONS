import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/bmi_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../theme/app_theme.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      if (authViewModel.currentUserId != null) {
        final bmiViewModel = context.read<BmiViewModel>();
        final profileViewModel = context.read<ProfileViewModel>();
        bmiViewModel.loadBmiHistory(authViewModel.currentUserId!);
        
        if (profileViewModel.user != null) {
          _weightController.text = profileViewModel.user!.weight.toString();
          _heightController.text = profileViewModel.user!.height.toString();
        }
      }
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora IMC'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer2<BmiViewModel, ProfileViewModel>(
        builder: (context, bmiViewModel, profileViewModel, child) {
          final user = profileViewModel.user;
          final latestBmi = bmiViewModel.latestBmi;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentBmiCard(latestBmi, user),
                const SizedBox(height: 24),
                _buildCalculatorCard(bmiViewModel, user),
                const SizedBox(height: 24),
                _buildHistoryChart(bmiViewModel),
                const SizedBox(height: 24),
                _buildHistoryList(bmiViewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentBmiCard(latestBmi, user) {
    final bmi = latestBmi?.bmi ?? (user?.bmi ?? 0.0);
    final category = bmiViewModel(context).getCategory(bmi);
    final color = _getBmiColor(bmi);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: bmi > 0 ? (bmi / 40).clamp(0.0, 1.0) : 0,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  Text(
                    bmi > 0 ? bmi.toStringAsFixed(1) : '--',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu IMC Actual',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (user != null && user.height > 0)
                    Text(
                      'Peso ideal: ${user.idealWeightMin.toStringAsFixed(1)} - ${user.idealWeightMax.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorCard(BmiViewModel bmiViewModel, user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calcular Nuevo IMC',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Altura (cm)',
                prefixIcon: Icon(Icons.height),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: bmiViewModel.state == BmiLoadingState.saving
                    ? null
                    : () async {
                        final weight = double.tryParse(_weightController.text);
                        final height = double.tryParse(_heightController.text);
                        if (weight != null && height != null && weight > 0 && height > 0) {
                          await bmiViewModel.saveBmiRecord(
                            weight: weight,
                            height: height,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('IMC guardado correctamente'),
                                backgroundColor: AppTheme.successColor,
                              ),
                            );
                          }
                        }
                      },
                icon: bmiViewModel.state == BmiLoadingState.saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: const Text('Guardar IMC'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryChart(BmiViewModel bmiViewModel) {
    final history = bmiViewModel.bmiHistory;
    if (history.isEmpty) return const SizedBox.shrink();

    final spots = history.reversed.take(10).toList().asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.bmi);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evolución del IMC',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(BmiViewModel bmiViewModel) {
    final history = bmiViewModel.bmiHistory;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historial de IMC',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (history.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No hay registros aún'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length.clamp(0, 10),
                itemBuilder: (context, index) {
                  final item = history[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.color.withValues(alpha: 0.1),
                      child: Text(
                        item.bmi.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: item.color,
                        ),
                      ),
                    ),
                    title: Text(item.category),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy', 'es_ES').format(item.date),
                    ),
                    trailing: Text('${item.weight} kg'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  BmiViewModel bmiViewModel(BuildContext context) => context.read<BmiViewModel>();

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }
}
