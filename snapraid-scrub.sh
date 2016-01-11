#!/bin/sh
SNAPRAID_BINARY='/usr/local/bin/snapraid'
NOTIFICATION_SCRIPT='/root/diagnostics/send-notification.sh'
SCRUB_OUTPUT='/root/diagnostics/last-scrub.log'
EXIT_CODE=0

$SNAPRAID_BINARY scrub > $SCRUB_OUTPUT
$EXIT_CODE=$?

if [ "$EXIT_CODE" -ne "0" ]; then
  $NOTIFICATION_SCRIPT "SnapRAID Scrub Problem" "Srubbing exitted with a non-zero code: ${EXIT_CODE}. Please investigate."
  echo "Exiting with code $EXIT_CODE"
  exit $EXIT_CODE
fi

cat $SCRUB_OUTPUT
echo "Exiting with code $EXIT_CODE"

exit $EXIT_CODE
