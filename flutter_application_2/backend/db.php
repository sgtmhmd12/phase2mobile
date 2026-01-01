<?php
$host = $_ENV["MYSQLHOST"];
$user = $_ENV["MYSQLUSER"];
$pass = $_ENV["MYSQLPASSWORD"];
$db   = $_ENV["MYSQLDATABASE"];
$port = $_ENV["MYSQLPORT"];

$conn = new mysqli($host, $user, $pass, $db, $port);

if ($conn->connect_error) {
    die(json_encode([
        "db_error" => $conn->connect_error,
        "host" => $host,
        "db" => $db
    ]));
}
