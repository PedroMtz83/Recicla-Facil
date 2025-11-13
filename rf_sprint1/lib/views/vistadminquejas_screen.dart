// En un nuevo archivo: screens/vista_admin_quejas.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/queja_service.dart';
import '../models/queja.dart';
class VistaAdminQuejas extends StatefulWidget {
   VistaAdminQuejas({super.key});

  @override
  State<VistaAdminQuejas> createState() => _VistaAdminQuejasState();
}

class _VistaAdminQuejasState extends State<VistaAdminQuejas> {
  late Future<List<Queja>> _quejasFuture;
  final QuejaService _quejaService = QuejaService();
  bool _isActionLoading = false;
  String? _categoriaFiltro;
  final List<String> _categoriasDisponibles = [
    // La primera opción siempre será para ver todas las quejas.
    'Todas las Pendientes',
    // El resto de categorías que usas en tu formulario.
    'Sugerencia / Nueva Funcionalidad',
    'Duda',
    'Reporte de Falla Técnica (Error)',
    'Diseño y Facilidad de Uso',
    'Información sobre Reciclaje',
    'Cuenta / Perfil',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _recargarQuejas();
  }

  void _recargarQuejas() {
    setState(() {
      // Si no hay filtro o el filtro es "Todas", llamamos al método original.
      if (_categoriaFiltro == null || _categoriaFiltro == 'Todas las Pendientes') {
        _quejasFuture = _quejaService.obtenerQuejasPendientes();
      } else {
        // Si hay una categoría seleccionada, llamamos al nuevo método.
        _quejasFuture = _quejaService.obtenerQuejasPorCategoria(_categoriaFiltro!);
      }
    });
  }

  void _mostrarSnackBar(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : Colors.green,
      ),
    );
  }

  void _atenderQueja(Queja queja) {
    final respuestaController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final DateFormat formato = DateFormat('dd/MM/yyyy - hh:mm a');

    showDialog(
      context: context,
      builder: (ctx) {
        return Center(
          child: SizedBox(
            // Usamos un ancho ligeramente menor para pantallas muy pequeñas
            width: MediaQuery.of(context).size.width.clamp(300.0, 500.0),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: Text('Atender Queja'),
              contentPadding: EdgeInsets.only(top: 20.0), // Padding solo arriba

              content: Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                color: Colors.transparent,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- INFORMACIÓN DE CONTEXTO AÑADIDA ---
                      _construirInfoSoloLectura(
                        icon: Icons.calendar_today,
                        label: 'Fecha de Creación',
                        value: formato.format(queja.fechaCreacion),
                      ),
                      SizedBox(height: 12),
                      _construirInfoSoloLectura(
                        icon: Icons.message,
                        label: 'Mensaje del Usuario',
                        value: queja.mensaje,
                      ),
                      Divider(height: 32, thickness: 0.8), // Separador visual

                      // --- FORMULARIO PARA LA RESPUESTA ---
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Form(
                          key: formKey,
                          child: TextFormField(
                            controller: respuestaController,
                            decoration: InputDecoration(
                              labelText: 'Tu Respuesta',
                              hintText: 'Escribe aquí tu respuesta...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 4,
                            autofocus: true,
                            validator: (value) => value == null || value.trim().isEmpty
                                ? 'La respuesta no puede estar vacía'
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 24), // Espacio al final del contenido
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      // ... (El resto de tu lógica de onPressed no necesita cambios)
                      if (_isActionLoading) return;
                      setState(() => _isActionLoading = true);
                      Navigator.of(ctx).pop();
                      try {
                        final resultado = await _quejaService.atenderQueja(
                            queja.id, // Usamos el id del objeto queja
                            respuestaController.text);
                        if (mounted) {
                          if (resultado['statusCode'] == 200) {
                            _mostrarSnackBar('Queja atendida correctamente.');
                            _recargarQuejas();
                          } else {
                            _mostrarSnackBar(resultado['mensaje'] ?? 'Error al atender la queja.', esError: true);
                          }
                        }
                      } catch (e) {
                        if (mounted) _mostrarSnackBar(e.toString(), esError: true);
                      } finally {
                        if (mounted) setState(() => _isActionLoading = false);
                      }
                    }
                  },
                  child: Text('Enviar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _construirInfoSoloLectura({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
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
                    color: Colors.grey.shade800,
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
  // ==========================================================
  // LÓGICA PARA ELIMINAR QUEJA
  // ==========================================================
  void _eliminarQueja(String quejaId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:  Text('Confirmar Eliminación'),
        content:  Text('¿Estás seguro de que deseas eliminar esta queja? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:  Text('No'),
          ),
          // Botón rojo para confirmar la eliminación
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            icon:  Icon(Icons.warning),
            label:  Text('Sí, Eliminar'),
            onPressed: () async {
              // Bloquea múltiples clics
              if (_isActionLoading) return;
              setState(() => _isActionLoading = true);

              // Cierra el diálogo
              Navigator.of(ctx).pop();

              try {
                final resultado = await _quejaService.eliminarQueja(quejaId);
                if (resultado['statusCode'] == 200) {
                  _mostrarSnackBar('Queja eliminada correctamente.');
                  _recargarQuejas(); // Actualiza la lista
                } else {
                  _mostrarSnackBar(
                      resultado['mensaje'] ?? 'Error al eliminar la queja.',
                      esError: true);
                }
              } catch (e) {
                _mostrarSnackBar(e.toString(), esError: true);
              } finally {
                setState(() => _isActionLoading = false);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- WIDGET DEL FILTRO DE CATEGORÍAS ---
        Padding(
          padding:  EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: DropdownButtonFormField<String>(
            value: _categoriaFiltro ?? 'Todas las Pendientes',
            hint:  Text("Filtrar por categoría"),
            decoration:  InputDecoration(
              labelText: 'Filtro de Categorías',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.filter_list),
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
            isExpanded: true,
            items: _categoriasDisponibles.map((String categoria) {
              return DropdownMenuItem<String>(
                value: categoria,
                child: Text(
                  categoria,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (String? nuevoValor) {
              setState(() {
                _categoriaFiltro = nuevoValor;
                _recargarQuejas();
              });
            },
          ),
        ),

        // --- LISTA DE RESULTADOS DE QUEJAS ---
        // 'Expanded' es crucial para que la lista ocupe todo el espacio vertical
        // restante en la pantalla después del filtro.
        Expanded(
          child: Stack(
            children: [
              FutureBuilder<List<Queja>>(
                // El FutureBuilder ahora escucha a la variable genérica '_quejasFuture'.
                future: _quejasFuture,
                builder: (context, snapshot) {
                  // 1. Estado de Carga
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Muestra un loader solo si no hay una acción (atender/eliminar) ya en curso.
                    return _isActionLoading
                        ?  SizedBox.shrink()
                        :  Center(child: CircularProgressIndicator());
                  }

                  // 2. Estado de Error
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding:  EdgeInsets.all(16.0),
                        child: Text(
                          'Error al cargar las quejas: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style:  TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  // 3. Estado de Sin Datos
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return  Center(
                      child: Text(
                        'No hay quejas que coincidan con el filtro seleccionado.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  // 4. Estado Exitoso (Hay datos para mostrar)
                  final quejas = snapshot.data!;
                  return ListView.builder(
                    padding:  EdgeInsets.only(top: 8.0),
                    itemCount: quejas.length,
                    itemBuilder: (ctx, index) {
                      final queja = quejas[index];
                      return Card(
                        margin:  EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                        elevation: 3,
                        child: ListTile(
                          title: Text(
                            '${queja.categoria} - (${queja.correo})',
                            style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Padding(
                            padding:  EdgeInsets.only(top: 4.0),
                            child: Text(queja.mensaje, style: TextStyle(color: Colors.grey[700])),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:  Icon(Icons.check_circle_outline, color: Colors.green),
                                onPressed: () => _atenderQueja(queja),
                                tooltip: 'Atender Queja',
                              ),
                              IconButton(
                                icon:  Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _eliminarQueja(queja.id),
                                tooltip: 'Eliminar Queja',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              // --- INDICADOR DE CARGA PARA ACCIONES (ATENDER/ELIMINAR) ---
              // Este widget se superpone a la lista cuando '_isActionLoading' es true.
              if (_isActionLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child:  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Procesando...',
                          style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
