<!DOCTYPE html>
<html>

<head>
    <title>MySQL Backup Files</title>
    <style type="text/css">
        table {
            border-collapse: collapse;
            width: 100%;
        }

        th,
        td {
            text-align: left;
            padding: 8px;
            border-bottom: 1px solid #ddd;
        }

        th {
            background-color: #4CAF50;
            color: white;
        }

        tr:hover {
            background-color: #f5f5f5;
        }

        a {
            text-decoration: none;
            color: blue;
        }
    </style>
</head>

<body>

    <h1>MySQL Backup Files</h1>

    <?php
    // Include mysql_backup.sh script
    include('mysql_backup.sh');

    // Set backup directory
    $backup_dir = '/home/backup/';

    // Get list of backup files in the backup directory
    $backup_files = array_diff(scandir($backup_dir), array('..', '.'));

    // Display table of backup files with download links
    if (count($backup_files) > 0) {
        echo "<table>\n";
        echo "<tr><th>Backup File</th><th>Date</th><th>Download</th></tr>\n";
        foreach ($backup_files as $backup_file) {
            if (pathinfo($backup_file, PATHINFO_EXTENSION) === 'gz') {
                $backup_date = date('F j, Y H:i:s', filemtime($backup_dir . $backup_file));
                echo "<tr><td>$backup_file</td><td>$backup_date</td><td><a href=\"download.php?file=$backup_file\">Download</a></td></tr>\n";
            }
        }
        echo "</table>\n";
    } else {
        echo "<p>No backup files found.</p>\n";
    }
    ?>

</body>

</html>