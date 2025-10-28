const mongoose = require('mongoose');

const usarioSchema = new mongoose.Schema({
    nombre: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    admin: { type: Boolean, default: false },
    fechaCreacion: { type: Date, default: Date.now }
})

exports.Usuario = mongoose.model('Coleccion_Usuario', usarioSchema);