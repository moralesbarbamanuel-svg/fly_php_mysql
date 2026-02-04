<?php
$host = getenv('DB_HOST') ?: 'mainline.proxy.rlwy.net';
$db   = getenv('DB_NAME') ?: 'app_db';
$user = getenv('DB_USER') ?: 'root';
$pass = getenv('DB_PASS') ?: 'HFOHleMAEWbJcCfbUGfEtgToLpvLooey';
$port = getenv('DB_PORT') ?: '20131';  // ← PUERTO CORRECTO
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;port=$port;dbname=$db;charset=$charset";
try {
    $pdo = new PDO($dsn, $user, $pass, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
    echo "✅ Conectado correctamente<br>";
} catch (PDOException $e) {
    die("❌ Error de conexión: " . $e->getMessage());
}

// Consulta
$sql = "SELECT * FROM users";
$stmt = $pdo->query($sql);
$rows = $stmt->fetchAll();
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Listado de usuarios</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        table { border-collapse: collapse; width: 50%; }
        th, td { border: 1px solid #ccc; padding: 8px; }
        th { background: #f4f4f4; }
    </style>
</head>
<body>

<h1>Usuarios</h1>

<?php if (count($rows) > 0): ?>
<table>
    <tr>
        <?php foreach (array_keys($rows[0]) as $col): ?>
            <th><?= htmlspecialchars($col) ?></th>
        <?php endforeach; ?>
    </tr>
    <?php foreach ($rows as $row): ?>
        <tr>
            <?php foreach ($row as $value): ?>
                <td><?= htmlspecialchars($value) ?></td>
            <?php endforeach; ?>
        </tr>
    <?php endforeach; ?>
</table>
<?php else: ?>
<p>No hay registros.</p>
<?php endif; ?>

</body>
</html>
