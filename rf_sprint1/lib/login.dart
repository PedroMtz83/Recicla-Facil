import 'package:flutter/material.dart';
import 'services/usuario_service.dart';
class AppSp01 extends StatefulWidget {
  const AppSp01({super.key});

  @override
  State<AppSp01> createState() => _AppSp01State();
}

class _AppSp01State extends State<AppSp01> {
  final UsuarioService _apiService = UsuarioService();
  String _apiResponse = 'Presiona un botón para probar la API';
  void _probarGet() async {
    setState(() => _apiResponse = 'Cargando lista de usuarios...');
    try {
      List<dynamic> usuarios = await _apiService.obtenerUsuarios();
      setState(() {
        if (usuarios.isNotEmpty) {
          final primerUsuario = usuarios[0];
          _apiResponse =
          '¡Éxito! Se encontraron ${usuarios.length} usuarios.\n\n'
              'Primer usuario:\n'
              'Nombre: ${primerUsuario['nombre']}\n'
              'Email: ${primerUsuario['email']}\n'
              'Password: ${primerUsuario['password']}\n'
              'Admin: ${primerUsuario['admin']}'
          ;
        } else {
          _apiResponse = 'No se encontraron usuarios en la base de datos o hubo un problema.';
        }
      });
    } catch (e) {
      setState(() {
        _apiResponse = 'Ocurrió un error inesperado en la UI: $e';
      });
    }
  }

  void _probarPost() async {
    setState(() => _apiResponse = 'Creando...');
    final correoUnico = 'user.${DateTime.now().millisecondsSinceEpoch}@example.com';
    // ¡Usa los parámetros correctos: nombre, email, password!
    bool exito = await _apiService.crearUsuario(
        nombre: 'Usuario Flutter',
        email: correoUnico,
        password: '123'
    );
    setState(() => _apiResponse = exito ? 'Usuario creado!' : 'Error creando');
  }

  void _probarPut() async {
    setState(() => _apiResponse = 'Actualizando...');
    // Actualiza usando el email 'test@example.com' (asegúrate de que exista)
    bool exito = await _apiService.actualizarUsuario(
        email: 'test@example.com',
        nombre: 'Nombre Actualizado Desde Flutter'
    );
    setState(() => _apiResponse = exito ? 'Usuario actualizado!' : 'Error actualizando');
  }

  void _probarDelete() async {
    setState(() => _apiResponse = 'Eliminando...');
    // Elimina usando el email 'test2@example.com' (asegúrate de que exista)
    bool exito = await _apiService.eliminarUsuario('test2@example.com');
    setState(() => _apiResponse = exito ? 'Usuario eliminado!' : 'Error eliminando');
  }

// ... resto de tu widget de prueba con los botones ...

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Probando API')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Contenedor para mostrar la respuesta
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400)
                ),
                child: Text(
                  _apiResponse,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),

              // Botón que llama a la función
              ElevatedButton(
                onPressed: _probarGet, // Asocia la función al botón
                child: const Text('GET (Obtener Usuarios)'),
              ),

              // Aquí puedes añadir los otros botones
            ],
          ),
        ),
      ),
    );
  }
}
