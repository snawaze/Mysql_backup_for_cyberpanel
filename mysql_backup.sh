#!/bin/bash

###########################################################
# Script: mysql_backup.sh
# Description: Backup all MySQL databases to a single compressed file
# Author: Hirantha Bandara Muramudali
# Date: March 25, 2023
# Usage: ./mysql_backup.sh
###########################################################

#set directory name using timestamp

timestamp_for_bkp=$(date +%Y-%m-%d__%H-%M)

# Get MySQL password from CyberPanel
mysql_password=$(cat /etc/cyberpanel/mysqlPassword)

# Get list of databases (excluding system databases)
databases=$(mysql -u root -p"$mysql_password" -e "SHOW DATABASES;" | grep -Ev "(Database|mysql|performance_schema|information_schema)")

# Create backup directory
if mkdir -p "$timestamp_for_bkp"; then
  echo "$(date) - Backup directory created: $timestamp_for_bkp" >> backup.log
else
  echo "$(date) - Error creating backup directory: $timestamp_for_bkp" >> backup_error_log
  exit 1
fi

# Backup each database separately
for db in $databases; do
  backup_file="$timestamp_for_bkp/$db.sql.gz"
  if /usr/bin/mysqldump -h localhost -u root -p"$mysql_password" "$db" | gzip -c > "$backup_file"; then
    echo "$(date) - Database backup completed: $backup_file" >> backup.log
  else
    echo "$(date) - Error backing up database: $db" >> backup_error_log
    exit 1
  fi
done

# Compress all backup files into a single archive
if tar -czvf "all_databases-${timestamp_for_bkp}.tar.gz" "$timestamp_for_bkp"; then
  echo "$(date) - Backup files compressed into: all_databases-${timestamp_for_bkp}.tar.gz" >> backup.log
else
  echo "$(date) - Error compressing backup files into: all_databases-${timestamp_for_bkp}.tar.gz" >> backup_error_log
  exit 1
fi

# Remove individual backup files
if rm -r "$timestamp_for_bkp"; then
  echo "$(date) - Individual backup files removed: $timestamp_for_bkp" >> backup.log
else
  echo "$(date) - Error removing individual backup files: $timestamp_for_bkp" >> backup_error_log
  exit 1
fi

# Upload the backup file to Google Drive using the Drive API
# Replace <path_to_credentials_file> with the path to your Google Drive API credentials file
if python3 upload_to_drive.py "<path_to_credentials_file>" "all_databases-${timestamp_for_bkp}.tar.gz"; then
  echo "$(date) - Backup file uploaded to Google Drive: all_databases-${timestamp_for_bkp}.tar.gz" >> backup.log
else
  echo "$(date) - Error uploading backup file to Google Drive: all_databases-${timestamp_for_bkp}.tar.gz" >> backup_error_log
  exit 1
fi

# Log time taken for backup process
echo "$(date) - Backup process completed in $(printf '%02d:%02d' $((SECONDS/60)) $((SECONDS%60))) minutes:seconds to file all_databases-${timestamp_for_bkp}.tar.gz" >> backup.log