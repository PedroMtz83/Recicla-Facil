import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rf_sprint1/views/contenidousuario_screen.dart';
import 'package:rf_sprint1/views/contenidoadmin_screen.dart';
import '../auth_provider.dart';

class ContenidoScreen extends StatelessWidget {
  const ContenidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAdmin) {
      return ContenidoAdminScreen();
    } else {
      return ContenidoUsuarioScreen();
    }
  }
}
