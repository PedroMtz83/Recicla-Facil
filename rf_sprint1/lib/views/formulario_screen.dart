import 'package:flutter/material.dart';
import '../services/usuario_service.dart';

class FormularioScreen extends StatefulWidget {
   FormularioScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FormularioScreenState createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mensajeController = TextEditingController();
  bool _isLoading = false;
//Cambiar e integrar el back del formulario con los siguientes atributos en el modelo
  // mensaje String correo String estadoRespondido (true o false)
  void _enviar() {
    print(_mensajeController.text);
    Navigator.pushReplacementNamed(context, '/login');
  /*  if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final usuarioService = UsuarioService();
      final response = await usuarioService.mensajeUsuario(
        mensaje: _mensajeController.text,
      );

      if (response != null && response['mensaje'] == 'Mensaje enviado con éxito') {
        debugPrint('Mensaje enviado: ${response['usuario']}');
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }

   */
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla para tomar decisiones si es necesario.
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ----------------------------------------------------
          // 1. FONDO: Ocupa toda la pantalla (Esto estaba bien)
          // ----------------------------------------------------
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/fondo_login.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          // ----------------------------------------------------
          // 2. CONTENIDO DEL FORMULARIO: Centrado y con ancho máximo
          // ----------------------------------------------------
          Center( // <-- PASO 1: Centra a su hijo horizontal y verticalmente
            child: ConstrainedBox( // <-- PASO 2: Limita el ancho máximo del formulario
              constraints:  BoxConstraints(maxWidth: 450), // Un buen ancho para formularios
              child: SingleChildScrollView(
                padding:  EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  // El resto de tu formulario va aquí dentro, sin cambios
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Centra el contenido de la columna
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // El SizedBox inicial ya no es necesario si la columna está centrada
                      //  SizedBox(height: 70),

                      SizedBox(
                        // Puedes usar un ancho relativo si quieres
                        width: screenSize.width * 0.6,
                        child: Image.asset(
                          'assets/images/logos/logo_completo.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                       SizedBox(height: 16),

                       Text(
                        'Formulario de quejas y sugerencias',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                       SizedBox(height: 50),

                      // Campo de nombre (sin cambios)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          controller: _mensajeController,
                          decoration:  InputDecoration(
                            labelText: 'Envíe su mensaje',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            prefixIcon: Icon(Icons.person),
                          ),
                          maxLines: null,
                        ),
                      ),
                       SizedBox(height: 30),
                      // Botón Ingresar (sin cambios)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _enviar,
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
                            'Enviar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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
    _mensajeController.dispose();
    super.dispose();
  }
}