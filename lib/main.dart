import 'package:arebbus/screens/login_screen.dart';
import 'package:arebbus/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:arebbus/screens/home_screen.dart';

void main(){
  const baseUrl = String.fromEnvironment("BASE_URL", defaultValue: "http://localhost:6996");
  debugPrint("Base URL: $baseUrl");
  runApp(Arebbus());
}

class Arebbus extends StatelessWidget{
  const Arebbus({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Arebbus",
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Example font
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 4.0,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.tealAccent[700],
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
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
        cardTheme: CardTheme(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.teal),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.tealAccent[700]!, width: 2.0),
          ),
          labelStyle: const TextStyle(color: Colors.teal),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.tealAccent[700],
          unselectedItemColor: Colors.grey[600],
          backgroundColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        // Add other routes here as you create more screens
      },
    );
  }
  
}