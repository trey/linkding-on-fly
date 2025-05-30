#!/bin/bash
set -e

# Restore the database if it does not already exist.
if [ -f $DB_PATH ]; then
  echo "Database exists, skipping restore."
else
  echo "No database found, attempt to restore from a replica."
  litestream restore -if-replica-exists $DB_PATH
  echo "Finished restoring the database."
fi

# Load cron configuration.
crontab /etc/linkding/crontab
echo "Cron has been configured." >> /var/log/cron.log

# Start cron as a daemon.
cron
echo "Cron has been started." >> /var/log/cron.log

printf "AWS_ACCESS_KEY_ID=%s\n" $AWS_ACCESS_KEY_ID >> /etc/environment
printf "AWS_SECRET_ACCESS_KEY=%s\n" $AWS_SECRET_ACCESS_KEY >> /etc/environment
printf "UPTIME_COMMAND=%s\n" "$UPTIME_COMMAND" >> /etc/environment
printf "S3_BUCKET_NAME=%s\n" $S3_BUCKET_NAME >> /etc/environment
printf "S3_ENDPOINT=%s\n" $S3_ENDPOINT >> /etc/environment

# Define storage lifecycle for daily backup bucket
aws s3api put-bucket-lifecycle-configuration \
    --bucket $S3_BUCKET_NAME \
    --lifecycle-configuration file:///scripts/spaces-lifecycle.json \
    --endpoint=$S3_ENDPOINT

echo "Starting Litestream & Linkding service."

# Run litestream with your app as the subprocess.
exec litestream replicate -exec "/etc/linkding/bootstrap.sh"
