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
            usuario: { nombre: nuevoUsuario.nombre }
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
            email: usuario.email,
            admin: usuario.admin
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
        const { correo, categoria, mensaje } = req.body;

        // Validamos que los datos necesarios hayan llegado
        if (!correo) {
            return res.status(400).json({ mensaje: 'El correo es obligatorio.' });
        }

        if (!categoria) {
            return res.status(400).json({ mensaje: 'La categoría es obligatoria.' });
        }

        if (!mensaje) {
            return res.status(400).json({ mensaje: 'El mensaje es obligatorio.' });
        }

        // Creamos el nuevo documento 'Queja' en la base de datos
        const nuevaQueja = new modelos.Queja({
            correo: correo, 
            categoria: categoria,
            mensaje: mensaje
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
        const correoUsuario = req.params.email;

        // Buscamos todas las quejas que coincidan con el correo del usuario
        // y las ordenamos de la más reciente a la más antigua.
        const quejas = await modelos.Queja.find({ correo : correoUsuario }).sort({ fechaCreacion: -1 });

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
            .sort({ fechaCreacion: 1 }); // Ordenamos de la más antigua a la más nueva

        res.status(200).json(quejasPendientes);

    } catch (error) {
        console.error("Error al obtener quejas pendientes:", error);
        res.status(500).json({ mensaje: 'Error interno del servidor.' });
    }
};

exports.obtenerQuejasPorCategoria = async (req, res) => {
    try {
      
        const categoria = decodeURIComponent(req.params.categoria);
        if (!categoria) {
            return res.status(400).json({ mensaje: 'La categoría es requerida en la URL.' });
        }
        const quejas = await modelos.Queja.find({ categoria: new RegExp(`^${categoria}$`, 'i') })
            .sort({ fechaCreacion: -1 });

        res.status(200).json(quejas);


    } catch (error) {
        console.error("Error al obtener quejas por categoría:", error);
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

// @desc    Eliminar una queja
// @route   DELETE /api/quejas/:id
exports.eliminarQueja = async (req, res) => {
    try {
        const quejaId = req.params.id;

        const quejaEliminada = await modelos.Queja.findByIdAndDelete(quejaId);

        if (!quejaEliminada) {
            return res.status(404).json({ mensaje: 'No se encontró una queja con ese ID.' });
        }

        res.status(200).json({ mensaje: 'Queja eliminada exitosamente.' });

    } catch (error) {
        res.status(500).json({ mensaje: 'Error del servidor al querer eliminar la queja.' });
    }
<<<<<<< Updated upstream
};

=======
};
// =========================================================================
// CONTROLADORES DE CONTENIDO EDUCATIVO
// =========================================================================

// @desc    Crear nuevo contenido educativo
// @route   POST /api/contenido-educativo
// @access  Privado (Admin)

exports.crearContenidoEducativo = async (req, res) => {
    try {
        const {
            titulo,
            descripcion,
            contenido,
            categoria,
            tipo_material,
            imagenes,
            puntos_clave,
            acciones_correctas,
            acciones_incorrectas,
            etiquetas,
            publicado
        } = req.body;

        // Validaciones básicas
        if (!titulo || !descripcion || !contenido || !categoria || !tipo_material) {
            return res.status(400).json({ 
                mensaje: 'Faltan campos obligatorios: título, descripción, contenido, categoría y tipo de material son requeridos.' 
            });
        }

        // Validar que al menos haya una imagen principal
        if (imagenes && imagenes.length > 0) {
            const tieneImagenPrincipal = imagenes.some(img => img.es_principal === true);
            if (!tieneImagenPrincipal) {
                // Si no hay imagen principal, marcar la primera como principal
                imagenes[0].es_principal = true;
            }
        }

        const nuevoContenido = new modelos.ContenidoEducativo({
            titulo: titulo.trim(),
            descripcion: descripcion.trim(),
            contenido: contenido,
            categoria,
            tipo_material,
            imagenes: imagenes || [],
            puntos_clave: puntos_clave || [],
            acciones_correctas: acciones_correctas || [],
            acciones_incorrectas: acciones_incorrectas || [],
            etiquetas: etiquetas || [],
            publicado: publicado || false
        });

        await nuevoContenido.save();

        res.status(201).json({
            mensaje: 'Contenido educativo creado con éxito.',
            contenido: nuevoContenido
        });

    } catch (error) {
        console.error("Error en crearContenidoEducativo:", error);
        res.status(500).json({ 
            mensaje: 'Error interno al crear el contenido educativo.',
            error: error.message 
        });
    }
};

// @desc    Obtener todo el contenido educativo (con filtros opcionales)
// @route   GET /api/contenido-educativo
// @access  Público
exports.obtenerContenidoEducativo = async (req, res) => {
    try {
        const { 
            categoria, 
            tipo_material, 
            publicado, 
            etiqueta,
            limit = 10,
            page = 1 
        } = req.query;

        const filtro = {};
        
        // Aplicar filtros si se proporcionan
        if (categoria) filtro.categoria = categoria;
        if (tipo_material) filtro.tipo_material = tipo_material;
        if (publicado !== undefined) filtro.publicado = publicado === 'true';
        if (etiqueta) filtro.etiquetas = { $in: [etiqueta] };

        const skip = (parseInt(page) - 1) * parseInt(limit);

        const contenidos = await modelos.ContenidoEducativo.find(filtro)
            .sort({ fecha_creacion: -1 })
            .skip(skip)
            .limit(parseInt(limit));

        const total = await modelos.ContenidoEducativo.countDocuments(filtro);

        res.status(200).json({
            contenidos,
            paginacion: {
                pagina_actual: parseInt(page),
                total_paginas: Math.ceil(total / limit),
                total_contenidos: total,
                hasNext: (skip + contenidos.length) < total,
                hasPrev: page > 1
            }
        });

    } catch (error) {
        console.error("Error en obtenerContenidoEducativo:", error);
        res.status(500).json({ 
            mensaje: 'Error interno al obtener el contenido educativo.',
            error: error.message 
        });
    }
};

// @desc    Obtener contenido educativo por ID
// @route   GET /api/contenido-educativo/:id
// @access  Público
exports.obtenerContenidoPorId = async (req, res) => {
    try {
        const contenidoId = req.params.id;
        const contenido = await modelos.ContenidoEducativo.findById(contenidoId);

        if (!contenido) {
            return res.status(404).json({ mensaje: 'Contenido educativo no encontrado.' });
        }

        res.status(200).json(contenido);

    } catch (error) {
        console.error("Error en obtenerContenidoPorId:", error);
        res.status(500).json({ 
            mensaje: 'Error interno al obtener el contenido educativo.',
            error: error.message 
        });
    }
};

// @desc    Actualizar contenido educativo
// @route   PUT /api/contenido-educativo/:id
// @access  Privado (Admin)
exports.actualizarContenidoEducativo = async (req, res) => {
    try {
        const contenidoId = req.params.id;
        const {
            titulo,
            descripcion,
            contenido,
            categoria,
            tipo_material,
            imagenes,
            puntos_clave,
            acciones_correctas,
            acciones_incorrectas,
            etiquetas,
            publicado
        } = req.body;

        const contenidoExistente = await modelos.ContenidoEducativo.findById(contenidoId);
        if (!contenidoExistente) {
            return res.status(404).json({ mensaje: 'Contenido educativo no encontrado.' });
        }

        // Construir objeto de actualización
        const update = {};
        if (titulo !== undefined) update.titulo = titulo.trim();
        if (descripcion !== undefined) update.descripcion = descripcion.trim();
        if (contenido !== undefined) update.contenido = contenido;
        if (categoria !== undefined) update.categoria = categoria;
        if (tipo_material !== undefined) update.tipo_material = tipo_material;
        if (imagenes !== undefined) update.imagenes = imagenes;
        if (puntos_clave !== undefined) update.puntos_clave = puntos_clave;
        if (acciones_correctas !== undefined) update.acciones_correctas = acciones_correctas;
        if (acciones_incorrectas !== undefined) update.acciones_incorrectas = acciones_incorrectas;
        if (etiquetas !== undefined) update.etiquetas = etiquetas;
        if (publicado !== undefined) update.publicado = publicado;

        const contenidoActualizado = await modelos.ContenidoEducativo.findByIdAndUpdate(
            contenidoId,
            update,
            { new: true, runValidators: true }
        );

        res.status(200).json({
            mensaje: 'Contenido educativo actualizado con éxito.',
            contenido: contenidoActualizado
        });

    } catch (error) {
        console.error("Error en actualizarContenidoEducativo:", error);
        res.status(500).json({ 
            mensaje: 'Error interno al actualizar el contenido educativo.',
            error: error.message 
        });
    }
};

// @desc    Eliminar contenido educativo
// @route   DELETE /api/contenido-educativo/:id
// @access  Privado (Admin)
exports.eliminarContenidoEducativo = async (req, res) => {
    try {
        const contenidoId = req.params.id;
        const contenidoEliminado = await modelos.ContenidoEducativo.findByIdAndDelete(contenidoId);

        if (!contenidoEliminado) {
            return res.status(404).json({ mensaje: 'Contenido educativo no encontrado.' });
        }

        res.status(200).json({ 
            mensaje: 'Contenido educativo eliminado exitosamente.' 
        });

    } catch (error) {
        console.error("Error en eliminarContenidoEducativo:", error);
        res.status(500).json({ 
            mensaje: 'Error interno al eliminar el contenido educativo.',
            error: error.message 
        });
    }
};

// @desc    Obtener contenido por categoría
// @route   GET /api/contenido-educativo/categoria/:categoria
// @access  Público
exports.obtenerContenidoPorCategoria = async (req, res) => {
    try {
        const categoria = req.params.categoria;
        const { publicado = 'true' } = req.query;

        const filtro = { 
            categoria,
            publicado: publicado === 'true'
        };

        const contenidos = await modelos.ContenidoEducativo.find(filtro)
            .sort({ fecha_creacion: -1 });

        res.status(200).json(contenidos);

    } catch (error) {
        console.error("Error en obtenerContenidoPorCategoria:", error);
        res.status(500).json({ 
            mensaje: 'Error interno al obtener el contenido por categoría.',
            error: error.message 
        });
    }
};

// @desc    Obtener contenido por tipo de material
// @route   GET /api/contenido-educativo/material/:tipo_material
// @access  Público
exports.obtenerContenidoPorTipoMaterial = async (req, res) => {
    try {
        const tipo_material = req.params.tipo_material;
        const { publicado = 'true' } = req.query;

        const filtro = { 
            tipo_material,
            publicado: publicado === 'true'
        };

        const contenidos = await modelos.ContenidoEducativo.find(filtro)
            .sort({ fecha_creacion: -1 });

        res.status(200).json(contenidos);

    } catch (error) {
        console.error("Error en obtenerContenidoPorTipoMaterial:", error);
        res.status(500).json({ 
            mensaje: 'Error interno al obtener el contenido por tipo de material.',
            error: error.message 
        });
    }
};

// @desc    Buscar contenido educativo por término
// @route   GET /api/contenido-educativo/buscar/:termino
// @access  Público
exports.buscarContenidoEducativo = async (req, res) => {
    try {
        const termino = req.params.termino;
        const { publicado = 'true' } = req.query;

        const filtro = {
            publicado: publicado === 'true',
            $or: [
                { titulo: { $regex: termino, $options: 'i' } },
                { descripcion: { $regex: termino, $options: 'i' } },
                { etiquetas: { $in: [new RegExp(termino, 'i')] } }
            ]
        };

        const contenidos = await modelos.ContenidoEducativo.find(filtro)
            .sort({ fecha_creacion: -1 });

        res.status(200).json(contenidos);

    } catch (error) {
        console.error("Error en buscarContenidoEducativo:", error);
        res.status(500).json({ 
            mensaje: 'Error interno al buscar contenido educativo.',
            error: error.message 
        });
    }
};
>>>>>>> Stashed changes
