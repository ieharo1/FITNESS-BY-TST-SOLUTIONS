import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/progress_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../theme/app_theme.dart';

class ExportDataScreen extends StatelessWidget {
  const ExportDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar Datos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer3<AuthViewModel, ProgressViewModel, HomeViewModel>(
        builder: (context, authViewModel, progressViewModel, homeViewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Exporta tu progreso',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Descarga un resumen de tu progreso en formato texto',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                _buildExportCard(
                  context,
                  icon: Icons.monitor_weight,
                  title: 'Historial de Peso',
                  description: 'Exporta tu registro de peso a lo largo del tiempo',
                  onExport: () => _exportWeightData(context, progressViewModel),
                ),
                const SizedBox(height: 12),
                _buildExportCard(
                  context,
                  icon: Icons.fitness_center,
                  title: 'Resumen de Entrenamientos',
                  description: 'Total de entrenamientos y rutinas completadas',
                  onExport: () => _exportWorkoutSummary(context, homeViewModel),
                ),
                const SizedBox(height: 12),
                _buildExportCard(
                  context,
                  icon: Icons.assessment,
                  title: 'Resumen Completo',
                  description: 'Descarga un resumen con toda tu información',
                  onExport: () => _exportFullData(context, progressViewModel, homeViewModel),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Los datos se compartirán como archivo de texto que puedes guardar o enviar.',
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExportCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onExport,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description, style: const TextStyle(fontSize: 12)),
        trailing: ElevatedButton(
          onPressed: onExport,
          child: const Text('Exportar'),
        ),
      ),
    );
  }

  Future<void> _exportWeightData(BuildContext context, ProgressViewModel progressViewModel) async {
    final progress = progressViewModel.progressList;
    
    if (progress.isEmpty) {
      _showMessage(context, 'No hay datos de peso para exportar');
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('HISTORIAL DE PESO - Fitness By TST');
    buffer.writeln('=' * 40);
    buffer.writeln('');
    
    for (var p in progress.reversed) {
      buffer.writeln('${DateFormat('dd/MM/yyyy').format(p.date)} - ${p.weight} kg');
    }
    
    await _shareData(context, buffer.toString(), 'historial_peso.txt');
  }

  Future<void> _exportWorkoutSummary(BuildContext context, HomeViewModel homeViewModel) async {
    final buffer = StringBuffer();
    buffer.writeln('RESUMEN DE ENTRENAMIENTOS');
    buffer.writeln('=' * 40);
    buffer.writeln('');
    buffer.writeln('Total de entrenamientos: ${homeViewModel.workoutCount}');
    buffer.writeln('Racha actual: ${homeViewModel.completedRoutinesToday.length}');
    
    await _shareData(context, buffer.toString(), 'resumen_entrenamientos.txt');
  }

  Future<void> _exportFullData(BuildContext context, ProgressViewModel progressViewModel, HomeViewModel homeViewModel) async {
    final buffer = StringBuffer();
    buffer.writeln('RESUMEN COMPLETO - Fitness By TST');
    buffer.writeln('=' * 50);
    buffer.writeln('');
    
    buffer.writeln('ESTADÍSTICAS:');
    buffer.writeln('-'.padRight(30, '-'));
    buffer.writeln('Entrenamientos: ${homeViewModel.workoutCount}');
    buffer.writeln('Peso actual: ${homeViewModel.latestWeight} kg');
    
    if (homeViewModel.user != null) {
      buffer.writeln('IMC: ${homeViewModel.user!.bmi.toStringAsFixed(1)}');
      buffer.writeln('Categoría: ${homeViewModel.user!.bmiCategory}');
    }
    
    buffer.writeln('');
    buffer.writeln('HISTORIAL DE PESO:');
    buffer.writeln('-'.padRight(30, '-'));
    
    final progress = progressViewModel.progressList;
    for (var p in progress.reversed.take(10)) {
      buffer.writeln('${DateFormat('dd/MM/yyyy').format(p.date)} - ${p.weight} kg');
    }
    
    await _shareData(context, buffer.toString(), 'resumen_fitness.txt');
  }

  Future<void> _shareData(BuildContext context, String content, String filename) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Mis datos de Fitness By TST',
      );
    } catch (e) {
      _showMessage(context, 'Error al exportar: $e');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
