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

// SQL query to fetch the latest game details from the 'games' table, ordered by game_id descending, limited to 1
$sql = "SELECT game_id, `home_team`, `opponent_team`, `Location`, `date_time` 
        FROM Games 
        ORDER BY game_id DESC 
        LIMIT 1";
        
$result = $conn->query($sql);

// Check if there are results
if ($result->num_rows > 0) {
    $game = $result->fetch_assoc(); // Fetch the latest game
    echo json_encode(["status" => "success", "data" => $game]);
} else {
    echo json_encode(["status" => "error", "message" => "No game details found."]);
}

// Close the connection
$conn->close();
?>
