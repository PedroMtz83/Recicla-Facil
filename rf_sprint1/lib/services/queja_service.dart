import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

import '../models/queja.dart';

class QuejaService {
  // La URL base para el recurso de quejas.
  final String _baseUrl = 'http://192.168.1.101:3000/api/quejas';

  QuejaService();

  Future<Map<String, dynamic>> crearQueja({
    required String correo,
    required String categoria,
    required String mensaje
  }) async {
    final url = Uri.parse(_baseUrl);

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
      ).timeout( Duration(seconds: 15));

      final Map<String, dynamic> responseData = json.decode(response.body);
      responseData['statusCode'] = response.statusCode;
      return responseData;

    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Revisa tu conexión.');
    }
  }
  Future<List<Queja>> obtenerMisQuejas(String email) async {
    // La ruta ahora incluye el email, como en tu definición original.
    final url = Uri.parse('$_baseUrl/mis-quejas/$email');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      }).timeout( Duration(seconds: 15));

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

  Future<List<Queja>> obtenerQuejasPorCategoria(String categoria) async {
    // Codificamos la categoría para asegurarnos de que los caracteres especiales
    // (como '/') se manejen correctamente en la URL.
    final String categoriaCodificada = Uri.encodeComponent(categoria);
    final url = Uri.parse('$_baseUrl/categoria/$categoriaCodificada');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      }).timeout( Duration(seconds: 15));

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

  Future<List<Queja>> obtenerQuejasPendientes() async {
    final url = Uri.parse('$_baseUrl/pendientes');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      }).timeout( Duration(seconds: 15));

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

  Future<Map<String, dynamic>> atenderQueja(String quejaId, String respuestaAdmin) async {
    // La ruta apunta al ID específico de la queja
    final url = Uri.parse('$_baseUrl/$quejaId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        // Enviamos la respuesta del admin en el cuerpo de la petición
        body: json.encode({'respuestaAdmin': respuestaAdmin}),
      ).timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData = json.decode(response.body);
      // Incluimos el código de estado para que la UI pueda verificarlo
      responseData['statusCode'] = response.statusCode;
      return responseData;

    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Revisa tu conexión.');
    } catch (e) {
      throw Exception('Ocurrió un error inesperado al atender la queja: $e');
    }
  }

  Future<Map<String, dynamic>> eliminarQueja(String quejaId) async {
    final url = Uri.parse('$_baseUrl/$quejaId');

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout( Duration(seconds: 15));

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
