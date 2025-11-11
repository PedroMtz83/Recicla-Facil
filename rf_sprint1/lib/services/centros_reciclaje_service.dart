import '../models/centro_reciclaje.dart';

class CentrosReciclajeService {
  static final List<CentroReciclaje> centros = [
    CentroReciclaje(
      nombre: "Centro de Reciclaje La Loma",
      descripcion: "Punto de recolección de plástico y vidrio.",
      latitud: 21.51284,
      longitud: -104.89521,
      icono: "assets/iconos/recycle_plastic.png",
      tipoMaterial: ["PET", "Vidrio"],
      direccion: "Av. Insurgentes 1450, Col. La Loma, Tepic, Nayarit",
      telefono: "311 212 3456",
      horario: "Lunes a Viernes: 9:00 - 17:00",
      validado: false
    ),
    CentroReciclaje(
      nombre: "Recicla Tepic - Parque Metropolitano",
      descripcion: "Centro temporal de reciclaje los fines de semana en el parque.",
      latitud: 21.47655,
      longitud: -104.87212,
      icono: "assets/iconos/recycle_general.png",
      tipoMaterial: ["Papel", "Cartón", "PET"],
      direccion: "Parque Metropolitano, Av. del Parque S/N, Tepic, Nayarit",
      telefono: "311 225 6789",
      horario: "Sábados y Domingos: 8:00 - 14:00",
      validado: false
    ),
    CentroReciclaje(
      nombre: "EcoPunto Tecnológico",
      descripcion: "Recolecta residuos hechos con Aluminio.",
      latitud: 21.50311,
      longitud: -104.88463,
      icono: "assets/iconos/recycle_electronic.png",
      tipoMaterial: ["Aluminio"],
      direccion: "Calle Tecnológico 259, Col. Menchaca, Tepic, Nayarit",
      telefono: "311 289 4455",
      horario: "Lunes a Viernes: 9:00 - 18:00",
    ),
    CentroReciclaje(
      nombre: "Recicla Fácil Tepic Centro",
      descripcion: "Centro de acopio en el corazón de Tepic para materiales comunes.",
      latitud: 21.50673,
      longitud: -104.89407,
      icono: "assets/iconos/recycle_paper.png",
      tipoMaterial: ["Papel", "Cartón"],
      direccion: "Av. México 120, Col. Centro, Tepic, Nayarit",
      telefono: "311 245 3344",
      horario: "Lunes a Sábado: 8:00 - 16:00",
    ),
    CentroReciclaje(
      nombre: "Punto Verde UAN",
      descripcion: "Centro universitario de reciclaje abierto a la comunidad.",
      latitud: 21.48089,
      longitud: -104.86544,
      icono: "assets/iconos/recycle_university.png",
      tipoMaterial: ["PET", "Vidrio", "Papel", "Aluminio"],
      direccion: "Ciudad de la Cultura Amado Nervo, UAN, Tepic, Nayarit",
      telefono: "311 211 0011",
      horario: "Lunes a Viernes: 9:00 - 15:00",
    ),
  ];

  static List<CentroReciclaje> obtenerTodos() {
    return centros;
  }

  static List<CentroReciclaje> filtrarPorMaterial(String material) {
    return centros.where((centro) {
      return centro.tipoMaterial.any((tipo) => 
        tipo.toLowerCase().contains(material.toLowerCase()));
    }).toList();
  }
}