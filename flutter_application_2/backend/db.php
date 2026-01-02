<?php
$publicUrl = getenv('MYSQL_PUBLIC_URL');

if (!$publicUrl) {
    die(json_encode([
        "error" => "MYSQL_PUBLIC_URL not set",
        "env_keys" => array_keys($_SERVER)
    ]));
}

$parts = parse_url($publicUrl);

$conn = new mysqli(
    $parts['host'],
    $parts['user'],
    $parts['pass'],
    ltrim($parts['path'], '/'),
    $parts['port']
);

if ($conn->connect_error) {
    die(json_encode(["error" => $conn->connect_error]));
}
