<?php
session_start();
if (isset($_SESSION['username'])) {
    $conn = mysqli_connect('db', 'root', 'password', 'ecommerce');
    mysqli_query($conn, "DELETE FROM users WHERE username='" . $_SESSION['username'] . "'");
    session_destroy();
    header("Location: index.php");
}
?>
