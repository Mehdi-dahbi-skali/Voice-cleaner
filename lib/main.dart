import 'package:flutter/material.dart';
import 'login/login_screen.dart';
import 'screens/onboarding_screen.dart';

/// Main entry point of the Flutter application
/// 
/// This is where the app starts when launched
void main() {
  runApp(const MyApp());
}

/// Root widget of the application
/// 
/// This widget sets up the Material Design theme and
/// provides the app structure
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App title shown in task switcher
      title: 'Flutter Frontend',
      
      // Remove debug banner in top right corner
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: ThemeData(
        // Primary color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        
        // Use Material 3 design
        useMaterial3: true,
        
        // Card theme
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        // App bar theme
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      
      // Entry point - Now shows OnboardingScreen first
      home: const OnboardingScreen(),
    );
  }
}

