import 'package:flutter/material.dart';
import 'package:rf_sprint1/views/datosUsuario.dart';
import 'package:rf_sprint1/views/formulario_screen.dart';
import 'package:rf_sprint1/views/register_screen.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'views/login_screen.dart'; 

void main() {

  runApp(
      MultiProvider(
          providers: [
            // Aquí "provees" tu AuthProvider. Cualquier widget en la app
            // podrá acceder a él para saber si el usuario está logueado y
            // obtener sus datos (email, nombre).
            ChangeNotifierProvider(create: (_) => AuthProvider()),

            // Si en el futuro necesitas otro provider (ej. para las quejas),
            // lo añadirías aquí:
            // ChangeNotifierProvider(create: (_) => QuejaProvider()),
          ],
      child: MyApp(),
      ),
    );
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
      home:  LoginScreen(),
      initialRoute: '/login',
      debugShowCheckedModeBanner: false,

      // Opcional: Si quieres definir rutas nombradas para la navegación
      routes: {
        '/home': (context) =>  HomeScreen(), // Asume que tienes un HomeScreen
        '/login':(context) =>  LoginScreen(),
        '/qys':(context) =>  FormularioScreen(),
        '/register':(context) => RegisterScreen(),
        '/profile':(context) => ProfileScreen(),
        // '/register': (context) => const RegisterScreen(),
      },
    );
  }
}

// Ejemplo de un HomeScreen para que las rutas funcionen
// En tu archivo home_screen.dart


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Renombrado para mayor claridad

  // --- PASO 2: Define una lista de widgets que corresponden a cada ítem del menú ---
  // Estos son los "cuerpos" que se mostrarán en el Scaffold.
  final List<Widget> _pages = [
     ProfileScreen(), // Índice 0: Perfil
     FormularioScreen(), // Índice 1: Quejas y Sugerencias
    // El índice 2 (Cerrar Sesión) no necesita una página, es una acción.
  ];

  void _onItemTapped(int index) {
    // --- PASO 3: Lógica de navegación mejorada ---

    // Si el índice es para cerrar sesión, ejecuta la acción y no cambies de página.
    if (index == 2) {
      _cerrarSesion(context);
    } else {
      // Si es cualquier otra página, actualiza el estado para cambiar el contenido.
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El AppBar puede ser dinámico si quieres, o simplemente mostrar el título general.
      appBar: AppBar(
        title: Text(_getAppBarTitle(_currentIndex)),
        automaticallyImplyLeading: false, // Evita que aparezca un botón de "atrás"
      ),
      // --- PASO 4: Muestra la página correspondiente al índice actual ---
      // Si el índice es 2 (Cerrar Sesión), mostramos un loader mientras se cierra.
      body: _currentIndex == 2
          ? const Center(child: CircularProgressIndicator())
          : _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
          BottomNavigationBarItem(icon: Icon(Icons.subject), label: "Quejas y sugerencias"),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Cerrar sesión"),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped, // Llama a la nueva lógica de navegación
      ),
    );
  }

  // Función para cerrar sesión de forma segura
  void _cerrarSesion(BuildContext context) {
    // Llama al método logout del provider para limpiar el estado
    Provider.of<AuthProvider>(context, listen: false).logout();

    // Navega a la pantalla de login y elimina todas las rutas anteriores
    // para que el usuario no pueda "volver atrás" a la pantalla de home.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  // Función auxiliar para tener títulos de AppBar dinámicos
  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Mi Perfil';
      case 1:
        return 'Quejas y Sugerencias';
      default:
        return 'ReciclaFácil';
    }
  }
}
