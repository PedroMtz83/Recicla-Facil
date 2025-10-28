import 'package:flutter/material.dart';
import 'services/usuario_service.dart';

class AppSp01 extends StatefulWidget {
  AppSp01({super.key});

  @override
  State<AppSp01> createState() => _AppSp01State();
}

class _AppSp01State extends State<AppSp01> {
  final UsuarioService _apiService = UsuarioService();

  // --- CAMBIO 1: Variables de estado para la lista ---
  // Guardaremos la lista de usuarios aquí en lugar de en un simple String.
  List<dynamic> _usuarios = [];
  // Para mostrar un indicador de carga mientras se obtienen los datos.
  bool _isLoading = false;
  // Mantenemos una variable para los mensajes de los otros botones.
  String _statusMessage = 'Presiona un botón para probar la API';

  // --- CAMBIO 2: Función _probarGet actualizada ---
  // Ahora llena la lista _usuarios y maneja el estado de carga.
  void _probarGet() async {
    setState(() {
      _isLoading = true; // Inicia el indicador de carga
      _statusMessage = 'Cargando lista de usuarios...';
    });

    try {
      final usuariosObtenidos = await _apiService.obtenerUsuarios();
      setState(() {
        _usuarios = usuariosObtenidos; // Guarda la lista completa
        _statusMessage = 'Se encontraron ${_usuarios.length} usuarios.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al obtener usuarios: $e';
        _usuarios = []; // Limpia la lista en caso de error
      });
    } finally {
      setState(() {
        _isLoading = false; // Detiene el indicador de carga
      });
    }
  }

  // --- Mantenemos tus otras funciones de prueba ---
  void _probarPost() async {
    setState(() => _statusMessage = 'Creando usuario...');
    final correoUnico = 'prueba1@example.com';
    bool exito = await _apiService.crearUsuario(
        nombre: 'Pedro92A', email: correoUnico, password: '12345');
    setState(() => _statusMessage = exito
        ? 'Usuario creado con éxito. ¡Vuelve a presionar GET!'
        : 'Error al crear usuario.');
    if (exito) _usuarios = []; // Limpia la lista para forzar la recarga
  }

  void _probarPut() async {
    setState(() => _statusMessage = 'Actualizando usuario...');
    bool exito = await _apiService.actualizarUsuario(
        email: 'prueba1@example.com', nombre: 'PedroM', admin: true);
    setState(() => _statusMessage = exito
        ? 'Usuario actualizado con éxito. ¡Vuelve a presionar GET!'
        : 'Error al actualizar.');
    if (exito) _usuarios = [];
  }

  void _probarDelete() async {
    setState(() => _statusMessage = 'Eliminando usuario...');
    bool exito = await _apiService.eliminarUsuario('prueba1@example.com');
    setState(() => _statusMessage = exito
        ? 'Usuario eliminado con éxito. ¡Vuelve a presionar GET!'
        : 'Error al eliminar.');
    if (exito) _usuarios = [];
  }

  // --- CAMBIO 3: El método build refactorizado ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestor de Usuarios API'),
        actions: [
          // Un botón para recargar la lista directamente desde la AppBar
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _probarGet,
            tooltip: 'Recargar Lista',
          ),
        ],
      ),
      // El cuerpo ahora es dinámico: muestra la lista o los botones
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Una sección superior para los botones y mensajes
            _buildControlPanel(),
            Divider(height: 20, thickness: 2),
            // Una sección inferior que muestra la lista de usuarios
            _buildUserListView(),
          ],
        ),
      ),
    );
  }

  // Widget para los botones de control
  Widget _buildControlPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400)),
          child: Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(height: 10),
        // Usamos una fila para que los botones se vean mejor
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: _probarGet, child: const Text('GET')),
            ElevatedButton(
                onPressed: _probarPost,
                child: Text('POST'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green)),
            ElevatedButton(
                onPressed: _probarPut,
                child: Text('PUT'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange)),
            ElevatedButton(
                onPressed: _probarDelete,
                child: Text('DELETE'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red)),
          ],
        ),
      ],
    );
  }

  // Widget para la lista de usuarios
  Widget _buildUserListView() {
    // Si está cargando, muestra el CircularProgressIndicator
    if (_isLoading) {
      return Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    // Si la lista está vacía (después de cargar), muestra un mensaje
    if (_usuarios.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'No hay usuarios para mostrar.\nPresiona "GET" para cargar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    // Si hay usuarios, construye el ListView.builder
    // Expanded es crucial para que el ListView ocupe el espacio restante.
    return Expanded(
      child: ListView.builder(
        itemCount: _usuarios.length,
        itemBuilder: (context, index) {
          final usuario = _usuarios[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 6.0),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(usuario['nombre']?[0] ?? 'U'),
              ),
              title: Text(usuario['nombre'] ?? 'Sin nombre'),
              subtitle: Text(usuario['email'] ?? 'Sin email'),
              trailing: (usuario['admin'] == true)
                  ? Icon(Icons.shield, color: Colors.blue)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
