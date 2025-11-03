import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/queja.dart';

class QuejaService {
  static String _apiRoot = '';
  static bool _ipInitialized = false;

  // ===================================================================
  // DETECTAR IP AUTOMÁTICAMENTE
  // ===================================================================
  static Future<void> _initializeIP() async {
    if (_ipInitialized) return;
    
    try {
      // Intentar con IPs comunes en redes locales
      final commonIPs = [
        '192.168.1.101',    // Tu IP original
        '192.168.1.100',    // Otra IP común
        '10.0.2.2',         // Para Android emulator
        'localhost',         // Para desarrollo local
        '127.0.0.1',        // Localhost
      ];
      
      // Probar cada IP hasta encontrar una que funcione
      for (String ip in commonIPs) {
        try {
          final testUrl = Uri.parse('http://$ip:3000/api/quejas');
          final response = await http.get(testUrl).timeout(const Duration(seconds: 2));
          
          if (response.statusCode == 200) {
            _apiRoot = 'http://$ip:3000/api';
            debugPrint(' IP detectada automáticamente para QuejaService: $ip');
            break;
          }
        } catch (e) {
          // Continuar con la siguiente IP
          debugPrint(' IP $ip no disponible para QuejaService: $e');
        }
      }
      
      // Si ninguna IP funcionó, usar la original como fallback
      if (_apiRoot.isEmpty) {
        _apiRoot = 'http://192.168.1.101:3000/api';
        debugPrint('  Usando IP por defecto para QuejaService: $_apiRoot');
      }
      
    } catch (e) {
      _apiRoot = 'http://192.168.1.101:3000/api';
      debugPrint(' Error en detección automática, usando fallback: $_apiRoot');
    }
    
    _ipInitialized = true;
  }

  // ===================================================================
  // MÉTODO PARA OBTENER LA URL COMPLETA
  // ===================================================================
  static Future<String> _getFullUrl(String endpoint) async {
    await _initializeIP();
    return '$_apiRoot/quejas/$endpoint';
  }

  // ===================================================================
  // 1. CREAR QUEJA
  // ===================================================================
  Future<Map<String, dynamic>> crearQueja({
    required String correo,
    required String categoria,
    required String mensaje
  }) async {
    final url = Uri.parse(await _getFullUrl(''));
    debugPrint('QuejaService - Creando queja en: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'correo': correo,
          'categoria': categoria,
          'mensaje': mensaje
        }),
      ).timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData = json.decode(response.body);
      responseData['statusCode'] = response.statusCode;
      return responseData;

    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Revisa tu conexión.');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ===================================================================
  // 2. OBTENER MIS QUEJAS
  // ===================================================================
  Future<List<Queja>> obtenerMisQuejas(String email) async {
    final url = Uri.parse(await _getFullUrl('mis-quejas/$email'));
    debugPrint('QuejaService - Obteniendo mis quejas en: $url');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return quejaFromJson(response.body);
      } else {
        throw Exception('Error al cargar tus quejas: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Revisa tu conexión.');
    } catch (e) {
      throw Exception('Ocurrió un error inesperado: $e');
    }
  }

  // ===================================================================
  // 3. OBTENER QUEJAS POR CATEGORÍA
  // ===================================================================
  Future<List<Queja>> obtenerQuejasPorCategoria(String categoria) async {
    final String categoriaCodificada = Uri.encodeComponent(categoria);
    final url = Uri.parse(await _getFullUrl('categoria/$categoriaCodificada'));
    debugPrint('QuejaService - Obteniendo quejas por categoría en: $url');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return quejaFromJson(response.body);
      } else {
        throw Exception('Error al cargar quejas por categoría: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Revisa tu conexión.');
    } catch (e) {
      throw Exception('Ocurrió un error inesperado: $e');
    }
  }

  // ===================================================================
  // 4. OBTENER QUEJAS PENDIENTES
  // ===================================================================
  Future<List<Queja>> obtenerQuejasPendientes() async {
    final url = Uri.parse(await _getFullUrl('pendientes'));
    debugPrint('QuejaService - Obteniendo quejas pendientes en: $url');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return quejaFromJson(response.body);
      } else {
        throw Exception('Error al cargar quejas pendientes: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Revisa tu conexión.');
    } catch (e) {
      throw Exception('Ocurrió un error inesperado: $e');
    }
  }

  // ===================================================================
  // 5. ATENDER QUEJA
  // ===================================================================
  Future<Map<String, dynamic>> atenderQueja(String quejaId, String respuestaAdmin) async {
    final url = Uri.parse(await _getFullUrl(quejaId));
    debugPrint('QuejaService - Atendiendo queja en: $url');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'respuestaAdmin': respuestaAdmin}),
      ).timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData = json.decode(response.body);
      responseData['statusCode'] = response.statusCode;
      return responseData;

    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Revisa tu conexión.');
    } catch (e) {
      throw Exception('Ocurrió un error inesperado al atender la queja: $e');
    }
  }

  // ===================================================================
  // 6. ELIMINAR QUEJA
  // ===================================================================
  Future<Map<String, dynamic>> eliminarQueja(String quejaId) async {
    final url = Uri.parse(await _getFullUrl(quejaId));
    debugPrint('QuejaService - Eliminando queja en: $url');

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData = json.decode(response.body);
      responseData['statusCode'] = response.statusCode;
      return responseData;

    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Revisa tu conexión.');
    } catch (e) {
      throw Exception('Ocurrió un error inesperado al eliminar la queja: $e');
    }
  }
}