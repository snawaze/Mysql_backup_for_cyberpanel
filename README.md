# Mysql_backup

Mysql backup script for use in cyberpanel with gzip compression

###########################################################

# Script: mysql_backup.sh

# Description: Backup all MySQL databases separately

# Author: Hirantha Bandara Muramudali

# Date: March 25, 2023

# Usage: ./mysql_backup.sh

###########################################################

This script retrieves the MySQL password from CyberPanel using the cat command and stores it in the mysql_password variable. Then it uses this password to connect to the MySQL server and back up each database separately. Note that you should make sure that the mysql command is in the system's PATH or provide the full path to the command if it's not.
