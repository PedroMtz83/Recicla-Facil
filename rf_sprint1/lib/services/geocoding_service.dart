// lib/services/geocoding_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class UbicacionPreview {
  final double latitud;
  final double longitud;
  final String? precision;

  UbicacionPreview({
    required this.latitud,
    required this.longitud,
    this.precision,
  });

  factory UbicacionPreview.fromJson(Map<String, dynamic> json) {
    return UbicacionPreview(
      latitud: json['latitud'] is int 
          ? (json['latitud'] as int).toDouble() 
          : json['latitud'],
      longitud: json['longitud'] is int 
          ? (json['longitud'] as int).toDouble() 
          : json['longitud'],
      precision: json['precision'],
    );
  }
}

class GeocodingService {
  final String _baseUrl = 'http://localhost:3000/api';

  /// Obtiene las coordenadas de una dirección para vista previa
  /// No requiere autenticación (endpoint público)
  Future<UbicacionPreview> obtenerUbicacionPreview({
    required String calle,
    required String numero,
    required String colonia,
    String ciudad = 'Tepic',
    String estado = 'Nayarit',
    String pais = 'Mexico',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/geocodificar-preview'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'calle': calle.trim(),
          'numero': numero.trim(),
          'colonia': colonia.trim(),
          'ciudad': ciudad,
          'estado': estado,
          'pais': pais,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return UbicacionPreview.fromJson(data['data']);
      } else {
        throw Exception('Error al geocodificar: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerUbicacionPreview: $e');
      // Devolver Tepic como fallback
      return UbicacionPreview(
        latitud: 21.5018,
        longitud: -104.8946,
        precision: 'por defecto',
      );
    }
  }
}
