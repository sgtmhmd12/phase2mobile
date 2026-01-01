<?php
$host = "mainline.proxy.rlwy.net";
$user = "root";
$pass = "HXIovQcKJlVKbryWaFqSeCyoGLOzSDdj";
$db   = "railway";
$port = 28507;

$conn = new mysqli($host, $user, $pass, $db, $port);

if ($conn->connect_error) {
    die("DB connection failed: " . $conn->connect_error);
}
?>
