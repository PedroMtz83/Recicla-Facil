import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../services/perfil_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Map<String, dynamic>>? _userProfileFuture;
  String? _userEmail;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProfile();
    });
  }

  void _initializeProfile() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isLoggedIn && authProvider.userEmail != null) {
      setState(() {
        _userEmail = authProvider.userEmail;
        _loadUserProfile();
      });
    } else {
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _loadUserProfile() {
    if (_userEmail != null) {
      setState(() {
        _userProfileFuture = PerfilService.getUserProfile(_userEmail!);
      });
    }
  }

  Future<void> _refreshProfile() async {
    _loadUserProfile();
  }

  void _showChangePasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar Contraseña'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña Nueva',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Campo requerido';
                    if (val.length < 6) return 'Debe tener al menos 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Contraseña Nueva',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Campo requerido';
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
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (_userEmail != null) {
                    _changePassword(
                      context,
                      newPasswordController.text,
                      confirmPasswordController.text,
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword(
    BuildContext context,
    String newPassword,
    String confirmPassword,
  ) async {
    setState(() => _isLoading = true);

    try {
      final result = await PerfilService.changePassword(
        email: _userEmail!,
        nuevaPassword: newPassword,
      );

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Cierra el diálogo

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['mensaje'] ?? 'Contraseña cambiada exitosamente'),
          duration: const Duration(seconds: 4),
          backgroundColor: result['statusCode'] == 200 ? Colors.green : Colors.red,
        ),
      );

      if (result['statusCode'] == 200) {
        // Limpiar campos después de éxito
        _loadUserProfile();
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Cierra el diálogo
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sesión cerrada exitosamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            tooltip: 'Cerrar Sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/fondo_login.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: (_userEmail == null || _userProfileFuture == null)
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<Map<String, dynamic>>(
                future: _userProfileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _buildErrorWidget(snapshot.error.toString());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyWidget();
                  }

                  final userData = snapshot.data!;
                  return _buildProfileContent(userData);
                },
              ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar el perfil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No se encontraron datos del usuario',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> userData) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildProfileHeader(
                userData['nombre'] ?? 'N/A',
                userData['email'] ?? 'N/A',
              ),
              const SizedBox(height: 30),
              _buildInfoCard(
                title: 'Información Personal',
                children: [
                  _infoTile(Icons.person_outline, 'Nombre', userData['nombre'] ?? 'N/A'),
                  _infoTile(Icons.email_outlined, 'Email', userData['email'] ?? 'N/A'),
                  _infoTile(Icons.password_outlined, 'Contraseña', '********'),
                  if (userData['admin'] != null)
                    _infoTile(
                      Icons.admin_panel_settings,
                      'Rol',
                      userData['admin'] == true ? 'Administrador' : 'Usuario',
                    ),
                  if (userData['fechaCreacion'] != null)
                    _infoTile(
                      Icons.calendar_today,
                      'Fecha de Registro',
                      _formatDate(userData['fechaCreacion']),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: () => _showChangePasswordDialog(context),
                      icon: const Icon(Icons.lock_reset),
                      label: const Text('Cambiar Contraseña'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
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
  }

  Widget _buildProfileHeader(String name, String email) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.lightGreen.shade100,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style: const TextStyle(fontSize: 40, color: Colors.black),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          email,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }

  String _formatDate(dynamic date) {
    try {
      if (date is String) {
        return DateTime.parse(date).toString().split(' ')[0];
      }
      return date.toString();
    } catch (e) {
      return 'Fecha no disponible';
    }
  }
}