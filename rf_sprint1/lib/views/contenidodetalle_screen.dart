import 'package:flutter/material.dart';
import '../services/contenido_edu_service.dart';
import '../models/contenido_educativo.dart';

class ContenidoDetalleScreen extends StatefulWidget {
  final String contenidoId;

  const ContenidoDetalleScreen({
    super.key,
    required this.contenidoId,
  });

  @override
  State<ContenidoDetalleScreen> createState() => _ContenidoDetalleScreenState();
}

class _ContenidoDetalleScreenState extends State<ContenidoDetalleScreen> {
  final ContenidoEduService _servicio = ContenidoEduService();
  late Future<ContenidoEducativo> _contenidoFuture;

  @override
  void initState() {
    super.initState();
    _contenidoFuture = _servicio.obtenerContenidoPorId(widget.contenidoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Contenido'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<ContenidoEducativo>(
        future: _contenidoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar el contenido: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final contenido = snapshot.data!;
            return _buildDetalleView(contenido);
          }
          return Center(child: Text('Contenido no encontrado.'));
        },
      ),
    );
  }

  Widget _buildDetalleView(ContenidoEducativo contenido) {
    final String? urlOPath = contenido.imagenPrincipal;
    String? imagenFinalUrl;

    if (urlOPath != null && urlOPath.isNotEmpty) {
      if (urlOPath.startsWith('http')) {
        imagenFinalUrl = urlOPath;
      } else {
        imagenFinalUrl = ContenidoEduService.serverBaseUrl + urlOPath;
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imagenFinalUrl != null)
            Image.network(
              imagenFinalUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                color: Colors.grey[200],
                child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
              ),
            )
          else
            Container(
              height: 250,
              color: Colors.grey[200],
              child: Icon(Icons.photo, size: 60, color: Colors.grey),
            ),

          SizedBox(height: 16),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contenido.titulo,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    Chip(
                      label: Text(contenido.categoria),
                      avatar: Icon(Icons.category_outlined, size: 18),
                      backgroundColor: Colors.blue.shade50,
                    ),
                    Chip(
                      label: Text(contenido.tipoMaterial),
                      avatar: Icon(Icons.inventory_2_outlined, size: 18),
                      backgroundColor: Colors.teal.shade50,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 32.0, thickness: 1, indent: 16, endIndent: 16),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              contenido.contenido,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ),

          SizedBox(height: 24),

          if (contenido.puntosClave.isNotEmpty && contenido.puntosClave.length > 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Puntos Clave",
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12.0),
                  ...contenido.puntosClave.map((punto) => Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green, size: 22),
                        SizedBox(width: 12.0),
                        Expanded(child: Text(punto, style: TextStyle(fontSize: 15.0))),
                      ],
                    ),
                  )),
                ],
              ),
            ),

          SizedBox(height: 30),
        ],
      ),
    );
  }

}
