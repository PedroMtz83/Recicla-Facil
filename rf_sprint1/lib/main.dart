import 'package:flutter/material.dart';
import 'package:rf_sprint1/views/formulario_screen.dart';
import 'views/login_screen.dart'; // Asegúrate de que la ruta sea correcta

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

      // --- CAMBIO CLAVE ---
      // Asigna LoginScreen directamente como la pantalla de inicio.
      // Ya no se necesita el Scaffold ni el SizedBox aquí.
      home:  LoginScreen(),

      debugShowCheckedModeBanner: false,

      // Opcional: Si quieres definir rutas nombradas para la navegación
      routes: {
        '/home': (context) =>  HomeScreen(), // Asume que tienes un HomeScreen
        '/login':(context) =>  LoginScreen(),
        '/qys':(context) =>  FormularioScreen(),
        // '/register': (context) => const RegisterScreen(),
      },
    );
  }
}

// Ejemplo de un HomeScreen para que las rutas funcionen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página Principal')),
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('¡Bienvenido! Has iniciado sesión.'),
            FilledButton(onPressed: (){
              _abrirQuejasSugerencias(context);
            }, child: Text("Quejas y sugerencias")
            ),
            FilledButton(onPressed: (){
              _cerrarSesion(context);
            }, child: Text("Cerrar sesión")
            ),
          ]
            ),
      ),
    );
  }
  void _cerrarSesion(BuildContext context){
    Navigator.pushReplacementNamed(context, '/login');
  }
  void _abrirQuejasSugerencias(BuildContext context){
    Navigator.pushReplacementNamed(context, '/qys');
  }
}
