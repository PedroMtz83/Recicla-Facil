const express = require('express');
const router = express.Router();
const controlador = require('../controllers/controlador');
const upload = require('../config/multer.config');

// Importar middlewares
const auth = require('../middleware/auth');
const esAdmin = require('../middleware/esAdmin');

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
router.post('/contenido-educativo', upload.array('imagenes', 10), controlador.crearContenidoEducativo);
router.get('/contenido-educativo', controlador.obtenerContenidoEducativo);
router.get('/contenido-educativo/:id', controlador.obtenerContenidoPorId);
router.put('/contenido-educativo/:id', upload.array('imagenes', 10), controlador.actualizarContenidoEducativo);
router.delete('/contenido-educativo/:id', controlador.eliminarContenidoEducativo);
router.get('/contenido-educativo/categoria/:categoria', controlador.obtenerContenidoPorCategoria);
router.get('/contenido-educativo/material/:tipo_material', controlador.obtenerContenidoPorTipoMaterial);
router.get('/contenido-educativo/buscar/:termino', controlador.buscarContenidoEducativo);

// =========================================================================
// RUTAS DE PUNTOS DE RECICLAJE
// =========================================================================
router.get('/puntos-reciclaje/material/:tipo_material', controlador.obtenerPuntosReciclajePorMaterial);
router.get('/puntos-reciclaje/estado/:aceptado', controlador.obtenerPuntosReciclajeEstado);
router.put('/puntos-reciclaje/:id', controlador.actualizarPuntoReciclaje);
router.put('/puntos-reciclaje/estado/:id', controlador.aceptarPunto);
router.delete('/puntos-reciclaje/:id', controlador.eliminarPuntoReciclaje);

// =========================================================================
// RUTAS DE SOLICITUDES DE PUNTOS DE RECICLAJE
// =========================================================================

// CREAR NUEVA SOLICITUD (usuarios autenticados)
router.post('/solicitudes-puntos', auth, controlador.crearSolicitudPunto);

// OBTENER MIS SOLICITUDES (usuario actual)
router.get('/solicitudes-puntos/mis-solicitudes', auth, controlador.obtenerMisSolicitudes);

// OBTENER SOLICITUDES PENDIENTES (solo admin)
router.get('/solicitudes-puntos/admin/pendientes', auth, esAdmin, controlador.obtenerSolicitudesPendientes);

// OBTENER TODAS LAS SOLICITUDES (solo admin, con filtros)
router.get('/solicitudes-puntos/admin/todas', auth, esAdmin, controlador.obtenerTodasLasSolicitudes);

// APROBAR SOLICITUD (solo admin)
router.put('/solicitudes-puntos/admin/:id/aprobar', auth, esAdmin, controlador.aprobarSolicitudPunto);

// RECHAZAR SOLICITUD (solo admin)
router.put('/solicitudes-puntos/admin/:id/rechazar', auth, esAdmin, controlador.rechazarSolicitudPunto);

// OBTENER ESTADÍSTICAS DE SOLICITUDES (solo admin)
router.get('/solicitudes-puntos/admin/estadisticas', auth, esAdmin, controlador.obtenerEstadisticasSolicitudes);

module.exports = router;