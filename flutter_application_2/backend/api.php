<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  http_response_code(200);
  exit;
}

include "db.php";

$action = $_GET['action'] ?? '';

if ($action === 'add_book') {
  $title = $_GET['title'] ?? '';
  $author = $_GET['author'] ?? '';
  $description = $_GET['description'] ?? '';
  $image = $_GET['image'] ?? '';

  $stmt = $conn->prepare(
    "INSERT INTO books (title, author, description, image)
     VALUES (?, ?, ?, ?)"
  );
  $stmt->bind_param("ssss", $title, $author, $description, $image);
  $stmt->execute();

  echo json_encode(["success" => true]);
}
