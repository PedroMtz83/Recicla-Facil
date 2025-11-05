import 'package:flutter/material.dart';
import '../models/contenido_educativo.dart';
import '../services/contenido_edu_service.dart';
import '../widgets/detalle_contenido_dialog.dart';

enum TipoBusqueda { porTermino, porCategoria, porTipoMaterial }

class ContenidoUsuarioScreen extends StatefulWidget {
  const ContenidoUsuarioScreen({super.key});

  @override
  State<ContenidoUsuarioScreen> createState() => _ContenidoUsuarioScreenState();
}

class _ContenidoUsuarioScreenState extends State<ContenidoUsuarioScreen> {
  final ContenidoEduService _contenidoService = ContenidoEduService();
  late Future<List<ContenidoEducativo>> _contenidosFuture;

  final TextEditingController _busquedaController = TextEditingController();
  TipoBusqueda _tipoBusquedaSeleccionada = TipoBusqueda.porTermino; // Valor por defecto

  @override
  void initState() {
    super.initState();
    _contenidosFuture = _cargarContenido();
  }

  Future <List<ContenidoEducativo>> _cargarContenido() async{
    if (_busquedaController.text.isEmpty) {
      return _contenidoService.obtenerContenidoEducativo();
    } else {
      final termino = _busquedaController.text;
      switch (_tipoBusquedaSeleccionada) {
        case TipoBusqueda.porTermino:
          return _contenidoService.buscarContenidoEducativo(termino);
        case TipoBusqueda.porCategoria:
          return _contenidoService.obtenerContenidoPorCategoria(termino);
        case TipoBusqueda.porTipoMaterial:
          return _contenidoService.obtenerContenidoPorTipoMaterial(termino);
      }
    }
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Contenido Educativo'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          _buildBarraDeBusqueda(),

          Expanded(

            child: FutureBuilder<List<ContenidoEducativo>>(
              future: _contenidosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  debugPrint("FUTUREBUILDER ERROR: ${snapshot.error}");
                  debugPrint("STACKTRACE: ${snapshot.stackTrace}");
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Error: ${snapshot.error}',
                          textAlign: TextAlign.center),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  debugPrint("FUTUREBUILDER ERROR: snapshot.data es null.");
                  return Center(
                    child: Text('No se encontraron resultados.',
                        style: TextStyle(fontSize: 16)),
                  );
                }

                final contenidos = snapshot.data!;
                if (contenidos.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron resultados.'),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: contenidos.length,
                  itemBuilder: (context, index) {
                    final contenido = contenidos[index];
                    return InkWell(
                      onTap: () {
                        _mostrarDetallesDialog(context, contenido);
                      },
                      child: _buildContenidoCard(contenido),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDetallesDialog(BuildContext context, ContenidoEducativo contenido) {
    final String? imagenRelativaUrl = contenido.imagenPrincipal;
    String? imagenCompletaUrl;

    if (imagenRelativaUrl != null && imagenRelativaUrl.isNotEmpty) {
      imagenCompletaUrl = ContenidoEduService.serverBaseUrl + imagenRelativaUrl;
    }

    // Opcional: Imprime la URL para depurar el diálogo también.
    debugPrint("Abriendo diálogo para '${contenido.titulo}' con URL: $imagenCompletaUrl");
    // ====================================================================

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return DetalleContenidoDialog(contenido: contenido);
      },
    );
  }

  Widget _buildBarraDeBusqueda() {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        children: [
          DropdownButtonFormField<TipoBusqueda>(
            value: _tipoBusquedaSeleccionada,
            decoration: InputDecoration(
              labelText: 'Buscar por',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
            ),
            items: [
              DropdownMenuItem(
                value: TipoBusqueda.porTermino,
                child: Text('Término (título, desc., etiqueta)'),
              ),
              DropdownMenuItem(
                value: TipoBusqueda.porCategoria,
                child: Text('Categoría'),
              ),
              DropdownMenuItem(
                value: TipoBusqueda.porTipoMaterial,
                child: Text('Tipo de Material'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _tipoBusquedaSeleccionada = value;
                });
              }
            },
          ),
          SizedBox(height: 12),

          TextField(
            controller: _busquedaController,
            decoration: InputDecoration(
              labelText: 'Escribe tu búsqueda aquí...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _busquedaController.clear();
                  setState(() {
                    _contenidosFuture = _cargarContenido();
                  });
                },
              ),
            ),
            onSubmitted: (_) {
              setState(() {
                _contenidosFuture = _cargarContenido();
              });
            },
          ),
          SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.search),
              label: Text('Buscar'),
              onPressed: (){
                setState(() {
                  _contenidosFuture = _cargarContenido();
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContenidoCard(ContenidoEducativo contenido) {
    final String? urlOPath = contenido.imagenPrincipal;
    String? imagenFinalUrl; // Renombramos la variable para mayor claridad

    // ====================== LÓGICA CORREGIDA ======================
    if (urlOPath != null && urlOPath.isNotEmpty) {
      // Si la ruta ya es una URL completa (empieza con http), úsala directamente.
      if (urlOPath.startsWith('http')) {
        imagenFinalUrl = urlOPath;
      } else {
        // Si es una ruta relativa (empieza con '/'), construye la URL completa.
        imagenFinalUrl = ContenidoEduService.serverBaseUrl + urlOPath;
      }
    }
    // =============================================================

    debugPrint("URL final para la tarjeta '${contenido.titulo}': $imagenFinalUrl");

    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.only(bottom: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. Comprueba si la URL existe ANTES de intentar usar Image.network
          if (imagenFinalUrl != null)
            Image.network(
              imagenFinalUrl, // La URL que estamos probando
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              // 3. Este loadingBuilder es bueno para la experiencia de usuario
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              // 4. ¡ESTE ES EL SALVAVIDAS! Evita que la app se congele si la imagen no carga.
              errorBuilder: (context, error, stackTrace) {
                // Imprime el error específico para esta imagen en la consola.
                debugPrint("FALLO AL CARGAR IMAGEN: $imagenFinalUrl - Error: $error");
                // Devuelve un widget placeholder en lugar de romper la UI.
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                );
              },
            )
          else
          // 5. Muestra un placeholder si el registro no tiene imagen.
            Container(
              height: 200,
              color: Colors.grey[200],
              child: const Icon(Icons.photo, color: Colors.grey, size: 50),
            ),

          // El resto de la tarjeta (título, descripción) no necesita cambios
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contenido.titulo,
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),
                Text(
                  contenido.descripcion,
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
