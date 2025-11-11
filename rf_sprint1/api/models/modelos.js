const mongoose = require('mongoose');
const materialesPermitidos = ["Todos", "Aluminio", "Cartón", "Papel", "PET", "Vidrio"];
const estadosPermitidos = ["true", "false"];

//modelo para usuarios
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

//modelo para quejas
const quejaSchema = new mongoose.Schema({
    correo: {
        type: String,
        required: [true, 'El correo del remitente es obligatorio.'],
        trim: true,
        lowercase: true
    },
    categoria: {
        type: String,
        required: [true, 'La categoría no puede estar vacía.'],
        trim: true
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

// Modelo para el contenido educativo
const contenidoEducativoSchema = new mongoose.Schema({
    titulo: {
        type: String,
        required: [true, 'El título es obligatorio'],
        trim: true
    },
    descripcion: {
        type: String,
        required: [true, 'La descripción es obligatoria']
    },
    contenido: {
        type: String,
        required: [true, 'El contenido es obligatorio']
    },
    categoria: {
        type: String,
        enum: ['tipos-materiales', 'proceso-reciclaje', 'consejos-practicos', 'preparacion-materiales'],
        required: [true, 'La categoría es obligatoria']
    },
    tipo_material: {
        type: String,
        enum: ['plastico', 'vidrio', 'papel', 'metal', 'organico', 'electronico', 'general'],
        required: [true, 'El tipo de material es obligatorio']
    },
    imagenes: [{
        ruta: {
            type: String,
            required: [true, 'La ruta de la imagen es obligatoria']
        },
        pie_de_imagen: {
            type: String,
            default: ''
        },
        es_principal: {
            type: Boolean,
            default: false
        }
    }],
    puntos_clave: [{
        type: String
    }],
    acciones_correctas: [{
        type: String
    }],
    acciones_incorrectas: [{
        type: String
    }],
    etiquetas: [{
        type: String
    }],
    publicado: {
        type: Boolean,
        default: false
    },
    autor: {
        type: String,
        default: 'Sistema de Reciclaje Local'
    },
    fecha_creacion: {
        type: Date,
        default: Date.now
    },
    fecha_actualizacion: {
        type: Date,
        default: Date.now
    }
});

// Modelo para los puntos de reciclaje
    const puntosReciclajeSchema = new mongoose.Schema({
    nombre:{
    type: String,
    required: [true, "El nombre no puede estar vacío"],
    trim: true
    },
    descripcion:{
    type: String,
    required: [true, "La descripción no puede estar vacía"],
    trim: true
    },
    latitud:{
    type: Number,
    required: [true, "La latitud no puede estar vacía"],
    trim: true
    },
    longitud:{
    type: Number,
    required: [true, "La longitud no puede estar vacía"],
    trim: true
    },
    icono:{
    type: String, 
    default: "assets/iconos/recycle_paper.png"
    },
    tipo_material:{
    type: [String],
    required: [true, "El tipo de material es obligatorio"],
    validate: {
            validator: function(arrayDeMateriales) {
                if (!arrayDeMateriales || arrayDeMateriales.length === 0) return false;
                return arrayDeMateriales.every(material => materialesPermitidos.includes(material));
            },
            message: props => `El array contiene materiales no válidos. Solo se permiten: ${materialesPermitidos.join(', ')}`
        }
    },
    direccion:{
    type: String,
    required: [true, "La dirección no puede estar vacía"],
    trim: true
    },
    telefono:{
    type: String,
    required: [true, "El teléfono no puede estar vacío"],
    trim: true
    },
    horario:{
    type: String,
    required: [true, "El horario no puede estar vacío"],
    trim: true
    },
    aceptado:{
    type: String,
    required: true,
    enum: estadosPermitidos,
    default: "false"
    }});

// Middleware para actualizar la fecha de actualización antes de guardar
contenidoEducativoSchema.pre('save', function(next) {
    this.fecha_actualizacion = Date.now();
    next();
});



quejaSchema.index({ usuario: 1, estado: 1 });

// Crear índices para el contenido educativo para optimizar búsquedas
contenidoEducativoSchema.index({ categoria: 1, publicado: 1 });
contenidoEducativoSchema.index({ tipo_material: 1 });
contenidoEducativoSchema.index({ etiquetas: 1 });
contenidoEducativoSchema.index({ fecha_creacion: -1 });

exports.Usuario = mongoose.model('coleccion_usuarios', usuarioSchema);
exports.Queja = mongoose.model('coleccion_queja', quejaSchema);
exports.ContenidoEducativo = mongoose.model('coleccion_contenido_educativo', contenidoEducativoSchema);
exports.PuntosReciclaje = mongoose.model(
  'PuntoReciclaje',         
  puntosReciclajeSchema,  
  'coleccion_puntos_reciclaje' 
);