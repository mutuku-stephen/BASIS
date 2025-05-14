<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET");
header("Access-Control-Allow-Headers: Content-Type");

$host = "localhost";
$user = "root";
$password = "";
$dbname = "falcon_stats";

$conn = new mysqli($host, $user, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Connection failed: " . $conn->connect_error]));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Deletion
    $input = json_decode(file_get_contents("php://input"), true);
    if (isset($input['player_name'])) {
        $playerName = $input['player_name'];
        $stmt = $conn->prepare("DELETE FROM players WHERE player_name = ? AND players_team = 'Daystar Falcons'");
        $stmt->bind_param("s", $playerName);
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Player deleted successfully"]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to delete player"]);
        }
        $stmt->close();
    } else {
        echo json_encode(["success" => false, "message" => "Player name not provided"]);
    }
} else {
    // Fetching players
    $teamName = 'Daystar Falcons';
    $sql = "SELECT player_name FROM players WHERE players_team = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $teamName);
    $stmt->execute();
    $result = $stmt->get_result();

    $players = [];
    while ($row = $result->fetch_assoc()) {
        $players[] = $row['player_name'];
    }

    if (!empty($players)) {
        echo json_encode(["success" => true, "players" => $players]);
    } else {
        echo json_encode(["success" => false, "message" => "No players found for Daystar Falcons"]);
    }

    $stmt->close();
}

$conn->close();
?>
