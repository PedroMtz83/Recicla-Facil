import 'dart:convert';
import 'package:http/http.dart' as http;

class PerfilService {
  // Asegúrate de que esta IP sea accesible desde tu emulador/dispositivo.
  // Para emulador de Android usa 10.0.2.2 en lugar de localhost.
  //static const String _baseUrl = 'http://10.0.2.2:3000/api/users';
  static const String _baseUrl = 'http://192.168.1.101:3000/api/usuarios';

  // Obtiene los datos del perfil del usuario
  static Future<Map<String, dynamic>> getUserProfile(String email) async {
    final response = await http.get(Uri.parse('$_baseUrl/$email'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {

      throw Exception(response.body);
    }
  }

  // Cambia la contraseña del usuario
  static Future<Map<String, dynamic>> changePassword({
    required String email,
    required String nuevaPassword
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/cambiar-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'nuevaPassword': nuevaPassword,
      }),
    );

    return json.decode(response.body);
  }
}
