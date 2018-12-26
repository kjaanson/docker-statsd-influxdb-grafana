#!/bin/bash
docker run --ulimit nofile=66000:66000 \
  -d \
  --name docker-influxdb-grafana-mosquitto \
  -p 1883:1883 \
  -p 3003:3003 \
  -p 3004:8888 \
  -p 8086:8086 \
  -p 9001:9001 \
  -p 22022:22 \
  -p 8125:8125/udp \
  docker-influxdb-tick

