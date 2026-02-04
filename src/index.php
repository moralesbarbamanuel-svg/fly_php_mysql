<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "1. Script iniciado<br>";

$host = 'localhost'; 
$db   = 'app_db';
$user = 'root';
$pass = '';
$charset = 'utf8mb4';

echo "2. Variables configuradas<br>";

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";

echo "3. DSN creado: $dsn<br>";

try {
    echo "4. Intentando conectar...<br>";
    $pdo = new PDO($dsn, $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
    echo "5. ✅ Conectado a BD<br>";
} catch (PDOException $e) {
    echo "5. ❌ Error de conexión: " . $e->getMessage() . "<br>";
    die();
}

echo "6. Ejecutando consulta...<br>";

try {
    $sql = "SELECT * FROM users";
    $stmt = $pdo->query($sql);
    $rows = $stmt->fetchAll();
    echo "7. ✅ Consulta exitosa. Registros: " . count($rows) . "<br>";
} catch (PDOException $e) {
    echo "7. ❌ Error en consulta: " . $e->getMessage() . "<br>";
    die();
}
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
