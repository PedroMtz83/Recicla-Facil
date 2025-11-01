import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../services/perfil_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
   ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- CORRECCIÓN: _userProfileFuture debe ser anulable ---
  // Para que no tengamos que inicializarlo con un valor por defecto.
  Future<Map<String, dynamic>>? _userProfileFuture;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    // Ejecuta este código después de que el widget se haya construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProfile();
    });
  }

  void _initializeProfile() {
    // Obtiene la instancia del AuthProvider para saber quién es el usuario
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isLoggedIn && authProvider.userEmail != null) {
      // Si el usuario está logueado, guardamos su email y cargamos su perfil
      setState(() {
        _userEmail = authProvider.userEmail;
        _loadUserProfile();
      });
    } else {
      // Medida de seguridad: si se llega aquí sin estar logueado, se redirige al login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _loadUserProfile() {
    // Solo carga los datos si tenemos un email
    if (_userEmail != null) {
      setState(() {
        _userProfileFuture = PerfilService.getUserProfile(_userEmail!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- CORRECCIÓN: Lógica de construcción invertida y simplificada ---
    return Scaffold(
      appBar: AppBar(
        title:  Text('Mi Perfil'),
        backgroundColor: Colors.green,
        actions: [
          // Botón para cerrar sesión
          IconButton(
            tooltip: 'Cerrar Sesión',
            icon:  Icon(Icons.logout),
            onPressed: () {
              // Llama al método logout del provider
              Provider.of<AuthProvider>(context, listen: false).logout();
              // Redirige al usuario a la pantalla de login y limpia el historial de navegación
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) =>  LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration:  BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/fondo_login.png'),
            fit: BoxFit.cover,
          ),
        ),
        // Si aún no hemos obtenido el email o no hemos empezado a cargar, mostramos un loader.
        child: (_userEmail == null || _userProfileFuture == null)
            ?  Center(child: CircularProgressIndicator())
            : FutureBuilder<Map<String, dynamic>>(
          future: _userProfileFuture,
          builder: (context, snapshot) {
            // Mientras se cargan los datos
            if (snapshot.connectionState == ConnectionState.waiting) {
              return  Center(child: CircularProgressIndicator());
            }
            // Si hubo un error de red o de la API
            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar el perfil: ${snapshot.error}'));
            }
            // Si no hay datos (ej. usuario no encontrado)
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return  Center(child: Text('No se encontraron datos del usuario.'));
            }

            // Si todo va bien, obtenemos los datos del usuario.
            // OJO: Si tu API devuelve { "usuario": { ... } }, debes usar snapshot.data!['usuario']
            final userData = snapshot.data!;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600
                ),
                child: RefreshIndicator(
                  onRefresh: () async => _loadUserProfile(),
                  child: ListView(
                    padding:  EdgeInsets.all(16.0),
                    children: [
                      _buildProfileHeader(userData['nombre'] ?? 'N/A', userData['email'] ?? 'N/A'),
                       SizedBox(height: 30),
                      _buildInfoCard(
                        title: 'Información Personal',
                        children: [
                          _infoTile(Icons.person_outline, 'Nombre', userData['nombre'] ?? 'N/A'),
                          _infoTile(Icons.email_outlined, 'Email', userData['email'] ?? 'N/A'),
                          // --- CORRECCIÓN: NUNCA muestres la contraseña en la UI ---
                          _infoTile(Icons.password_outlined, 'Contraseña', '********'),
                        ],
                      ),
                       SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _showChangePasswordDialog(context),
                        icon:  Icon(Icons.lock_reset),
                        label:  Text('Cambiar Contraseña'),
                        style: ElevatedButton.styleFrom(
                          padding:  EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Widgets de la UI (Sin cambios) ---

  Widget _buildProfileHeader(String name, String email) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.lightGreen.shade100,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style:  TextStyle(fontSize: 40, color: Colors.black),
          ),
        ),
         SizedBox(height: 10),
        Text(name, style:  TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(email, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding:  EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style:  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
             Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(label, style:  TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(value, style:  TextStyle(fontSize: 16)),
    );
  }

  // --- Lógica del Diálogo para Cambiar Contraseña ---

  void _showChangePasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:  Text('Cambiar Contraseña'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration:  InputDecoration(labelText: 'Contraseña Nueva'),
                  validator: (val) {
                    if (val!.isEmpty) return 'Campo requerido';
                    if (val.length < 4) return 'Debe tener al menos 4 caracteres';
                    return null;
                  },
                ),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration:  InputDecoration(labelText: 'Confirmar Contraseña Nueva'),
                  validator: (val) {
                    if (val != newPasswordController.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:  Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // --- CORRECCIÓN: Usar la variable de estado _userEmail ---
                  // Nos aseguramos de que _userEmail no sea nulo antes de usarlo.
                  if (_userEmail != null) {
                    final result = await PerfilService.changePassword(
                      email: _userEmail!,
                      nuevaPassword: confirmPasswordController.text,
                    );

                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop(); // Cierra el diálogo

                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['mensaje'] ?? 'Respuesta recibida.'),
                        duration:  Duration(seconds: 4),
                        backgroundColor: result['statusCode'] == 200 ? Colors.green : Colors.red,
                      ),
                    );

                    // Vuelve a cargar el perfil para reflejar cualquier cambio (aunque aquí no aplica)
                    _loadUserProfile();
                  }
                }
              },
              child:  Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
