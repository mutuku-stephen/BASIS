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

// SQL query
$sql = "SELECT
            game_id,
            Player,
            ft_made,
            ft_missed,
            two_pt_made,
            two_pt_missed,
            three_pt_made,
            three_pt_missed,
            off_reb,
            def_reb,
            steals,
            turnovers,
            assists,
            blocks,
            fouls,
            points
        FROM playercumstats";

$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $data = [];
    $player_stats = []; // Array to store stats for each player

    while ($row = $result->fetch_assoc()) {
        $player_name = $row['Player'];
        $game_id = $row['game_id'];
        $points = (int)$row['points'];
        $ft_made = (int)$row['ft_made'];
        $ft_missed = (int)$row['ft_missed'];
        $two_made = (int)$row['two_pt_made'];
        $two_missed = (int)$row['two_pt_missed'];
        $three_made = (int)$row['three_pt_made'];
        $three_missed = (int)$row['three_pt_missed'];

        $total_made = $ft_made + $two_made + $three_made;
        $total_attempts = $ft_made + $ft_missed + $two_made + $two_missed + $three_made + $three_missed;

        // FG%
        $fg_percentage = $total_attempts > 0 ? round(($total_made / $total_attempts) * 100, 2) : 0.0;

        // 2PT%
        $two_attempts = $two_made + $two_missed;
        $two_percentage = $two_attempts > 0 ? round(($two_made / $two_attempts) * 100, 2) : 0.0;

        // 3PT%
        $three_attempts = $three_made + $three_missed;
        $three_percentage = $three_attempts > 0 ? round(($three_made / $three_attempts) * 100, 2) : 0.0;

        // FT%
        $ft_attempts = $ft_made + $ft_missed;
        $ft_percentage = $ft_attempts > 0 ? round(($ft_made / $ft_attempts) * 100, 2) : 0.0;

        // Add percentages to each row
        $row['FG%'] = $fg_percentage;
        $row['2PT%'] = $two_percentage;
        $row['3PT%'] = $three_percentage;
        $row['FT%'] = $ft_percentage;

        $data[] = $row;

        // Aggregate stats
        if (!isset($player_stats[$player_name])) {
            $player_stats[$player_name] = [
                'fg_sum' => 0,
                'fg_count' => 0,
                '2pt_sum' => 0,
                '2pt_count' => 0,
                '3pt_sum' => 0,
                '3pt_count' => 0,
                'ft_sum' => 0,
                'ft_count' => 0,
                'points_total' => 0,
                'game_ids' => [],
                'performance_score_total' => 0,
            ];
        }

        if ($total_attempts > 0) {
            $player_stats[$player_name]['fg_sum'] += $fg_percentage;
            $player_stats[$player_name]['fg_count']++;
        }
        if ($two_attempts > 0) {
            $player_stats[$player_name]['2pt_sum'] += $two_percentage;
            $player_stats[$player_name]['2pt_count']++;
        }
        if ($three_attempts > 0) {
            $player_stats[$player_name]['3pt_sum'] += $three_percentage;
            $player_stats[$player_name]['3pt_count']++;
        }
        if ($ft_attempts > 0) {
            $player_stats[$player_name]['ft_sum'] += $ft_percentage;
            $player_stats[$player_name]['ft_count']++;
        }

        // Track total points
        $player_stats[$player_name]['points_total'] += $points;

        // Track unique game appearances
        if (!in_array($game_id, $player_stats[$player_name]['game_ids'])) {
            $player_stats[$player_name]['game_ids'][] = $game_id;
        }

        // Performance Score Calculation
        $performance_score = 
            ($row['off_reb'] * 1.5) +
            ($row['assists'] * 2.0) +
            ($row['steals'] * 1.5) +
            ($row['def_reb'] * 1.5) +
            ($row['blocks'] * 2.0) -
            ($row['turnovers'] * 2.0) -
            ($row['fouls'] * 1.0);

        $player_stats[$player_name]['performance_score_total'] += $performance_score;
    }

    // Prepare final output
    $average_performance = [];
    foreach ($player_stats as $player => $stats) {
        $appearances = count($stats['game_ids']);
        $average_score = $appearances > 0 ? round($stats['performance_score_total'] / $appearances, 2) : 0.0;

        $average_performance[$player] = [
            'average_fg%' => $stats['fg_count'] > 0 ? round($stats['fg_sum'] / $stats['fg_count'], 2) : 0.0,
            'average_2pt%' => $stats['2pt_count'] > 0 ? round($stats['2pt_sum'] / $stats['2pt_count'], 2) : 0.0,
            'average_3pt%' => $stats['3pt_count'] > 0 ? round($stats['3pt_sum'] / $stats['3pt_count'], 2) : 0.0,
            'average_ft%' => $stats['ft_count'] > 0 ? round($stats['ft_sum'] / $stats['ft_count'], 2) : 0.0,
            'appearances' => $appearances,
            'total_points' => $stats['points_total'],
            'average_performance_score' => $average_score
        ];
    }

    echo json_encode([
        "success" => true,
        "data" => $data,
        "average_performance" => $average_performance
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "No data found or error in query."
    ]);
}

$conn->close();
?>
