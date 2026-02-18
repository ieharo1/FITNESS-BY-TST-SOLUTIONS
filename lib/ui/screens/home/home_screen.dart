import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/theme_provider.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showedDailyPopup = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _checkDailyWeight();
    });
  }

  void _loadData() {
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.currentUserId != null) {
      context.read<HomeViewModel>().initialize(authViewModel.currentUserId!);
    }
  }

  void _checkDailyWeight() async {
    if (_showedDailyPopup) return;
    
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    final homeViewModel = context.read<HomeViewModel>();
    final lastWeightDate = homeViewModel.lastWeightDate;
    final today = DateTime.now();
    
    final shouldShow = lastWeightDate == null || 
        lastWeightDate.year != today.year || 
        lastWeightDate.month != today.month || 
        lastWeightDate.day != today.day;
    
    if (shouldShow && homeViewModel.user != null) {
      _showedDailyPopup = true;
      _showDailyWeightDialog();
    }
  }

  void _showDailyWeightDialog() {
    final weightController = TextEditingController();
    final homeViewModel = context.read<HomeViewModel>();
    
    if (homeViewModel.user != null && homeViewModel.user!.weight > 0) {
      weightController.text = homeViewModel.user!.weight.toString();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.monitor_weight, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('¿Cómo estás hoy?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Actualiza tu peso para seguir tu progreso',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Peso actual (kg)',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Más tarde'),
          ),
          ElevatedButton(
            onPressed: () async {
              final weight = double.tryParse(weightController.text);
              if (weight != null && weight > 0) {
                await homeViewModel.updateTodayWeight(weight);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Peso actualizado!'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showCelebrationDialog(String routineName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              color: Colors.amber,
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              '¡FELICIDADES! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rutina "$routineName" completada',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Colors.green),
                  const Text(
                    ' +1 Entrenamiento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Sigue así! 💪',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('¡Genial!'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness By TST'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => themeProvider.toggleTheme(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Consumer<HomeViewModel>(
        builder: (context, homeViewModel, child) {
          if (homeViewModel.state == LoadingState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(homeViewModel),
                  const SizedBox(height: 24),
                  _buildStatsRow(homeViewModel),
                  const SizedBox(height: 16),
                  _buildBMIQuickView(homeViewModel),
                  const SizedBox(height: 24),
                  _buildRecentWorkouts(homeViewModel),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-workout'),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              context.push('/progress');
              break;
            case 2:
              context.push('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Progreso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(HomeViewModel homeViewModel) {
    final userName = homeViewModel.user?.name ?? 'Usuario';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, $userName! 👋',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '¿Listo para tu entrenamiento de hoy?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(HomeViewModel homeViewModel) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.monitor_weight_outlined,
            label: 'Peso Actual',
            value: '${homeViewModel.latestWeight.toStringAsFixed(1)} kg',
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.fitness_center,
            label: 'Entrenamientos',
            value: '${homeViewModel.workoutCount}',
            color: AppTheme.secondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBMIQuickView(HomeViewModel homeViewModel) {
    final user = homeViewModel.user;
    if (user == null || user.height <= 0 || user.weight <= 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info_outline, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Completa tu peso y altura en el perfil para ver tu IMC',
                  style: TextStyle(color: Colors.orange, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/profile'),
                child: const Text('Completar'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: user.bmiColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    user.bmi.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: user.bmiColor,
                    ),
                  ),
                  Text(
                    'IMC',
                    style: TextStyle(fontSize: 10, color: user.bmiColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.bmiCategory,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: user.bmiColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Peso ideal: ${user.idealWeightMin.toStringAsFixed(1)} - ${user.idealWeightMax.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.push('/profile'),
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentWorkouts(HomeViewModel homeViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Rutinas de Hoy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => context.push('/routines'),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildTodayRoutines(homeViewModel),
        const SizedBox(height: 24),
        const Text(
          'Entrenamientos Recientes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (homeViewModel.recentWorkouts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay entrenamientos aún',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => context.push('/add-workout'),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: homeViewModel.recentWorkouts.length,
            itemBuilder: (context, index) {
              final workout = homeViewModel.recentWorkouts[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.type,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy', 'es_ES').format(workout.date),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${workout.exercises.length} ejer.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTodayRoutines(HomeViewModel homeViewModel) {
    final todayRoutines = homeViewModel.todayRoutines;
    final completedRoutines = homeViewModel.completedRoutinesToday;

    if (todayRoutines.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No hay rutinas programadas para hoy',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.push('/routines'),
              child: const Text('Crear una rutina'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: todayRoutines.map((routine) {
        final isCompleted = completedRoutines.contains(routine.id);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isCompleted ? Border.all(color: Colors.green, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Checkbox(
              value: isCompleted,
              activeColor: Colors.green,
              onChanged: (value) {
                if (value == true && !isCompleted) {
                  homeViewModel.completeRoutine(routine);
                  _showCelebrationDialog(routine.name);
                }
              },
            ),
            title: Text(
              routine.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : null,
              ),
            ),
            subtitle: Text(
              '${routine.exercises.length} ejercicios • ${routine.estimatedMinutes} min',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            trailing: isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.play_circle_outline, color: AppTheme.primaryColor),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.fitness_center, color: AppTheme.primaryColor, size: 32),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Fitness By TST',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  context.read<AuthViewModel>().currentUser?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          _buildDrawerItem(context, Icons.home, 'Inicio', '/home', 0),
          _buildDrawerItem(context, Icons.local_fire_department, 'Calorías', '/calories', 2),
          _buildDrawerItem(context, Icons.straighten, 'Medidas Corporales', '/measurements', 3),
          _buildDrawerItem(context, Icons.fitness_center, 'Mis Rutinas', '/routines', 4),
          _buildDrawerItem(context, Icons.timer, 'Temporizador', '/timer', 5),
          _buildDrawerItem(context, Icons.restaurant, 'Nutrición', '/nutrition', 6),
          _buildDrawerItem(context, Icons.flag, 'Metas y Progreso', '/goals', 7),
          _buildDrawerItem(context, Icons.emoji_events, 'Logros', '/achievements', 11),
          _buildDrawerItem(context, Icons.download, 'Exportar Datos', '/export', 12),
          const Divider(),
          _buildDrawerItem(context, Icons.trending_up, 'Progreso', '/progress', 8),
          _buildDrawerItem(context, Icons.person, 'Perfil', '/profile', 9),
          _buildDrawerItem(context, Icons.help_outline, 'Ayuda / FAQ', '/faq', 10),
          _buildDrawerItem(context, Icons.info_outline, 'Acerca de TST', '/about', 13),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route, int index) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (route != '/home') {
          context.push(route);
        }
      },
    );
  }
}
