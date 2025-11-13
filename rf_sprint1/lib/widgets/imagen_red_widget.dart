import 'package:flutter/material.dart';
import '../services/contenido_edu_service.dart';

/// Widget mejorado para cargar imágenes de red de forma robusta en cualquier dispositivo
class ImagenRedWidget extends StatefulWidget {
  final String? rutaOUrl;
  final double height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool mostrarLoadingWidget;

  const ImagenRedWidget({
    super.key,
    required this.rutaOUrl,
    this.height = 200,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.mostrarLoadingWidget = true,
  });

  @override
  State<ImagenRedWidget> createState() => _ImagenRedWidgetState();
}

class _ImagenRedWidgetState extends State<ImagenRedWidget> {
  late Future<String> _urlFinalFuture;

  @override
  void initState() {
    super.initState();
    _urlFinalFuture = _construirUrlFinal();
  }

  /// Construir la URL final: obtener dinámicamente la URL base del servidor
  /// y luego prependerla a la ruta relativa
  Future<String> _construirUrlFinal() async {
    final rutaOUrl = widget.rutaOUrl;
    
    if (rutaOUrl == null || rutaOUrl.isEmpty) {
      return '';
    }

    // Si ya es una URL absoluta, usarla tal cual
    if (rutaOUrl.startsWith('http://') || rutaOUrl.startsWith('https://')) {
      debugPrint('[ImagenRedWidget] URL absoluta detectada: $rutaOUrl');
      return rutaOUrl;
    }

    // Si es una ruta relativa, obtener la URL base del servidor dinámicamente
    try {
      final baseUrl = await ContenidoEduService.obtenerServerBaseUrl();
      final urlCompleta = baseUrl + rutaOUrl;
      debugPrint('[ImagenRedWidget] URL relativa construida: $urlCompleta (base: $baseUrl, ruta: $rutaOUrl)');
      return urlCompleta;
    } catch (e) {
      debugPrint('[ImagenRedWidget] Error obteniendo URL base: $e');
      // Fallback: usar serverBaseUrl estático
      final urlFallback = ContenidoEduService.serverBaseUrl + rutaOUrl;
      debugPrint('[ImagenRedWidget] Usando fallback: $urlFallback');
      return urlFallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _urlFinalFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        }

        final urlFinal = snapshot.data ?? '';

        if (urlFinal.isEmpty) {
          return _buildPlaceholder('Sin imagen');
        }

        return ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          child: Image.network(
            urlFinal,
            height: widget.height,
            width: widget.width ?? double.infinity,
            fit: widget.fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              if (!widget.mostrarLoadingWidget) {
                return SizedBox(
                  height: widget.height,
                  width: widget.width ?? double.infinity,
                );
              }
              return Container(
                height: widget.height,
                width: widget.width ?? double.infinity,
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              debugPrint(
                '[ImagenRedWidget] Error cargando imagen: $urlFinal\n'
                'Error: $error\n'
                'Stack: $stackTrace',
              );

              return _buildPlaceholder('Error al cargar');
            },
            headers: {
              'Accept': 'image/*',
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: widget.height,
      width: widget.width ?? double.infinity,
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildPlaceholder(String mensaje) {
    return Container(
      height: widget.height,
      width: widget.width ?? double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            color: Colors.grey[400],
            size: 50,
          ),
          SizedBox(height: 8),
          Text(
            mensaje,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
