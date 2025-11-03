import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/foundation.dart';

class PerfilService {
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
          final testUrl = Uri.parse('http://$ip:3000/api/usuarios');
          final response = await http.get(testUrl).timeout(const Duration(seconds: 2));
          
          if (response.statusCode == 200) {
            _apiRoot = 'http://$ip:3000/api';
            debugPrint(' IP detectada automáticamente para PerfilService: $ip');
            break;
          }
        } catch (e) {
          // Continuar con la siguiente IP
          debugPrint(' IP $ip no disponible para PerfilService: $e');
        }
      }
      
      // Si ninguna IP funcionó, usar la original como fallback
      if (_apiRoot.isEmpty) {
        _apiRoot = 'http://192.168.1.101:3000/api';
        debugPrint('  Usando IP por defecto para PerfilService: $_apiRoot');
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
    return '$_apiRoot/usuarios/$endpoint';
  }

  // ===================================================================
  // 1. OBTENER PERFIL DE USUARIO
  // ===================================================================
  static Future<Map<String, dynamic>> getUserProfile(String email) async {
    final url = Uri.parse(await _getFullUrl(email));
    debugPrint('PerfilService - Obteniendo perfil en: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Error del servidor [GET PROFILE]: ${response.statusCode}');
        debugPrint('Respuesta: ${response.body}');
        throw Exception('Error al cargar perfil: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Revisa tu conexión.');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ===================================================================
  // 2. CAMBIAR CONTRASEÑA
  // ===================================================================
  static Future<Map<String, dynamic>> changePassword({
    required String email,
    required String nuevaPassword
  }) async {
    final url = Uri.parse(await _getFullUrl('cambiar-password'));
    debugPrint('PerfilService - Cambiando contraseña en: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'nuevaPassword': nuevaPassword,
        }),
      ).timeout(const Duration(seconds: 10));

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
  // 3. ACTUALIZAR PERFIL 
  // ===================================================================
  static Future<Map<String, dynamic>> updateProfile({
    required String email,
    String? nombre,
    String? nuevoEmail,
  }) async {
    final url = Uri.parse(await _getFullUrl(email));
    debugPrint('PerfilService - Actualizando perfil en: $url');

    try {
      final Map<String, dynamic> body = {};
      if (nombre != null) body['nombre'] = nombre;
      if (nuevoEmail != null) body['email'] = nuevoEmail;

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      final Map<String, dynamic> responseData = json.decode(response.body);
      responseData['statusCode'] = response.statusCode;
      return responseData;

    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Revisa tu conexión.');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}