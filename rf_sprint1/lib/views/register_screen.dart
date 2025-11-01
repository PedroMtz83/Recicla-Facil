import 'package:flutter/material.dart';
import '../services/usuario_service.dart';

class RegisterScreen extends StatefulWidget {
   RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usuarioService = UsuarioService();
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Verificar que las contraseñas coincidan
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. Llamar al servicio (que ahora devuelve un Map)
      final response = await usuarioService.crearUsuario(
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text, // Las contraseñas no suelen llevar .trim()
      );

      // Si por alguna razón la respuesta es nula, lo manejamos.
      // --- ¡NUEVA LÓGICA DE MANEJO DE RESPUESTAS! ---
      // Usamos el statusCode que añadimos en el servicio.

      if (response['statusCode'] == 201) { // 201: Creado con éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro exitoso. ¡Ahora puedes iniciar sesión!')),
          );
          Navigator.pop(context); // Volver a la pantalla de login
        }
      } else if (response['statusCode'] == 409) { // 409: Conflicto (Correo ya existe)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['mensaje'] ?? 'El correo ya está en uso.')),
          );
        }
      } else { // Cualquier otro código de error (400, 500, etc.)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['mensaje'] ?? 'Ocurrió un error en el registro.')),
          );
        }
      }

    } catch (e) {
      // 4. El bloque CATCH ahora solo atrapa los errores de CONEXIÓN que lanzamos desde el servicio
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          // Mostramos el mensaje exacto de la excepción (Timeout, Sin conexión, etc.)
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      // 5. Asegurarnos de que el indicador de carga siempre se oculte
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            // Fondo de pantalla (mismo que login)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration:  BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/backgrounds/fondo_login.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Capa semitransparente
            Container(
              width: double.infinity,
              height: double.infinity,
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.3),
            ),
            
            Center(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding:  EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 450
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                           SizedBox(height: 40),

                          // Logo + Título
                          SizedBox(
                            width: 393,
                            height: 104,
                            child: Image.asset(
                              'assets/images/logos/logo_completo.png',
                              fit: BoxFit.contain,
                            ),
                          ),

                           SizedBox(height: 16),

                           Text(
                            'Regístrate',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),

                           SizedBox(height: 40),

                          // Campo de nombre de usuario
                          Container(
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: _nombreController,
                              decoration:  InputDecoration(
                                labelText: 'Nombre de usuario',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nombre obligatorio';
                                }
                                if (value.length < 3) {
                                  return 'Mínimo 3 caracteres';
                                }
                                return null;
                              },
                            ),
                          ),

                           SizedBox(height: 20),

                          // Campo de correo electrónico
                          Container(
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration:  InputDecoration(
                                labelText: 'Correo Electrónico',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Correo electrónico obligatorio';
                                }
                                if (!value.contains('@') || !value.contains('.')) {
                                  return 'Ingresa un correo válido';
                                }
                                return null;
                              },
                            ),
                          ),

                           SizedBox(height: 20),

                          // Campo de contraseña
                          Container(
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                border: InputBorder.none,
                                contentPadding:  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                prefixIcon:  Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Contraseña obligatoria';
                                }
                                if (value.length < 6) {
                                  return 'Mínimo 6 caracteres';
                                }
                                return null;
                              },
                            ),
                          ),

                           SizedBox(height: 20),

                          // Campo de confirmar contraseña
                          Container(
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'Confirmar Contraseña',
                                border: InputBorder.none,
                                contentPadding:  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                prefixIcon:  Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Confirma tu contraseña';
                                }
                                return null;
                              },
                            ),
                          ),

                           SizedBox(height: 30),

                          // Botón Registrarse
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 4,
                              ),
                              child: _isLoading
                                  ?  SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  :  Text(
                                      'Registrarse',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                           SizedBox(height: 20),

                          // Enlace para volver al login
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child:  Text(
                              '¿Ya tienes cuenta? Inicia sesión',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),

                           SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}