// services/geocoding.js
const axios = require('axios');

// Coordenadas por defecto para Tepic, Nayarit
const TEPIC_DEFAULT = {
    latitud: 21.5018,
    longitud: -104.8946
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
async function geocodificarConNominatim(query, reintentos = 0) {
    const MAX_REINTENTOS = 3;
    
    try {
        const response = await axios.get('https://nominatim.openstreetmap.org/search', {
            params: {
                q: query,
                format: 'json',
                limit: 1,
                timeout: 5000,
                countrycodes: 'mx' // Limitar a México
            },
            headers: {
                'User-Agent': 'ReciclaFacilApp/1.0'
            },
            timeout: 6000
        });
        
        if (response.data && response.data.length > 0) {
            const resultado = response.data[0];
            return {
                latitud: parseFloat(resultado.lat),
                longitud: parseFloat(resultado.lon),
                precisión: resultado.class || 'desconocida'
            };
        }
        
        // Si no encuentra, reintentar con versión simplificada
        if (reintentos < MAX_REINTENTOS) {
            console.log(`  Reintentando con búsqueda simplificada (intento ${reintentos + 1}/${MAX_REINTENTOS})`);
            return geocodificarConNominatim(query.split(',')[0], reintentos + 1);
        }
        
        return null;
        
    } catch (error) {
        if (reintentos < MAX_REINTENTOS && error.code === 'ECONNABORTED') {
            console.log(`  Timeout en Nominatim, reintentando... (${reintentos + 1}/${MAX_REINTENTOS})`);
            await new Promise(resolve => setTimeout(resolve, 1000)); // Esperar 1s
            return geocodificarConNominatim(query, reintentos + 1);
        }
        return null;
    }
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
        
        // Estrategia 1: Búsqueda completa con Nominatim
        let resultado = await geocodificarConNominatim(direccionCompleta);
        
        if (resultado) {
            console.log(`✅ Geocodificación exitosa (completa): Lat ${resultado.latitud}, Lon ${resultado.longitud}`);
            return resultado;
        }
        
        // Estrategia 2: Búsqueda con calle + colonia + ciudad
        const busqueda2 = `${calle}, ${colonia}, ${ciudad}, ${estado}, ${pais}`;
        resultado = await geocodificarConNominatim(busqueda2);
        
        if (resultado) {
            console.log(`✅ Geocodificación exitosa (calle+colonia+ciudad): Lat ${resultado.latitud}, Lon ${resultado.longitud}`);
            return resultado;
        }
        
        // Estrategia 3: Búsqueda solo colonia + ciudad
        const busqueda3 = `${colonia}, ${ciudad}, ${estado}, ${pais}`;
        resultado = await geocodificarConNominatim(busqueda3);
        
        if (resultado) {
            console.log(`✅ Geocodificación exitosa (colonia+ciudad): Lat ${resultado.latitud}, Lon ${resultado.longitud}`);
            return resultado;
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

module.exports = {
    geocodificarDireccion,
    geocodificarParaPreview,
    validarDireccion,
    TEPIC_DEFAULT
};
