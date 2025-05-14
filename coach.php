<?php
// Allow cross-origin requests
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Set the content type to JSON
header('Content-Type: application/json');
$servername = "localhost";
$username = "root"; // Update with your database username
$password = ""; // Update with your database password
$dbname = "falcon_stats"; // Update with your database name

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Function to register a team
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'register_team') {
    $team_name = $_POST['team_name'];
    $team_coach = $_POST['team_coach'];
    $team_assistant_coach = $_POST['team_assistant_coach'];
    $team_manager = $_POST['team_manager'];
    $team_statistician = $_POST['team_statistician'];
    $team_doctor = $_POST['team_doctor'];

    // Check if team name already exists
    $check_sql = "SELECT * FROM Teams WHERE team_name = ?";
    $stmt = $conn->prepare($check_sql);
    $stmt->bind_param("s", $team_name);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result && $result->num_rows > 0) {
        echo json_encode(['status' => 'error', 'message' => 'Team name already exists.']);
    } else {
        // Insert new team
        $sql = "INSERT INTO Teams (team_name, team_coach, team_assistant_coach, team_manager, team_statistician, team_doctor)
                VALUES (?, ?, ?, ?, ?, ?)";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ssssss", $team_name, $team_coach, $team_assistant_coach, $team_manager, $team_statistician, $team_doctor);

        if ($stmt->execute()) {
            echo json_encode(['status' => 'success', 'message' => 'Team registered successfully.']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Error registering team: ' . $stmt->error]);
        }
    }

    $stmt->close();
}


// Function to register a player
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'register_player') {
    $league_number = $_POST['league_number'];
    $first_name = $_POST['first_name'];
    $last_name = $_POST['last_name'];
    $nationality = $_POST['nationality'];
    $age = $_POST['age'];
    $height = $_POST['height'];
    $weight = $_POST['weight'];
    $players_team = $_POST['players_team'];
    $position = $_POST['position'];
    $gender = $_POST['gender'];
	

    // Check if league number already exists
    $check_sql = "SELECT * FROM players WHERE league_number = '$league_number'";
    $check_result = $conn->query($check_sql);

    if ($check_result->num_rows > 0) {
        echo json_encode(['status' => 'error', 'message' => 'A player with this league number already exists.']);
    } else {
        // Check if team exists in the Teams table
        $team_check_sql = "SELECT * FROM Teams WHERE team_name = '$players_team'";
        $team_check_result = $conn->query($team_check_sql);

        if ($team_check_result->num_rows == 0) {
            echo json_encode(['status' => 'error', 'message' => 'The team does not exist. Please register the team first.']);
        } else {
            // Proceed to insert the player
            $sql = "INSERT INTO players (league_number, first_name, last_name, nationality, age, height, weight, players_team, position, gender)
                    VALUES ('$league_number', '$first_name','$last_name', '$nationality', '$age', '$height', '$weight', '$players_team','$position','$gender')";

            if ($conn->query($sql) === TRUE) {
                echo json_encode(['status' => 'success', 'message' => 'Player registered successfully.']);
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Error registering player: ' . $conn->error]);
            }
        }
    }
}


// Function to add a fixture
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'add_fixture') {
    $team_a = $_POST['team_a'];
    $team_b = $_POST['team_b'];
    $location = $_POST['location'];
    $time = $_POST['time'];

    $sql = "INSERT INTO fixtures (team_a, team_b, location, time)
            VALUES ('$team_a', '$team_b', '$location', '$time')";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(['status' => 'success', 'message' => 'Fixture added successfully.']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Error adding fixture: ' . $conn->error]);
    }
}

// Close connection
$conn->close();
?>
