// lib/services/geocoding_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
  // ===================================================================
  // DETECTAR IP AUTOMÁTICAMENTE
  // ===================================================================
  static const String _direccionIpLocal = '192.168.137.115'; // <- CAMBIA ESTO POR TU IP

  // 2. LÓGICA DE ASIGNACIÓN: Este getter elige la IP correcta según la plataforma.
  static String get _apiRoot {
    // ASIGNACIÓN PARA WEB:
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    // ASIGNACIÓN PARA MÓVIL (Android):
    try {
      if (Platform.isAndroid) {
        // En el emulador de Android, se "asigna" la IP especial del alias.
        return 'http://10.0.2.2:3000/api';
      }
    } catch (e) {
      // Fallback por si 'Platform' no está disponible.
      return 'http://localhost:3000/api';
    }

    // ASIGNACIÓN PARA MÓVIL (iOS o dispositivo físico):
    // Se "asigna" la IP de desarrollo configurada manualmente.
    return 'http://$_direccionIpLocal:3000/api';
  }
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
        Uri.parse('$_apiRoot/geocodificar-preview'),
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
