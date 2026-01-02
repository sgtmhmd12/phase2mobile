<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

/* =========================
   HEADERS & CORS
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
   UPLOAD CONFIG
========================= */
$uploadDir = __DIR__ . "/uploads/";
$baseUrl  = "https://phase2mobile.onrender.com/uploads/";

if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

/* =========================
   GET BOOKS
========================= */
if ($action === 'get_books') {

    $result = mysqli_query(
        $conn,
        "SELECT id, title, author, description, image, price
         FROM books
         ORDER BY id DESC"
    );

    $books = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $books[] = $row;
    }

    echo json_encode($books);
    exit;
}

/* =========================
   ADD BOOK (FILE UPLOAD)
========================= */
if ($action === 'add_book' && $_SERVER['REQUEST_METHOD'] === 'POST') {

    $title = $_POST['title'] ?? '';
    $author = $_POST['author'] ?? '';
    $description = $_POST['description'] ?? '';
    $price = $_POST['price'] ?? 0;
    $imagePath = '';

    if ($title === '' || $author === '' || $description === '') {
        http_response_code(400);
        echo json_encode(["success" => false, "error" => "Missing fields"]);
        exit;
    }

    /* IMAGE FILE */
    if (!empty($_FILES['image']['name'])) {
        $ext = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
        $fileName = uniqid("book_") . "." . $ext;
        $target = $uploadDir . $fileName;

        if (move_uploaded_file($_FILES['image']['tmp_name'], $target)) {
            $imagePath = $baseUrl . $fileName;
        }
    }

    $stmt = $conn->prepare(
        "INSERT INTO books (title, author, description, image, price)
         VALUES (?, ?, ?, ?, ?)"
    );

    $stmt->bind_param("ssssd",
        $title,
        $author,
        $description,
        $imagePath,
        $price
    );

    $stmt->execute();

    echo json_encode([
        "success" => true,
        "id" => $stmt->insert_id
    ]);
    exit;
}

/* =========================
   UPDATE BOOK (OPTIONAL FILE)
========================= */
if ($action === 'update_book' && $_SERVER['REQUEST_METHOD'] === 'POST') {

    $id = $_POST['id'] ?? '';
    $title = $_POST['title'] ?? '';
    $author = $_POST['author'] ?? '';
    $description = $_POST['description'] ?? '';
    $price = $_POST['price'] ?? 0;
    $imagePath = $_POST['existing_image'] ?? '';

    if ($id === '') {
        http_response_code(400);
        echo json_encode(["success" => false, "error" => "Missing ID"]);
        exit;
    }

    if (!empty($_FILES['image']['name'])) {
        $ext = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
        $fileName = uniqid("book_") . "." . $ext;
        $target = $uploadDir . $fileName;

        if (move_uploaded_file($_FILES['image']['tmp_name'], $target)) {
            $imagePath = $baseUrl . $fileName;
        }
    }

    $stmt = $conn->prepare(
        "UPDATE books
         SET title=?, author=?, description=?, image=?, price=?
         WHERE id=?"
    );

    $stmt->bind_param("ssssdi",
        $title,
        $author,
        $description,
        $imagePath,
        $price,
        $id
    );

    $stmt->execute();

    echo json_encode(["success" => true]);
    exit;
}

/* =========================
   DELETE BOOK
========================= */
if ($action === 'delete_book') {

    $id = $_GET['id'] ?? '';

    $stmt = $conn->prepare("DELETE FROM books WHERE id=?");
    $stmt->bind_param("i", $id);
    $stmt->execute();

    echo json_encode(["success" => true]);
    exit;
}

/* =========================
   INVALID
========================= */
http_response_code(400);
echo json_encode(["error" => "Invalid action"]);
