import '../models/punto_reciclaje.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/foundation.dart';

class PuntosReciclajeService {
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

  // ===================================================================
  // 1. OBTENER PERFIL DE USUARIO
  // ===================================================================
  static Future<List<dynamic>> obtenerPuntosReciclajePorMaterial(String material) async {
    final url = Uri.parse('$_apiRoot/puntos-reciclaje/material/'+material);
    debugPrint('Puntos_reciclaje_Service - Obteniendo datos en: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final dynamic datosDecodificados = json.decode(response.body);

        if (datosDecodificados is List) {
          debugPrint('PuntosService - Éxito. Se recibieron ${datosDecodificados.length} elementos.');
          return datosDecodificados;
        } else {
          debugPrint('PuntosService - Error: La respuesta no es una lista, es un ${datosDecodificados.runtimeType}.');
          return [];
        }
      } else {
        debugPrint('PuntosService - Error del servidor. Código: ${response.statusCode}. Cuerpo: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('PuntosService - Excepción capturada: $e');
      return [];
    }
  }

  static Future<List<dynamic>> obtenerPuntosReciclajeEstado(String estado) async {
    final url = Uri.parse('$_apiRoot/puntos-reciclaje/estado/'+estado);
    debugPrint('Puntos_reciclaje_Service - Obteniendo datos en: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final dynamic datosDecodificados = json.decode(response.body);

        if (datosDecodificados is List) {
          debugPrint('PuntosService - Éxito. Se recibieron ${datosDecodificados.length} elementos.');
          return datosDecodificados;
        } else {
          debugPrint('PuntosService - Error: La respuesta no es una lista, es un ${datosDecodificados.runtimeType}.');
          return [];
        }
      } else {
        debugPrint('PuntosService - Error del servidor. Código: ${response.statusCode}. Cuerpo: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('PuntosService - Excepción capturada: $e');
      return [];
    }
  }
}