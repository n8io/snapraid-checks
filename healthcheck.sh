#!/bin/bash

DRIVE_MOUNT_REGEX='/mnt/[dp]'
DRIVE_INFO_TEMP='/root/diagnostics/.drives'
DRIVE_INFO_DEST='/root/diagnostics/drives'
SMART_LOCK_FILE='/root/diagnostics/.smart-lock'
HEALTH_LOG_DEST='/root/diagnostics/last-healthcheck.log'
HEALTH_ERR_DEST='/root/diagnostics/last-healthcheck.err'
HEALTH_LOG_TRUNCATE=1
HEALTH_ERR_TRUNCATE=1
TEST_RESULTS_KEY='SMART'
SMART_BINARY='/usr/sbin/smartctl'
NOTIFICATION_SCRIPT='/root/diagnostics/send-notification.sh'
EXIT_CODE=0

function log() {
  NOW=$(date +"%Y-%m-%d %r")

  if [ "$1" = "0"  ]; then
    echo -n "[ $NOW ] $2"
  elif [ "$1" = "1" ]; then
    echo $2
  else
    echo "[ $NOW ] $*"
  fi
}

# Create drive info temp file
df -kh --output=target,size,used,avail,pcent,source | sed -n 2,50p | grep ${DRIVE_MOUNT_REGEX} > $DRIVE_INFO_TEMP

# Wipe out dest file
echo '' > $DRIVE_INFO_DEST

if [ $HEALTH_LOG_TRUNCATE ]
then
  # Wipe health log
  echo '' > $HEALTH_LOG_DEST
fi

if [ $HEALTH_ERR_TRUNCATE ]
then
  # Wipe health error log
  echo '' > $HEALTH_ERR_DEST
fi

log "------------------------------------------------------------------------------------" >> $HEALTH_LOG_DEST
log "Starting health checks ..." >> $HEALTH_LOG_DEST
while IFS='' read -r line || [[ -n "$line" ]]; do
  MOUNT=`echo $line | sed -n 1p | awk '{print $1}'`
  SIZE=`echo $line | sed -n 1p | awk '{print $2}'`
  AVAIL=`echo $line | sed -n 1p | awk '{print $3}'`
  USED=`echo $line | sed -n 1p | awk '{print $4}'`
  PERCENT=`echo $line | sed -n 1p | awk '{print $5}'`
  PERCENT_INT=`echo $PERCENT | tr -d '%'`
  SOURCE=`echo $line | sed -n 1p | awk '{print $6}'`
  UUID=`blkid -o value $SOURCE | sed -n 2p`

  if [ -z $UUID ]; then
    continue # skip those w/o valid UUIDs
  fi

  # Write out to dest file w/UUIDs
  echo $MOUNT $SIZE $AVAIL $USED $PERCENT_INT $UUID >> $DRIVE_INFO_DEST

  if [ ! -f $SMART_LOCK_FILE ]; then
    # Enable S.M.A.R.T. support
    log 0 "Enabling S.M.A.R.T support for $UUID  ( $SOURCE ) ... " >> $HEALTH_LOG_DEST
    $SMART_BINARY -s on -o on -S on $SOURCE >> /dev/null
    log 1 "DONE" >> $HEALTH_LOG_DEST
  fi

  # Write out health log
  log 0 "Running health check for $UUID ( $SOURCE ) ... " >> $HEALTH_LOG_DEST
  OUTPUT=`$SMART_BINARY  -H $SOURCE`

  if [[ $OUTPUT =~ ^.*PASSED$ ]]; then
    log 1 "PASSED" >> $HEALTH_LOG_DEST
  else
    EXIT_CODE=1
    log 1 "FAILED. See $HEALTH_ERR_DEST for details." >> $HEALTH_LOG_DEST
    log "DRIVE FAILURE: $UUID ( $SOURCE )" >> $HEALTH_ERR_DEST
    $SMART_BINARY -H $SOURCE >> $HEALTH_ERR_DEST
  fi
done < $DRIVE_INFO_TEMP
cat $DRIVE_INFO_TEMP > $DRIVE_INFO_DEST

# All drives have S.M.A.R.T. enabled, create lock file
touch $SMART_LOCK_FILE

# Cleanup temp file
log 0 "Cleaning up ... " >> $HEALTH_LOG_DEST
rm $DRIVE_INFO_TEMP
log 1 "DONE" >> $HEALTH_LOG_DEST

log "... health check complete" >> $HEALTH_LOG_DEST

if [ "$EXIT_CODE" != "0" ]; then
  # Send notification
  $NOTIFICATION_SCRIPT "Titan Hard Drive Failure" "There is an unhealthy drive in your RAID array. Please resolve immediately."
fi

echo "Exited with code: $EXIT_CODE" >> $HEALTH_LOG_DEST

# cat results
cat $HEALTH_LOG_DEST

exit $EXIT_CODE

