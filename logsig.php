<?php
// Allow cross-origin requests
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Set the content type to JSON
header('Content-Type: application/json');

// Database connection details
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "falcon_stats";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed."]));
}

// Handle the OPTIONS request (CORS preflight check)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    header("HTTP/1.1 200 OK");
    exit;
}

// Function to handle user signup
function signup($conn) {
    $user_id = $_POST['user_id'];
    $password = $_POST['password'];
    $user_type = $_POST['user_type'];

    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    $check_query = "SELECT * FROM users WHERE user_id = ?";
    $stmt = $conn->prepare($check_query);
    $stmt->bind_param("s", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    if ($result->num_rows > 0) {
        echo json_encode(["status" => "error", "message" => "User ID already exists."]);
        return;
    }

    $insert_query = "INSERT INTO users (user_id, password, user_type) VALUES (?, ?, ?)";
    $stmt = $conn->prepare($insert_query);
    $stmt->bind_param("sss", $user_id, $hashed_password, $user_type);
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "User registered successfully."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error in user registration."]);
    }
}

// Function to handle user login
function login($conn) {
    $user_id = $_POST['user_id'];
    $password = $_POST['password'];

    $query = "SELECT * FROM users WHERE user_id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("s", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        if (password_verify($password, $user['password'])) {
            echo json_encode([
                "status" => "success",
                "message" => "Login successful",
                "user_type" => $user['user_type']
            ]);
        } else {
            echo json_encode(["status" => "error", "message" => "Incorrect password."]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "User ID not found."]);
    }
}

// Function to handle password reset
function reset_password($conn) {
    $user_id = $_POST['user_id'];
    $new_password = $_POST['new_password'];

    // Hash new password
    $hashed_password = password_hash($new_password, PASSWORD_DEFAULT);

    // Check if user exists
    $check_query = "SELECT * FROM users WHERE user_id = ?";
    $stmt = $conn->prepare($check_query);
    $stmt->bind_param("s", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    if ($result->num_rows === 0) {
        echo json_encode(["status" => "error", "message" => "User ID not found."]);
        return;
    }

    // Update the password
    $update_query = "UPDATE users SET password = ? WHERE user_id = ?";
    $stmt = $conn->prepare($update_query);
    $stmt->bind_param("ss", $hashed_password, $user_id);
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Password updated successfully."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to update password."]);
    }
}

// Route the request
if (isset($_POST['action'])) {
    $action = $_POST['action'];
    if ($action === 'signup') {
        signup($conn);
    } elseif ($action === 'login') {
        login($conn);
    } elseif ($action === 'reset_password') {
        reset_password($conn);
    } else {
        echo json_encode(["status" => "error", "message" => "Invalid action."]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "No action provided."]);
}

// Close connection
$conn->close();
?>
