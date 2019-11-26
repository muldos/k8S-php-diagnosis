<?php
require __DIR__ . '/vendor/autoload.php';
if (isset($_ENV['PHP_APPLICATION_ENV']) && (strcmp('dev',$_ENV['PHP_APPLICATION_ENV']) === 0) ) {
    $dotenv = Dotenv\Dotenv::create(__DIR__);
    $dotenv->load();
}
?>
<html>
<head>
    <title>12 factors php app</title>
</head>
    <body>
        <h1 style="color: blue;">Diagnosis</h1>
        <?php
            $envtype = getenv('PHP_APPLICATION_ENV');
            $host = getenv('MYSQL_HOST');
            $dbname = getenv('MYSQL_DBNAME');
            $docker_host = gethostname();
            $basedir = getenv('SHARED_FS_ROOT');
            if(!file_exists($basedir)){
                mkdir($basedir,0777,TRUE);
            }
            $path_to_container_file = $basedir . DIRECTORY_SEPARATOR . $docker_host . '.txt';
            if(!file_exists($path_to_container_file)){
                $myfile = fopen($path_to_container_file, "w");
            }
            $filesFound = scandir($basedir);
        ?>
        <h2>variables</h2>
        <ul>
            <li>envtype: <?php print $envtype;?></li>
            <li>host: <?php print $host;?></li>
            <li>dbname: <?php print $dbname;?></li>
            <li>container_host : <?php print $docker_host;?></li>
            <li>shared fs root : <?php print $basedir;?></li>
        </ul>
        <h2>filesystem</h2>
        <ul>
        <?php foreach($filesFound as $filename): ?>
            <li><?php echo $filename;?></li>
        <?php endforeach; ?>
        </ul>
    </body>
</html>