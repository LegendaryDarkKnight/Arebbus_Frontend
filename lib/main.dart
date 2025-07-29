import 'package:arebbus/service/auth_provider.dart' show AuthProvider;
import 'package:arebbus/services/location_tracking_service.dart';
import 'package:flutter/material.dart';
import 'package:arebbus/screens/login_screen.dart';
import 'package:arebbus/screens/register_screen.dart';
import 'package:arebbus/screens/home_screen.dart';
import 'package:arebbus/screens/bus_list_screen.dart';
import 'package:arebbus/config/app_config.dart';
import 'package:provider/provider.dart' show ChangeNotifierProvider, Consumer;

/// Entry point of the Arebbus Flutter application.
/// 
/// This function initializes the application by:
/// - Ensuring Flutter binding is initialized for platform-specific features
/// - Loading application configuration from environment variables
/// - Initializing the location tracking service singleton for background tracking
/// - Setting up the Provider pattern for global state management
/// - Bootstrapping the authentication provider for user session management
/// 
/// The app uses a Provider-based architecture for state management and includes
/// comprehensive routing, theming, and authentication handling.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initializeFromEnv();
  
  // Initialize location tracking service
  // It will start tracking automatically when user status changes
  LocationTrackingService.instance;
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider()..initAuth(),
      child: ArebbusApp(),
    ),
  );
}

/// Route names used throughout the app
/// 
/// Defines all the named routes used in the application for navigation.
/// Using constants helps maintain consistency and prevents typos in route names.
/// These routes map to different screens and features in the Arebbus app:
/// - authWrapper: Initial route that determines authentication state
/// - login/register: Authentication screens for user access
/// - home: Main dashboard after successful authentication
/// - allBuses/installedBuses: Bus listing screens with different filters
/// - busDetail: Individual bus information and tracking screen
class AppRoutes {
  static const String authWrapper = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String allBuses = '/buses';
  static const String installedBuses = '/installed-buses';
  static const String busDetail = '/bus-detail';
}

/// The main application widget
/// 
/// ArebbusApp serves as the root widget of the Flutter application and is responsible for:
/// - Configuring the MaterialApp with app-wide settings
/// - Setting up the visual theme using AppTheme.buildTheme()
/// - Defining the route table for navigation between screens
/// - Configuring the initial route to start with authentication checking
/// - Enabling/disabling debug features like the debug banner
/// 
/// This widget is wrapped by a ChangeNotifierProvider in main() to provide
/// access to AuthProvider throughout the widget tree for state management.
class ArebbusApp extends StatelessWidget {
  const ArebbusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arebbus New',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(),
      initialRoute: AppRoutes.authWrapper,
      routes: {
        AppRoutes.authWrapper: (context) => const AuthWrapper(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.allBuses: (context) => const BusListScreen(showBottomNav: true),
        AppRoutes.installedBuses: (context) => const BusListScreen(showInstalledOnly: true, showBottomNav: true),
      },
    );
  }
}

/// AuthWrapper to decide which screen to show based on auth status
/// 
/// This widget acts as a smart router that determines the initial screen
/// based on the user's authentication state. It uses the Consumer pattern
/// to listen to AuthProvider changes and:
/// 
/// - Shows a loading indicator while authentication status is being checked
/// - Navigates to HomeScreen if user is authenticated
/// - Navigates to LoginScreen if user is not authenticated
/// - Uses pushReplacementNamed to prevent back navigation to this wrapper
/// 
/// The navigation logic is wrapped in addPostFrameCallback to ensure
/// the widget tree is fully built before performing navigation.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while checking auth status
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (authProvider.isLoggedIn) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          } else {
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          }
        });

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

/// Centralized theme builder for the Arebbus app
/// 
/// AppTheme provides a consistent Material Design 3 theme configuration
/// for the entire application. The theme includes:
/// 
/// - Color scheme based on teal as the seed color for brand consistency
/// - Custom AppBar styling with teal background and white text
/// - Elevated button theming with teal accent and rounded corners
/// - Input decoration with focused teal borders and rounded corners
/// - Card theming with consistent elevation and shadow styling
/// - Bottom navigation bar theming with teal accents
/// - Button theming for legacy widgets with consistent styling
/// 
/// All components follow Material 3 design principles while maintaining
/// the Arebbus brand identity through the consistent use of teal colors.
class AppTheme {
  /// Builds and returns the complete theme configuration for the app.
  /// 
  /// Creates a comprehensive ThemeData object that defines the visual
  /// appearance of all UI components throughout the application.
  /// The theme uses teal as the primary color and includes:
  /// 
  /// - Material 3 design system with teal color scheme
  /// - Roboto font family for consistent typography
  /// - Custom component themes for AppBar, buttons, inputs, and cards
  /// - Adaptive platform density for optimal display across devices
  /// 
  /// @return ThemeData configured with Arebbus branding and Material 3 styling
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
      cardTheme: CardThemeData(
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