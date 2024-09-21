<?php
$conn = mysqli_connect('db', 'root', 'password', 'ecommerce');

// Проверка подключения к БД
if ($conn === false) {
    die("Ошибка подключения: " . mysqli_connect_error());
}

if (isset($_POST['login'])) {
    $username = $_POST['username'];
    $password = $_POST['password'];
    
    // SQL Injection уязвимость
    $query = "SELECT * FROM users WHERE username='$username' AND password='$password'";
    $result = mysqli_query($conn, $query);
    
    // Проверяем, была ли ошибка в выполнении запроса
    if ($result === false) {
        die("Ошибка в запросе: " . mysqli_error($conn));
    }
    
    if (mysqli_num_rows($result) > 0) {
        session_start();
        $_SESSION['username'] = $username;
    }
}

if (isset($_SESSION['username'])) {
    echo "<h1>Добро пожаловать, " . htmlspecialchars($_SESSION['username']) . "</h1>";
} else {
    echo '<form method="POST"><input name="username" required><input name="password" type="password" required><button type="submit" name="login">Вход</button></form>';
}
?>

