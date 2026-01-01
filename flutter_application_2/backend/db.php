<?php
$conn = new mysqli(
  getenv("mysql.railway.internal"),
  getenv("root"),
  getenv("afZKYPhCCxDWFCcUURzZSAAvHgluURLL"),
  getenv("railway"),
  getenv("3306")
);

if ($conn->connect_error) {
  die("DB connection failed");
}
