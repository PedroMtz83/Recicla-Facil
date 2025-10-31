const modelos = require('../models/modelos');
const nodemailer = require('nodemailer');

// Configuración del transporte de correo
const transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 587,
    secure: false, // true para 465, false para otros puertos
    auth: {
        user: 'jolumartinezro@ittepic.edu.mx',
        pass: 'jyvmbzztdgsxkmss'
    },
    tls: {
        rejectUnauthorized: false // No recomendado para producción
    }
});

exports.crearUsuario = async (req, res) => {
    try{
        const { nombre, email, password } = req.body;
        const nuevoUsuario = new modelos.Usuario({ nombre, email, password });
        await nuevoUsuario.save();
        res.status(201).json({ mensaje: 'Usuario creado exitosamente', usuario: nuevoUsuario });
    }catch(error){
        res.status(500).json({ mensaje: 'Error al crear el usuario', error: error.message });
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
exports.obtenerUsuarioId = async (req, res) => {
    // Lógica para obtener un usuario por ID
    const email=req.params.email;
    try{
        if(!email){
            return res.status(400).json({ mensaje: 'El email es requerido para obtener el usuario' });
        }
        const usuario = await modelos.Usuario.findOne({email});
        if(!usuario){
            return res.status(404).json({ mensaje: 'Usuario no encontrado' });
        }
        res.status(200).json(usuario);
    }catch(error){
        res.status(500).json({ mensaje: 'Error al obtener el usuario', error: error.message });
    }
}
exports.cambiarPassword = async (req, res) => {
    const { email, nuevaPassword } = req.body;
    try {
        // Validar datos requeridos
        if (!email || !nuevaPassword) {
            return res.status(400).json({ mensaje: 'El email y la nueva contraseña son requeridos' });
        }

        // Primero verificar si el usuario existe
        const usuarioExiste = await modelos.Usuario.findOne({ email });
        if (!usuarioExiste) {
            return res.status(404).json({ mensaje: 'No se encontró ningún usuario con ese correo electrónico' });
        }

        // Actualizar la contraseña
        const usuarioActualizado = await modelos.Usuario.findOneAndUpdate(
            { email },
            { password: nuevaPassword },
            { new: true }
        );

        console.log('Usuario encontrado:', usuarioActualizado); // Para debugging

        res.status(200).json({ 
            mensaje: 'Contraseña actualizada exitosamente',
            usuario: usuarioActualizado
        });
    } catch (error) {
        console.error('Error al cambiar la contraseña:', error);
        res.status(500).json({ 
            mensaje: 'Error al cambiar la contraseña',
            error: error.message 
        });
    }
}
exports.loginUsuario = async (req, res) => {
    // Lógica para el inicio de sesión de un usuario
    try{
        const { nombre, password } = req.body;
        const usuario = await modelos.Usuario.findOne({ nombre, password });
        if(!usuario){
            return res.status(404).json({ mensaje: 'Usuario no encontrado' });
        }else{
            res.status(200).json({ mensaje: 'Inicio de sesión exitoso', usuario });
        }
    }catch(error){
        res.status(500).json({ mensaje: 'Error al iniciar sesión', error: error.message });
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

exports.recuperarPassword = async (req, res) => {
    try {
        const { email } = req.body;
        
        // Buscar al usuario por email
        const usuario = await modelos.Usuario.findOne({ email });
        
        if (!usuario) {
            return res.status(404).json({ mensaje: 'No se encontró ningún usuario con ese correo electrónico' });
        }

        // Configurar el correo
        const mailOptions = {
            from: 'jolumartinezro@ittepic.edu.mx',
            to: email,
            subject: 'Recuperación de Contraseña - Recicla Fácil',
            html: `
                <h1>Recuperación de Contraseña</h1>
                <p>Hola ${usuario.nombre},</p>
                <p>Tu contraseña actual es: <strong>${usuario.password}</strong></p>
                <p>Por seguridad, te recomendamos cambiar tu contraseña una vez que inicies sesión.</p>
                <p>Saludos,<br>Equipo de Recicla Fácil</p>
            `
        };

        // Enviar el correo
        await transporter.sendMail(mailOptions);

        res.status(200).json({ 
            mensaje: 'Se ha enviado un correo con tu contraseña',
            email: email
        });
    } catch (error) {
        console.error('Error en recuperación de contraseña:', error);
        res.status(500).json({ 
            mensaje: 'Error al enviar el correo de recuperación',
            error: error.message 
        });
    }
}
