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
$now = time();
$sql = "INSERT INTO customer (firstname, lastname) VALUES ('Jon', '". $now ."')";
$mysqli->query($sql);
$mysqli->commit();
$mysqli->close();
// this allow you to test launching your app as a one-off process.
if (php_sapi_name() == "cli") {
    echo ('line inserted');
} else {
echo ('<html><body>line inserted</body></html>');

 }?>
    
