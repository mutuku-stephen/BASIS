<?php
// Set the content type to JSON for the response
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Your database connection details
$servername = "localhost";  
$username = "root";         
$password = "";             
$dbname = "falcon_stats";   

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]);
    exit;
}

// Get POST data
$homeTeam = isset($_POST['home_team']) ? $_POST['home_team'] : '';
$opponentTeam = isset($_POST['opponent_team']) ? $_POST['opponent_team'] : '';
$location = isset($_POST['location']) ? $_POST['location'] : '';
$dateTime = isset($_POST['date_time']) ? $_POST['date_time'] : '';

// Check if fields are empty
if (empty($homeTeam) || empty($opponentTeam) || empty($location) || empty($dateTime)) {
    echo json_encode(["status" => "error", "message" => "All fields are required."]);
    exit;
}

// Check if Team A and Team B are the same
if ($homeTeam === $opponentTeam) {
    echo json_encode(["status" => "error", "message" => "Home_Team and Opponent_Team cannot be the same."]);
    exit;
}

// Check if Team A exists in the 'teams' table
$sql = "SELECT COUNT(*) as count FROM teams WHERE team_name = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $homeTeam);
$stmt->execute();
$result = $stmt->get_result();
$row = $result->fetch_assoc();

if ($row['count'] == 0) {
    echo json_encode(["status" => "error", "message" => "Home_Team does not exist. Please register Home_Team first."]);
    exit;
}

// Check if Team B exists in the 'teams' table
$stmt->bind_param("s", $opponentTeam);
$stmt->execute();
$result = $stmt->get_result();
$row = $result->fetch_assoc();

if ($row['count'] == 0) {
    echo json_encode(["status" => "error", "message" => "Opponent_Team does not exist. Please register Opponent_Team first."]);
    exit;
}

// Insert into the database
$sql = "INSERT INTO Games (`Home_Team`, `Opponent_Team`, `Location`, `date_time`) 
        VALUES ('$homeTeam', '$opponentTeam', '$location', '$dateTime')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["status" => "success", "message" => "Game details saved successfully"]);
} else {
    echo json_encode(["status" => "error", "message" => "Error: " . $conn->error]);
}

// Close the connection
$conn->close();
?>
