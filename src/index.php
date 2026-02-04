<?php
echo "✅ Servidor PHP funciona correctamente<br>";

echo "Variables de entorno:<br>";
echo "DB_HOST: " . getenv('DB_HOST') . "<br>";
echo "DB_PORT: " . getenv('DB_PORT') . "<br>";
echo "DB_USER: " . getenv('DB_USER') . "<br>";
echo "DB_NAME: " . getenv('DB_NAME') . "<br>";

$host = getenv('DB_HOST') ?: 'mainline.proxy.rlwy.net';
$port = getenv('DB_PORT') ?: '20131';
$user = getenv('DB_USER') ?: 'root';
$pass = getenv('DB_PASS') ?: 'HFOHleMAEWbJcCfbUGfEtgToLpvLooey';
$db = getenv('DB_NAME') ?: 'app_db';

echo "<br>Intentando conectar a: $host:$port<br>";

try {
    $pdo = new PDO("mysql:host=$host;port=$port;dbname=$db", $user, $pass);
    echo "✅ Conectado a BD<br>";
    
    $sql = "SELECT * FROM users";
    $stmt = $pdo->query($sql);
    $rows = $stmt->fetchAll();
    
    echo "Registros: " . count($rows) . "<br>";
    
} catch (PDOException $e) {
    echo "❌ Error BD: " . $e->getMessage() . "<br>";
    echo "Código: " . $e->getCode() . "<br>";
}
?>
