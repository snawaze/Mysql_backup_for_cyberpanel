<!DOCTYPE html>
<html>

<head>
    <title>MySQL Backup</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        $(document).ready(function () {
            $("#backup_button").click(function () {
                $.ajax({
                    url: "backup.php",
                    type: "POST",
                    dataType: "json",
                    beforeSend: function () {
                        $("#progress_bar").show();
                    },
                    success: function (response) {
                        $("#progress_bar").hide();
                        if (response.success) {
                            $("#error_message").hide();
                            $("#backup_files_table").html(response.backup_files);
                        } else {
                            $("#error_message").html(response.error_message).show();
                        }
                    },
                    error: function (xhr, status, error) {
                        $("#progress_bar").hide();
                        $("#error_message").html("An error occurred while backing up MySQL: " + error).show();
                    },
                    xhr: function () {
                        var xhr = $.ajaxSettings.xhr();
                        if (xhr.upload) {
                            xhr.upload.addEventListener('progress', function (event) {
                                if (event.lengthComputable) {
                                    var percent = Math.round((event.loaded / event.total) * 100);
                                    $("#progress_bar").val(percent);
                                }
                            }, false);
                        }
                        return xhr;
                    }
                });
            });
        });
    </script>
    <style>
        #progress_bar {
            display: none;
        }
    </style>
</head>

<body>
    <h1>MySQL Backup</h1>
    <button id="backup_button">Backup MySQL</button>
    <progress id="progress_bar" max="100"></progress>
    <div id="error_message"></div>
    <div id="backup_files_table"></div>
</body>

</html>