const express = require('express');
const router = express.Router();
const booksController = require('../controllers/books_controller.js');
router.get('/', booksController.getBooks);
router.get('/:bookId', booksController.getBookById);
router.post('/', booksController.createBook);
router.put('/:bookId', booksController.updateBook);
router.delete('/:bookId', booksController.deleteBook);
module.exports = router;