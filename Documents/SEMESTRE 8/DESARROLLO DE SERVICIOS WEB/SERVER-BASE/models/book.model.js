const mongoose = require('mongoose');

let bookSchema = new mongoose.Schema({
    titulo: {type: String},
    autor: {type: String},
    isbn: {type: String},
    precio: {type: Number},
    stock: {type: Number},
    image: {type: String}
});

module.exports = mongoose.model('books', bookSchema);