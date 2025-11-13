// En un nuevo archivo: screens/vista_usuario_quejas.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../models/queja.dart';
import '../services/queja_service.dart';
class VistaUsuarioQuejas extends StatefulWidget {
   const VistaUsuarioQuejas({super.key});

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
    final QuejaService _ = QuejaService();
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
                onTap: (){
                  _mostrarVistaQueja(queja);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarVistaQueja(Queja q){
    showDialog(
      context: context,
      builder: (context) {
        // Para formatear las fechas de una manera más legible
        final DateFormat formatter = DateFormat('dd/MM/yyyy - hh:mm a');

        return AlertDialog(
          // 1. Título del diálogo
          title: Text('Detalles de la Queja'),

          // 2. Quitamos el padding por defecto para que la Card se ajuste bien.
          contentPadding: EdgeInsets.zero,

          // 3. El contenido principal ahora es una Card.
          content: Card(
            // La Card no necesita sombra ni bordes extra aquí,
            // porque ya está dentro de un AlertDialog.
            elevation: 0,
            margin: EdgeInsets.zero,

            // 4. SingleChildScrollView para evitar que el contenido se desborde
            //    si los textos son muy largos.
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0), // Padding interno para la Card
              child: Column(
                mainAxisSize: MainAxisSize.min, // Hace que la columna sea compacta
                crossAxisAlignment: CrossAxisAlignment.start, // Alinea todo a la izquierda
                children: [
                  // --- Usaremos un widget auxiliar para no repetir código ---
                  _construirInfoRenglon(
                    icon: Icons.category,
                    label: 'Categoría',
                    value: q.categoria,
                  ),
                  _construirInfoRenglon(
                    icon: Icons.message,
                    label: 'Mensaje',
                    value: q.mensaje,
                  ),
                  _construirInfoRenglon(
                    icon: q.estado == 'Pendiente' ? Icons.hourglass_top : Icons.check_circle,
                    label: 'Estado',
                    value: q.estado,
                    // Color condicional para el valor
                    valueColor: q.estado == 'Pendiente' ? Colors.orange.shade700 : Colors.green.shade700,
                  ),
                  _construirInfoRenglon(
                    icon: Icons.calendar_today,
                    label: 'Fecha de Creación',
                    // Formateamos la fecha para que sea más legible
                    value: formatter.format(q.fechaCreacion),
                  ),
                  // Mostramos la respuesta solo si no está vacía o es nula
                  if (q.respuestaAdmin != null && q.respuestaAdmin!.isNotEmpty)
                    _construirInfoRenglon(
                      icon: Icons.admin_panel_settings,
                      label: 'Respuesta del Admin',
                      value: q.respuestaAdmin!,
                    ),
                  // Mostramos la fecha de atención solo si existe
                  if (q.fechaAtencion != null)
                    _construirInfoRenglon(
                      icon: Icons.event_available,
                      label: 'Fecha de Atención',
                      value: formatter.format(q.fechaAtencion!),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
          // Es una buena práctica redondear los bordes del AlertDialog también
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        );
      },
    );
  }

  Widget _construirInfoRenglon({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? Colors.black54, // Usa el color pasado o negro por defecto
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
