import 'package:flutter/material.dart';
import 'views/formulario_screen.dart';
import 'datosUsuario.dart';
import 'views/login_screen.dart'; // Asegúrate de que la ruta sea correcta
import 'vars.dart';

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
        '/profile':(context) =>  ProfileScreen(userEmail: email),
        // '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
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
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        BottomNavigationBarItem(icon: Icon(Icons.subject), label: "Quejas y sugerencias"),
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Cerrar sesión"),
      ],
        currentIndex: index,
        onTap: (index){
          setState(() {
            this.index=index;
          });
          contenido();
        }

      ),

    );
  }
  void _cerrarSesion(BuildContext context){
    Navigator.pushReplacementNamed(context, '/login');
  }
  void _abrirQuejasSugerencias(BuildContext context){
    Navigator.pushReplacementNamed(context, '/qys');
  }
  void _abrirPerfil(BuildContext context){
    Navigator.pushReplacementNamed(context, '/profile');
  }
  void contenido(){
    switch(index){
      case 0:
        _abrirPerfil(context);
        break;
      case 1:
        _abrirQuejasSugerencias(context);
        break;
      case 2:
        _cerrarSesion(context);
        break;
      default:
        break;
    }

  }

}

// Ejemplo de un HomeScreen para que las rutas funcionen
/*class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int index=0;
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
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
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        BottomNavigationBarItem(icon: Icon(Icons.subject), label: "Quejas y sugerencias"),
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Cerrar sesión"),
      ],
        currentIndex: index,
      ),
    );
  }
  void _cerrarSesion(BuildContext context){
    Navigator.pushReplacementNamed(context, '/login');
  }
  void _abrirQuejasSugerencias(BuildContext context){
    Navigator.pushReplacementNamed(context, '/qys');
  }
}*/

