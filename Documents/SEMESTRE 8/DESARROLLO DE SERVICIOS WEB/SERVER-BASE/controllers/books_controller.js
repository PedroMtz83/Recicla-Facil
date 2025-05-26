const Book = require("../models/book.model");

//Obtener todos los libros
exports.getBooks = async (req, res) => {
    try {
        const books = await Book.find();
        return res.status(200).json({
            code: 200,
            message: "Consulta de libros",
            data: books
        });
    } catch (error) {
        return res.status(500).json({
            code: 500,
            message: "Error en el servidor"
        });
    }
}
//Obtener un libro por id
exports.getBookById = async (req, res) => {
    try {
        const bookId = req.params.bookId;
        const book = await Book.findById(bookId);
        return res.status(200).json({
            code: 200,
            message: "Consulta de libro por id",
            data: book
        });
    } catch (error) {
        return res.status(500).json({
            code: 500,
            message: "Error en el servidor",
            data: error
        });
    }
}
//Crear un libro
exports.createBook = async(req, res) => {
    try {
        const { titulo, autor, isbn, precio, stock, image } = req.body;
        const newBook = new Book({
            titulo,
            autor,
            isbn,
            precio,
            stock,
            image
        });
        console.log(newBook);
        await newBook.save();

        return res.status(200).json({
            code: 200,
            message: "Creación de libro",
            data: newBook
        });
    } catch (error) {
        return res.status(500).json({
            code: 500,
            message: "Error en el servidor",
            data: error
        });
    }
}   
//Actualizar un libro
exports.updateBook = async(req, res) => {
    try {
        const bookId = req.params.bookId;
        const book = req.body;
        await Book.findByIdAndUpdate(bookId, book, { new: true });
        return res.status(200).json({
            code: 200,
            message: "Actualización de libro",
            data: bookId,
            body: book
        });
    } catch (error) {
        return res.status(500).json({
            code: 500,
            message: "Error en el servidor",
            data: error
        });
    }
}
//Eliminar un libro
exports.deleteBook = async(req, res) => {
    try {
        const bookId = req.params.bookId;
        await Book.findByIdAndDelete(bookId);
        return res.status(200).json({
            code: 200,
            message: "Eliminación de libro",
            data: bookId
        });
    } catch (error) {
        return res.status(500).json({
            code: 500,
            message: "Error en el servidor",
            data: error
        });
    }
}
