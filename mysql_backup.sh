#!/bin/bash

###########################################################
# Script: mysql_backup.sh
# Description: Backup all MySQL databases to a single compressed file
# Author: Your Name
# Date: March 25, 2023
# Usage: ./mysql_backup.sh
###########################################################

# Set backup directory
backup_dir="/home/backup/$(date +%Y-%m-%d_%H-%M-%S)"

# Get MySQL password from CyberPanel
mysql_password=$(cat /etc/cyberpanel/mysqlPassword)

# Get list of databases
databases=$(mysql -u root -p"$mysql_password" -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)")

# Create backup directory
mkdir -p "$backup_dir"

# Backup each database separately
for db in $databases; do
  backup_file="$backup_dir/$db.sql.gz"
  /usr/bin/mysqldump -h localhost -u root -p"$mysql_password" "$db" | gzip -c > "$backup_file"
done

# Compress all backup files into a single archive
tar -czvf "$backup_dir/all_databases-$(date +%Y-%m-%d_%H-%M-%S).tar.gz" "$backup_dir"
