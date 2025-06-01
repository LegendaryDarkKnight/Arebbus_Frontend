import 'package:arebbus/service/auth_provider.dart' show AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:arebbus/screens/login_screen.dart';
import 'package:arebbus/screens/register_screen.dart';
import 'package:arebbus/screens/home_screen.dart';
import 'package:arebbus/config/app_config.dart';
import 'package:provider/provider.dart' show ChangeNotifierProvider, Consumer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();
  // if (kIsWeb) {
  //   await Firebase.initializeApp(
  //     options: FirebaseOptions(
  //       apiKey: AppConfig.instance.apiKey,
  //       appId: AppConfig.instance.appId,
  //       messagingSenderId: AppConfig.instance.messagingSenderId,
  //       projectId: AppConfig.instance.projectId,
  //     ),
  //   );
  // }
  
  // FIX: Add runApp() here!
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider()..initAuth(),
      child: ArebbusApp(),
    ),
  );
}

/// Route names used throughout the app
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
}

/// The main application widget
class ArebbusApp extends StatelessWidget {
  const ArebbusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arebbus New',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(),
      home: AuthWrapper(), // Use AuthWrapper instead of initialRoute
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
      },
    );
  }
}

/// AuthWrapper to decide which screen to show based on auth status
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while checking auth status
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show home screen if logged in, otherwise show login screen
        if (authProvider.isLoggedIn) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

/// Centralized theme builder for the Arebbus app
class AppTheme {
  static ThemeData buildTheme() {
    final Color seedColor = Colors.teal;

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 4.0,
        centerTitle: true,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent[700],
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.tealAccent[700]!, width: 2.0),
        ),
        labelStyle: const TextStyle(color: Colors.teal),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 3,
        shadowColor: Colors.grey[300],
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.tealAccent[700],
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),

      // General Button Theme (for legacy widgets)
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.tealAccent[700],
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),

      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}