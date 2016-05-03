#!/bin/bash
SNAPRAID_SETTINGS_FILE='/root/diagnostics/.snapraid-settings'
SNAPRAID_BINARY='/usr/local/bin/snapraid'
NOTIFICATION_SCRIPT='/root/diagnostics/send-notification.sh'
SCRUB_OUTPUT='/root/diagnostics/last-scrub.log'
EXIT_CODE=0

source $SNAPRAID_SETTINGS_FILE

# echo $SNAPRAID_CONFIG_PARAMS

$SNAPRAID_BINARY scrub $SNAPRAID_CONFIG_PARAMS  > $SCRUB_OUTPUT
$EXIT_CODE=$?

if [ "$EXIT_CODE" -ne "0" ]; then
  $NOTIFICATION_SCRIPT "SnapRAID Scrub Problem" "Srubbing exited with a non-zero code: ${EXIT_CODE}. Please investigate."
  echo "Exiting with code $EXIT_CODE"
  exit $EXIT_CODE
fi

cat $SCRUB_OUTPUT
echo "Exiting with code $EXIT_CODE"

exit $EXIT_CODE
