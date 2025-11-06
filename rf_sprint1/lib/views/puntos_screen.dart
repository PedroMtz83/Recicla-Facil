import 'package:flutter/material.dart';

class PuntosScreen extends StatefulWidget {
  const PuntosScreen({super.key});

  @override
  State<PuntosScreen> createState() => _PuntosScreenState();
}

class _PuntosScreenState extends State<PuntosScreen> {
  bool _isLoading = false;
  String? _materialFiltro;

  final List<String> _tiposMaterial = [
    'Todos',
    'Aluminio',
    'Cartón',
    'Papel',
    'PET',
    'Vidrio',
  ];

  final Map<String, String> _puntoEstatico = {
    'nombre': 'Centro de Reciclaje La Loma',
    'descripcion': 'Punto de recolección de plástico y vidrio',
    'material': 'PET - Vidrio',
    'direccion': 'Av. Insurgentes 1450, Col. La Loma, Tepic, Nayarit',
    'telefono': '311 212 3456',
    'horario': 'Lunes a Viernes: 9:00 - 17:00'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Buscador de puntos de reciclaje",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _materialFiltro ?? 'Todos',
                      hint: Text("Filtrar por material"),
                      decoration: InputDecoration(
                        labelText: 'Filtro de material',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.filter_list),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      isExpanded: true,
                      items: _tiposMaterial.map((String material) {
                        return DropdownMenuItem<String>(
                          value: material,
                          child: Text(
                            material,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? nuevoValor) {
                        setState(() {
                          _materialFiltro = nuevoValor;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _buscarPuntos,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 4,
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text('Buscar', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _mostrarDialogoConInfo(context);
                },
                child: Text("Mostrar Punto de Ejemplo"),
              ),
              SizedBox(height: 20),
              Card(
                color: Colors.grey,
                child: SizedBox(
                  height: 100,
                  child: Center(child: Text('Resultados de la búsqueda aparecerán aquí')),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoConInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Detalle del Punto"),
          content: _buildDialogContent(),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoRow(Icons.location_on, "Nombre", _puntoEstatico['nombre']!),
          _buildInfoRow(Icons.description, "Descripción", _puntoEstatico['descripcion']!),
          _buildInfoRow(Icons.recycling, "Material", _puntoEstatico['material']!),
          _buildInfoRow(Icons.place, "Dirección", _puntoEstatico['direccion']!),
          _buildInfoRow(Icons.phone, "Teléfono", _puntoEstatico['telefono']!),
          _buildInfoRow(Icons.access_time, "Horario", _puntoEstatico['horario']!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _buscarPuntos() {
    setState(() => _isLoading = true);
    debugPrint("Buscando puntos con filtro: $_materialFiltro");

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
    });
  }
}
