const express = require('express');
const router=express.Router();
const controlador=require('../controllers/controlador');

router.post('/usuarios', controlador.crearUsuario);
router.get('/usuarios', controlador.obtenerUsuarios);
router.post('/usuarios/login', controlador.loginUsuario);
router.put('/usuarios/', controlador.actualizarUsuario);
router.delete('/usuarios/:email', controlador.eliminarUsuario);

module.exports=router;