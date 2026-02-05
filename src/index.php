<?php
// Configuración DB
$host = '127.0.0.1'; // TCP para evitar Permission denied
$db   = 'app_db';
$user = 'app_user';  // coincide con init.sql
$pass = 'app_pass';
$charset = 'utf8mb4';

// Conexión PDO
$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
try {
    $pdo = new PDO($dsn, $user, $pass, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
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
