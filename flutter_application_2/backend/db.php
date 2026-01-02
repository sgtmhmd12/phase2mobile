<?php
$host = "mysql-yvl7.railway.internal ";
$user = "root";
$pass = "LVnCNImdjThTsCUVeTamnaSdalgzohuP ";
$db   = "railway";
$port = 3306;

$conn = new mysqli($host, $user, $pass, $db, $port);

if ($conn->connect_error) {
    die("DB connection failed: " . $conn->connect_error);
}
?>
