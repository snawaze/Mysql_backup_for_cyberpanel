if /home/backup/megatools/megatools put  test.sh; then
  echo "$(date) - Backup file uploaded to Mega.nz: all_databases-${timestamp_for_bkp}.tar.gz"
else
  echo "$(date) - Error uploading backup file to Mega.nz: all_databases-${timestamp_for_bkp}.tar.gz"
  #exit 1
fi