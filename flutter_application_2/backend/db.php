<?php
$publicUrl = $_ENV['MYSQL_PUBLIC_URL'] ?? null;

if (!$publicUrl) {
    die(json_encode(["error" => "MYSQL_PUBLIC_URL not set"]));
}

$parts = parse_url($publicUrl);

$host = $parts['host'];
$user = $parts['user'];
$pass = $parts['pass'];
$db   = ltrim($parts['path'], '/');
$port = $parts['port'];

$conn = new mysqli($host, $user, $pass, $db, $port);

if ($conn->connect_error) {
    die(json_encode(["error" => $conn->connect_error]));
}
