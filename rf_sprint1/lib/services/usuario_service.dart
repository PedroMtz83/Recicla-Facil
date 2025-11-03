import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/foundation.dart';

class UsuarioService {
  static String _apiRoot = '';
  static bool _ipInitialized = false;

  // ===================================================================
  // DETECTAR IP AUTOMÁTICAMENTE (Versión simplificada)
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
            debugPrint('✅ IP detectada automáticamente: $ip');
            break;
          }
        } catch (e) {
          // Continuar con la siguiente IP
          debugPrint('❌ IP $ip no disponible: $e');
        }
      }
      
      // Si ninguna IP funcionó, usar la original como fallback
      if (_apiRoot.isEmpty) {
        _apiRoot = 'http://192.168.1.101:3000/api';
        debugPrint('⚠️  Usando IP por defecto: $_apiRoot');
      }
      
    } catch (e) {
      _apiRoot = 'http://192.168.1.101:3000/api';
      debugPrint('❌ Error en detección automática, usando fallback: $_apiRoot');
    }
    
    _ipInitialized = true;
  }

  // ===================================================================
  // MÉTODO PARA OBTENER LA URL COMPLETA
  // ===================================================================
  static Future<String> _getFullUrl(String endpoint) async {
    await _initializeIP();
    return '$_apiRoot/$endpoint';
  }

  // ===================================================================
  // 1. LOGIN de un usuario
  // ===================================================================
  Future<Map<String, dynamic>> loginUsuario({
    required String nombre,
    required String password,
  }) async {
    final url = Uri.parse(await _getFullUrl('usuarios/login'));
    debugPrint('Haciendo POST a: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'nombre': nombre, 'password': password}),
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
  // 2. CREAR un nuevo usuario
  // ===================================================================
  Future<Map<String, dynamic>> crearUsuario({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(await _getFullUrl('usuarios'));
    debugPrint('Haciendo POST a: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'nombre': nombre,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final Map<String, dynamic> responseData = json.decode(response.body);
      responseData['statusCode'] = response.statusCode;
      return responseData;

    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Revisa tu conexión a internet.');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ===================================================================
  // 3. OBTENER todos los usuarios
  // ===================================================================
  Future<List<dynamic>> obtenerUsuarios() async {
    final url = Uri.parse(await _getFullUrl('usuarios'));
    debugPrint('Haciendo GET a: $url');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Error del servidor [GET]: ${response.statusCode}');
        debugPrint('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error de conexión [GET]: $e');
      return [];
    }
  }

  // ===================================================================
  // 4. ACTUALIZAR un usuario por su email
  // ===================================================================
  Future<bool> actualizarUsuario({
    required String email,
    String? nombre,
    String? password,
    bool? admin,
  }) async {
    final url = Uri.parse(await _getFullUrl('usuarios/$email'));

    final Map<String, dynamic> body = {};
    if (nombre != null) body['nombre'] = nombre;
    if (password != null) body['password'] = password;
    if (admin != null) body['admin'] = admin;
    if (body.isEmpty) {
      debugPrint("No se proporcionaron datos para actualizar.");
      return false;
    }

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        debugPrint('Usuario actualizado exitosamente.');
        return true;
      } else {
        debugPrint('Error del servidor [PUT]: ${response.statusCode}');
        debugPrint('Respuesta: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error de conexión [PUT]: $e');
      return false;
    }
  }

  // ===================================================================
  // 5. ELIMINAR un usuario por su email
  // ===================================================================
  Future<bool> eliminarUsuario(String email) async {
    try {
      final url = Uri.parse(await _getFullUrl('usuarios/$email'));
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        debugPrint('Usuario eliminado exitosamente.');
        return true;
      } else {
        debugPrint('Error del servidor [DELETE]: ${response.statusCode}');
        debugPrint('Respuesta: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error de conexión [DELETE]: $e');
      return false;
    }
  }
}