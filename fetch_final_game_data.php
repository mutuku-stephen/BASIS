<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Database connection
$host = "localhost";
$user = "root"; // change if necessary
$password = ""; // change if you have a password
$database = "falcon_stats";

// Create connection
$conn = new mysqli($host, $user, $password, $database);

// Check connection
if ($conn->connect_error) {
    die(json_encode([
        "success" => false,
        "message" => "Connection failed: " . $conn->connect_error
    ]));
}

// SQL to fetch data from the view and join with the games table
$sql = "SELECT fg.Home_team, fg.Opponent_team, fg.Home_scores, fg.opponent_score, fg.game_id, fg.result, fg.winner, g.Location, g.date_time 
        FROM finalgame fg 
        JOIN games g ON fg.game_id = g.game_id";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $games = [];

    while ($row = $result->fetch_assoc()) {
        $games[] = $row;
    }

    echo json_encode([
        "success" => true,
        "data" => $games
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "No game data found"
    ]);
}

$conn->close();
?>
