<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "falcon_stats";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Get mode from POST
$mode = isset($_POST['mode']) ? $_POST['mode'] : '';

// Log received POST data for debugging
error_log("Received POST data: " . print_r($_POST, true));

// ====== MODE: save_stats (Single Player) ======
if ($mode === 'save_stats') {
    $game_id_query = "SELECT game_id FROM games ORDER BY game_id DESC LIMIT 1";
    $game_id_result = mysqli_query($conn, $game_id_query);

    if ($game_id_result && mysqli_num_rows($game_id_result) > 0) {
        $game_id_row = mysqli_fetch_assoc($game_id_result);
        $game_id = $game_id_row['game_id'];
        error_log("Latest game_id from games table: $game_id");
    } else {
        echo json_encode(["status" => "error", "message" => "No game found in the games table"]);
        exit;
    }

    $quarter_id = $_POST['quarter_id'];
    $player_name = $_POST['player_name'];
    $ft_made = $_POST['ft_made'];
    $ft_missed = $_POST['ft_missed'];
    $two_pt_made = $_POST['two_pt_made'];
    $two_pt_missed = $_POST['two_pt_missed'];
    $three_pt_made = $_POST['three_pt_made'];
    $three_pt_missed = $_POST['three_pt_missed'];
    $off_reb = $_POST['off_reb'];
    $def_reb = $_POST['def_reb'];
    $steals = $_POST['steals'];
    $turnovers = $_POST['turnovers'];
    $assists = $_POST['assists'];
    $blocks = $_POST['blocks'];
    $fouls = $_POST['fouls'];
    $points = $_POST['points'];

    if (!is_numeric($game_id)) {
        echo json_encode(["status" => "error", "message" => "Invalid game_id"]);
        exit;
    }

    $query = "INSERT INTO stats (game_id, quarter_id, player_name, ft_made, ft_missed, two_pt_made, two_pt_missed, three_pt_made, three_pt_missed, off_reb, def_reb, steals, turnovers, assists, blocks, fouls, points)
              VALUES ('$game_id', '$quarter_id', '$player_name', '$ft_made', '$ft_missed', '$two_pt_made', '$two_pt_missed', '$three_pt_made', '$three_pt_missed', '$off_reb', '$def_reb', '$steals', '$turnovers', '$assists', '$blocks', '$fouls', '$points')";

    $result = mysqli_query($conn, $query);

    if ($result) {
        // If the 4th quarter is saved, update home and opponent scores
        if ($quarter_id == 4) {
            $totalPoints = $_POST['totalPoints'];
            $opponent_score = $_POST['opponent_score'];
            $update_query = "UPDATE games SET totalPoints = '$totalPoints', opponent_score = '$opponent_score' WHERE game_id = '$game_id'";
            mysqli_query($conn, $update_query);
        }

        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode(["status" => "error", "message" => mysqli_error($conn)]);
    }

// ====== MODE: save_quarter ======
} elseif ($mode === 'save_quarter') {
    $game_id_query = "SELECT game_id FROM games ORDER BY game_id DESC LIMIT 1";
    $game_id_result = mysqli_query($conn, $game_id_query);

    if ($game_id_result && mysqli_num_rows($game_id_result) > 0) {
        $game_id_row = mysqli_fetch_assoc($game_id_result);
        $game_id = $game_id_row['game_id'];
        error_log("Latest game_id from games table: $game_id");
    } else {
        echo json_encode(["status" => "error", "message" => "No game found in the games table"]);
        exit;
    }

    $quarter_number = $_POST['quarter_number'];

    if (!is_numeric($game_id)) {
        echo json_encode(["status" => "error", "message" => "Invalid game_id"]);
        exit;
    } 
	$totalPoints = $_POST['totalPoints'];
    $opponent_score = $_POST['opponent_score'];


    $query = "INSERT INTO quarter (game_id, quarter_number, totalPoints, opponent_score) VALUES ('$game_id', '$quarter_number','$totalPoints','$opponent_score')";
    $result = mysqli_query($conn, $query);

    if ($result) {
        echo json_encode(["status" => "success", "data" => ["quarter_id" => mysqli_insert_id($conn)]]);
    } else {
        echo json_encode(["status" => "error", "message" => mysqli_error($conn)]);
    }

// ====== MODE: save_stats_batch (Multiple Players) ======
} elseif ($mode === 'save_stats_batch') {
    $game_id_query = "SELECT game_id FROM games ORDER BY game_id DESC LIMIT 1";
    $game_id_result = mysqli_query($conn, $game_id_query);

    if ($game_id_result && mysqli_num_rows($game_id_result) > 0) {
        $game_id_row = mysqli_fetch_assoc($game_id_result);
        $game_id = $game_id_row['game_id'];
        error_log("Latest game_id from games table: $game_id");
    } else {
        echo json_encode(["status" => "error", "message" => "No game found in the games table"]);
        exit;
    }

    $quarter_id = $_POST['quarter_id'];
    $stats_json = $_POST['stats'];
    $stats_array = json_decode($stats_json, true);

    if (!is_array($stats_array)) {
        echo json_encode(["status" => "error", "message" => "Invalid stats data"]);
        exit;
    }

    $all_success = true;
    foreach ($stats_array as $stat) {
        $player_name = isset($stat['player_name']) ? mysqli_real_escape_string($conn, $stat['player_name']) : '';
        $ft_made = isset($stat['ft_made']) ? (int) $stat['ft_made'] : 0;
        $ft_missed = isset($stat['ft_missed']) ? (int) $stat['ft_missed'] : 0;
        $two_pt_made = isset($stat['two_pt_made']) ? (int) $stat['two_pt_made'] : 0;
        $two_pt_missed = isset($stat['two_pt_missed']) ? (int) $stat['two_pt_missed'] : 0;
        $three_pt_made = isset($stat['three_pt_made']) ? (int) $stat['three_pt_made'] : 0;
        $three_pt_missed = isset($stat['three_pt_missed']) ? (int) $stat['three_pt_missed'] : 0;
        $off_reb = isset($stat['off_reb']) ? (int) $stat['off_reb'] : 0;
        $def_reb = isset($stat['def_reb']) ? (int) $stat['def_reb'] : 0;
        $steals = isset($stat['steals']) ? (int) $stat['steals'] : 0;
        $turnovers = isset($stat['turnovers']) ? (int) $stat['turnovers'] : 0;
        $assists = isset($stat['assists']) ? (int) $stat['assists'] : 0;
        $blocks = isset($stat['blocks']) ? (int) $stat['blocks'] : 0;
        $fouls = isset($stat['fouls']) ? (int) $stat['fouls'] : 0;
        $points = isset($stat['points']) ? (int) $stat['points'] : 0;

        $query = "INSERT INTO stats (
            game_id, quarter_id, player_name, 
            ft_made, ft_missed, two_pt_made, two_pt_missed, 
            three_pt_made, three_pt_missed, off_reb, def_reb, 
            steals, turnovers, assists, blocks, fouls, points
        ) VALUES (
            '$game_id', '$quarter_id', '$player_name', 
            '$ft_made', '$ft_missed', '$two_pt_made', '$two_pt_missed', 
            '$three_pt_made', '$three_pt_missed', '$off_reb', '$def_reb', 
            '$steals', '$turnovers', '$assists', '$blocks', '$fouls', '$points'
        )";
		if ($quarter_id == 4) {
    $totalPoints = $_POST['totalPoints'];
    $opponent_score = $_POST['opponent_score'];

    $update_query = "UPDATE games SET totalPoints = '$totalPoints', opponent_score = '$opponent_score' WHERE game_id = '$game_id'";
    mysqli_query($conn, $update_query);
}


        if (!mysqli_query($conn, $query)) {
            $all_success = false;
            error_log("Error inserting stat for $player_name: " . mysqli_error($conn));
        }
    }

    if ($all_success) {
        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode(["status" => "error", "message" => "One or more stats failed to insert. Check server logs."]);
    }

} elseif ($mode === 'finalize_game') {
// ====== MODE: finalize_game ======
    $game_id_query = "SELECT game_id FROM games ORDER BY game_id DESC LIMIT 1";
    $game_id_result = mysqli_query($conn, $game_id_query);

    if ($game_id_result && mysqli_num_rows($game_id_result) > 0) {
        $game_id_row = mysqli_fetch_assoc($game_id_result);
        $game_id = $game_id_row['game_id'];
        error_log("Latest game_id from games table: $game_id");
    } else {
        echo json_encode(["status" => "error", "message" => "No game found in the games table"]);
        exit;
    }

    $totalPoints = $_POST['totalPoints'];
    $opponent_score = $_POST['opponent_score'];

    if (!is_numeric($totalPoints) || !is_numeric($opponent_score)) {
        echo json_encode(["status" => "error", "message" => "Invalid scores"]);
        exit;
    }

    $query = "UPDATE games SET totalPoints = '$totalPoints', opponent_score = '$opponent_score' WHERE game_id = '$game_id'";

    if (mysqli_query($conn, $query)) {
        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode(["status" => "error", "message" => mysqli_error($conn)]);
    }
}

$conn->close();
?>