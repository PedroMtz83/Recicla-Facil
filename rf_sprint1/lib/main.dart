import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importa tus vistas y providers
import 'package:rf_sprint1/views/perfilUsuario_screen.dart';
import 'package:rf_sprint1/views/quejas_tabs_screen.dart';
import 'package:rf_sprint1/views/register_screen.dart';
import 'package:rf_sprint1/views/login_screen.dart';
import 'auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // La instancia de AuthProvider se crea aquí, fuera del MaterialApp.
        // Ahora es persistente y no se reiniciará con las reconstrucciones de la UI.
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Si en el futuro necesitas otro provider, lo añadirías aquí:
        // ChangeNotifierProvider(create: (_) => QuejaProvider()),
      ],
      // El hijo ahora es el widget que CONSTRUYE la UI basándose en el estado.
      child: MyApp(),
    ),
  );
}

// El rol de MyApp ahora es leer el estado de los providers y construir
// el MaterialApp en consecuencia. Ya no crea estado, solo lo consume.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos context.watch para que el widget se reconstruya automáticamente
    // cuando el estado de autenticación cambie (ej. al hacer login/logout).
    final authProvider = context.watch<AuthProvider>();


    return MaterialApp(
      key: ValueKey(authProvider.isLoggedIn),
      title: 'RECICLAFÁCIL',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,

      // Si el usuario está logueado, muestra
      // HomeScreen. Si no, muestra LoginScreen. Como AuthProvider ya no se
      // reinicia, esta lógica es ahora estable y no causará el bug.
      home: authProvider.isLoggedIn ? HomeScreen() : LoginScreen(),

      // Define las rutas nombradas para una navegación limpia.
      routes: {
        // No necesitas una ruta para '/home' si la gestionas con la lógica de 'home:'.
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/profile': (context) => ProfileScreen(),
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
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ProfileScreen(), // Índice 0: Perfil
    QuejasTabsScreen(), // Índice 1: Quejas y Sugerencias
  ];

  void _onItemTapped(int index) {
      setState(() {
        _currentIndex = index;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
          BottomNavigationBarItem(icon: Icon(Icons.subject), label: "Quejas"),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

}
