import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/punto_reciclaje.dart';
import '../services/puntos_reciclaje_service.dart';

class PuntosScreen extends StatefulWidget {
  const PuntosScreen({super.key});

  @override
  State<PuntosScreen> createState() => _PuntosScreenState();
}

class _PuntosScreenState extends State<PuntosScreen> {
  bool _isLoading = false;
  String? _materialFiltro;
  List<PuntoReciclaje> _puntosEncontrados = [];
  bool _mostrarMapa = false;
  LatLng? _currentLocation;
  MapController _mapController = MapController();

  final List<String> _tiposMaterial = [
    'Todos',
    'Aluminio',
    'Cartón',
    'Papel',
    'PET',
    'Vidrio',
  ];

  static const LatLng _centroTepic = LatLng(21.5018, -104.8946);

  @override
  void initState() {
    super.initState();
    _materialFiltro = 'Todos';
    _cargarCentrosIniciales();
    _getCurrentLocation();
  }

  void _cargarCentrosIniciales() async{
    try{
    final List<dynamic> datosCrudos = await PuntosReciclajeService.obtenerPuntosReciclajePorMaterial(_materialFiltro!);
    final List<PuntoReciclaje> puntos = datosCrudos
        .map((mapaCentro) => PuntoReciclaje.fromJson(mapaCentro as Map<String, dynamic>))
        .toList();

    // 5. Actualiza el estado con la LISTA DE OBJETOS ya parseada
    if (mounted) {
      setState(() {
        _puntosEncontrados = puntos;
      });
    }
  } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar los puntos: $e')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && 
          permission != LocationPermission.always) return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error obteniendo ubicación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_mostrarMapa ? Icons.list : Icons.map),
            onPressed: () => setState(() => _mostrarMapa = !_mostrarMapa),
            tooltip: _mostrarMapa ? 'Ver lista' : 'Ver mapa',
          ),
        ],
      ),
      body: Column(
        children: [
          // Sección de búsqueda
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Buscador de puntos de reciclaje",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _materialFiltro,
                        decoration: InputDecoration(
                          labelText: 'Filtro de material',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.filter_list),
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        ),
                        items: _tiposMaterial.map((material) {
                          return DropdownMenuItem<String>(
                            value: material,
                            child: Text(material),
                          );
                        }).toList(),
                        onChanged: (String? nuevoValor) {
                          setState(() => _materialFiltro = nuevoValor);
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _buscarPuntos,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('Buscar'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  '${_puntosEncontrados.length} centros encontrados',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _puntosEncontrados.isEmpty
                    ? Center(child: Text('No se encontraron centros'))
                    : _mostrarMapa ? _construirMapa() : _construirLista(),
          ),
        ],
      ),
    );
  }

  Widget _construirLista() {
    return ListView.builder(
      itemCount: _puntosEncontrados.length,
      itemBuilder: (context, index) {
        final centro = _puntosEncontrados[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Icon(Icons.recycling, color: Colors.green),
            title: Text(centro.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(centro.direccion),
            trailing: Icon(Icons.chevron_right, color: Colors.green),
            onTap: () => _mostrarDetallesCentro(centro),
          ),
        );
      },
    );
  }

  Widget _construirMapa() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _currentLocation ?? _centroTepic,
            zoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.rf_sprint1.app',
            ),
            if (_currentLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation!,
                    builder: (ctx) => Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                  ),
                ],
              ),
            MarkerLayer(
              markers: _puntosEncontrados.map((centro) {
                return Marker(
                  point: centro.coordenadas,
                  builder: (ctx) => GestureDetector(
                    onTap: () => _mostrarDetallesCentro(centro),
                    child: Tooltip(
                      message: centro.nombre,
                      child: Icon(Icons.recycling, color: Colors.green, size: 30),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        if (_currentLocation != null)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => _mapController.move(_currentLocation!, 15.0),
              child: Icon(Icons.my_location),
              backgroundColor: Colors.green,
              mini: true,
            ),
          ),
      ],
    );
  }

  void _mostrarDetallesCentro(PuntoReciclaje centro) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.recycling, color: Colors.green, size: 30),
                  SizedBox(width: 12),
                  Expanded(child: Text(centro.nombre, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                ],
              ),
              SizedBox(height: 16),
              Text(centro.descripcion, style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 16),
              _buildInfoRow(Icons.location_on, centro.direccion),
              _buildInfoRow(Icons.phone, centro.telefono),
              _buildInfoRow(Icons.access_time, centro.horario),
              SizedBox(height: 16),
              Text('Materiales aceptados:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),

              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: centro.tipoMaterial.map((material) {
                  return Chip(
                    label: Text(
                      material,
                      style: TextStyle(color: Colors.green[800]),
                    ),
                    backgroundColor: Colors.green[100],
                    side: BorderSide(color: Colors.green.shade200),
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text('Cerrar', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _buscarPuntos() async {
    setState(() => _isLoading = true);
    debugPrint('--- Widget: Iniciando _buscarPuntos ---');

    try {
      final List<dynamic> datosRecibidosDelServicio =
      await PuntosReciclajeService.obtenerPuntosReciclajePorMaterial(
          _materialFiltro!);

      debugPrint('--- Widget: ¿Los datos llegaron a la función? ${datosRecibidosDelServicio != null ? 'SÍ' : 'NO'}');
      if (datosRecibidosDelServicio != null) {
        debugPrint('--- Widget: Elementos recibidos en la función: ${datosRecibidosDelServicio.length}');
      }

      final List<PuntoReciclaje> puntos = datosRecibidosDelServicio
          .map((mapaCentro) =>
          PuntoReciclaje.fromJson(mapaCentro as Map<String, dynamic>))
          .toList();

      debugPrint('--- Widget: Parseo a objetos PuntoReciclaje exitoso. Puntos creados: ${puntos.length}'); // <-- Añade esto

      if (mounted) {
        setState(() {
          _puntosEncontrados = puntos;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('--- Widget: ¡ERROR CAPTURADO! ---');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      // -----------------------------------------
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar los puntos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('--- Widget: Fin de _buscarPuntos ---');
    }
  }
}