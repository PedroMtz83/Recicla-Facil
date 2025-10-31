// providers/auth_provider.dart
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _userEmail;
  String? _userName;
  bool _isLoggedIn = false;

  // "Getters" públicos para acceder a los datos de forma segura
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  bool get isLoggedIn => _isLoggedIn;

  // Método que se llamará después de un login exitoso
  void login(String email, String name) {
    _userEmail = email;
    _userName = name;
    _isLoggedIn = true;

    // Notifica a todos los widgets que están "escuchando" que hubo un cambio.
    notifyListeners();
  }

  // Método para cerrar sesión
  void logout() {
    _userEmail = null;
    _userName = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
