#!/bin/bash

###########################################################
# Script: mysql_backup.sh
# Description: Backup all MySQL databases separately
# Author: Your Name
# Date: March 25, 2023
# Usage: ./mysql_backup.sh
###########################################################

# Set backup directory
backup_dir="/home/backup"

# Get MySQL password from CyberPanel
mysql_password=$(cat /etc/cyberpanel/mysqlPassword)

# Get list of databases
databases=$(mysql -u root -p"$mysql_password" -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)")

# Backup each database separately
for db in $databases; do
  backup_file="$backup_dir/$db-$(date +%Y-%m-%d_%H-%M-%S).sql.gz"
  /usr/bin/mysqldump -h localhost -u root -p"$mysql_password" "$db" | gzip -9 -c > "$backup_file"
done
