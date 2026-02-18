import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/local_cache_service.dart';
import '../../theme/app_theme.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialPage> _pages = [
    const TutorialPage(
      icon: Icons.fitness_center,
      title: 'Bienvenido a Fitness By TST',
      description: 'Tu companion de entrenamiento personal. Registra tus workouts, sigue tu progreso y alcanza tus metas fitness.',
      color: AppTheme.primaryColor,
    ),
    const TutorialPage(
      icon: Icons.check_circle,
      title: 'Rutinas del Día',
      description: 'Crea tus rutinas personalizadas con los ejercicios que quieras. Cada día te mostraremos qué hacer.',
      color: Colors.green,
    ),
    const TutorialPage(
      icon: Icons.monitor_weight,
      title: 'Registra tu Peso',
      description: 'Actualiza tu peso diariamente para ver tu evolución. El IMC se calcula automáticamente en tu perfil.',
      color: Colors.orange,
    ),
    const TutorialPage(
      icon: Icons.local_fire_department,
      title: 'Racha y Logros',
      description: 'Mantén tu racha entrenando cada día. Desbloquea logros por cada meta que cumplas.',
      color: Colors.red,
    ),
    const TutorialPage(
      icon: Icons.timer,
      title: 'Temporizador',
      description: 'Usa el temporizador para tus descansos. Configura el tiempo y cuando termine, sonará una alarma.',
      color: Colors.purple,
    ),
    const TutorialPage(
      icon: Icons.restaurant,
      title: 'Nutrición',
      description: 'Calcula tus calorías diarias y consulta el plan nutricional con ejemplos de comidas saludables.',
      color: Colors.teal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            _buildIndicators(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(TutorialPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: page.color,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppTheme.primaryColor
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _completeTutorial,
            child: Text(
              'Omitir',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_currentPage < _pages.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                _completeTutorial();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              _currentPage < _pages.length - 1 ? 'Siguiente' : 'Comenzar',
            ),
          ),
        ],
      ),
    );
  }

  void _completeTutorial() async {
    await LocalCacheService.setTutorialCompleted(true);
    if (mounted) {
      context.go('/home');
    }
  }
}

class TutorialPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const TutorialPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
