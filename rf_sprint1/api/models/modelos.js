const mongoose = require('mongoose');

const usuarioSchema = new mongoose.Schema({
    nombre: { 
        type: String, 
        required: true,
        trim: true 
    },
    email: { 
        type: String, 
        required: true, 
        unique: true, 
        trim: true,   
        lowercase: true
    },
    password: { 
        type: String, 
        required: true 
    },
    admin: { 
        type: Boolean, 
        default: false 
    },
    fechaCreacion: { 
        type: Date, 
        default: Date.now 
    }
});

const quejaSchema = new mongoose.Schema({
     // Este campo solo se usará si un usuario LOGUEADO crea una queja
    // desde otra parte de la app. Para nuestro formulario, será null.
    usuario: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Usuario',
        required: false // <-- ¡CAMBIO IMPORTANTE! Ya no es obligatorio.
    },
    // --- CAMPO CLAVE PARA EL FORMULARIO PÚBLICO ---
    correo: {
        type: String,
        required: [true, 'El correo del remitente es obligatorio.'],
        trim: true,
        lowercase: true
    },
    mensaje: {
        type: String,
        required: [true, 'El mensaje no puede estar vacío.'],
        trim: true
    },
    estado: {
        type: String,
        enum: ['Pendiente', 'Atendida'],
        default: 'Pendiente'
    },
    respuestaAdmin: {
        type: String,
        trim: true
    },
    fechaCreacion: {
        type: Date,
        default: Date.now
    },
    fechaAtencion: {
        type: Date
    }
});

quejaSchema.index({ usuario: 1, estado: 1 });

exports.Usuario = mongoose.model('coleccion_usuarios', usuarioSchema);
exports.Queja = mongoose.model('coleccion_queja', quejaSchema);
