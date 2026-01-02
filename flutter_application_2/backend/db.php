<?php
$publicUrl = $_ENV["MYSQL_PUBLIC_URL"];

/*
 Example:
 mysql://root:password@containers-us-west-123.railway.app:6543/railway
*/

$parts = parse_url($publicUrl);

$host = $parts["host"];
$user = $parts["user"];
$pass = $parts["pass"];
$db   = ltrim($parts["path"], "/");
$port = $parts["port"];

$conn = new mysqli($host, $user, $pass, $db, $port);

if ($conn->connect_error) {
    die(json_encode(["error" => $conn->connect_error]));
}
