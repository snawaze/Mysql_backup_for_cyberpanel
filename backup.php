<!-- Include jQuery library -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>

<!-- Add a button to trigger the backup -->
<button id="backup_button">Backup MySQL</button>

<!-- Display the backup files in a table -->
<table id="backup_table">
    <tr>
        <th>Backup File</th>
        <th>Timestamp</th>
    </tr>
</table>

<!-- JavaScript code to handle the button click and display backup files -->
<script>
    $(document).ready(function () {
        $("#backup_button").click(function () {
            $.ajax({
                url: "/path/to/mysql_backup.php",
                type: "post",
                success: function (result) {
                    $("#backup_table").append(result);
                }
            });
        });
    });
</script>