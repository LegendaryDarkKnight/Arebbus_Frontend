import 'package:arebbus/screens/login_screen.dart';
import 'package:arebbus/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:arebbus/screens/home_screen.dart';

void main(){
  const baseUrl = String.fromEnvironment("BASE_URL", defaultValue: "http://localhost:6996");
  print("Base URL: $baseUrl");
  runApp(Arebbus());
}

class Arebbus extends StatelessWidget{
  const Arebbus({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Arebbus",
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        // Add other routes here as you create more screens
      },
    );
  }
}