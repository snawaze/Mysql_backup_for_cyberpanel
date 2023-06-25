#!/bin/bash

###########################################################
# Script: mysql_backup.sh
# Description: Backup all MySQL databases to a single compressed file
# Author: Hirantha Bandara Muramudali
# Date: March 9, 2023
# Updated: March 20, 2023
# Usage: ./mysql_backup.sh
###########################################################

# Set directory name using timestamp
ip_address=$(curl -s ifconfig.me)
current_date=$(date +"%Y%m%d%h%i")
timestamp_for_bkp="${ip_address}-${current_date}"
backup_dir="/home/backup/"

# Get MySQL password from CyberPanel
mysql_password=$(cat /etc/cyberpanel/mysqlPassword)

# Get list of databases (excluding system databases)
databases=$(mysql -u root -p"$mysql_password" -e "SHOW DATABASES;" | grep -Ev "(Database|mysql|performance_schema|information_schema)")

# Create backup directory
if mkdir -p "${backup_dir}${timestamp_for_bkp}"; then
  echo "$(date) - Backup directory created: ${backup_dir}${timestamp_for_bkp}" >> "${backup_dir}backup.log"
else
  echo "$(date) - Error creating backup directory: ${backup_dir}${timestamp_for_bkp}" >> "${backup_dir}backup_error_log"
  exit 1
fi

# Backup each database separately
for db in $databases; do
  backup_file="${backup_dir}${timestamp_for_bkp}/${db}.sql.gz"
  if /usr/bin/mysqldump -h localhost -u root -p"$mysql_password" "$db" | gzip -5 -c > "${backup_file}"; then
    echo "$(date) - Database backup completed: ${backup_file}" >> "${backup_dir}backup.log"
  else
    echo "$(date) - Error backing up database: $db" >> "${backup_dir}backup_error_log"
    exit 1
  fi
done

# Compress all backup files into a single archive
if tar -czvf "${backup_dir}all_databases-${timestamp_for_bkp}.tar.gz" "${backup_dir}${timestamp_for_bkp}"; then
  echo "$(date) - Backup files compressed into: ${backup_dir}all_databases-${timestamp_for_bkp}.tar.gz" >> "${backup_dir}backup.log"
else
  echo "$(date) - Error compressing backup files into: ${backup_dir}all_databases-${timestamp_for_bkp}.tar.gz" >> "${backup_dir}backup_error_log"
  exit 1
fi

# Remove individual backup files
if rm -r "${backup_dir}$timestamp_for_bkp"; then
  echo "$(date) - Individual backup files removed: $timestamp_for_bkp" >> backup.log
else
  echo "$(date) - Error removing individual backup files: $timestamp_for_bkp" >> backup_error_log
  exit 1
fi

# Upload the backup file to Mega.nz  Putting in the Trash folder as the file needs to be deleted after 30days inorder to prevent over usage
if "${backup_dir}"megatools/megatools put "${backup_dir}all_databases-${timestamp_for_bkp}.tar.gz" --path /Trash  --config "${backup_dir}"/megatools/.megarc; then
  echo "$(date) - Backup file uploaded to Mega.nz: ${backup_dir}all_databases-${timestamp_for_bkp}.tar.gz" >> "${backup_dir}backup.log"
else
  echo "$(date) - Error uploading backup file to Mega.nz: ${backup_dir}all_databases-${timestamp_for_bkp}.tar.gz" >> "${backup_dir}backup_error_log"
  #exit 1
fi

# # Upload the backup file to Google Drive using the Drive API
# # Replace <path_to_credentials_file> with the path to your Google Drive API credentials file
# if python3 upload_to_drive.py "<path_to_credentials_file>" "${backup_dir}all_databases-${timestamp_for_bkp}.tar.gz"; then
#   echo "$(date) - Backup file uploaded to Google Drive: ${backup_dir}all_databases-${timestamp_for_bkp}.tar.gz" >> ${backup_dir}backup.log
# else
#   echo "$(date) - Error uploading backup file to Google Drive: ${backup_dir}all_databases-${timestamp_for

# Log time taken for backup process
echo "$(date) - Backup process completed in $(printf '%02d:%02d' $((SECONDS/60)) $((SECONDS%60))) minutes:seconds to file all_databases-${timestamp_for_bkp}.tar.gz" >> "${backup_dir}backup.log"
echo "===============================================================================" >> "${backup_dir}backup.log"