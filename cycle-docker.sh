#!/bin/bash
DOCKER_COMPOSE_BIN="/usr/local/bin/docker-compose"
cd /code/media-server-config
${DOCKER_COMPOSE_BIN} restart > /root/diagnostics/last-cycle-docker.log 2>&1
echo $(date +"%Y-%m-%d %r") >> /root/diagnostics/last-cycle-docker.log
