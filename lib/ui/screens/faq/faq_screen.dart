import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda / FAQ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '¿Cómo funciona la app?',
              'Fitness By TST te ayuda a seguir tu progreso fitness. '
              'Registra tus entrenamientos, mide tu peso, calcula tu IMC y establece metas.',
              Icons.info_outline,
            ),
            _buildSection(
              '¿Cómo usar las rutinas?',
              '1. Crea rutinas con los ejercicios que quieras.\n'
              '2. Selecciona los días de la semana.\n'
              '3. Cada día te aparecerán las rutinas programadas.\n'
              '4. ¡Marca el check cuando las completes!',
              Icons.fitness_center,
            ),
            _buildSection(
              '¿Qué es el IMC?',
              'El Índice de Masa Corporal (IMC) es una medida que relaciona tu peso con tu altura. '
              'Te ayuda a saber si estás en un peso saludable. Lo encuentras en tu Perfil.',
              Icons.monitor_weight,
            ),
            _buildSection(
              '¿Para qué sirven las calorías?',
              'Las calorías son la energía que obtienes de los alimentos. '
              'Usa la calculadora para saber cuántas calorías necesitas según tu objetivo: '
              'perder peso, mantenerlo o ganar músculo.',
              Icons.local_fire_department,
            ),
            _buildSection(
              '¿Qué son los macros?',
              'Son los tres principales nutrientes:\n'
              '• Proteína: Construye músculos\n'
              '• Carbohidratos: Energía para entrenar\n'
              '• Grasas: Energía y vitaminas',
              Icons.pie_chart,
            ),
            _buildSection(
              '¿Cómo funciona el temporizador?',
              'Úsalo para los descansos entre ejercicios. '
              'Configura el tiempo que necesites (30s, 60s, 90s, etc) '
              'y cuando termine sonará una alarma.',
              Icons.timer,
            ),
            _buildSection(
              '¿Qué son las medidas corporales?',
              'Registra tu cintura, pecho, brazos y piernas para ver cómo cambia tu cuerpo. '
              'El peso y el IMC escríbelo en tu Perfil.',
              Icons.straighten,
            ),
            _buildSection(
              '¿Qué es la racha?',
              'La racha cuenta cuántos días seguidos has entrenado. '
              '¡Mantén tu racha entrenando cada día!',
              Icons.local_fire_department,
            ),
            _buildSection(
              '¿Cómo cambiar entre modo claro y oscuro?',
              'Toca el icono del sol/luna en la barra superior de la pantalla principal.',
              Icons.dark_mode,
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.fitness_center, size: 48, color: AppTheme.primaryColor),
                  const SizedBox(height: 8),
                  Text(
                    '¡Entrena con Fitness By TST!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
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

  Widget _buildSection(String title, String content, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
