#!/bin/bash

###########################################################
# Script: mysql_backup.sh
# Description: Backup all MySQL databases to a single compressed file
# Author: Hirantha Bandara Muramudali
# Date: March 25, 2023
# Usage: ./mysql_backup.sh
###########################################################

#set directory name using timestamp
timestamp_for_bkp=$(date +%Y-%m-%d_%H-%M-%S)

# Set backup directory
backup_dir="/home/backup/${timestamp_for_bkp}"

# Create backup directory
mkdir -p "$backup_dir"

# Get MySQL password from CyberPanel
mysql_password=$(cat /etc/cyberpanel/mysqlPassword)

# Get list of databases (excluding system databases)
databases=$(mysql -u root -p"$mysql_password" -e "SHOW DATABASES;" | grep -Ev "(Database|mysql|performance_schema|information_schema)")

# Backup each database separately
for db in $databases; do
  backup_file="$backup_dir/$db.sql.gz"
  /usr/bin/mysqldump -h localhost -u root -p"$mysql_password" "$db" | gzip -c > "$backup_file"
done

# Compress all backup files into a single archive
tar -czvf "${backup_dir}/all_databases-${timestamp_for_bkp}.tar.gz" "$backup_dir"

# Remove individual backup files
#rm -f "${backup_dir}"/*.sql.gz
