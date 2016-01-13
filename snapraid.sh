#!/bin/bash
NOTIFICATION_SCRIPT='/root/diagnostics/send-notification.sh'
DIFF_OUTPUT='/root/diagnostics/last-diff.log'
SYNC_OUTPUT='/root/diagnostics/last-sync.log'
DELETE_MAX_THRESHOLD=50
SNAPRAID_BINARY='/usr/local/bin/snapraid'
DAYOFWEEK_REMINDER='Wednesday'
DAYOFWEEK=$(date "+%A")
NOW=$(date "+%Y-%m-%d %r")
MACHINE_NAME="[$(hostname)]"

echo "Process started @ $NOW" > $DIFF_OUTPUT
$SNAPRAID_BINARY diff >> $DIFF_OUTPUT
EXIT_CODE=$? # 2 if there were diffs, 0 if no diffs, 1 if error

NOW=$(date +"%Y-%m-%d %r")
echo "Process completed @ $NOW" >> $DIFF_OUTPUT
echo "Exited with code: $EXIT_CODE" >> $DIFF_OUTPUT

# cat diff results
cat $DIFF_OUTPUT

DEL_COUNT=$(grep -w '^ \{1,\}[0-9]* removed$' $DIFF_OUTPUT | sed 's/^ *//g' | cut -d ' ' -f1)
# ADD_COUNT=$(grep -w '^ \{1,\}[0-9]* added$' $DIFF_OUTPUT | sed 's/^ *//g' | cut -d ' ' -f1)
# MOVE_COUNT=$(grep -w '^ \{1,\}[0-9]* moved$' $DIFF_OUTPUT | sed 's/^ *//g' | cut -d ' ' -f1)
# COPY_COUNT=$(grep -w '^ \{1,\}[0-9]* copied$' $DIFF_OUTPUT | sed 's/^ *//g' | cut -d ' ' -f1)
# UPDATE_COUNT=$(grep -w '^ \{1,\}[0-9]* updated$' $DIFF_OUTPUT | sed 's/^ *//g' | cut -d ' ' -f1)

if [ "$DEL_COUNT" -gt "$DELETE_MAX_THRESHOLD" ]; then
  $NOTIFICATION_SCRIPT "SnapRAID Sync Halted" "A diff has determined that the number of deleted items ($DEL_COUNT) from since your last sync exceeds the acceptable threshold ($DELETE_MAX_THRESHOLD). Sync will not run until again this has been investigated."
  exit 1
fi

NOW=$(date +"%Y-%m-%d %r")
echo "Process started @ $NOW" > $SYNC_OUTPUT
$SNAPRAID_BINARY sync >> $SYNC_OUTPUT
EXIT_CODE=$?
NOW=$(date "+%Y-%m-%d %r")
echo "Process completed @ $NOW" >> $SYNC_OUTPUT

if [ "$EXIT_CODE" -ne "0" ]; then
  $NOTIFICATION_SCRIPT "SnapRAID Sync Issue Reported" "The last sync process reported a problem. Please investigate before the next scheduled sync."
  echo "Exited with code: $EXIT_CODE" >> $SYNC_OUTPUT
  cat $SYNC_OUTPUT
  exit $EXIT_CODE
elif [ "$DAYOFWEEK" == "$DAYOFWEEK_REMINDER" ]; then
  $NOTIFICATION_SCRIPT "Everything is OK" "Every $DAYOFWEEK_REMINDER $MACHINE_NAME likes to remind you that things are all good."
fi

echo "Sync complete OK" >> $SYNC_OUTPUT
echo "Exited with code: $EXIT_CODE" >> $SYNC_OUTPUT

# cat sync results
cat $SYNC_OUTPUT

exit $EXIT_CODE
