<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");


// Database connection
$host = "localhost";
$user = "root";
$password = ""; // use your MySQL password if set
$database = "falcon_stats";

$conn = new mysqli($host, $user, $password, $database);

// Check connection
if ($conn->connect_error) {
    die(json_encode([
        "success" => false,
        "message" => "Connection failed: " . $conn->connect_error
    ]));
}

// Fetch data from the view
$sql = "SELECT 
			game_id AS 'game_id',
            Player AS Player,
            ft_made AS `FT Md`,
            ft_missed AS `FT Msd`,
            two_pt_made AS `2PT Md`,
            two_pt_missed AS `2PT Msd`,
            three_pt_made AS `3PT Md`,
            three_pt_missed AS `3PT Msd`,
            off_reb AS `Off Reb`,
            def_reb AS `Def Reb`,
            steals AS Steals,
            turnovers AS Turnovers,
            assists AS Assists,
            blocks AS Blocks,
            fouls AS Fouls,
            points AS Points
        FROM playercumstats";

$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $data = [];

    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

    echo json_encode([
        "success" => true,
        "data" => $data
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "No data found or error in query."
    ]);
}

$conn->close();
?>
