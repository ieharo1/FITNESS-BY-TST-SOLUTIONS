import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../ui/screens/splash/splash_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/register_screen.dart';
import '../ui/screens/home/home_screen.dart';
import '../ui/screens/workout/add_workout_screen.dart';
import '../ui/screens/progress/progress_screen.dart';
import '../ui/screens/profile/profile_screen.dart';
import '../ui/screens/bmi/bmi_screen.dart';
import '../ui/screens/calories/calories_screen.dart';
import '../ui/screens/measurements/measurements_screen.dart';
import '../ui/screens/routines/routines_screen.dart';
import '../ui/screens/timer/timer_screen.dart';
import '../ui/screens/goals/goals_screen.dart';
import '../ui/screens/nutrition/nutrition_screen.dart';
import '../ui/screens/faq/faq_screen.dart';
import '../ui/screens/achievements/achievements_screen.dart';
import '../ui/screens/export/export_data_screen.dart';
import '../ui/screens/about/about_screen.dart';
import '../ui/viewmodels/auth_viewmodel.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(BuildContext context) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      redirect: (context, state) {
        final authViewModel = context.read<AuthViewModel>();
        final isAuthenticated = authViewModel.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login' || 
                           state.matchedLocation == '/register' ||
                           state.matchedLocation == '/';
        
        if (!isAuthenticated && !isLoggingIn) {
          return '/login';
        }
        
        if (isAuthenticated && isLoggingIn) {
          return '/home';
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/add-workout',
          builder: (context, state) => const AddWorkoutScreen(),
        ),
        GoRoute(
          path: '/progress',
          builder: (context, state) => const ProgressScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/bmi',
          builder: (context, state) => const BmiScreen(),
        ),
        GoRoute(
          path: '/calories',
          builder: (context, state) => const CaloriesScreen(),
        ),
        GoRoute(
          path: '/measurements',
          builder: (context, state) => const MeasurementsScreen(),
        ),
        GoRoute(
          path: '/routines',
          builder: (context, state) => const RoutinesScreen(),
        ),
        GoRoute(
          path: '/timer',
          builder: (context, state) => const TimerScreen(),
        ),
        GoRoute(
          path: '/goals',
          builder: (context, state) => const GoalsScreen(),
        ),
        GoRoute(
          path: '/nutrition',
          builder: (context, state) => const NutritionScreen(),
        ),
        GoRoute(
          path: '/faq',
          builder: (context, state) => const FaqScreen(),
        ),
        GoRoute(
          path: '/achievements',
          builder: (context, state) => const AchievementsScreen(),
        ),
        GoRoute(
          path: '/export',
          builder: (context, state) => const ExportDataScreen(),
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutScreen(),
        ),
      ],
    );
  }
}
