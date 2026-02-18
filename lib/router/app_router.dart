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
      ],
    );
  }
}
