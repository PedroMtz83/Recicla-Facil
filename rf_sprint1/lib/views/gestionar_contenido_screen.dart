import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GestionarContenidoScreen extends StatefulWidget {
  const GestionarContenidoScreen({super.key});

  @override
  State<GestionarContenidoScreen> createState() => _GestionarContenidoScreenState();
}

class _GestionarContenidoScreenState extends State<GestionarContenidoScreen> {
  final List<Map<String, dynamic>> _contenidos = [
    {
      'titulo': 'Campaña de reciclaje',
      'imagen':
      'https://s1.significados.com/foto/reciclaje-og.jpg',
      'texto':
      'Participa en nuestra campaña para promover el reciclaje responsable.',
    },
    {
      'titulo': 'Ahorro de energía',
      'imagen':
      'https://s1.significados.com/foto/reciclaje-og.jpg',
      'texto': 'Apaga las luces cuando no las uses. ¡Cuidemos el planeta!',
    },
  ];

  final ImagePicker _picker = ImagePicker();
  File? _nuevaImagen;

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _textoController = TextEditingController();

  // Método para abrir la galería
  Future<void> _seleccionarImagenDesdeGaleria() async {
    final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      setState(() {
        _nuevaImagen = File(imagen.path);
      });
    }
  }

  // Diálogo para editar contenido
  void _mostrarDialogoEditar(int index) {
    final contenido = _contenidos[index];
    _tituloController.text = contenido['titulo'];
    _textoController.text = contenido['texto'];
    _nuevaImagen = null; // reinicia imagen temporal

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                'Editar contenido',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Imagen actual o nueva
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _nuevaImagen != null
                          ? Image.file(_nuevaImagen!,
                          height: 150, width: double.infinity, fit: BoxFit.cover)
                          : Image.network(
                        contenido['imagen'],
                        height: 120,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: Icon(Icons.image, color: Colors.white),
                      label: Text('Cambiar imagen',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                      ),
                      onPressed: () async {
                        final XFile? nueva =
                        await _picker.pickImage(source: ImageSource.gallery);
                        if (nueva != null) {
                          setStateDialog(() {
                            _nuevaImagen = File(nueva.path);
                          });
                        }
                      },
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        labelText: 'Título',
                        filled: true,
                        fillColor: Colors.purple.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _textoController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Contenido',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Colors.purple.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    setState(() {
                      _contenidos[index]['titulo'] = _tituloController.text;
                      _contenidos[index]['texto'] = _textoController.text;
                      if (_nuevaImagen != null) {
                        _contenidos[index]['imagen'] = _nuevaImagen!.path;
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Guardar',
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _esRutaLocal(String ruta) {
    return ruta.startsWith('/') || ruta.contains(r'C:');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: _contenidos.length,
        itemBuilder: (context, index) {
          final contenido = _contenidos[index];
          return Container(
            margin: EdgeInsets.only(bottom: 20),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contenido['titulo'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _esRutaLocal(contenido['imagen'])
                      ? Image.file(
                    File(contenido['imagen']),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Image.network(
                    contenido['imagen'],
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          contenido['texto'],
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _mostrarDialogoEditar(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _contenidos.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
