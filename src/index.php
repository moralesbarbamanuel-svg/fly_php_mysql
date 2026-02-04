<?php
echo "Test 1<br>";

$host = 'localhost'; 
$db   = 'app_db';
$user = 'root';
$pass = '';

echo "Test 2<br>";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db", $user, $pass);
    echo "Test 3 - Conectado<br>";
    
    $result = $pdo->query("SELECT * FROM users");
    $rows = $result->fetchAll();
    
    echo "Test 4 - Registros: " . count($rows) . "<br>";
    
    foreach ($rows as $row) {
        echo "ID: " . $row['id'] . " - Nombre: " . $row['name'] . "<br>";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>

</body>
</html>
