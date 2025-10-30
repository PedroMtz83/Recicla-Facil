import 'package:flutter/material.dart';
import '../services/queja_service.dart';

class FormularioScreen extends StatefulWidget {
   FormularioScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FormularioScreenState createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mensajeController = TextEditingController();
  // --- PASO 1: Añadir controlador para el correo ---
  final _emailController = TextEditingController();
  bool _isLoading = false;

  // --- PASO 2: Implementar la lógica de envío completa ---
  Future<void> _enviar() async {
    // Validar ambos campos del formulario
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Instanciar el servicio
      final quejaService = QuejaService();

      // Llamar al método para crear la queja con ambos datos
      final response = await quejaService.crearQueja(
        mensaje: _mensajeController.text.trim(),
        correo: _emailController.text.trim(),
      );
      if (!mounted) return;

      // Interpretar la respuesta del servidor
      if (response['statusCode'] == 201) { // 201: Creado con éxito
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('Mensaje enviado con éxito. Gracias por tu opinión.'),
            backgroundColor: Colors.green,
          ),
        );
        // Regresar a la pantalla anterior
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Mostrar cualquier otro mensaje de error que venga del backend
        final errorMessage = response['mensaje'] ?? 'Error desconocido al enviar el mensaje.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Atrapar errores de conexión (Timeout, sin internet, etc.)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Asegurarse de que el spinner siempre se oculte
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      // Añadido para evitar que el teclado empuje y deforme el layout
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/backgrounds/fondo_login.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          Center(
            child: ConstrainedBox(
              constraints:  BoxConstraints(maxWidth: 450),
              child: SingleChildScrollView(
                padding:  EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenSize.width * 0.6,
                        child: Image.asset('assets/images/logos/logo_completo.png', fit: BoxFit.contain),
                      ),
                       SizedBox(height: 16),
                       Text(
                        'Formulario de quejas y sugerencias',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w300),
                      ),
                       SizedBox(height: 50),

                      // --- PASO 3: Añadir el campo de correo ---
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration:  InputDecoration(
                            labelText: 'Tu correo electrónico',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, ingresa tu correo.';
                            }
                            // Expresión regular para validar correo
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Por favor, ingresa un correo válido.';
                            }
                            return null;
                          },
                        ),
                      ),
                       SizedBox(height: 16),

                      // Campo de mensaje (adaptado)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          controller: _mensajeController,
                          decoration:  InputDecoration(
                            labelText: 'Tu mensaje',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            prefixIcon: Icon(Icons.message_outlined),
                          ),
                          maxLines: 5, // Un número razonable de líneas
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El mensaje no puede estar vacío.';
                            }
                            if (value.length < 10) {
                              return 'Por favor, danos más detalles (mínimo 10 caracteres).';
                            }
                            return null;
                          },
                        ),
                      ),
                       SizedBox(height: 30),
                      // Botón Enviar (sin cambios en la apariencia)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _enviar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                              :  Text('Enviar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    // --- PASO 4: Limpiar ambos controladores ---
    _mensajeController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
