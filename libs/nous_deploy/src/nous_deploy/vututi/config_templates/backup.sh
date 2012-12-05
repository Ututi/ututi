#!/bin/bash

set -e
set -u

BACKUP_LOCATION={{service.settings.backups_dir}}
DAILY_BACKUP_LOCATION=$BACKUP_LOCATION/daily
NUM_BACKUPS=5

mkdir -p $DAILY_BACKUP_LOCATION

function number_of_backups() {
    echo `ls -1 $DAILY_BACKUP_LOCATION | wc -l`
}

function oldest_backup() {
    echo -n `ls -1 $DAILY_BACKUP_LOCATION | head -1`
}

function newest_backup() {
    echo -n `ls -1 $DAILY_BACKUP_LOCATION | tail -1`
}

# move oldest backup into current (so we would not have to copy all
# the files every time)
if [ $(number_of_backups) -lt $NUM_BACKUPS ]
then
  mkdir -p $BACKUP_LOCATION/current
else
  mv $DAILY_BACKUP_LOCATION/$(oldest_backup) $BACKUP_LOCATION/current
fi

# Make database dump
{{service.pg_dump_command}} > $BACKUP_LOCATION/current/dbdump
# Rsync all the files
rsync -rt {{service.settings.upload_dir}} $BACKUP_LOCATION/current

# Move current backup into timestamped directory
mv $BACKUP_LOCATION/current $DAILY_BACKUP_LOCATION/`date +%Y-%m-%d_%H-%M-%S`

# delete old backups
while [ $(number_of_backups) -gt $NUM_BACKUPS ]
do
    rm -rf "$DAILY_BACKUP_LOCATION/$(oldest_backup)"
done

# remove symlink to the newest backup
rm -f $BACKUP_LOCATION/backup

# create symlink to the newest backup
ln -s $DAILY_BACKUP_LOCATION/$(newest_backup) $BACKUP_LOCATION/backup
