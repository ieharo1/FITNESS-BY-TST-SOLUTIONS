import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/measurements_viewmodel.dart';
import '../../theme/app_theme.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  final _weightController = TextEditingController();
  final _waistController = TextEditingController();
  final _chestController = TextEditingController();
  final _armController = TextEditingController();
  final _legController = TextEditingController();
  final _hipsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      if (authViewModel.currentUserId != null) {
        context.read<MeasurementsViewModel>().loadMeasurements(authViewModel.currentUserId!);
      }
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _chestController.dispose();
    _armController.dispose();
    _legController.dispose();
    _hipsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medidas Corporales'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMeasurementDialog(),
          ),
        ],
      ),
      body: Consumer<MeasurementsViewModel>(
        builder: (context, measurementsViewModel, child) {
          if (measurementsViewModel.state == MeasurementsLoadingState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentMeasurements(measurementsViewModel),
                const SizedBox(height: 24),
                _buildEvolutionChart(measurementsViewModel),
                const SizedBox(height: 24),
                _buildMeasurementsList(measurementsViewModel),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMeasurementDialog,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }

  Widget _buildCurrentMeasurements(MeasurementsViewModel viewModel) {
    final latest = viewModel.latestMeasurement;
    if (latest == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.straighten, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('No hay medidas registradas'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _showAddMeasurementDialog,
                  child: const Text('Agregar primera medida'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Últimas Medidas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('dd MMM yyyy', 'es_ES').format(latest.date),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildMeasureChip('Peso', '${latest.weight} kg', Icons.monitor_weight),
                if (latest.waist != null) _buildMeasureChip('Cintura', '${latest.waist} cm', Icons.straighten),
                if (latest.chest != null) _buildMeasureChip('Pecho', '${latest.chest} cm', Icons.accessibility),
                if (latest.arm != null) _buildMeasureChip('Brazo', '${latest.arm} cm', Icons.fitness_center),
                if (latest.leg != null) _buildMeasureChip('Pierna', '${latest.leg} cm', Icons.directions_walk),
                if (latest.hips != null) _buildMeasureChip('Caderas', '${latest.hips} cm', Icons.accessibility_new),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasureChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionChart(MeasurementsViewModel viewModel) {
    final measurements = viewModel.measurements;
    if (measurements.isEmpty) return const SizedBox.shrink();

    final weightSpots = measurements.reversed.take(10).toList().asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evolución del Peso',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      spots: weightSpots,
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

  Widget _buildMeasurementsList(MeasurementsViewModel viewModel) {
    final measurements = viewModel.measurements;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historial',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (measurements.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No hay registros aún'),
              ))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: measurements.length.clamp(0, 10),
                itemBuilder: (context, index) {
                  final m = measurements[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                      child: Text('${m.weight}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    title: Text(DateFormat('dd MMM yyyy', 'es_ES').format(m.date)),
                    subtitle: Text('Peso: ${m.weight} kg'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => viewModel.deleteMeasurement(m.id),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAddMeasurementDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nueva Medida', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Peso (kg)', prefixIcon: Icon(Icons.monitor_weight)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _waistController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cintura (cm)', prefixIcon: Icon(Icons.straighten)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _chestController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Pecho (cm)', prefixIcon: Icon(Icons.accessibility)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _armController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Brazo (cm)', prefixIcon: Icon(Icons.fitness_center)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _legController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Pierna (cm)', prefixIcon: Icon(Icons.directions_walk)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final weight = double.tryParse(_weightController.text);
                  if (weight != null && weight > 0) {
                    await context.read<MeasurementsViewModel>().addMeasurement(
                      weight: weight,
                      waist: double.tryParse(_waistController.text),
                      chest: double.tryParse(_chestController.text),
                      arm: double.tryParse(_armController.text),
                      leg: double.tryParse(_legController.text),
                    );
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Guardar'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
