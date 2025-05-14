<?php
// Set the response headers
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "falcon_stats";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$data = json_decode(file_get_contents("php://input"));

$game_id = $data->game_id;
$quarter_no = $data->quarter_no;

// Insert the quarter information into the database
$query = "INSERT INTO quarters (game_id, quarter_no) VALUES ('$game_id', '$quarter_no')";
$result = mysqli_query($conn, $query);

if ($result) {
    echo json_encode(["status" => "success", "data" => ["quarter_id" => mysqli_insert_id($conn)]]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to save quarter"]);
}

$conn->close();
?>
