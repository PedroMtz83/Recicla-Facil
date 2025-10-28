    // -----------------------------------------------------------------
    // ARCHIVO: src/models/usuarioModel.js
    // -----------------------------------------------------------------

    // 1. Importar el cliente de MongoDB
    const { MongoClient } = require('mongodb');

    // 2. Declarar variables para la conexión y la colección
    //    Las declaramos aquí fuera para que sean accesibles en todo el archivo.
    let db;
    let coleccionUsuario;

    // 3. Crear la función para conectar a la base de datos
    const connectDB = async () => {
        try {
            // Se conecta usando la URI guardada en el archivo .env
            const client = new MongoClient(process.env.MONGO_URI);
            await client.connect();

            // Obtenemos la base de datos (la que especificaste en la URI)
            db = client.db();

            // Obtenemos una referencia a la colección específica que vamos a usar
            coleccionUsuario = db.collection('coleccionUsuario');

            // Mensaje de éxito para saber que todo ha ido bien
            console.log('✅ Conectado exitosamente a la colección de usuarios en MongoDB.');

        } catch (error) {
            // Si algo falla (ej. contraseña incorrecta, IP no permitida, etc.)
            console.error('❌ Error al conectar a MongoDB:', error);
            throw error; // Propagamos el error para que el servidor principal se detenga
        }
    };

    // 4. Crear una función para "exportar" la colección
    //    Esto permite a los controladores (que crearemos después) usarla.
    const getColeccionUsuario = () => {
        if (!coleccionUsuario) {
            throw new Error('La colección de usuarios no ha sido inicializada. ¿Se conectó a la BD?');
        }
        return coleccionUsuario;
    };

    // 5. Exportar las funciones para que otros archivos puedan usarlas
    module.exports = { connectDB, getColeccionUsuario };
    