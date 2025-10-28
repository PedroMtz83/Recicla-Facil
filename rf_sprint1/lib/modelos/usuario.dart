
class Usuario {
  final String nombreUsuario;
  final String correo;
  final String contrasena;
  Usuario({
    required this.nombreUsuario,
    required this.correo,
    required this.contrasena,
  });


  Map<String, dynamic> toMap() {
    return {
      'nombreUsuario': nombreUsuario,
      'correo': correo,
      'contrasena': contrasena,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    if (map['nombreUsuario'] == null || map['correo'] == null || map['contrasena'] == null) {
      throw Exception("El documento de usuario tiene campos faltantes.");
    }

    return Usuario(
      nombreUsuario: map['nombreUsuario'] as String,
      correo: map['correo'] as String,
      contrasena: map['contrasena'] as String,
    );
  }
}
