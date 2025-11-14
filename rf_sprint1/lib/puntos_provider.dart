// providers/puntos_provider.dart

import 'package:flutter/material.dart';
import '../models/punto_reciclaje.dart';
import '../services/puntos_reciclaje_service.dart';

class PuntosProvider with ChangeNotifier {
  List<PuntoReciclaje> _puntos = [];
  bool _isLoading = false;

  // Getters para que los widgets puedan acceder a los datos de forma segura
  List<PuntoReciclaje> get puntos => _puntos;
  bool get isLoading => _isLoading;

  // El método clave para cargar y recargar los datos
  Future<void> cargarPuntos({String material = 'Todos'}) async {
    // Evita cargas múltiples si ya se está cargando
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners(); // Notifica a los widgets que la carga ha comenzado

    try {
      final List<dynamic> datosCrudos = await PuntosReciclajeService.obtenerPuntosReciclajePorMaterial(material);
      _puntos = datosCrudos
          .map((mapa) => PuntoReciclaje.fromJson(mapa as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Manejar el error apropiadamente
      _puntos = [];
      debugPrint("Error en PuntosProvider: $e");
    }

    _isLoading = false;
    notifyListeners(); // Notifica a los widgets que la carga ha terminado y los datos están listos
  }
}
