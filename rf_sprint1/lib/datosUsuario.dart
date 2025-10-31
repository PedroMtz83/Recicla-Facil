import 'package:flutter/material.dart';
import 'api_service.dart'; // Asegúrate de que la ruta sea correcta

class ProfileScreen extends StatefulWidget {
  final String userEmail; // El ID del usuario que ha iniciado sesión

  const ProfileScreen({super.key, required this.userEmail});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    _userProfileFuture = ApiService.getUserProfile(widget.userEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/fondo_login.png'),
            fit: BoxFit.cover, // Para que la imagen cubra todo el espacio
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _userProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No se encontraron datos del usuario.'));
            }

            final userData = snapshot.data!;

            return RefreshIndicator(
              onRefresh: () async => setState(() => _loadUserProfile()),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildProfileHeader(userData['nombre'], userData['email']),
                  const SizedBox(height: 30),
                  _buildInfoCard(
                    title: 'Información Personal',
                    children: [
                      _infoTile(Icons.person_outline, 'Nombre', userData['nombre']),
                      _infoTile(Icons.email_outlined, 'Email', userData['email']),
                      _infoTile(Icons.password_outlined, 'Contraseña', userData['password'] ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
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
            );
          },
        ),
      ),
    );
  }

  // --- Widgets de la UI ---

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
        Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(email, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
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
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  // --- Lógica del Diálogo para Cambiar Contraseña ---

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
                  decoration: const InputDecoration(labelText: 'Contraseña Nueva'),
                  validator: (val) {
                    if (val!.isEmpty) return 'Campo requerido';
                    if (val.length < 4) return 'Debe tener al menos 4 caracteres';
                    return null;
                  },
                ),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirmar Contraseña Nueva'),
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
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {

                    final result = await ApiService.changePassword(email: widget.userEmail, nuevaPassword: confirmPasswordController.text);

                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop(); // Cierra el diálogo

                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['mensaje']),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                    setState(() {
                      _loadUserProfile();
                    });



                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
