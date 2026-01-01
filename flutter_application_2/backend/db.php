<?php
$host = "mainline.proxy.rlwy.net";
$user = "root";              // <-- value of MYSQLUSER
$pass = "HXIovQcKJlVKbryWaFqSeCyoGLOzSDdj";  // <-- value of MYSQLPASSWORD
$db   = "railway";              // <-- value of MYSQLDATABASE
$port = 3306;                  // <-- value of MYSQLPORT

$conn = new mysqli($host, $user, $pass, $db, $port);

if ($conn->connect_error) {
    die("DB connection failed: " . $conn->connect_error);
}
?>
