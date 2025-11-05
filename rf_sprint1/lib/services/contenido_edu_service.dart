import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/contenido_educativo.dart';

class ContenidoEduService {
// ===================================================================
  // DETECTAR IP AUTOMÁTICAMENTE
  // ===================================================================
  static const String _direccionIpLocal = '192.168.1.101'; // <- CAMBIA ESTO POR TU IP

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

  static String get serverBaseUrl {
    // Para web, SIEMPRE usamos la IP local para acceder a recursos.
    if (kIsWeb) {
      return 'http://$_direccionIpLocal:3000';
    }

    // Para móvil, la lógica puede ser más compleja
    try {
      if (Platform.isAndroid) {
        // En emulador, usamos la IP especial. En físico, la IP local.
        // Una forma simple es asumir que si no es web, es la IP local.
        // Pero para ser precisos con el emulador:
        // return 'http://10.0.2.2:3000'; // Solo para emulador
        return 'http://$_direccionIpLocal:3000'; // Para dispositivo físico
      }
    } catch (e) {
      // Fallback
    }

    // Default para iOS y otros
    return 'http://$_direccionIpLocal:3000';
  }

  // ===================================================================
  // 1. OBTENER TODO EL CONTENIDO EDUCATIVO
  // ===================================================================
  Future<List<ContenidoEducativo>> obtenerContenidoEducativo({
    String? categoria,
    String? tipoMaterial,
    bool publicado = true,
    String? etiqueta,
    int limit = 10,
    int page = 1,
  }) async {
    final queryParams = {
      if (categoria != null) 'categoria': categoria,
      if (tipoMaterial != null) 'tipo_material': tipoMaterial,
      'publicado': publicado.toString(),
      if (etiqueta != null) 'etiqueta': etiqueta,
      'limit': limit.toString(),
      'page': page.toString(),
    };

    final uri = Uri.parse('$_apiRoot/contenido-educativo/');
    debugPrint('ContenidoEduService - Obteniendo contenido en: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> contenidosJson = data['contenidos'];
        return contenidosJson.map((json) => ContenidoEducativo.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar contenido educativo: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Revisa tu conexión.');
    } catch (e) {
      throw Exception('Ocurrió un error inesperado: $e');
    }
  }

  // ===================================================================
  // 2. OBTENER CONTENIDO POR ID
  // ===================================================================
  Future<ContenidoEducativo> obtenerContenidoPorId(String id) async {
    final url = Uri.parse('$_apiRoot/contenido-educativo/'+id);
    debugPrint('ContenidoEduService - Obteniendo contenido por ID en: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ContenidoEducativo.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Contenido no encontrado');
      } else {
        throw Exception('Error al cargar el contenido: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Revisa tu conexión.');
    } catch (e) {
      throw Exception('Ocurrió un error inesperado: $e');
    }
  }

  // ===================================================================
  // 3. CREAR CONTENIDO EDUCATIVO
  // ===================================================================
  Future<Map<String, dynamic>> crearContenidoEducativo({
    required String titulo,
    required String descripcion,
    required String contenido,
    required String categoria,
    required String tipoMaterial,
    required List<Map<String, dynamic>> imagenes,
    required List<String> puntosClave,
    required List<String> accionesCorrectas,
    required List<String> accionesIncorrectas,
    required List<String> etiquetas,
    bool publicado = false,
  }) async {
    final url = Uri.parse('$_apiRoot/contenido-educativo/');
    debugPrint('ContenidoEduService - Creando contenido en: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'titulo': titulo,
          'descripcion': descripcion,
          'contenido': contenido,
          'categoria': categoria,
          'tipo_material': tipoMaterial,
          'imagenes': imagenes,
          'puntos_clave': puntosClave,
          'acciones_correctas': accionesCorrectas,
          'acciones_incorrectas': accionesIncorrectas,
          'etiquetas': etiquetas,
          'publicado': publicado,
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
  // 4. ACTUALIZAR CONTENIDO EDUCATIVO
  // ===================================================================
  Future<Map<String, dynamic>> actualizarContenidoEducativo({
    required String id,
    String? titulo,
    String? descripcion,
    String? contenido,
    String? categoria,
    String? tipoMaterial,
    List<Map<String, dynamic>>? imagenes,
    List<String>? puntosClave,
    List<String>? accionesCorrectas,
    List<String>? accionesIncorrectas,
    List<String>? etiquetas,
    bool? publicado,
  }) async {
    final url = Uri.parse('$_apiRoot/contenido-educativo/'+id);
    debugPrint('ContenidoEduService - Actualizando contenido en: $url');

    try {
      final Map<String, dynamic> updateData = {};
      if (titulo != null) updateData['titulo'] = titulo;
      if (descripcion != null) updateData['descripcion'] = descripcion;
      if (contenido != null) updateData['contenido'] = contenido;
      if (categoria != null) updateData['categoria'] = categoria;
      if (tipoMaterial != null) updateData['tipo_material'] = tipoMaterial;
      if (imagenes != null) updateData['imagenes'] = imagenes;
      if (puntosClave != null) updateData['puntos_clave'] = puntosClave;
      if (accionesCorrectas != null) updateData['acciones_correctas'] = accionesCorrectas;
      if (accionesIncorrectas != null) updateData['acciones_incorrectas'] = accionesIncorrectas;
      if (etiquetas != null) updateData['etiquetas'] = etiquetas;
      if (publicado != null) updateData['publicado'] = publicado;

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(updateData),
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
  // 5. ELIMINAR CONTENIDO EDUCATIVO
  // ===================================================================
  Future<Map<String, dynamic>> eliminarContenidoEducativo(String id) async {
    final url = Uri.parse('$_apiRoot/contenido-educativo/'+id);
    debugPrint('ContenidoEduService - Eliminando contenido en: $url');

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
      throw Exception('Ocurrió un error inesperado al eliminar el contenido: $e');
    }
  }

  // ===================================================================
  // 6. OBTENER CONTENIDO POR CATEGORÍA
  // ===================================================================
  Future<List<ContenidoEducativo>> obtenerContenidoPorCategoria(String categoria, {bool publicado = true}) async {
    final queryParams = {'publicado': publicado.toString()};
    final uri = Uri.parse('$_apiRoot/contenido-educativo/categoria/'+categoria);
    debugPrint('ContenidoEduService - Obteniendo contenido por categoría en: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ContenidoEducativo.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar contenido por categoría: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Revisa tu conexión.');
    } catch (e) {
      throw Exception('Ocurrió un error inesperado: $e');
    }
  }

  // ===================================================================
  // 7. OBTENER CONTENIDO POR TIPO DE MATERIAL
  // ===================================================================
  Future<List<ContenidoEducativo>> obtenerContenidoPorTipoMaterial(String tipoMaterial, {bool publicado = true}) async {
    final queryParams = {'publicado': publicado.toString()};
    final uri = Uri.parse('$_apiRoot/contenido-educativo/material/'+tipoMaterial);
    debugPrint('ContenidoEduService - Obteniendo contenido por tipo de material en: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ContenidoEducativo.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar contenido por tipo de material: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Revisa tu conexión.');
    } catch (e) {
      throw Exception('Ocurrió un error inesperado: $e');
    }
  }

  // ===================================================================
  // 8. BUSCAR CONTENIDO EDUCATIVO
  // ===================================================================
  Future<List<ContenidoEducativo>> buscarContenidoEducativo(String termino, {bool publicado = true}) async {
    final queryParams = {'publicado': publicado.toString()};
    final uri = Uri.parse('$_apiRoot/contenido-educativo/buscar/'+termino);
    debugPrint('ContenidoEduService - Buscando contenido en: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ContenidoEducativo.fromJson(json)).toList();
      } else {
        throw Exception('Error al buscar contenido: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Revisa tu conexión.');
    } catch (e) {
      throw Exception('Ocurrió un error inesperado: $e');
    }
  }
}