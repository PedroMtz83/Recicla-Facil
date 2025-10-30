import 'package:flutter/material.dart';
import 'views/login_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RECICLAFÁCIL',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Scaffold(
        body: SizedBox(
          width: 533,
          height: 800,
          child: LoginScreen(), 
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}