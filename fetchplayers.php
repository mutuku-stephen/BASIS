<?php
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
    die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $conn->connect_error]));
}

if (isset($_GET['gender'])) {
    $gender = $_GET['gender'];

    // Fetch the latest saved home_team from the games table
    $sql_latest_home_team = "SELECT home_team FROM games ORDER BY game_id DESC LIMIT 1";
    $result_latest_home_team = $conn->query($sql_latest_home_team);

    if ($result_latest_home_team && $result_latest_home_team->num_rows > 0) {
        $row_home_team = $result_latest_home_team->fetch_assoc();
        $latest_home_team = $row_home_team['home_team'];

        // Prepare the query to fetch player names based on gender and the latest home_team
        $sql = "SELECT p.player_name
                FROM players p
                INNER JOIN teams t ON p.players_team = t.team_name
                WHERE p.gender = ? AND t.team_name = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ss", $gender, $latest_home_team);
        $stmt->execute();
        $result = $stmt->get_result();

        $playerNames = [];
        while ($row = $result->fetch_assoc()) {
            $playerNames[] = $row['player_name'];
        }

        if (count($playerNames) > 0) {
            echo json_encode(['status' => 'success', 'data' => $playerNames]);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'No players found for this gender belonging to the latest home team']);
        }
        $stmt->close();
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Could not fetch the latest home team']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Gender parameter missing']);
}

$conn->close();
?>