import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class UsuarioService {
  static const String _baseUrl = 'http://192.168.1.70:3000/api/usuarios';

  // ===================================================================
  // 1. OBTENER todos los usuarios
  // ===================================================================
  Future<List<dynamic>> obtenerUsuarios() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
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
  // 2. CREAR un nuevo usuario
  // ===================================================================
  Future<bool> crearUsuario({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'nombre': nombre,
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 201) {
        debugPrint('Usuario creado exitosamente.');
        return true;
      } else {
        debugPrint('Error del servidor [POST]: ${response.statusCode}');
        debugPrint('Respuesta: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error de conexión [POST]: $e');
      return false;
    }
  }

  // ===================================================================
  // 3. ACTUALIZAR un usuario por su email
  // ===================================================================
  Future<bool> actualizarUsuario({
    required String email,
    String? nombre,
    String? password,
    bool? admin,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/$email');

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
  // 4. ELIMINAR un usuario por su email
  // ===================================================================
  Future<bool> eliminarUsuario(String email) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$email'));
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

  // ===================================================================
  // 5. LOGIN de usuario
  // ===================================================================
  Future<Map<String, dynamic>?> loginUsuario({
    required String nombre,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'nombre': nombre,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        debugPrint('Login exitoso.');
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        debugPrint('Usuario no encontrado');
        return null;
      } else {
        debugPrint('Error del servidor [LOGIN]: ${response.statusCode}');
        debugPrint('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error de conexión [LOGIN]: $e');
      return null;
    }
  }
}