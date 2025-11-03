import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../widgets/formulario_queja_widget.dart';
import 'gestionquejas_screen.dart';
import 'login_screen.dart';

class QuejasTabsScreen extends StatelessWidget {
  const QuejasTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quejas y Sugerencias'),
          backgroundColor: Colors.green,
          elevation: 2,
          actions: [
            // Botón para cerrar sesión
            IconButton(
              tooltip: 'Cerrar Sesión',
              icon: const Icon(Icons.logout),
              onPressed: () {
                _confirmLogout(context);
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3.0,
            labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            tabs: [
              const Tab(
                icon: Icon(Icons.edit_document),
                text: 'Enviar Mensaje',
              ),
              Tab(
                icon: const Icon(Icons.view_list),
                text: authProvider.isAdmin ? 'Gestionar Quejas' : 'Mis Mensajes',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña 1: El formulario para enviar quejas.
            FormularioQuejaWidget(),

            // Pestaña 2: La pantalla inteligente que muestra la vista
            // de admin o de usuario según corresponda.
            const GestionQuejasScreen(),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  // CONFIRMAR CERRAR SESIÓN
  // ===================================================================
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
                _performLogout(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  // ===================================================================
  // REALIZAR EL CIERRE DE SESIÓN
  // ===================================================================
  void _performLogout(BuildContext context) {
    // Obtener el provider y hacer logout
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.cerrarSesion();

    // Navegar al login y limpiar el stack de navegación
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );

    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sesión cerrada exitosamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}