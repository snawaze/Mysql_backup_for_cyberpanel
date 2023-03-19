$descriptorspec = array(
0 => array("pipe", "r"), // stdin
1 => array("pipe", "w"), // stdout
2 => array("pipe", "w") // stderr
);

$process = proc_open($backup_command, $descriptorspec, $pipes);

if (is_resource($process)) {
$output = '';
while (!feof($pipes[1])) {
$output .= fgets($pipes[1]);
}
fclose($pipes[1]);

$error_output = '';
while (!feof($pipes[2])) {
$error_output .= fgets($pipes[2]);
}
fclose($pipes[2]);

$exit_status = proc_close($process);

if ($exit_status === 0) {
// Backup successful
$backup_files = glob("/home/backup/all_databases-*.tar.gz");
$backup_files_list = "<ul>";
	foreach ($backup_files as $backup_file) {
	$backup_files_list .= "<li>" . basename($backup_file) . "</li>";
	}
	$backup_files_list .= "</ul>";

$response = array(
"success" => true,
"backup_files" => $backup_files_list
);
} else {
// Backup failed
$error_message = "MySQL backup failed. Please check backup logs for more information.";

$error_log = fopen("/home/backup/backup_error_log.txt", "a");
fwrite($error_log, date('Y-m-d H:i:s') . " - " . $error_output . PHP_EOL);
fclose($error_log);

$response = array(
"success" => false,
"error_message" => $error_message
);
}
} else {
// Failed to start process
$error_message = "Failed to start backup process.";

$error_log = fopen("/home/backup/backup_error_log.txt", "a");
fwrite($error_log, date('Y-m-d H:i:s') . " - " . $error_message . PHP_EOL);
fclose($error_log);

$response = array(
"success" => false,
"error_message" => $error_message
);
}