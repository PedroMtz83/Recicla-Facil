const express = require('express');
const router = express.Router();
const controlador = require('../controllers/controlador');

// =========================================================================
// RUTAS DE USUARIOS
// =========================================================================
router.post('/usuarios', controlador.crearUsuario);
router.get('/usuarios', controlador.obtenerUsuarios);
router.get('/usuarios/:email', controlador.obtenerUsuarioPorEmail);
router.post('/usuarios/login', controlador.loginUsuario);
router.put('/usuarios/:email', controlador.actualizarUsuario);
router.delete('/usuarios/:email', controlador.eliminarUsuario);
router.post('/usuarios/cambiar-password', controlador.cambiarPassword);

// =========================================================================
// RUTAS DE QUEJAS
// =========================================================================
router.post('/quejas', controlador.crearQueja);
router.get('/quejas/mis-quejas/:email', controlador.obtenerMisQuejas);
router.get('/quejas/pendientes', controlador.obtenerQuejasPendientes);
router.get('/quejas/categoria/:categoria', controlador.obtenerQuejasPorCategoria);
router.put('/quejas/:id', controlador.atenderQueja);
router.delete('/quejas/:id', controlador.eliminarQueja);

// =========================================================================
// RUTAS DE CONTENIDO EDUCATIVO
// =========================================================================

// Ruta para crear nuevo contenido educativo (Admin)
router.post('/contenido-educativo', controlador.crearContenidoEducativo);
// Ruta para obtener todo el contenido educativo (con filtros opcionales)
router.get('/contenido-educativo', controlador.obtenerContenidoEducativo);
// Ruta para obtener contenido educativo por ID
router.get('/contenido-educativo/:id', controlador.obtenerContenidoPorId);
// Ruta para actualizar contenido educativo (Admin)
router.put('/contenido-educativo/:id', controlador.actualizarContenidoEducativo);
// Ruta para eliminar contenido educativo (Admin)
router.delete('/contenido-educativo/:id', controlador.eliminarContenidoEducativo);
// Ruta para obtener contenido por categoría
router.get('/contenido-educativo/categoria/:categoria', controlador.obtenerContenidoPorCategoria);
// Ruta para obtener contenido por tipo de material
router.get('/contenido-educativo/material/:tipo_material', controlador.obtenerContenidoPorTipoMaterial);
// Ruta para buscar contenido educativo
router.get('/contenido-educativo/buscar/:termino', controlador.buscarContenidoEducativo);

module.exports = router;