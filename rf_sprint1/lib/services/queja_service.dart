import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class QuejaService {
  // La URL base para el recurso de quejas.
  final String _baseUrl = 'http://192.168.1.68:3000/api/quejas';

  QuejaService();

  Future<Map<String, dynamic>> crearQueja({
    required String mensaje,
    required String correo,
  }) async {
    final url = Uri.parse(_baseUrl);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'mensaje': mensaje,
          'correo': correo,
        }),
      ).timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData = json.decode(response.body);
      responseData['statusCode'] = response.statusCode;
      return responseData;

    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Revisa tu conexión.');
    }
  }
}
