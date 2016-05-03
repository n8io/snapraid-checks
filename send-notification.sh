#!/bin/bash

MSG_TYPE="note"
MSG_TITLE="${1:-Notification test}"
MSG_BODY="${2:-This is only a test}"

JSON="'{\"type\":\"$MSG_TYPE\",\"title\":\"$MSG_TITLE\",\"body\":\"$MSG_BODY\"}'"

PUSHBULLET_CREDENTIAL_FILE='/root/diagnostics/.pushbullet'

if [ ! -f "$PUSHBULLET_CREDENTIAL_FILE" ]; then
  echo "A Pushbullet credential file is needed to send notifications. See .pushbullet.example for format. Rename to .pushbullet after entering in your access token"
  exit 1
fi

source "$PUSHBULLET_CREDENTIAL_FILE"

if [ "$PUSHBULLET_ACCESS_TOKEN" = "" ]; then
  echo "PUSHBULLET_ACCESS_TOKEN is not set in credential file. Please enter your access token in .pushbullet"
  exit 1
fi

PUSHBULLET_URI="https://api.pushbullet.com/v"
PUSHBULLET_VERSION=2

POST_METHOD="-X POST"
TOKEN_HEADER="-H \"Access-Token: $PUSHBULLET_ACCESS_TOKEN\""
CONTENT_TYPE_HEADER="-H \"Content-Type: application/json\""
POST_HEADERS="$CONTENT_TYPE_HEADER $TOKEN_HEADER"
POST_BODY="--data-binary $JSON"
POST_REQ="$POST_METHOD $POST_HEADERS $POST_BODY"
POST_URI="\"${PUSHBULLET_URI}${PUSHBULLET_VERSION}/pushes\""

CMD="curl $POST_REQ ${POST_URI} > /dev/null 2>&1"

echo -n "Sending notification...."
eval $CMD
echo "sent."
