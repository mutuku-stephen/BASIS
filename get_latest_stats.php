<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Database connection
$host = 'localhost';
$user = 'root';
$password = ''; // adjust if your MySQL has a password
$database = 'falcon_stats';

$conn = new mysqli($host, $user, $password, $database);

// Check connection
if ($conn->connect_error) {
    die(json_encode(['error' => 'Connection failed: ' . $conn->connect_error]));
}

// Get latest game_id
$gameIdQuery = "SELECT MAX(game_id) AS latest_game_id FROM stats";
$gameIdResult = $conn->query($gameIdQuery);

if (!$gameIdResult || $gameIdResult->num_rows == 0) {
    echo json_encode(['error' => 'No game_id found']);
    exit();
}

$latestGameId = $gameIdResult->fetch_assoc()['latest_game_id'];

// Get latest quarter_number (maximum 4)
$quarterQuery = "SELECT MAX(quarter_number) AS latest_quarter FROM quarter WHERE game_id = $latestGameId AND quarter_number <= 4";
$quarterResult = $conn->query($quarterQuery);

if (!$quarterResult || $quarterResult->num_rows == 0) {
    echo json_encode(['error' => 'No quarter found for latest game_id']);
    exit();
}

$latestQuarter = $quarterResult->fetch_assoc()['latest_quarter'];

// Fetch stats for latest game_id with quarter_number included
$statsQuery = "
    SELECT 
        s.game_id,
        s.quarter_id,
        q.quarter_number,
        s.player_name,
        s.ft_made, s.ft_missed,
        s.two_pt_made, s.two_pt_missed,
        s.three_pt_made, s.three_pt_missed,
        s.off_reb, s.def_reb,
        s.steals, s.turnovers, s.assists,
        s.blocks, s.fouls, s.points
    FROM stats s
    INNER JOIN quarter q ON s.quarter_id = q.quarter_id AND s.game_id = q.game_id
    WHERE s.game_id = $latestGameId
";

$statsResult = $conn->query($statsQuery);
$statsData = [];

if ($statsResult && $statsResult->num_rows > 0) {
    while ($row = $statsResult->fetch_assoc()) {
        // Parse values to integers
        $ft_made = (int)$row['ft_made'];
        $ft_missed = (int)$row['ft_missed'];
        $two_made = (int)$row['two_pt_made'];
        $two_missed = (int)$row['two_pt_missed'];
        $three_made = (int)$row['three_pt_made'];
        $three_missed = (int)$row['three_pt_missed'];

        $total_made = $ft_made + $two_made + $three_made;
        $total_attempts = $ft_made + $ft_missed + $two_made + $two_missed + $three_made + $three_missed;

        $row['FG%'] = $total_attempts > 0 ? round(($total_made / $total_attempts) * 100, 2) : 0.0;
        $row['2PT%'] = ($two_made + $two_missed) > 0 ? round(($two_made / ($two_made + $two_missed)) * 100, 2) : 0.0;
        $row['3PT%'] = ($three_made + $three_missed) > 0 ? round(($three_made / ($three_made + $three_missed)) * 100, 2) : 0.0;
        $row['FT%'] = ($ft_made + $ft_missed) > 0 ? round(($ft_made / ($ft_made + $ft_missed)) * 100, 2) : 0.0;

        $statsData[] = $row;
    }
} else {
    $statsData = ['message' => 'No stats data found'];
}

// Fetch data from quarterlystats view for all quarters (1-4) for latest game_id
$viewQuery = "
    SELECT *
    FROM quarterlystats
    WHERE game_id = $latestGameId AND quarter_number IN (1, 2, 3, 4)
    ORDER BY quarter_number ASC
";

$viewResult = $conn->query($viewQuery);
$quarterlyData = [];

if ($viewResult && $viewResult->num_rows > 0) {
    while ($row = $viewResult->fetch_assoc()) {
        $quarterlyData[] = $row;
    }
} else {
    $quarterlyData = ['message' => 'No quarterlystats data found'];
}

// Final response
$response = [
    'latest_game_id' => $latestGameId,
    'latest_quarter_number' => $latestQuarter,
    'stats' => $statsData,
    'quarterly_stats' => $quarterlyData
];

echo json_encode($response);

$conn->close();
?>
