#!/bin/bash -x

# Ensure script stops when commands fail
set -e

mkdir -p /tmp

# Delete the previous backup if it exists (`-f` in case it doesn't exist)
rm -f /tmp/backup.sqlite3.gz

# Backup & compress our database to the tmp directory
sqlite3 /etc/linkding/data/db.sqlite3 '.backup /tmp/backup.sqlite3'
gzip /tmp/backup.sqlite3

/usr/local/bin/aws s3 cp /tmp/backup.sqlite3.gz s3://$S3_BUCKET_NAME/linkding/`date +%F`.sqlite3.gz --endpoint=$S3_ENDPOINT

# Delete the backup so it doesn't get in the way next time
rm /tmp/backup.sqlite3.gz
