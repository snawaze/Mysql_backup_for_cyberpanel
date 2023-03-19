<?php
// Set backup directory
$backup_dir = '/home/backup/';

// Get filename from query string
$filename = basename($_GET['file']);

// Set file path
$file = $backup_dir . $filename;

// Check if file exists and is a backup file
if (file_exists($file) && pathinfo($file, PATHINFO_EXTENSION) === 'gz') {
    // Set headers for file download
    header('Content-Description: File Transfer');
    header('Content-Type: application/octet-stream');
    header('Content-Disposition: attachment; filename="' . basename($file) . '"');
    header('Expires: 0');
    header('Cache-Control: must-revalidate');
    header('Pragma: public');
    header('Content-Length: ' . filesize($file));

    // Send file to user
    readfile($file);
    exit;
} else {
    // Redirect user back to backup files page
    header('Location: backup_files.php');
    exit;
}
?>