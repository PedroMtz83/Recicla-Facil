const express = require('express');
const router = express.Router();
const UserController = require('../controllers/user.controller');
const authMiddleware = require('../utils/auth.middleware')

router.get('/', authMiddleware.authenticateToken, UserController.getUsers);
router.post('/', UserController.registerUser);
router.post('/login', UserController.loginUser);

module.exports = router;