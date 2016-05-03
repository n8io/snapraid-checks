#!/bin/bash
cd /code/media-server-config
docker-compose restart > /root/diagnostics/last-cycle-docker.log
echo $(date +"%Y-%m-%d %r") >> /root/diagnostics/last-cycle-docker.log
