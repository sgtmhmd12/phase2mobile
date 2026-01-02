<?php
$publicUrl = getenv('MYSQL_PUBLIC_URL');

if (!$publicUrl) {
    die(json_encode(["error" => "MYSQL_PUBLIC_URL not set"]));
}

$parts = parse_url($publicUrl);

$host = $parts['host'];
$user = $parts['user'];
$pass = $parts['pass'];
$port = $parts['port'];

// ✅ HARD-SET THE DATABASE NAME
$db = 'railway';

$conn = new mysqli($host, $user, $pass, $db, $port);

if ($conn->connect_error) {
    die(json_encode(["error" => $conn->connect_error]));
}
