// lib/views/admin_puntos_screen.dart

import 'package:flutter/material.dart';
import '../models/punto_reciclaje.dart';
import '../services/puntos_reciclaje_service.dart';

class AdminPuntosScreen extends StatefulWidget {
  const AdminPuntosScreen({super.key});

  @override
  State<AdminPuntosScreen> createState() => _AdminPuntosScreenState();
}

class _AdminPuntosScreenState extends State<AdminPuntosScreen> {
  int _selectedIndex = 0;

   List<PuntoReciclaje> _puntosGestion=[];
   List<PuntoReciclaje> _puntosPorValidar=[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {

    try {
      final resultadosDinamicos = await Future.wait([
        PuntosReciclajeService.obtenerPuntosReciclajeEstado("true"),
        PuntosReciclajeService.obtenerPuntosReciclajeEstado("false"),
      ]);

      final List<PuntoReciclaje> listaAceptados = (resultadosDinamicos[0] as List)
          .map((data) => PuntoReciclaje.fromJson(data as Map<String, dynamic>))
          .toList();

      final List<PuntoReciclaje> listaNoAceptados = (resultadosDinamicos[1] as List)
          .map((data) => PuntoReciclaje.fromJson(data as Map<String, dynamic>))
          .toList();

      final puntosFiltradosGestion = listaAceptados;
      final puntosFiltradosPorValidar = listaNoAceptados;

      if (mounted) {
        setState(() {
          _puntosGestion = puntosFiltradosGestion;
          _puntosPorValidar = puntosFiltradosPorValidar;
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
          _selectedIndex == 0 ? 'Gestionar Puntos' : 'Validar Puntos',
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
        items: <BottomNavigationBarItem>[
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
      return Center(child: Text('No hay puntos de reciclaje para gestionar.'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(8.0),
      itemCount: _puntosGestion.length,
      itemBuilder: (context, index) {
        final centro = _puntosGestion[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(centro.nombre, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(centro.direccion, style: TextStyle(color: Colors.grey[700])),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.edit, size: 20),
                      label: Text('Editar'),
                      onPressed: () {
                        // TODO: Lógica para editar el centro
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Editar: ${centro.nombre}')),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                    SizedBox(width: 8),
                    TextButton.icon(
                      icon: Icon(Icons.delete_outline, size: 20),
                      label: Text('Eliminar'),
                      onPressed: () async {

                        _eliminarPunto(centro.id);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

// --- PANTALLA 2: VALIDAR PUNTOS (VERSIÓN MEJORADA) ---
  Widget _buildValidarScreen() {
    if (_puntosPorValidar.isEmpty) {
      return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('¡Excelente! No hay puntos nuevos pendientes de validación.',
                textAlign: TextAlign.center),
          ));
    }

    return ListView.builder(
      padding: EdgeInsets.all(8.0),
      itemCount: _puntosPorValidar.length,
      itemBuilder: (context, index) {
        final centro = _puntosPorValidar[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orange.shade200, width: 1),
          ),
          color: Colors.orange[50], // Tono para destacar que está pendiente
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Título Principal ---
                Text(centro.nombre,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                Divider(height: 20),

                // --- Fila de Dirección ---
                _buildInfoRow(
                    Icons.location_on_outlined, 'Dirección', centro.direccion),

                // --- Fila de Horario ---
                _buildInfoRow(
                    Icons.access_time_outlined, 'Horario', centro.horario),

                // --- Fila de Teléfono ---
                if (centro.telefono.isNotEmpty && centro.telefono != 'N/A')
                  _buildInfoRow(
                      Icons.phone_outlined, 'Teléfono', centro.telefono),

                // --- Fila de Descripción ---
                _buildInfoRow(
                    Icons.description_outlined, 'Descripción', centro.descripcion),
                SizedBox(height: 12),

                // --- Sección de Materiales Aceptados ---
                Text('Materiales que acepta:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey[800])),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: centro.tipoMaterial.map((material) {
                    return Chip(
                      label: Text(material),
                      backgroundColor: Colors.green[100],
                      side: BorderSide.none,
                      padding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),

                // --- Botones de Acción ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.thumb_down_outlined),
                        label: Text('Rechazar'),
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          elevation: 2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.thumb_up_outlined),
                        label: Text('Aceptar'),
                        onPressed: () => _aceptarPunto(centro),
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
      padding: EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey[800])),
                SizedBox(height: 2),
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
          // Botón rojo para confirmar la eliminación
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            icon:  Icon(Icons.warning),
            label:  Text('Sí, Eliminar'),
            onPressed: () async {
              // Bloquea múltiples clics
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
}
