import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:rf_sprint1/views/admin_puntos_screen.dart';
import 'package:rf_sprint1/views/contenido_screen.dart';

// Importa tus vistas y providers
import 'package:rf_sprint1/views/perfilUsuario_screen.dart';
import 'package:rf_sprint1/views/puntos_screen.dart';
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
    ProfileScreen(),
    QuejasTabsScreen(),
    ContenidoScreen(),
    PuntosScreen(),
    AdminPuntosScreen()
  ];

  final List<String> _pageTitles = [
    "Mi perfil",
    "Quejas y sugerencias",
    'Contenido informativo',
    'Puntos de reciclaje',
    'Gestionar Puntos de reciclaje'
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pop(context);
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return ProfileScreen();
      case 1:
        return QuejasTabsScreen();
      case 2:
        return ContenidoScreen();
      case 3:
        return PuntosScreen();
      case 4:
        return AdminPuntosScreen();
      default:
        return ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_currentIndex]),
        backgroundColor: Colors.green,
        elevation: 4.0,
        actions: [
          IconButton(
            tooltip: 'Cerrar Sesión',
            icon: Icon(Icons.logout),
            onPressed: () => _confirmarCerrarSesion(context),
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                'Menú de Navegación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Perfil'),
              selected: _currentIndex == 0,
              selectedTileColor: Colors.green.withOpacity(0.1), // Color de fondo cuando está seleccionado.
              onTap: () {
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.subject),
              title: Text('Quejas y sugerencias'),
              selected: _currentIndex == 1,
              selectedTileColor: Colors.green.withOpacity(0.1),
              onTap: () {
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Contenido informativo'),
              selected: _currentIndex == 2,
              selectedTileColor: Colors.green.withOpacity(0.1),
              onTap: () {
                _onItemTapped(2);
              },
            ),
            ListTile(
              leading: Icon(Icons.pin_drop),
              title: Text('Puntos de reciclaje'),
              selected: _currentIndex == 3,
              selectedTileColor: Colors.green.withOpacity(0.1),
              onTap: () {
                _onItemTapped(3);
              },
            ),
            ListTile(
              leading: Icon(Icons.admin_panel_settings),
              title: Text('Gestionar Puntos de reciclaje'),
              selected: _currentIndex == 4,
              selectedTileColor: Colors.green.withOpacity(0.1),
              onTap: () {
                _onItemTapped(4);
              },
            ),
          ],
        ),
      ),
      body: _buildCurrentPage(),
    );
  }

  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                _hacerCerrarSesion(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }

  void _hacerCerrarSesion(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.cerrarSesion();
  }

}
