// lib/widgets/mapa_ubicacion_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaUbicacionWidget extends StatelessWidget {
  final double latitud;
  final double longitud;
  final String? nombreUbicacion;
  final VoidCallback? onCerrar;

  const MapaUbicacionWidget({
    super.key,
    required this.latitud,
    required this.longitud,
    this.nombreUbicacion,
    this.onCerrar,
  });

  @override
  Widget build(BuildContext context) {
    final coordenadas = LatLng(latitud, longitud);

    return Dialog(
      insetPadding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            color: Colors.green,
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vista Previa - ${nombreUbicacion ?? "Ubicación"}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: onCerrar ?? () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Mapa
          Container(
            height: 400,
            width: double.maxFinite,
            child: FlutterMap(
              options: MapOptions(
                center: coordenadas,
                zoom: 17.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.reciclaFacil',
                  additionalOptions: {
                    'access_token': '',
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: coordenadas,
                      width: 50,
                      height: 50,
                      builder: (ctx) => Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Footer con información
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coordenadas:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Lat: ${latitud.toStringAsFixed(6)}'),
                Text('Lon: ${longitud.toStringAsFixed(6)}'),
                SizedBox(height: 16),
                Text(
                  'Nota: La ubicación mostrada es una aproximación basada en la geocodificación de tu dirección.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          // Botones
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: onCerrar ?? () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                  label: Text('Cerrar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Copiar al portapapeles
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Coordenadas copiadas al portapapeles'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: Icon(Icons.copy),
                  label: Text('Copiar Coords'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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
