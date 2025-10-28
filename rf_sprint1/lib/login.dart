import 'package:flutter/material.dart';
import 'package:rf_sprint1/basedatos.dart';



class AppSp01 extends StatefulWidget {
  const AppSp01({super.key});

  @override
  State<AppSp01> createState() => _AppSp01State();
}

class _AppSp01State extends State<AppSp01> {
  @override
  void initState() {
    super.initState();
    DB.conexion();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder(); //Llamado de interfaz
  }

  //Crear métodos para iniciarSesión (olvidé contraseña) y registrarUsuario


}
