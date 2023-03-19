<?php
if (isset($_POST['backup_button'])) {
    $output = shell_exec('/bin/bash /path/to/mysql_backup.sh');
}

$backup_dir = "/home/backup/";
$log_file = $backup_dir . "backup.log";

// Read the log file
$log_content = file_get_contents($log_file);

// Parse the log file to get the list of backup files
preg_match_all('/all_databases-(\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})\.tar\.gz/', $log_content, $matches);
$backup_files = $matches[0];
$backup_timestamps = $matches[1];

// Display the list of backup files in a table
$table_html = "<tr><th>Backup File</th><th>Timestamp</th></tr>";
foreach ($backup_files as $key => $backup_file) {
    $table_html .= "<tr><td><a href=\"$backup_dir/$backup_file\">$backup_file</a></td><td>$backup_timestamps[$key]</td></tr>";
}
echo $table_html;
?>