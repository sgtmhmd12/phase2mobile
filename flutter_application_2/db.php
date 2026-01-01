<?php
$conn = new mysqli(
  getenv("DB_HOST"),
  getenv("DB_USER"),
  getenv("DB_PASSWORD"),
  getenv("DB_NAME"),
  getenv("DB_PORT")
);

if ($conn->connect_error) {
  http_response_code(500);
  echo json_encode(["error" => "DB connection failed"]);
  exit;
}
