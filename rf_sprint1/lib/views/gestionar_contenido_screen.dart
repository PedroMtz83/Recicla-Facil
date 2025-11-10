import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Asegúrate de que las rutas de importación sean correctas para tu proyecto
import '../models/contenido_educativo.dart';
import '../services/contenido_edu_service.dart';

class GestionarContenidoScreen extends StatefulWidget {
  const GestionarContenidoScreen({super.key});

  @override
  State<GestionarContenidoScreen> createState() =>
      _GestionarContenidoScreenState();
}

class _GestionarContenidoScreenState extends State<GestionarContenidoScreen> {
  final ContenidoEduService _servicio = ContenidoEduService();
  late Future<List<ContenidoEducativo>> _contenidosFuture;

  final ImagePicker _picker = ImagePicker();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _contenidoController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _tipoMaterialController = TextEditingController();
  final _puntosClaveController = TextEditingController();
  final _etiquetasController = TextEditingController();
  final List<String> _categoria = [
    'tipos-materiales',
    'proceso-reciclaje',
    'consejos-practicos',
    'preparacion-materiales'
  ];
  final List<String> _materiales = [
    'plastico',
    'vidrio',
    'papel',
    'metal',
    'organico',
    'electronico',
    'general'
  ];
  String catSelect='tipos-materiales';
  String materialSelect='plastico';
  @override
  void initState() {
    super.initState();
    _recargarContenidos();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _contenidoController.dispose();
    _categoriaController.dispose();
    _tipoMaterialController.dispose();
    _puntosClaveController.dispose();
    _etiquetasController.dispose();
    super.dispose();
  }

  void _recargarContenidos() {
    setState(() {
      _contenidosFuture = _servicio.obtenerContenidoEducativo();
    });
  }

  Future<void> _eliminarContenido(String id) async {
    final bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar este contenido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    ) ?? false;

    if (confirmar) {
      try {
        final response = await _servicio.eliminarContenidoEducativo(id);
        if (response['statusCode'] == 200 || response['statusCode'] == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Contenido eliminado con éxito'),
              backgroundColor: Colors.green,
            ),
          );
          _recargarContenidos();
        } else {
          throw Exception(response['message'] ?? 'Error desconocido');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  void _mostrarDialogoEditar(ContenidoEducativo contenidoAEditar) {
    _tituloController.text = contenidoAEditar.titulo;
    _descripcionController.text = contenidoAEditar.descripcion;
    _contenidoController.text = contenidoAEditar.contenido;
    _categoriaController.text = contenidoAEditar.categoria;
    _tipoMaterialController.text = contenidoAEditar.tipoMaterial;
    _puntosClaveController.text = contenidoAEditar.puntosClave.join(', ');
    _etiquetasController.text = contenidoAEditar.etiquetas.join(', ');
    catSelect=contenidoAEditar.categoria;
    materialSelect=contenidoAEditar.tipoMaterial;


    List<File> _nuevasImagenes = [];
    bool _estaGuardando = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> _seleccionarImagenesDialog() async {
              final List<XFile> imagenes = await _picker.pickMultiImage();
              if (imagenes.isNotEmpty) {
                setStateDialog(() {
                  _nuevasImagenes = imagenes.map((xfile) => File(xfile.path)).toList();
                });
              }
            }
            Future<void> _guardarCambios() async {
              setStateDialog(() { _estaGuardando = true; });

              // TODO: Implementar la lógica de subida de imágenes
              // Si hay nuevas imágenes en `_nuevasImagenes`, deberías subirlas a tu servidor aquí
              // y obtener las nuevas URLs. Por ahora, este paso se omite.
              // List<Map<String, dynamic>>? imagenesParaActualizar = null;
              // if(_nuevasImagenes.isNotEmpty) {
              //   // 1. Subir cada imagen y recolectar URLs
              //   // 2. Formatear como `[{'url': '...', 'es_principal': true}, ...]`
              // }

              final puntosClaveList = _puntosClaveController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
              final etiquetasList = _etiquetasController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

              try {
                final response = await _servicio.actualizarContenidoEducativo(
                  id: contenidoAEditar.id,
                  titulo: _tituloController.text,
                  descripcion: _descripcionController.text,
                  contenido: _contenidoController.text,
                  categoria: catSelect,
                  tipoMaterial: materialSelect,
                  puntosClave: puntosClaveList,
                  etiquetas: etiquetasList,
                  nuevasImagenes: _nuevasImagenes,
                );

                if (response['statusCode'] == 200) {
                  Navigator.of(dialogContext).pop();
                  _recargarContenidos();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Contenido actualizado con éxito'), backgroundColor: Colors.green),
                  );
                } else {
                  throw Exception(response['message'] ?? 'Respuesta inesperada del servidor');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red),
                );
              } finally {
                setStateDialog(() { _estaGuardando = false; });
              }
            }

            return AlertDialog(
              title: Text("Editar Contenido"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextFormField(_tituloController, 'Título'),
                      SizedBox(height: 15),
                      _buildTextFormField(_descripcionController, 'Descripción corta', maxLines: 3),
                      SizedBox(height: 15),
                      _buildTextFormField(_contenidoController, 'Contenido completo', maxLines: 6),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Categoría',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                value: catSelect,
                                items: _categoria.map((String valor) {
                                  return DropdownMenuItem<String>(
                                    value: valor,
                                    child: Text(
                                      valor.replaceAll('-', ' ').toUpperCase(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? nuevoValor) {
                                  setState(() {
                                    catSelect = nuevoValor!;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true, // ajusta el dropdown al ancho disponible
                              decoration: InputDecoration(
                                labelText: 'Selecciona el tipo de material',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              value: materialSelect,
                              items: _materiales.map((String valor) {
                                return DropdownMenuItem<String>(
                                  value: valor,
                                  child: Text(
                                    valor.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? nuevoValor) {
                                setState(() {
                                  materialSelect = nuevoValor!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      _buildTextFormField(_puntosClaveController, 'Puntos Clave (separados por coma)'),
                      SizedBox(height: 15),
                      _buildTextFormField(_etiquetasController, 'Etiquetas (separadas por coma)'),
                      SizedBox(height: 20),


                      Text("Imágenes", style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 10),

                      if (_nuevasImagenes.isNotEmpty)
                        _buildVistaPreviaImagenesLocales(_nuevasImagenes)
                      else
                        _buildVistaPreviaImagenesActuales(contenidoAEditar.imagenes),

                      SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _seleccionarImagenesDialog,
                        icon: Icon(Icons.add_photo_alternate_outlined),
                        label: Text('Cambiar Imágenes'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _estaGuardando ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text("Cancelar"),
                ),
                ElevatedButton.icon(
                  onPressed: _estaGuardando ? null : _guardarCambios,
                  icon: _estaGuardando
                      ? Container(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Icon(Icons.save),
                  label: Text(_estaGuardando ? "Guardando..." : "Guardar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.green.shade200,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Widget _buildTextFormField(TextEditingController controller, String label, {int maxLines = 1, String? validationMsg}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: (value) {
        if (validationMsg != null && (value == null || value.isEmpty)) {
          return validationMsg;
        }
        return null;
      },
    );
  }

  Widget _buildVistaPreviaImagenesLocales(List<File> imagenes) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imagenes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(imagenes[index], width: 100, height: 100, fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVistaPreviaImagenesActuales(List<ImagenContenido> imagenes) {
    if (imagenes.isEmpty) {
      return Text("No hay imágenes actuales.", style: TextStyle(color: Colors.grey));
    }
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imagenes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImagenWidget(imagenes[index].ruta, height: 100),
            ),
          );
        },
      ),
    );
  }


  Widget _buildImagenWidget(dynamic imagenData, {double height = 160}) {
    if (imagenData is File) {
      return Image.file(
        imagenData,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (imagenData is String && imagenData.isNotEmpty) {
      String urlCompleta;
      if (imagenData.startsWith('http')) {
        urlCompleta = imagenData;
      } else {
        // Asegúrate de que ContenidoEduService.serverBaseUrl esté correctamente definido
        urlCompleta = '${ContenidoEduService.serverBaseUrl}$imagenData';
      }

      return Image.network(
        urlCompleta,
        height: height,
        width: double.infinity, // Ajustado para que quepa en el ClipRRect
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null ? child : Center(child: CircularProgressIndicator()),
        errorBuilder: (context, error, stack) => Container(
          height: height,
          color: Colors.grey[200],
          child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
        ),
      );
    }
    return Container(height: height, color: Colors.grey[200], child: Icon(Icons.photo, color: Colors.grey, size: 50));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<ContenidoEducativo>>(
        future: _contenidosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay contenido para gestionar.'));
          }

          final contenidos = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _recargarContenidos(),
            child: ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: contenidos.length,
              itemBuilder: (context, index) {
                final contenido = contenidos[index];
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
                      Text(contenido.titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImagenWidget(contenido.imagenPrincipal),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(color: Colors.green.shade200, borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text(contenido.descripcion, style: TextStyle(fontSize: 14))),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _mostrarDialogoEditar(contenido),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarContenido(contenido.id),
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
        },
      ),
    );
  }
}
