// En un nuevo archivo: screens/vista_usuario_quejas.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth_provider.dart';
import '../models/queja.dart';
import '../services/queja_service.dart';
class VistaUsuarioQuejas extends StatefulWidget {
   VistaUsuarioQuejas({super.key});

  @override
  State<VistaUsuarioQuejas> createState() => _VistaUsuarioQuejasState();
}

class _VistaUsuarioQuejasState extends State<VistaUsuarioQuejas> {
  late Future<List<Queja>> _misQuejasFuture;
  final QuejaService _quejaService = QuejaService();


  @override
  void initState() {
    super.initState();
    // Llama al servicio para obtener las quejas del usuario logueado.
    // El ApiService debería usar el token del AuthProvider para hacer la llamada segura.
    final QuejaService _quejaService = QuejaService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Este método se llama después de initState y cuando las dependencias (como Provider) cambian.
    // Es el lugar seguro para obtener datos del Provider.
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = authProvider.userEmail;

    if (userEmail != null) {
      // Llama al método pasándole el email del usuario logueado.
      _misQuejasFuture = _quejaService.obtenerMisQuejas(userEmail); // <-- 5. Pasa el email
    } else {
      // Maneja el caso en que el email no esté disponible (no debería pasar si está logueado)
      _misQuejasFuture = Future.error('No se pudo identificar el email del usuario.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Queja>>(
      future: _misQuejasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar tus quejas: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Aún no has enviado ninguna queja o sugerencia.'));
        }

        final misQuejas = snapshot.data!;
        // Muestra una lista simple de las quejas del usuario.
        // El usuario solo puede verlas, no puede atenderlas ni eliminarlas.
        return ListView.builder(
          itemCount: misQuejas.length,
          itemBuilder: (ctx, index) {
            final queja = misQuejas[index];
            return Card(
              margin:  EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: ListTile(
                leading: Icon(
                  queja.estado == 'Pendiente' ? Icons.hourglass_top : Icons.check_circle,
                  color: queja.estado == 'Pendiente' ? Colors.orange : Colors.green,
                ),
                title: Text(queja.categoria, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(queja.mensaje),
                trailing: Text(queja.estado),
              ),
            );
          },
        );
      },
    );
  }
}
