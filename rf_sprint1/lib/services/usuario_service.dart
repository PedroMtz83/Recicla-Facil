import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Para usar debugPrint

class UsuarioService {
  // Asegúrate de que esta sea la ruta base correcta donde se montan tus rutas de usuario.
  static const String _baseUrl = 'http://192.168.1.68:3000/api/usuarios'; //Cambien la ip si lo van a probar en su equipo.

  // ===================================================================
  // 1. OBTENER todos los usuarios (Coincide con `obtenerUsuarios`)
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
  // 2. CREAR un nuevo usuario (Coincide con `crearUsuario`)
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
        // Usamos los nombres de campos de TU controlador: nombre, email, password
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
  // 3. ACTUALIZAR un usuario por su email (Coincide con `actualizarUsuario`)
  // ===================================================================
  Future<bool> actualizarUsuario({
    required String email, // Email para identificar al usuario
    String? nombre,       // Datos opcionales a actualizar
    String? password,
    bool? admin,
  }) async {
    // URL específica para la actualización, ej: /api/usuarios/test@test.com
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
  // 4. ELIMINAR un usuario por su email (Coincide con `eliminarUsuario`)
  // ===================================================================
  Future<bool> eliminarUsuario(String email) async {
    try {
      // El email se añade directamente a la URL, como en tu controlador
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
}
