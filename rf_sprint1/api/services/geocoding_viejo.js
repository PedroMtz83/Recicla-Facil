// services/geocoding.js
const axios = require('axios');

// Coordenadas por defecto para Tepic, Nayarit
const TEPIC_DEFAULT = {
    latitud: 21.5018,
    longitud: -104.8946
};

// Bounding box aproximado de Tepic (minLat, maxLat, minLon, maxLon)
const TEPIC_BBOX = {
    minLat: 21.44,
    maxLat: 21.57,
    minLon: -104.95,
    maxLon: -104.83
};

// Puntos de referencia conocidos en Tepic para búsquedas locales
const PUNTOS_REFERENCIA_TEPIC = {
    'centro': { latitud: 21.5018, longitud: -104.8946 },
    'tecnologico': { latitud: 21.4567, longitud: -104.8902 },
    'plaza civica': { latitud: 21.5012, longitud: -104.8934 },
    'ayuntamiento': { latitud: 21.5018, longitud: -104.8950 }
};

/**
 * Valida que la dirección tenga los campos mínimos requeridos
 * @param {object} direccion - Objeto con calle, numero, colonia
 * @returns {boolean} true si la dirección es válida
 */
function validarDireccion(direccion) {
    if (!direccion) return false;
    const { calle, numero, colonia } = direccion;
    return calle && calle.trim() && numero && numero.trim() && colonia && colonia.trim();
}

/**
 * Intenta geocodificar usando Nominatim con reintentos
 * @param {string} query - Dirección a geocodificar
 * @param {number} reintentos - Número de reintentos (máx 3)
 * @returns {Promise<{latitud, longitud}>}
 */
async function geocodificarConNominatim(query, reintentos = 0, bbox) {
    const MAX_REINTENTOS = 3;
    
    try {
        const params = {
            q: query,
            format: 'json',
            limit: 5, // Pedir más resultados para poder filtrar mejor
            timeout: 5000,
            countrycodes: 'mx', // Limitar a México
            addressdetails: 1 // Obtener componentes de dirección
        };

        // Si se proporciona un bounding box, usar viewbox con prioridad alta
        if (bbox) {
            // viewbox format para Nominatim: left,top,right,bottom => minLon,maxLat,maxLon,minLat
            params.viewbox = `${bbox.minLon},${bbox.maxLat},${bbox.maxLon},${bbox.minLat}`;
            params.bounded = 1; // Estricto: solo resultados dentro del bbox
        }

        console.log(`  Nominatim query: "${query}"${bbox ? ' (con bbox)' : ''}`);
        const response = await axios.get('https://nominatim.openstreetmap.org/search', {
            params,
            headers: {
                'User-Agent': 'ReciclaFacilApp/1.0'
            },
            timeout: 6000
        });
        
        if (response.data && response.data.length > 0) {
            console.log(`  Encontrados ${response.data.length} resultados`);
            // Si tenemos bbox, filtrar por resultados dentro del bbox
            let resultado = response.data[0];
            if (bbox) {
                const dentro = response.data.filter(r => 
                    estaDentroDeBBox(parseFloat(r.lat), parseFloat(r.lon), bbox)
                );
                if (dentro.length > 0) {
                    resultado = dentro[0]; // Usar el primero que esté dentro
                    console.log(`  Resultado dentro de bbox: ${resultado.display_name}`);
                } else {
                    console.log(`  Ningún resultado dentro de bbox, usando primero: ${resultado.display_name}`);
                }
            } else {
                console.log(`  Primer resultado: ${resultado.display_name}`);
            }
            
            return {
                latitud: parseFloat(resultado.lat),
                longitud: parseFloat(resultado.lon),
                precisión: resultado.class || 'desconocida',
                displayName: resultado.display_name
            };
        }
        
        console.log(`  Sin resultados para: "${query}"`);
        
        // Si no encuentra, reintentar con versión simplificada
        if (reintentos < MAX_REINTENTOS) {
            const querySimplificada = query.split(',')[0];
            console.log(`  Reintentando con búsqueda simplificada: "${querySimplificada}" (intento ${reintentos + 1}/${MAX_REINTENTOS})`);
            await new Promise(resolve => setTimeout(resolve, 500)); // Pequeña pausa
            return geocodificarConNominatim(querySimplificada, reintentos + 1, bbox);
        }
        
        return null;
        
    } catch (error) {
        if (reintentos < MAX_REINTENTOS && error.code === 'ECONNABORTED') {
            console.log(`  Timeout en Nominatim, reintentando... (${reintentos + 1}/${MAX_REINTENTOS})`);
            await new Promise(resolve => setTimeout(resolve, 1000));
            return geocodificarConNominatim(query, reintentos + 1, bbox);
        }
        console.error(`  Error en Nominatim: ${error.message}`);
        return null;
    }
}

// Comprueba si unas coordenadas están dentro de un bounding box
function estaDentroDeBBox(lat, lon, bbox) {
    if (!bbox) return true;
    return lat >= bbox.minLat && lat <= bbox.maxLat && lon >= bbox.minLon && lon <= bbox.maxLon;
}

/**
 * Convierte una dirección en coordenadas (latitud, longitud)
 * Usa múltiples estrategias de geocodificación para mayor precisión
 * 
 * @param {string} calle - Nombre de la calle
 * @param {string} numero - Número de la calle
 * @param {string} colonia - Colonia/Barrio
 * @param {string} ciudad - Ciudad (ej: Tepic)
 * @param {string} estado - Estado (ej: Nayarit)
 * @param {string} pais - País (ej: México)
 * @returns {Promise<{latitud: number, longitud: number, precisión?: string}>}
 */
async function geocodificarDireccion(calle, numero, colonia, ciudad = 'Tepic', estado = 'Nayarit', pais = 'México') {
    try {
        // Validar dirección básica
        if (!calle || !numero || !colonia) {
            console.warn('⚠️ Dirección incompleta. Usando coordenadas por defecto de Tepic.');
            return TEPIC_DEFAULT;
        }
        
        const direccionCompleta = `${calle} ${numero}, ${colonia}, ${ciudad}, ${estado}, ${pais}`;
        console.log(`🔍 Geocodificando: ${direccionCompleta}`);
        
        // Estrategia 1: Búsqueda completa con Nominatim (si es Tepic, usar bbox)
        const usarBBox = ciudad && ciudad.toLowerCase() === 'tepic';
        let resultado = await geocodificarConNominatim(direccionCompleta, 0, usarBBox ? TEPIC_BBOX : null);

        if (resultado) {
            // Si pedimos bbox, validar que el resultado esté dentro
            if (usarBBox && !estaDentroDeBBox(resultado.latitud, resultado.longitud, TEPIC_BBOX)) {
                console.warn(`Resultado fuera de Tepic (completa): ${resultado.latitud}, ${resultado.longitud} — descartando.`);
            } else {
                console.log(`✅ Geocodificación exitosa (completa): Lat ${resultado.latitud}, Lon ${resultado.longitud}`);
                return resultado;
            }
        }
        
        // Estrategia 2: Búsqueda con calle + colonia + ciudad
        const busqueda2 = `${calle}, ${colonia}, ${ciudad}, ${estado}, ${pais}`;
        resultado = await geocodificarConNominatim(busqueda2, 0, usarBBox ? TEPIC_BBOX : null);
        
        if (resultado) {
            if (usarBBox && !estaDentroDeBBox(resultado.latitud, resultado.longitud, TEPIC_BBOX)) {
                console.warn(`Resultado fuera de Tepic (calle+colonia+ciudad): ${resultado.latitud}, ${resultado.longitud} — descartando.`);
            } else {
                console.log(`✅ Geocodificación exitosa (calle+colonia+ciudad): Lat ${resultado.latitud}, Lon ${resultado.longitud}`);
                return resultado;
            }
        }
        
        // Estrategia 3: Búsqueda solo colonia + ciudad
        const busqueda3 = `${colonia}, ${ciudad}, ${estado}, ${pais}`;
        resultado = await geocodificarConNominatim(busqueda3, 0, usarBBox ? TEPIC_BBOX : null);
        
        if (resultado) {
            if (usarBBox && !estaDentroDeBBox(resultado.latitud, resultado.longitud, TEPIC_BBOX)) {
                console.warn(`Resultado fuera de Tepic (colonia+ciudad): ${resultado.latitud}, ${resultado.longitud} — descartando.`);
            } else {
                console.log(`✅ Geocodificación exitosa (colonia+ciudad): Lat ${resultado.latitud}, Lon ${resultado.longitud}`);
                return resultado;
            }
        }
        
        // Estrategia 4: Si la ciudad es Tepic, intentar con puntos de referencia
        if (ciudad.toLowerCase() === 'tepic') {
            const palabrasClave = `${calle} ${colonia}`.toLowerCase();
            for (const [lugar, coords] of Object.entries(PUNTOS_REFERENCIA_TEPIC)) {
                if (palabrasClave.includes(lugar)) {
                    console.log(`✅ Geocodificación por punto de referencia (${lugar}): Lat ${coords.latitud}, Lon ${coords.longitud}`);
                    return coords;
                }
            }
        }
        
        // Fallback: coordenadas por defecto de Tepic
        console.warn(`⚠️ No se pudo geocodificar la dirección. Usando coordenadas por defecto de Tepic.`);
        return TEPIC_DEFAULT;
        
    } catch (error) {
        console.error('❌ Error crítico en geocodificación:', error.message);
        console.warn('Usando coordenadas por defecto de Tepic como fallback');
        return TEPIC_DEFAULT;
    }
}

/**
 * Geocodifica una dirección para visualización en tiempo real (usado para preview)
 * Esta versión es más rápida (timeout menor) para la UI
 */
async function geocodificarParaPreview(calle, numero, colonia, ciudad = 'Tepic', estado = 'Nayarit', pais = 'México') {
    const resultado = await geocodificarDireccion(calle, numero, colonia, ciudad, estado, pais);
    return resultado;
}

/**
 * Reverse geocoding: obtiene la dirección aproximada desde coordenadas (lat, lon)
 * Útil cuando el usuario ajusta manualmente la ubicación en el mapa
 * Intenta múltiples niveles de zoom para obtener la mejor aproximación
 * @param {number} latitud - Latitud
 * @param {number} longitud - Longitud
 * @returns {Promise<{calle, numero, colonia, ciudad, estado, direccion}>}
 */
async function obtenerDireccionDesdeCoordenas(latitud, longitud) {
    try {
        console.log(`Reverse geocoding: Lat ${latitud.toFixed(6)}, Lon ${longitud.toFixed(6)}`);\n        
        // Intentar con múltiples niveles de zoom
        const zooms = [20, 18, 16, 14];
        let response = null;
        let zoomUsado = null;
        
        for (const zoom of zooms) {
            try {
                const res = await axios.get('https://nominatim.openstreetmap.org/reverse', {
                    params: {
                        lat: latitud,
                        lon: longitud,
                        format: 'json',
                        zoom: zoom,
                        addressdetails: 1
                    },
                    headers: {
                        'User-Agent': 'ReciclaFacilApp/1.0'
                    },
                    timeout: 5000
                });
                
                if (res.data && res.data.address) {
                    response = res.data;
                    zoomUsado = zoom;
                    console.log(`  Zoom ${zoom} exitoso`);\n                    break;
                }
            } catch (e) {
                console.log(`  Zoom ${zoom} no disponible, intentando siguiente...`);\n                continue;
            }
        }
        
        if (!response || !response.address) {
            console.warn('Reverse geocoding sin resultado en ningún zoom');
            return {
                calle: 'Desconocida',
                numero: '',
                colonia: 'Desconocida',
                ciudad: 'Tepic',
                estado: 'Nayarit',
                direccion: `Lat: ${latitud.toFixed(4)}, Lon: ${longitud.toFixed(4)}`
            };
        }
        
        const address = response.address;\n        console.log(`  Componentes Nominatim:`, JSON.stringify(address, null, 2));\n        
        // Parsing mejorado con múltiples alternativas
        const calle = address.road || address.street || address.pedestrian || address.footway || 'Calle desconocida';\n        const numero = address.house_number || address.house || '';\n        const colonia = address.suburb || address.neighbourhood || address.village || address.county || address.district || 'Colonia desconocida';\n        const ciudad = address.city || address.town || address.municipality || 'Tepic';\n        const estado = address.state || address.province || 'Nayarit';\n        
        const resultado = {
            calle: calle,
            numero: numero,
            colonia: colonia,
            ciudad: ciudad,
            estado: estado,
            direccion: response.display_name || `${calle} ${numero}, ${colonia}`.trim()
        };\n        
        console.log(`Reverse geocoding exitoso (zoom ${zoomUsado}):`, resultado);
        return resultado;
        
    } catch (error) {
        console.error('Error crítico en reverse geocoding:', error.message);
        return {
            calle: 'Error',
            numero: '',
            colonia: 'No disponible',
            ciudad: 'Tepic',
            estado: 'Nayarit',
            direccion: 'No se pudo obtener la dirección'
        };
    }\n}
}

module.exports = {
    geocodificarDireccion,
    geocodificarParaPreview,
    validarDireccion,
    obtenerDireccionDesdeCoordenas,
    TEPIC_DEFAULT,
    TEPIC_BBOX,
    estaDentroDeBBox
};
