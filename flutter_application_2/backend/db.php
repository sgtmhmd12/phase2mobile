<?php
$host = "crossover.proxy.rlwy.net";
$user = "root";
$pass = "HXIovQcKJlVKbryWaFqSeCyoGLOzSDdj";
$db   = "railway";
$port = 56796;

$conn = new mysqli($host, $user, $pass, $db, $port);

if ($conn->connect_error) {
    die("DB connection failed: " . $conn->connect_error);
}
?>
