import 'package:mongo_dart/mongo_dart.dart';
import 'package:rf_sprint1/modelos/usuario.dart';

class DB {
  static var db;
  static late DbCollection coleccionUsuario;
  static conexion() async {

    db = await Db.create("mongodb+srv://admin:ETjJmZCNc7m4l86t@cluster0.ivcsn4e.mongodb.net/usuario?appName=Cluster0");

    await db.open();

    coleccionUsuario = db.collection('coleccionUsuario');
    print("¡Conexión a MongoDB establecida!");
  }

  static cerrarConexion() {
    db.close();
    print("Conexión a MongoDB cerrada.");
  }

  static Future<String> insertarUsuario(Usuario usuario) async {
    try {
      var resultado = await coleccionUsuario.insertOne(usuario.toMap());
      if (resultado.isSuccess) {
        return "Usuario insertado correctamente.";
      } else {
        return "Error al insertar usuario: ${resultado.writeError?.errmsg}";
      }
    } catch (e) {
      print("Error en insertarUsuario: $e");
      return "Ocurrió una excepción: $e";
    }
  }

  static Future<List<Usuario>> mostrarTodosUsuario() async {
    try {
      final documentos = await coleccionUsuario.find().toList();

      final usuarios = documentos.map((doc) => Usuario.fromMap(doc)).toList();
      return usuarios;

    } catch (e) {
      print("Error en mostrarTodos: $e");
      return [];
    }
  }

  static Future<String> editarUsuario(Usuario usuario) async {
    try {
      var usuarioExistente = await coleccionUsuario.findOne(where.eq('nombreUsuario', usuario.nombreUsuario));

      if (usuarioExistente == null) {
        return "Error: No se encontró un usuario con ese ID.";
      }

      var resultado = await coleccionUsuario.replaceOne(
          where.eq('nombreUsuario', usuario.nombreUsuario),
          usuario.toMap()
      );

      if (resultado.isSuccess) {
        return "Usuario actualizado correctamente.";
      } else {
        return "Error al actualizar usuario: ${resultado.writeError?.errmsg}";
      }

    } catch (e) {
      print("Error en editarUsuario: $e");
      return "Ocurrió una excepción: $e";
    }
  }

  static Future<String> eliminarUsuario(ObjectId id) async {
    try {
      var resultado = await coleccionUsuario.deleteOne(where.eq('_id', id));

      if (resultado.isSuccess && resultado.nRemoved > 0) {
        return "Usuario eliminado correctamente.";
      } else if (resultado.nRemoved == 0) {
        return "No se encontró ningún usuario con el ID proporcionado.";
      }
      else {
        return "Error al eliminar usuario: ${resultado.writeError?.errmsg}";
      }
    } catch (e) {
      print("Error en eliminarUsuario: $e");
      return "Ocurrió una excepción: $e";
    }
  }
}
