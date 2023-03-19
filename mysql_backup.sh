#!/bin/bash

###########################################################
# Script: mysql_backup.sh
# Description: Backup all MySQL databases to a single compressed file
# Author: Hirantha Bandara Muramudali
# Date: March 25, 2023
# Usage: ./mysql_backup.sh
###########################################################

#set directory name using timestamp

#timestamp_for_bkp=$(date +"%Y-%m-%d_%I-%M_%p")
timestamp_for_bkp=$(date +%Y-%m-%d__%H-%M)

# Set backup directory
backup_dir="/home/backup/${timestamp_for_bkp}"

# Get MySQL password from CyberPanel
mysql_password=$(cat /etc/cyberpanel/mysqlPassword)

# Get list of databases (excluding system databases)
databases=$(mysql -u root -p"$mysql_password" -e "SHOW DATABASES;" | grep -Ev "(Database|mysql|performance_schema|information_schema)")

# Create backup directory
if mkdir -p "$backup_dir"; then
  echo "$(date) - Backup directory created: $backup_dir" >> "/home/backup/backup.log"
else
  echo "$(date) - Error creating backup directory: $backup_dir" >> "/home/backup/backup_error_log"
  exit 1
fi

# Backup each database separately
for db in $databases; do
  backup_file="$backup_dir/$db.sql.gz"
  if /usr/bin/mysqldump -h localhost -u root -p"$mysql_password" "$db" | gzip -c > "$backup_file"; then
    echo "$(date) - Database backup completed: $backup_file" >> "/home/backup/backup.log"
  else
    echo "$(date) - Error backing up database: $db" >> "/home/backup/backup_error_log"
    exit 1
  fi
done

# Change working directory to backup directory
if cd "$backup_dir"; then
  echo "$(date) - Changed working directory to: $backup_dir" >> "/home/backup/backup.log"
else
  echo "$(date) - Error changing working directory to: $backup_dir" >> "/home/backup/backup_error_log"
  exit 1
fi

# Compress all backup files into a single archive
if tar -czvf "../all_databases-${timestamp_for_bkp}.tar.gz" .; then
  echo "$(date) - Backup files compressed into: all_databases-${timestamp_for_bkp}.tar.gz" >> "/home/backup/backup.log"
else
  echo "$(date) - Error compressing backup files into: all_databases-${timestamp_for_bkp}.tar.gz" >> "/home/backup/backup_error_log"
  exit 1
fi

# Remove individual backup files
# if rm -r "$backup_dir"; then
#   echo "$(date) - Individual backup files removed: $backup_dir" >> "/home/backup/backup.log"
# else
#   echo "$(date) - Error removing individual backup files: $backup_dir" >> "/home/backup/backup_error_log"
#   exit 1
# fi

# Log time taken for backup process
echo "$(date) - Backup process completed in $(printf '%02d:%02d' $((SECONDS/60)) $((SECONDS%60))) minutes:seconds to file all_databases-${timestamp_for_bkp}.tar.gz" >> "/home/backup/backup.log"
