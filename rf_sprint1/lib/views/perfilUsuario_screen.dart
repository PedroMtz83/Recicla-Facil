
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../services/perfil_service.dart';
import '../services/usuario_service.dart';
import 'login_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool? _esAdmin;
  bool _verificacionCompleta = false;
  String? _userEmail;
  Map<String, dynamic>? _userData;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarRolUsuario();
    });
  }

  Future<void> _verificarRolUsuario() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.userEmail == null) {
      setState(() {
        _esAdmin = false;
        _verificacionCompleta = true;
      });
      return;
    }
    _userEmail = authProvider.userEmail;
    try {
      final userData = await PerfilService.getUserProfile(_userEmail!);
      print("========================================================");
      print("PASO DE DEPURACIÓN: DATOS RECIBIDOS DEL PERFIL");
      print("TIPO DE DATO CRUDO: ${userData.runtimeType}");
      print("CONTENIDO CRUDO: $userData");
      print("VALOR DEL CAMPO 'admin': ${userData['admin']}");
      print("TIPO DEL CAMPO 'admin': ${userData['admin'].runtimeType}");
      print("========================================================");
      setState(() {
        _userData = userData;
        final adminValue = userData['admin'];
        _esAdmin = (adminValue == true || adminValue == 1 || adminValue == 'true');
        _verificacionCompleta = true;
      });
    } catch (e) {
      debugPrint("Error al verificar rol de admin: $e");
      setState(() {
        _esAdmin = null;
        _verificacionCompleta = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (!_verificacionCompleta) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_esAdmin == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security_update_warning, color: Colors.orange, size: 60),
                SizedBox(height: 20),
                Text(
                  'No se pudo verificar el rol del usuario',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Esto puede deberse a un problema de conexión. Intenta reiniciar la aplicación.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _verificacionCompleta = false;
                    });
                    _verificarRolUsuario();
                  },
                  child: Text('Reintentar'),
                )
              ],
            ),
          ),
        ),
      );
    }

    // 3. Si es admin, muestra la vista de admin (esto ya está bien)
    if (_esAdmin == true) {
      return VistaAdminConNavegacion(userData: _userData);
    }
    // 4. Si no, muestra la vista normal (esto ya está bien)
    else {
      return Scaffold(
        body: VistaPerfil(
            userEmail: _userEmail,
            initialData: _userData),
      );
    }
  }
}

class VistaAdminConNavegacion extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const VistaAdminConNavegacion({super.key, this.userData,});

  @override
  State<VistaAdminConNavegacion> createState() => _VistaAdminConNavegacionState();
}

class _VistaAdminConNavegacionState extends State<VistaAdminConNavegacion> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _pages = [
      VistaPerfil(
          userEmail: widget.userData?['email'],
          initialData: widget.userData,
      ),
      VistaConsultarUsuario(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.green,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Mi Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_search_outlined),
            activeIcon: Icon(Icons.manage_search),
            label: 'Gestionar',
          ),
        ],
      ),
    );
  }
}

class VistaPerfil extends StatefulWidget {
  final String? userEmail;
  final Map<String, dynamic>? initialData;
  const VistaPerfil({super.key, required this.userEmail, this.initialData});

  @override
  _VistaPerfilState createState() => _VistaPerfilState();
}

class _VistaPerfilState extends State<VistaPerfil> {
  Future<Map<String, dynamic>>? _userProfileFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialData != null && widget.initialData!.isNotEmpty) {
        setState(() {
          _userProfileFuture = Future.value(widget.initialData);
        });
      }
      else if (widget.userEmail != null) {
        _loadUserProfile();
      }
      else {
        _redirectToLogin();
      }
    });
  }

  void _redirectToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  void _loadUserProfile() {
    setState(() {
      _userProfileFuture = PerfilService.getUserProfile(widget.userEmail!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/backgrounds/fondo_login.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: (widget.userEmail == null || _userProfileFuture == null)
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<Map<String, dynamic>>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _construirWidgetError(snapshot.error.toString());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _construirWidgetVacio();
          }
          final userData = snapshot.data!;
          return _construirContenidoPerfil(userData);
        },
      ),
    );
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
          title: Text('Cambiar Contraseña'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Contraseña Nueva', border: OutlineInputBorder()),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Campo requerido';
                    if (val.length < 6) return 'Debe tener al menos 6 caracteres';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Confirmar Contraseña Nueva', border: OutlineInputBorder()),
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
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (widget.userEmail != null) {
                    _changePassword(context, newPasswordController.text);
                  }
                }
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword(BuildContext context, String newPassword) async {
    setState(() => _isLoading = true);
    try {
      final result = await PerfilService.changePassword(email: widget.userEmail!, nuevaPassword: newPassword);
      Navigator.of(context).pop(); // Cierra el diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['mensaje'] ?? 'Contraseña cambiada exitosamente'),
          backgroundColor: result['statusCode'] == 200 ? Colors.green : Colors.red,
        ),
      );
      if (result['statusCode'] == 200) {
        _loadUserProfile();
      }
    } catch (e) {
      Navigator.of(context).pop(); // Cierra el diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Widget _construirWidgetError(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Error al cargar el perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _loadUserProfile, child: Text('Reintentar')),
          ],
        ),
      ),
    );
  }

  Widget _construirWidgetVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No se encontraron datos del usuario', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _construirInfoCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(value, style: TextStyle(fontSize: 16)),
    );
  }

  String _formatoFecha(dynamic date) {
    try {
      if (date is String) {
        return DateTime.parse(date).toLocal().toString().split(' ')[0];
      }
      return date.toString();
    } catch (e) {
      return 'Fecha no disponible';
    }
  }


  Widget _construirContenidoPerfil(Map<String, dynamic> userData) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600),
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              SizedBox(height: 30),
              _construirInfoCard(
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
                      _formatoFecha(userData['fechaCreacion']),
                    ),
                ],
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                onPressed: () => _showChangePasswordDialog(context),
                icon: Icon(Icons.lock_reset),
                label: Text('Cambiar Contraseña'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
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
}
class VistaConsultarUsuario extends StatefulWidget {
  const VistaConsultarUsuario({super.key});

  @override
  _VistaConsultarUsuarioState createState() => _VistaConsultarUsuarioState();
}

class _VistaConsultarUsuarioState extends State<VistaConsultarUsuario> {
  final _emailController = TextEditingController();
  final _usuarioService = UsuarioService();
  Map<String, dynamic>? _usuarioEncontrado;
  Future<List<Map<String, dynamic>>>? _futureUsuarios;
  List<Map<String, dynamic>> _todosLosUsuarios = [];
  List<Map<String, dynamic>> _usuariosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _cargarTodosLosUsuarios();
    _emailController.addListener(_filtrarUsuarios);
  }

  @override
  void dispose() {
    _emailController.removeListener(_filtrarUsuarios);
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _cargarTodosLosUsuarios() async {
    setState(() {
      _futureUsuarios = _usuarioService.obtenerUsuarios();
    });

    try {
      final usuarios = await _futureUsuarios;
      setState(() {
        _todosLosUsuarios = usuarios ?? [];
        _usuariosFiltrados = usuarios ?? [];
      });
    } catch (e) {
      debugPrint("Error al poblar las listas locales: $e");
    }
  }

  void _filtrarUsuarios() {
    final query = _emailController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _usuariosFiltrados = _todosLosUsuarios;
      } else {
        _usuariosFiltrados = _todosLosUsuarios.where((usuario) {
          final nombre = (usuario['nombre'] as String? ?? '').toLowerCase();
          final email = (usuario['email'] as String? ?? '').toLowerCase();
          return nombre.contains(query) || email.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _buscarUsuario() async {
    if (_emailController.text.isEmpty) return;
    setState(() {
      _usuarioEncontrado = null;
    });

    try {
      final usuario = await PerfilService.getUserProfile(_emailController.text);
      setState(() => _usuarioEncontrado = usuario);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario no encontrado o error: $e'), backgroundColor: Colors.orange),
      );
    }
  }

  Future<void> _eliminarUsuario(String email) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar al usuario con email $email?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmar == true) {
      final exito = await _usuarioService.eliminarUsuario(email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(exito ? 'Usuario eliminado' : 'Error al eliminar'),
        backgroundColor: exito ? Colors.green : Colors.red,
      ));
      if (exito) {
        _cargarTodosLosUsuarios();
      }
    }
  }


  void _mostrarDialogoEditar(Map<String, dynamic> usuario) {
    final nombreController = TextEditingController(text: usuario['nombre']?.toString() ?? '');
    final passwordController = TextEditingController(text: usuario['password']?.toString() ?? '');

    Object? adminValue = usuario['admin'];
    bool esAdminInicial = false;
    if (adminValue is bool) {
      esAdminInicial = adminValue;
    } else if (adminValue is int) {
      esAdminInicial = (adminValue == 1);
    } else if (adminValue is String) {
      esAdminInicial = (adminValue.toLowerCase() == 'true');
    }
    bool esAdminActual = esAdminInicial;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {

            return AlertDialog(
              title: Text('Editar Usuario'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: InputDecoration(labelText: 'Nombre'),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Contraseña'),
                    ),
                    SizedBox(height: 8),
                    SwitchListTile(
                      title: Text('Administrador'),
                      value: esAdminActual,
                      onChanged: (newValue) {
                        setDialogState(() {
                          esAdminActual = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final exito = await _usuarioService.actualizarUsuario(
                      email: usuario['email'] ?? '',
                      nombre: nombreController.text,
                      admin: esAdminActual,
                    );

                    Navigator.of(dialogContext).pop();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(exito ? 'Usuario actualizado' : 'Error al actualizar'),
                        backgroundColor: exito ? Colors.green : Colors.red,
                      ));
                      if (exito) {
                        _cargarTodosLosUsuarios(); // Refresca la lista
                      }
                    }
                  },
                  child: Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/backgrounds/fondo_login.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Buscar por Email', border: InputBorder.none, prefixIcon: Icon(Icons.search)),
                      keyboardType: TextInputType.emailAddress,
                      onSubmitted: (_) => _buscarUsuario(),
                    ),
                  ),
                  IconButton(onPressed: _buscarUsuario, icon: Icon(Icons.send)),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureUsuarios,
          builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Error al cargar usuarios: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No se encontraron usuarios.', style: TextStyle(color: Colors.white)));
          }
          final List<Map<String, dynamic>> todosLosUsuarios =  snapshot.data!.where((u) => u != null).toList();
          final String query = _emailController.text.toLowerCase();
          final List<Map<String, dynamic>> usuariosFiltrados = query.isEmpty
              ? todosLosUsuarios
              : todosLosUsuarios.where((usuario) {
            final nombre = (usuario['nombre'] as String? ?? '').toLowerCase();
            final email = (usuario['email'] as String? ?? '').toLowerCase();
            return nombre.contains(query) || email.contains(query);
          }).toList();
          if (usuariosFiltrados.isEmpty) {
            return Center(
              child: Text(
                query.isEmpty
                    ? 'No hay usuarios.'
                    : 'No hay usuarios que coincidan con la búsqueda.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView.builder(
          itemCount: _usuariosFiltrados.length,
          itemBuilder: (context, index) {
          final usuario = _usuariosFiltrados[index];
          final String nombre = usuario['nombre'] ?? 'Sin Nombre';
          final String email = usuario['email'] ?? '';
           bool esAdmin;
          try {
            final adminValue = usuario['admin'];
            if (adminValue == null) {
              esAdmin = false;
            } else if (adminValue is bool) {
              esAdmin = adminValue;
            } else if (adminValue is int) {
              esAdmin = (adminValue == 1);
            } else if (adminValue is String) {
              esAdmin = (adminValue.toLowerCase() == 'true');
            } else {
              esAdmin = false;
            }
          } catch (e) {
            esAdmin = false;
            print("ERROR AL PROCESAR EL CAMPO 'admin': $e");
          }
          final Widget leadingWidget = CircleAvatar(
            backgroundColor: esAdmin ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
            child: Icon(esAdmin ? Icons.shield : Icons.person, color: esAdmin ? Colors.green : Colors.blueGrey),
          );

          final Widget titleWidget = Text(nombre, style: TextStyle(fontWeight: FontWeight.bold));
          final Widget subtitleWidget = Text(email);
          final Widget editButton = IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
            onPressed: () {
              _mostrarDialogoEditar(usuario);
            },
          );

          final Widget deleteButton = email.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
            onPressed: () {
              _eliminarUsuario(email);
            },
          )
              : SizedBox.shrink();

          return Card(
          margin: EdgeInsets.symmetric(vertical: 6.0),
          child: ListTile(
            leading: leadingWidget,
            title: titleWidget,
            subtitle: subtitleWidget,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                editButton,
                deleteButton,
              ],
            ),
                ),
              );
            }
            );
          }
         )
          )
        ],
      ),
    );
  }
}
