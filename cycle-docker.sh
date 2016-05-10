#!/bin/bash
DOCKER_COMPOSE_BIN="/usr/local/bin/docker-compose"
OUTPUT_FILE="/root/diagnostics/last-cycle-docker.log"
NOW=$(date "+%Y-%m-%d %r")
cd /code/media-server-config
echo "Process started @ $NOW" > ${OUTPUT_FILE}
${DOCKER_COMPOSE_BIN} restart >> ${OUTPUT_FILE}  2>&1
NOW=$(date "+%Y-%m-%d %r")
echo "Process ended @ $NOW" >> ${OUTPUT_FILE}
