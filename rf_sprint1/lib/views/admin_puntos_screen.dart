// lib/views/admin_puntos_screen.dart

import 'package:flutter/material.dart';
import '../models/punto_reciclaje.dart';
import '../models/solicitud_punto.dart';
import '../services/puntos_reciclaje_service.dart';
import '../services/solicitudes_puntos_service.dart';
import '../auth_provider.dart';
import 'package:provider/provider.dart';

import 'dialog_editar_punto_screen.dart';

class AdminPuntosScreen extends StatefulWidget {
  const AdminPuntosScreen({super.key});

  @override
  State<AdminPuntosScreen> createState() => _AdminPuntosScreenState();
}

class _AdminPuntosScreenState extends State<AdminPuntosScreen> {
  int _selectedIndex = 0;

   List<PuntoReciclaje> _puntosGestion=[];
   List<SolicitudPunto> _solicitudesPorValidar=[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final userName = authProvider.userName ?? '';
      final isAdmin = authProvider.isAdmin;

      final resultadosDinamicos = await Future.wait([
        PuntosReciclajeService.obtenerPuntosReciclajeEstado("true"),
        SolicitudesPuntosService().obtenerSolicitudesPendientes(
          userName: userName,
          isAdmin: isAdmin,
        ),
      ]);

      final List<PuntoReciclaje> listaAceptados = (resultadosDinamicos[0] as List)
          .map((data) => PuntoReciclaje.fromJson(data as Map<String, dynamic>))
          .toList();
      final List<SolicitudPunto> listaSolicitudes = resultadosDinamicos[1] as List<SolicitudPunto>;

      if (mounted) {
        setState(() {
          _puntosGestion = listaAceptados;
          _solicitudesPorValidar = listaSolicitudes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error al cargar los datos de gestión: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudieron cargar los datos.')),
        );
      }
    }
  }

  // Lista de widgets que se mostrarán en el body
  List<Widget> _buildScreens() {
    return [
      _buildGestionarScreen(),
      _buildValidarScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'Gestionar Puntos' : 'Validar Solicitudes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _isLoading ? Center (
        child: CircularProgressIndicator(),
      ): IndexedStack(
        index: _selectedIndex,
        children: _buildScreens(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey[600],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_location_alt),
            label: 'Gestionar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rule_folder_outlined),
            label: 'Validar',
          ),
        ],
      ),
    );
  }

  // --- PANTALLA 1: GESTIONAR PUNTOS ---
  Widget _buildGestionarScreen() {
    if (_puntosGestion.isEmpty) {
      return const Center(child: Text('No hay puntos de reciclaje para gestionar.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _puntosGestion.length,
      itemBuilder: (context, index) {
        final centro = _puntosGestion[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(centro.nombre, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(centro.direccion, style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 20),
                      label: const Text('Editar'),
                      onPressed: () {
                        // TODO: Lógica para editar el centro
                        _editarPunto(context, centro);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      label: const Text('Eliminar'),
                      onPressed: () async {
                        _eliminarPunto(centro.id);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // lib/views/admin_puntos_screen.dart

  void _mostrarSnackBar(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : Colors.green,
      ),
    );
  }
  void _editarPunto(BuildContext context, PuntoReciclaje punto) {
    // `punto` es el objeto que queremos editar (centro en tu código original)
    showDialog(
      context: context,
      // `barrierDismissible: false` evita que el diálogo se cierre al tocar fuera
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Usamos un widget separado para el formulario para mantener el código limpio.
        return DialogoEditarPunto(
          punto: punto,
          // Pasamos una función 'callback' que se ejecutará cuando la actualización sea exitosa.
          onPuntoActualizado: () {
            setState(() {
              // Vuelve a cargar los datos desde la API para refrescar la lista
              // con la información más reciente.
              _cargarDatos();
            });

            // Muestra un mensaje de éxito.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Punto de reciclaje actualizado con éxito.'),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _aceptarPunto(PuntoReciclaje punto) async {
    try {
      final resultado = await PuntosReciclajeService.aceptarPunto(
          punto.id);
      if (mounted) {
        if (resultado['statusCode'] == 200) {
          _mostrarSnackBar('Punto aceptado correctamente.');
          _cargarDatos();
        } else {
          _mostrarSnackBar(resultado['mensaje'] ?? 'Error al aceptar el punto.', esError: true);
        }
      }
    } catch (e) {
      if (mounted) _mostrarSnackBar(e.toString(), esError: true);
    }
  }

  Future<void> _aprobarSolicitud(SolicitudPunto solicitud) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final userName = authProvider.userName ?? '';
      final isAdmin = authProvider.isAdmin;

      final resultado = await SolicitudesPuntosService().aprobarSolicitud(
        solicitud.id,
        comentariosAdmin: 'Solicitud aprobada por el administrador',
        userName: userName,
        isAdmin: isAdmin,
      );

      if (mounted) {
        if (resultado) {
          _mostrarSnackBar('✓ Solicitud aprobada correctamente. El punto aparecerá en el mapa.');
          _cargarDatos();
        } else {
          _mostrarSnackBar('Error al aprobar la solicitud.', esError: true);
        }
      }
    } catch (e) {
      if (mounted) _mostrarSnackBar(e.toString(), esError: true);
    }
  }

// --- PANTALLA 2: VALIDAR SOLICITUDES DE PUNTOS ---
  Widget _buildValidarScreen() {
    if (_solicitudesPorValidar.isEmpty) {
      return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('¡Excelente! No hay solicitudes de puntos pendientes de validación.',
                textAlign: TextAlign.center),
          ));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _solicitudesPorValidar.length,
      itemBuilder: (context, index) {
        final solicitud = _solicitudesPorValidar[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orange.shade200, width: 1),
          ),
          color: Colors.orange[50],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Encabezado con usuario solicitante ---
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(solicitud.nombre,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text('Solicitado por: ${solicitud.usuarioSolicitante}',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Pendiente',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // --- Fila de Dirección ---
                _buildInfoRow(
                    Icons.location_on_outlined, 
                    'Dirección', 
                    '${solicitud.direccion.calle} ${solicitud.direccion.numero}, ${solicitud.direccion.colonia}'),

                // --- Fila de Descripción ---
                _buildInfoRow(
                    Icons.description_outlined, 'Descripción', solicitud.descripcion),
                
                // --- Fila de Tipos de Material ---
                if (solicitud.tipoMaterial.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Materiales que acepta:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: solicitud.tipoMaterial.map((material) {
                      return Chip(
                        label: Text(material),
                        backgroundColor: Colors.green[100],
                        side: BorderSide.none,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 20),

                // --- Botones de Acción ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text('Rechazar'),
                        onPressed: () => _mostrarDialogoRechazo(solicitud),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Aceptar'),
                        onPressed: () => _aprobarSolicitud(solicitud),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// --- WIDGET AUXILIAR PARA MOSTRAR LA INFORMACIÓN ---
// Puedes poner este método dentro de la clase _AdminPuntosScreenState
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: Colors.black.withOpacity(0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _eliminarPunto(String puntoId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:  Text('Confirmar Eliminación'),
        content:  Text('¿Estás seguro de que deseas eliminar este punto? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:  Text('No'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            icon:  Icon(Icons.warning),
            label:  Text('Sí, Eliminar'),
            onPressed: () async {
              if (_isLoading) return;
              setState(() => _isLoading = true);
              Navigator.of(ctx).pop();

              try {
                bool resultado = await PuntosReciclajeService.eliminarPuntoReciclaje(puntoId);
                if (resultado) {
                  _mostrarSnackBar('Punto eliminado correctamente.');
                  _cargarDatos();
                } else {
                  _mostrarSnackBar('Error al eliminar el punto.');
                }
              } catch (e) {
                _mostrarSnackBar(e.toString(), esError: true);
              } finally {
                setState(() => _isLoading = false);
              }
            },
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoRechazo(SolicitudPunto solicitud) {
    final TextEditingController motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Rechazar Solicitud'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Punto: ${solicitud.nombre}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Motivo del rechazo:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: motivoController,
              decoration: InputDecoration(
                hintText: 'Ingresa el motivo del rechazo...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            icon: Icon(Icons.close),
            label: Text('Rechazar'),
            onPressed: () async {
              if (motivoController.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                      content: Text('Debes ingresar un motivo del rechazo')),
                );
                return;
              }
              Navigator.pop(ctx);
              await _ejecutarRechazo(solicitud, motivoController.text.trim());
            },
          ),
        ],
      ),
    );
  }

  Future<void> _ejecutarRechazo(SolicitudPunto solicitud, String motivo) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final userName = authProvider.userName ?? '';
      final isAdmin = authProvider.isAdmin;

      final resultado = await SolicitudesPuntosService().rechazarSolicitud(
        solicitud.id,
        motivo,
        userName: userName,
        isAdmin: isAdmin,
      );

      if (mounted) {
        if (resultado) {
          _mostrarSnackBar('✗ Solicitud rechazada. El usuario recibirá una notificación.');
          _cargarDatos();
        } else {
          _mostrarSnackBar('Error al rechazar la solicitud.', esError: true);
        }
      }
    } catch (e) {
      if (mounted) _mostrarSnackBar(e.toString(), esError: true);
    }
  }
}
