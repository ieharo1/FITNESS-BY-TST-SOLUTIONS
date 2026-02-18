import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';
import 'ui/viewmodels/auth_viewmodel.dart';
import 'ui/viewmodels/home_viewmodel.dart';
import 'ui/viewmodels/workout_viewmodel.dart';
import 'ui/viewmodels/progress_viewmodel.dart';
import 'ui/viewmodels/profile_viewmodel.dart';
import 'ui/viewmodels/bmi_viewmodel.dart';
import 'ui/viewmodels/calories_viewmodel.dart';
import 'ui/viewmodels/measurements_viewmodel.dart';
import 'ui/viewmodels/routine_viewmodel.dart';
import 'ui/viewmodels/goals_viewmodel.dart';
import 'ui/viewmodels/nutrition_viewmodel.dart';
import 'ui/viewmodels/theme_provider.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  FirebaseFirestore.instance.settings = const Settings(
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    persistenceEnabled: true,
  );
  
  await initializeDateFormatting('es_ES', null);
  runApp(const FitTrackApp());
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => WorkoutViewModel()),
        ChangeNotifierProvider(create: (_) => ProgressViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => BmiViewModel()),
        ChangeNotifierProvider(create: (_) => CaloriesViewModel()),
        ChangeNotifierProvider(create: (_) => MeasurementsViewModel()),
        ChangeNotifierProvider(create: (_) => RoutineViewModel()),
        ChangeNotifierProvider(create: (_) => GoalsViewModel()),
        ChangeNotifierProvider(create: (_) => NutritionViewModel()),
      ],
      child: Consumer2<AuthViewModel, ThemeProvider>(
        builder: (context, authViewModel, themeProvider, child) {
          return MaterialApp.router(
            title: 'Fitness By TST',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router(context),
          );
        },
      ),
    );
  }
}
