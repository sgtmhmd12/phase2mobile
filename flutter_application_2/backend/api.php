<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  http_response_code(200);
  exit;
}

include "db.php";

$action = $_GET['action'] ?? '';

// ==========================
// GET BOOKS ✅
// ==========================
if ($action === 'get_books') {
  $result = mysqli_query($conn, "SELECT * FROM books ORDER BY id DESC");

  $books = [];
  while ($row = mysqli_fetch_assoc($result)) {
    $books[] = $row;
  }

  echo json_encode($books);
  exit;
}

// ==========================
// ADD BOOK
// ==========================
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
  exit;
}

// ==========================
// UNKNOWN ACTION ❌
// ==========================
http_response_code(400);
echo json_encode(["error" => "Invalid action"]);
