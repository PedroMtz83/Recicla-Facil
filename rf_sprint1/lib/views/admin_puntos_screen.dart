// lib/views/admin_puntos_screen.dart

import 'package:flutter/material.dart';
import '../models/centro_reciclaje.dart';
import '../services/centros_reciclaje_service.dart';

class AdminPuntosScreen extends StatefulWidget {
  const AdminPuntosScreen({super.key});

  @override
  State<AdminPuntosScreen> createState() => _AdminPuntosScreenState();
}

class _AdminPuntosScreenState extends State<AdminPuntosScreen> {
  // 0: Gestionar, 1: Validar
  int _selectedIndex = 0;

  late List<CentroReciclaje> _puntosGestion;
  late List<CentroReciclaje> _puntosPorValidar;

  @override
  void initState() {
    super.initState();
    // Cargamos los datos iniciales desde el servicio (simulado)
    _puntosGestion = CentrosReciclajeService.obtenerTodos()
        .where((c) => c.validado)
        .toList();
    _puntosPorValidar = CentrosReciclajeService.obtenerTodos()
        .where((c) => !c.validado)
        .toList();
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
      body: IndexedStack(
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Editar: ${centro.nombre}')),
                        );
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
                      onPressed: () {
                        // TODO: Lógica para eliminar el centro
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Eliminar: ${centro.nombre}')),
                        );
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
      padding: const EdgeInsets.all(8.0),
      itemCount: _puntosPorValidar.length,
      itemBuilder: (context, index) {
        final centro = _puntosPorValidar[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orange.shade200, width: 1),
          ),
          color: Colors.orange[50], // Tono para destacar que está pendiente
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Título Principal ---
                Text(centro.nombre,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const Divider(height: 20),

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
                const SizedBox(height: 12),

                // --- Sección de Materiales Aceptados ---
                Text('Materiales que acepta:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: centro.tipoMaterial.map((material) {
                    return Chip(
                      label: Text(material),
                      backgroundColor: Colors.green[100],
                      side: BorderSide.none,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // --- Botones de Acción ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.thumb_down_outlined),
                        label: const Text('Rechazar'),
                        onPressed: () {
                          // TODO: Lógica para rechazar el punto
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Rechazado: ${centro.nombre}')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade400),
                          foregroundColor: Colors.red[800],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.thumb_up_outlined),
                        label: const Text('Aceptar'),
                        onPressed: () {
                          // TODO: Lógica para aceptar/validar el punto
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Aceptado: ${centro.nombre}')),
                          );
                        },
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

}
