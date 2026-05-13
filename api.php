<?php
// API REST para TOTU
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];
$endpoint = $_GET['endpoint'] ?? '';

try {
    $db = getDBConnection();
    
    switch($endpoint) {
        case 'dispositivos':
            if ($method === 'GET') {
                $stmt = $db->query("SELECT * FROM dispositivos ORDER BY fecha_instalacion DESC");
                jsonResponse(['success' => true, 'data' => $stmt->fetchAll()]);
            }
            break;
            
        case 'lecturas':
            if ($method === 'GET') {
                $dispositivo_id = $_GET['dispositivo_id'] ?? null;
                $limit = intval($_GET['limit'] ?? 50);
                
                if ($dispositivo_id) {
                    $stmt = $db->prepare("SELECT * FROM lecturas WHERE dispositivo_id = ? ORDER BY fecha_hora DESC LIMIT ?");
                    $stmt->execute([$dispositivo_id, $limit]);
                } else {
                    $stmt = $db->query("SELECT l.*, d.nombre as dispositivo_nombre FROM lecturas l JOIN dispositivos d ON l.dispositivo_id = d.id ORDER BY l.fecha_hora DESC LIMIT $limit");
                }
                jsonResponse(['success' => true, 'data' => $stmt->fetchAll()]);
            }
            
            if ($method === 'POST') {
                $data = json_decode(file_get_contents('php://input'), true);
                $stmt = $db->prepare("INSERT INTO lecturas (dispositivo_id, temperatura, humedad, presion, velocidad_viento, direccion_viento, lluvia, uv_index) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                $stmt->execute([
                    $data['dispositivo_id'],
                    $data['temperatura'],
                    $data['humedad'],
                    $data['presion'],
                    $data['velocidad_viento'],
                    $data['direccion_viento'],
                    $data['lluvia'] ? 1 : 0,
                    $data['uv_index']
                ]);
                jsonResponse(['success' => true, 'id' => $db->lastInsertId()]);
            }
            break;
            
        case 'alertas':
            if ($method === 'GET') {
                $activas = isset($_GET['activas']) ? "WHERE activa = 1" : "";
                $stmt = $db->query("SELECT a.*, d.nombre as dispositivo_nombre, d.ubicacion FROM alertas a JOIN dispositivos d ON a.dispositivo_id = d.id $activas ORDER BY fecha_creacion DESC");
                jsonResponse(['success' => true, 'data' => $stmt->fetchAll()]);
            }
            
            if ($method === 'POST') {
                $data = json_decode(file_get_contents('php://input'), true);
                $stmt = $db->prepare("INSERT INTO alertas (dispositivo_id, tipo, nivel, mensaje, mensaje_qom, mensaje_wichi, mensaje_moqoit) VALUES (?, ?, ?, ?, ?, ?, ?)");
                $stmt->execute([
                    $data['dispositivo_id'],
                    $data['tipo'],
                    $data['nivel'],
                    $data['mensaje'],
                    $data['mensaje_qom'] ?? null,
                    $data['mensaje_wichi'] ?? null,
                    $data['mensaje_moqoit'] ?? null
                ]);
                jsonResponse(['success' => true, 'id' => $db->lastInsertId()]);
            }
            break;
            
        case 'estadisticas':
            if ($method === 'GET') {
                $stats = [];
                
                // Total dispositivos
                $stmt = $db->query("SELECT COUNT(*) as total, SUM(botellas_recicladas) as botellas FROM dispositivos WHERE estado = 'activo'");
                $stats['dispositivos'] = $stmt->fetch();
                
                // Lecturas de hoy
                $stmt = $db->query("SELECT COUNT(*) as total FROM lecturas WHERE DATE(fecha_hora) = CURDATE()");
                $stats['lecturas_hoy'] = $stmt->fetch()['total'];
                
                // Alertas activas
                $stmt = $db->query("SELECT COUNT(*) as total FROM alertas WHERE activa = 1");
                $stats['alertas_activas'] = $stmt->fetch()['total'];
                
                // Promedios actuales
                $stmt = $db->query("SELECT AVG(temperatura) as temp_avg, AVG(humedad) as hum_avg FROM lecturas WHERE fecha_hora >= DATE_SUB(NOW(), INTERVAL 1 HOUR)");
                $stats['promedios'] = $stmt->fetch();
                
                jsonResponse(['success' => true, 'data' => $stats]);
            }
            break;
            
        case 'contacto':
            if ($method === 'POST') {
                $data = json_decode(file_get_contents('php://input'), true);
                $stmt = $db->prepare("INSERT INTO contactos (nombre, email, telefono, asunto, mensaje, sector_interes) VALUES (?, ?, ?, ?, ?, ?)");
                $stmt->execute([
                    sanitize($data['nombre']),
                    sanitize($data['email']),
                    sanitize($data['telefono'] ?? ''),
                    sanitize($data['asunto'] ?? ''),
                    sanitize($data['mensaje']),
                    $data['sector'] ?? 'particular'
                ]);
                jsonResponse(['success' => true, 'message' => 'Mensaje enviado correctamente']);
            }
            break;
            
        default:
            jsonResponse(['success' => false, 'error' => 'Endpoint no encontrado'], 404);
    }
    
} catch(Exception $e) {
    jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
}
