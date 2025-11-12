import 'package:flutter/material.dart';

class SolicitudesPuntosScreen extends StatefulWidget {
  const SolicitudesPuntosScreen({super.key});

  @override
  State<SolicitudesPuntosScreen> createState() => _SolicitudesPuntosScreenState();
}

class _SolicitudesPuntosScreenState extends State<SolicitudesPuntosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ver solicitudes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Center(child: Text("Aquí se mostrarán las solicitudes hechas por el usuario"))
    );

  }
}




