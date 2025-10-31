const modelos = require('../models/modelos');

exports.crearUsuario = async (req, res) => {
     try {
        const { nombre, email, password } = req.body;

        // 1. Verificar si el correo ya existe en la base de datos
        const nombreExistente = await modelos.Usuario.findOne({ nombre: nombre.trim() });
        if (nombreExistente) {
                    // Usa el código 409 Conflict: El recurso no se puede crear porque ya existe.
                    return res.status(409).json({ mensaje: "El nombre de usuario ya está registrado." });
                }

        const emailExistente = await modelos.Usuario.findOne({ email: email.trim() });

        if (emailExistente) {
            // Usa el código 409 Conflict: El recurso no se puede crear porque ya existe.
            return res.status(409).json({ mensaje: "El correo electrónico ya está registrado." });
        }

        // (Aquí va tu lógica para hashear la contraseña con bcrypt, si la usas)

        // Limpia y crea el nuevo usuario
        const nuevoUsuario = await modelos.Usuario.create({
            nombre: nombre.trim(),
            email: email.trim(),
            password: password, // O la contraseña hasheada
        });

        // 2. Respuesta de éxito: Código 201 Created
        res.status(201).json({ 
            mensaje: 'Usuario creado con éxito',
            usuario: { id: nuevoUsuario.id, nombre: nuevoUsuario.nombre }
        });

    } catch (error) {
        console.error("Error en crearUsuario:", error);
        // 3. Respuesta de error del servidor: Código 500
        res.status(500).json({ mensaje: 'Error interno al crear el usuario.' });
    }
}

exports.obtenerUsuarios = async (req, res) => {
    try{
        const usuarios = await modelos.Usuario.find();
        res.status(200).json(usuarios);
    }catch(error){
        res.status(500).json({ mensaje: 'Error al obtener los usuarios', error: error.message });
    }
}

exports.obtenerUsuarioPorEmail = async (req, res) => {
    try {
        // 1. Obtiene el email de los parámetros de la URL
        const email = req.params.email;

        // 2. Busca al usuario en la base de datos
        const usuario = await modelos.Usuario.findOne({ email: email });

        // 3. Si no se encuentra el usuario, envía un error 404
        if (!usuario) {
            return res.status(404).json({ mensaje: 'Usuario no encontrado.' });
        }

        // 4. Si se encuentra, envía los datos (¡SIN LA CONTRASEÑA!)
        const usuarioParaCliente = {
            nombre: usuario.nombre,
            email: usuario.email
        };

        res.status(200).json(usuarioParaCliente);

    } catch (error) {
        console.error("Error en obtenerUsuarioPorEmail:", error);
        res.status(500).json({ mensaje: 'Error interno al buscar el usuario.' });
    }
};


// ===================================================================
// @desc    Cambiar la contraseña de un usuario
// @route   POST /api/usuarios/cambiar-password
// @access  Privado (debería estar protegido)
// ===================================================================
exports.cambiarPassword = async (req, res) => {
    try {
        // 1. Obtiene el email y la nueva contraseña del cuerpo de la petición
        const { email, nuevaPassword } = req.body;

        // 2. Valida que los datos necesarios fueron enviados
        if (!email || !nuevaPassword) {
            return res.status(400).json({ mensaje: 'Faltan datos requeridos (email o nuevaPassword).' });
        }

        // 3. Busca al usuario por su email
        const usuario = await modelos.Usuario.findOne({ email: email });

        if (!usuario) {
            return res.status(404).json({ mensaje: 'Usuario no encontrado.' });
        }

        // 4. Actualiza la contraseña del usuario encontrado
        // En un proyecto real, la 'nuevaPassword' debería ser hasheada antes de guardarla.
        usuario.password = nuevaPassword;
        await usuario.save();

        // 5. Envía una respuesta de éxito
        res.status(200).json({ mensaje: 'Contraseña actualizada exitosamente.' });

    } catch (error) {
        console.error("Error en cambiarPassword:", error);
        res.status(500).json({ mensaje: 'Error interno al cambiar la contraseña.' });
    }
};

exports.loginUsuario = async (req, res) => {
    // Lógica para el inicio de sesión de un usuario
    try{
        const { nombre, password } = req.body;

        const usuario = await modelos.Usuario.findOne( { nombre: nombre });
        if(!usuario){
        
            return res.status(401).json({ mensaje: 'Usuario incorrecto' });
        } 
        
        // 4. Si las contraseñas NO coinciden, envía un 401
        if (password != usuario.password) {
            return res.status(401).json({ mensaje: 'Contraseña incorrecta' });
        }

        // 5. Si TODO es correcto, envía un 200 (OK)
        
        const usuarioParaCliente = {
            nombre: usuario.nombre,
            password: usuario.password,
            email: usuario.email
        };
        
        res.status(200).json({ 
            mensaje: 'Inicio de sesión exitoso', 
            usuario: usuarioParaCliente 
        });

    } catch (error) {
        console.error("Error en loginUsuario:", error); // Es bueno loggear el error real
        res.status(500).json({ mensaje: 'Error interno al iniciar sesión' });
    }

}
exports.actualizarUsuario = async (req, res) => {

    // Lógica para actualizar un usuario
    // Aceptar email por body o por parámetro de ruta (req.params.email)
    const { nombre, password, admin } = req.body;
    const email = req.params && req.params.email ? req.params.email : req.body.email;
    try{
        if(!email){
            return res.status(400).json({ mensaje: 'El email es requerido para actualizar el usuario' });
        }

        // Construir objeto de actualización sólo con campos presentes
        const update = {};
        if(nombre !== undefined) update.nombre = nombre;
        if(password !== undefined) update.password = password;
        if(admin !== undefined) update.admin = admin;
        // Buscar por email y actualizar
        const usuarioActualizado = await modelos.Usuario.findOneAndUpdate({ email }, update, { new: true });

        if(!usuarioActualizado){
            return res.status(404).json({ mensaje: 'Usuario no encontrado' });
        }

        res.status(200).json({ mensaje: 'Usuario actualizado exitosamente', usuario: usuarioActualizado });
    }catch(error){
        res.status(500).json({ mensaje: 'Error al actualizar el usuario', error: error.message });
    }

}  
exports.eliminarUsuario = async (req, res) => {
    // Lógica para eliminar un usuario
    const email=req.params.email;
    try{
        if(!email){
            return res.status(400).json({ mensaje: 'El email es requerido para eliminar el usuario' });
        }
        const usuarioEliminado=await modelos.Usuario.findOneAndDelete({email});
        if(!usuarioEliminado){
            return res.status(404).json({ mensaje: 'Usuario no encontrado' });
        }
        res.status(200).json({ mensaje: 'Usuario eliminado exitosamente', usuario: usuarioEliminado });
    }catch(error){
        res.status(500).json({ mensaje: 'Error al eliminar el usuario', error: error.message });
    }
}

// =========================================================================
// @desc    Crear una nueva queja (desde un formulario público)
// @route   POST /api/quejas
// @access  Público
// =========================================================================
exports.crearQueja = async (req, res) => {
    try {
        // --- ¡CAMBIO CLAVE! Leemos 'correo' y 'mensaje' del cuerpo ---
        const { mensaje, correo } = req.body;

        // Validamos que los datos necesarios hayan llegado
        if (!mensaje || !correo) {
            return res.status(400).json({ mensaje: 'Los campos de mensaje y correo son obligatorios.' });
        }

        // Creamos el nuevo documento 'Queja' en la base de datos
        const nuevaQueja = new modelos.Queja({
            mensaje: mensaje,
            correo: correo // Guardamos el correo proporcionado
            // Ya no hay 'usuario: usuarioId' porque no estamos logueados
        });

        // Guardamos la nueva queja en la base de datos
        await nuevaQueja.save();

        // Enviamos una respuesta de éxito (201 Created)
        res.status(201).json({
            mensaje: 'Queja enviada con éxito.',
            queja: nuevaQueja
        });

    } catch (error) {
        console.error("Error al crear la queja:", error);
        res.status(500).json({ mensaje: 'Error interno del servidor al procesar la solicitud.' });
    }
};

// =========================================================================
// @desc    Obtener todas las quejas del usuario que está logueado
// @route   GET /api/quejas/mis-quejas
// @access  Privado (solo para el usuario dueño de las quejas)
// =========================================================================
exports.obtenerMisQuejas = async (req, res) => {
    try {
        // Obtenemos el ID del usuario desde el middleware de autenticación
        const usuarioId = req.usuario.id;

        // Buscamos todas las quejas que coincidan con el ID del usuario
        // y las ordenamos de la más reciente a la más antigua.
        const quejas = await modelos.Queja.find({ usuario: usuarioId }).sort({ fechaCreacion: -1 });

        res.status(200).json(quejas);

    } catch (error) {
        console.error("Error al obtener mis quejas:", error);
        res.status(500).json({ mensaje: 'Error interno del servidor.' });
    }
};

// =========================================================================
// @desc    Obtener todas las quejas pendientes (para Administradores)
// @route   GET /api/quejas/pendientes
// @access  Privado (solo para Administradores)
// =========================================================================
exports.obtenerQuejasPendientes = async (req, res) => {
    try {
        // Buscamos todas las quejas con estado 'Pendiente'
        // 'populate' es muy útil aquí: reemplaza el ID del usuario con los datos del usuario (nombre y email).
        const quejasPendientes = await modelos.Queja.find({ estado: 'Pendiente' })
            .populate('usuario', 'nombre email') // <-- ¡Esto es muy potente!
            .sort({ fechaCreacion: 1 }); // Ordenamos de la más antigua a la más nueva

        res.status(200).json(quejasPendientes);

    } catch (error) {
        console.error("Error al obtener quejas pendientes:", error);
        res.status(500).json({ mensaje: 'Error interno del servidor.' });
    }
};

// =========================================================================
// @desc    Atender una queja (para Administradores)
// @route   PUT /api/quejas/:id
// @access  Privado (solo para Administradores)
// =========================================================================
exports.atenderQueja = async (req, res) => {
    try {
        const { respuestaAdmin } = req.body;
        const quejaId = req.params.id; // El ID de la queja viene de la URL

        if (!respuestaAdmin) {
            return res.status(400).json({ mensaje: 'La respuesta del administrador es obligatoria.' });
        }

        // Buscamos la queja por su ID y la actualizamos
        const quejaAtendida = await modelos.Queja.findByIdAndUpdate(
            quejaId,
            {
                estado: 'Atendida',
                respuestaAdmin: respuestaAdmin,
                fechaAtencion: new Date() // Guardamos la fecha actual
            },
            { new: true } // {new: true} hace que Mongoose devuelva el documento ya actualizado
        );

        if (!quejaAtendida) {
            return res.status(404).json({ mensaje: 'No se encontró una queja con ese ID.' });
        }

        res.status(200).json({
            mensaje: 'La queja ha sido atendida con éxito.',
            queja: quejaAtendida
        });

    } catch (error) {
        console.error("Error al atender la queja:", error);
        res.status(500).json({ mensaje: 'Error interno del servidor.' });
    }
};

