class CentroReciclaje {
  final String nombre;
  final String descripcion;
  final double latitud;
  final double longitud;
  final String icono;
  final List<String> tipoMaterial;
  final String direccion;
  final String telefono;
  final String horario;

  CentroReciclaje({
    required this.nombre,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    required this.icono,
    required this.tipoMaterial,
    required this.direccion,
    required this.telefono,
    required this.horario,
  });

  // Constructor desde JSON
  factory CentroReciclaje.fromJson(Map<String, dynamic> json) {
    return CentroReciclaje(
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      latitud: json['latitud'],
      longitud: json['longitud'],
      icono: json['icono'],
      tipoMaterial: List<String>.from(json['tipo_material']),
      direccion: json['direccion'],
      telefono: json['telefono'],
      horario: json['horario'],
    );
  }
}