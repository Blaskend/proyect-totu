-- Base de datos TOTU - Tótem Observacional del Tiempo Universal
-- phpMyAdmin compatible

CREATE DATABASE IF NOT EXISTS totu_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE totu_db;

-- Tabla de dispositivos TOTU
CREATE TABLE IF NOT EXISTS dispositivos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    ubicacion VARCHAR(200),
    latitud DECIMAL(10, 8),
    longitud DECIMAL(11, 8),
    sector ENUM('salud', 'educacion', 'agro', 'particular') DEFAULT 'particular',
    estado ENUM('activo', 'inactivo', 'mantenimiento') DEFAULT 'activo',
    fecha_instalacion DATE,
    ultima_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    braille_habilitado BOOLEAN DEFAULT FALSE,
    audio_habilitado BOOLEAN DEFAULT TRUE,
    idioma VARCHAR(20) DEFAULT 'es',
    botellas_recicladas INT DEFAULT 20
);

-- Tabla de lecturas meteorológicas
CREATE TABLE IF NOT EXISTS lecturas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dispositivo_id INT NOT NULL,
    temperatura DECIMAL(5, 2),
    humedad DECIMAL(5, 2),
    presion DECIMAL(7, 2),
    velocidad_viento DECIMAL(5, 2),
    direccion_viento VARCHAR(20),
    lluvia BOOLEAN DEFAULT FALSE,
    uv_index DECIMAL(4, 2),
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dispositivo_id) REFERENCES dispositivos(id) ON DELETE CASCADE
);

-- Tabla de alertas meteorológicas
CREATE TABLE IF NOT EXISTS alertas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dispositivo_id INT NOT NULL,
    tipo ENUM('tormenta', 'viento_fuerte', 'calor_extremo', 'frio_extremo', 'lluvia_intensa', 'granizo') NOT NULL,
    nivel ENUM('bajo', 'medio', 'alto', 'critico') NOT NULL,
    mensaje TEXT,
    mensaje_qom TEXT,
    mensaje_wichi TEXT,
    mensaje_moqoit TEXT,
    activa BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_resolucion TIMESTAMP NULL,
    FOREIGN KEY (dispositivo_id) REFERENCES dispositivos(id) ON DELETE CASCADE
);

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    rol ENUM('admin', 'operador', 'cliente') DEFAULT 'cliente',
    telefono VARCHAR(20),
    organizacion VARCHAR(100),
    sector ENUM('salud', 'educacion', 'agro', 'particular') DEFAULT 'particular',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP NULL,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de suscripciones
CREATE TABLE IF NOT EXISTS suscripciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    dispositivo_id INT NOT NULL,
    tipo ENUM('basica', 'avanzada', 'empresarial') DEFAULT 'basica',
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    estado ENUM('activa', 'suspendida', 'cancelada') DEFAULT 'activa',
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (dispositivo_id) REFERENCES dispositivos(id) ON DELETE CASCADE
);

-- Tabla de contactos/mensajes
CREATE TABLE IF NOT EXISTS contactos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    asunto VARCHAR(200),
    mensaje TEXT NOT NULL,
    sector_interes ENUM('salud', 'educacion', 'agro', 'particular') DEFAULT 'particular',
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    leido BOOLEAN DEFAULT FALSE
);

-- Datos de ejemplo
INSERT INTO dispositivos (codigo, nombre, ubicacion, latitud, longitud, sector, estado, fecha_instalacion, braille_habilitado, idioma, botellas_recicladas) VALUES
('TOTU-001', 'Hospital Central', 'Hospital Central de Resistencia, Chaco', -27.4512, -58.9867, 'salud', 'activo', '2024-01-15', TRUE, 'es', 20),
('TOTU-002', 'Escuela Agrotécnica N°12', 'Escuela Agrotécnica, Colonia Benítez', -27.3312, -58.9234, 'educacion', 'activo', '2024-02-20', FALSE, 'es', 20),
('TOTU-003', 'Vivero Municipal', 'Vivero Municipal Resistencia', -27.4234, -58.9567, 'agro', 'activo', '2024-03-10', TRUE, 'qom', 20);

INSERT INTO usuarios (email, password, nombre, apellido, rol, telefono, organizacion, sector) VALUES
('admin@totu.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrador', 'TOTU', 'admin', '3624-123456', 'TOTU Project', 'salud'),
('demo@totu.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Usuario', 'Demo', 'cliente', '3624-789012', 'ITESA', 'educacion');

INSERT INTO lecturas (dispositivo_id, temperatura, humedad, presion, velocidad_viento, direccion_viento, lluvia, uv_index) VALUES
(1, 28.5, 65.0, 1013.25, 15.5, 'NE', FALSE, 7.5),
(2, 30.2, 58.0, 1012.80, 12.0, 'E', FALSE, 8.2),
(3, 27.8, 70.0, 1014.00, 18.5, 'N', TRUE, 4.5);
