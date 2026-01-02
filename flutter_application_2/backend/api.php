<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

/* =========================
   CORS HEADERS (REQUIRED)
========================= */
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

/* Handle preflight */
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

include "db.php";

$action = $_GET['action'] ?? '';

/* =========================
   GET BOOKS
========================= */
if ($action === 'get_books') {

    $result = mysqli_query($conn, "SELECT * FROM books ORDER BY id DESC");

    if (!$result) {
        http_response_code(500);
        echo json_encode(["error" => mysqli_error($conn)]);
        exit;
    }

    $books = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $books[] = $row;
    }

    echo json_encode($books);
    exit;
}

/* =========================
   ADD BOOK (POST ONLY)
========================= */
if ($action === 'add_book' && $_SERVER['REQUEST_METHOD'] === 'POST') {

    $data = json_decode(file_get_contents("php://input"), true);

    $title = $data['title'] ?? '';
    $author = $data['author'] ?? '';
    $description = $data['description'] ?? '';
    $image = $data['image'] ?? '';

    if ($title === '' || $author === '' || $description === '') {
        http_response_code(400);
        echo json_encode(["success" => false, "error" => "Missing fields"]);
        exit;
    }

    $stmt = $conn->prepare(
        "INSERT INTO books (title, author, description, image)
         VALUES (?, ?, ?, ?)"
    );

    if (!$stmt) {
        http_response_code(500);
        echo json_encode(["success" => false, "error" => $conn->error]);
        exit;
    }

    $stmt->bind_param("ssss", $title, $author, $description, $image);

    if (!$stmt->execute()) {
        http_response_code(500);
        echo json_encode(["success" => false, "error" => $stmt->error]);
        exit;
    }

    echo json_encode([
        "success" => true,
        "id" => $stmt->insert_id
    ]);
    exit;
}

/* =========================
   INVALID ACTION
========================= */
http_response_code(400);
echo json_encode(["error" => "Invalid action"]);
