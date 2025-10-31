const express = require('express');
const router=express.Router();
const controlador=require('../controllers/controlador');

router.post('/usuarios', controlador.crearUsuario);
router.get('/usuarios', controlador.obtenerUsuarios);
router.get('/usuarios/:email', controlador.obtenerUsuarioId);
router.post('/usuarios/login', controlador.loginUsuario);
router.put('/usuarios/', controlador.actualizarUsuario);
router.delete('/usuarios/:email', controlador.eliminarUsuario);
router.post('/usuarios/recuperar-password', controlador.recuperarPassword);
router.post('/usuarios/cambiar-password', controlador.cambiarPassword);
module.exports=router;