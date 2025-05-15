import 'package:flutter/material.dart';
import 'package:arebbus/screens/home_screen.dart';

void main(){
  runApp(Arebbus());
}

class Arebbus extends StatelessWidget{
  const Arebbus({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Arebbus",
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        // '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        // Add other routes here as you create more screens
      },
    );
  }
}