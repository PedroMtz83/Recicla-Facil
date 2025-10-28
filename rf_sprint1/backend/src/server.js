    // -----------------------------------------------------------------
    // ARCHIVO: src/server.js
    // -----------------------------------------------------------------
    
    // 1. Importar las librerías necesarias
    const express = require('express');
    const cors = require('cors');
    
    // ESTA LÍNEA ES CLAVE: Carga las variables del archivo .env
    // para que process.env.MONGO_URI y process.env.PORT funcionen.
    require('dotenv').config(); 
    
    // Importamos la función para conectar a la BD que está en otro archivo
    const { connectDB } = require('./models/usuarioModel'); 
    
    // 2. Inicializar la aplicación de Express
    const app = express();
    
    // Usamos el puerto definido en .env, o el 8080 si no está definido
    const port = process.env.PORT || 8080;
    
    // 3. Middlewares (configuraciones que se ejecutan en cada petición)
    app.use(cors());           // Permite peticiones desde otros orígenes (tu app Flutter)
    app.use(express.json());   // Permite que el servidor entienda peticiones con body en formato JSON
    
    // 4. ¡LA LÓGICA DE CONEXIÓN!
    // Llamamos a la función para conectar a la base de datos
    connectDB().then(() => {
        // ---- Si la conexión es exitosa, se ejecuta este bloque ----
    
        // Aún no necesitamos las rutas, las dejamos comentadas por ahora
        // app.use('/api/usuarios', require('./routes/usuarioRoutes'));
    
        // Iniciar el servidor para que empiece a escuchar peticiones
        app.listen(port, () => {
            // Este mensaje SÓLO aparecerá si la conexión a la BD fue correcta
            console.log(`✅ Conexión a BD exitosa. Servidor escuchando en http://localhost:${port}`);
        });
    
    }).catch(err => {
        // ---- Si la conexión falla, se ejecuta este bloque ----
    
        console.error("❌ ERROR: No se pudo conectar a la base de datos.");
        console.error(err); // Muestra el error detallado de MongoDB
        process.exit(1);    // Detiene la aplicación. No tiene sentido correrla sin BD.
    });
    