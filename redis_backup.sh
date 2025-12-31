#!/bin/bash

REDIS_CLI="/usr/bin/redis-cli"
BACKUP_DIR="/home.backupuser/backup_redis"
REDIS_DIR="/var/lib/redis"
DATE=$(date +%F-%H%M)
LOG="/var/log/redis_backup.log"

mkdir -p $BACKUP_DIR

echo "[$(date)] Starting Redis backup" >> $LOG

#background snapshot
$REDIS_CLI BGSAVE

# Wait until snapshot completes
while true; 
do
  STATUS=$($REDIS_CLI INFO persistence | grep rdb_bgsave_in_progress | cut -d: -f2 | tr -d '\r')
  [ "$STATUS" = "0" ] && break
  sleep 1
done

#Copy RDB
cp $REDIS_DIR/dump.rdb $BACKUP_DIR/dump-$DATE.rdb

#Copy Append only file, if exists
if [ -f "$REDIS_DIR/appendonly.aof" ]; 
then
  cp $REDIS_DIR/appendonly.aof $BACKUP_DIR/appendonly-$DATE.aof
fi

echo "[$(date)] Redis backup completed" >> $LOG
