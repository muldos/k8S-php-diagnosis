<!DOCTYPE html>
<html>
<head>
    <title>12 factors php app</title>
</head>
<body>
<h1>A simple customers db listing !</h1>
<?php
require __DIR__ . '/vendor/autoload.php';
if (isset($_ENV['PHP_APPLICATION_ENV']) && (strcmp('dev',$_ENV['PHP_APPLICATION_ENV']) === 0) ) {
    $dotenv = Dotenv\Dotenv::create(__DIR__);
    $dotenv->load();
}
$host = getenv('MYSQL_HOST');
$login = getenv('MYSQL_USER');
$pwd = getenv('MYSQL_PWD');
$dbname = getenv('MYSQL_DBNAME');
$mysqli = new mysqli($host, $login, $pwd, $dbname);
?>


<?php

$sql = "SELECT firstname, lastname FROM customer";
$result = $mysqli->query($sql);

echo "<ul>\n";
while ($customer = $result->fetch_assoc()) {
    echo "<li>\n";
    echo $customer['firstname'] . ' ' . $customer['lastname'];
    echo "</a></li>\n";
}
echo "</ul>\n";
$result->free();
$mysqli->close();
?>

</body>
</html>