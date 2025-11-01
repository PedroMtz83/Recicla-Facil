import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../widgets/formulario_queja_widget.dart'; // El formulario que refactorizamos
import 'gestionquejas_screen.dart';
import 'login_screen.dart';

class QuejasTabsScreen extends StatelessWidget {
  const QuejasTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // DefaultTabController es la forma más fácil de crear pestañas.
    return DefaultTabController(
      length: 2, // Tendremos 2 pestañas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quejas y Sugerencias'),
          backgroundColor: Colors.green, // Un color que combine con tu app
          elevation: 2,
          // El TabBar se coloca en la parte inferior del AppBar.
          actions: [
            // Botón para cerrar sesión
            IconButton(
              tooltip: 'Cerrar Sesión',
              icon: const Icon(Icons.logout),
              onPressed: () {
                // Llama al método logout del provider
                Provider.of<AuthProvider>(context, listen: false).logout();
                // Redirige al usuario a la pantalla de login y limpia el historial de navegación
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) =>  LoginScreen()),
                      (Route<dynamic> route) => false,
                );
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
                // El texto de la pestaña cambia según el rol del usuario
                text: authProvider.isAdmin ? 'Gestionar Quejas' : 'Mis Mensajes',
              ),
            ],
          ),
        ),
        // TabBarView contiene el contenido de cada pestaña.
        body: TabBarView(
          children: [
            // Pestaña 1: El formulario para enviar quejas.
            FormularioQuejaWidget(),

            // Pestaña 2: La pantalla inteligente que muestra la vista
            // de admin o de usuario según corresponda.
            GestionQuejasScreen(),
          ],
        ),
      ),
    );
  }
}
