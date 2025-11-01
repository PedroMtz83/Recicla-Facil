const express = require('express');
const router=express.Router();
const controlador=require('../controllers/controlador');

router.post('/usuarios', controlador.crearUsuario);
router.get('/usuarios', controlador.obtenerUsuarios);
router.get('/usuarios/:email', controlador.obtenerUsuarioPorEmail);
router.post('/usuarios/login', controlador.loginUsuario);
router.put('/usuarios/:email', controlador.actualizarUsuario);
router.delete('/usuarios/:email', controlador.eliminarUsuario);
router.post('/usuarios/cambiar-password', controlador.cambiarPassword);

router.post('/quejas', controlador.crearQueja);
router.get('/quejas/mis-quejas/:email', controlador.obtenerMisQuejas);
router.get('/quejas/pendientes', controlador.obtenerQuejasPendientes);
router.get('/quejas/categoria/:categoria', controlador.obtenerQuejasPorCategoria);
router.put('/quejas/:id', controlador.atenderQueja);
router.delete('/quejas/:id', controlador.eliminarQueja);

module.exports=router;