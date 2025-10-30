import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/foundation.dart'; // Para usar debugPrint

class UsuarioService {
  static const String _apiRoot = 'http://192.168.1.68:3000/api';

  // ===================================================================
  // 1. LOGIN de un usuario
  // ===================================================================
  Future<Map<String, dynamic>> loginUsuario({
    required String nombre,
    required String password,
  }) async {
    final url = Uri.parse('$_apiRoot/usuarios/login');
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
    // --- CORRECCIÓN #2: La ruta para crear es sobre el recurso "usuarios" ---
    final url = Uri.parse('$_apiRoot/usuarios');
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
    }
  }

  // ===================================================================
  // 3. OBTENER todos los usuarios
  // ===================================================================
  Future<List<dynamic>> obtenerUsuarios() async {
    final url = Uri.parse('$_apiRoot/usuarios');
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
  // 3. ACTUALIZAR un usuario por su email (Coincide con `actualizarUsuario`)
  // ===================================================================
  Future<bool> actualizarUsuario({
    required String email, // Email para identificar al usuario
    String? nombre,       // Datos opcionales a actualizar
    String? password,
    bool? admin,
  }) async {
    // URL específica para la actualización, ej: /api/usuarios/test@test.com
    final Uri url = Uri.parse('$_apiRoot/usuarios/$email');

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
  // 4. ELIMINAR un usuario por su email (Coincide con `eliminarUsuario`)
  // ===================================================================
  Future<bool> eliminarUsuario(String email) async {
    try {
      // El email se añade directamente a la URL, como en tu controlador
      final response = await http.delete(Uri.parse('$_apiRoot/usuarios/$email'));
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
