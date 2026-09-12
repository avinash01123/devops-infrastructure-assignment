#!/bin/bash

LOG_FILE="/var/log/infra_health.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

CPU_USAGE=$(top -bn1 | awk -F',' '/Cpu\(s\)/ {
    for (i=1; i<=NF; i++) {
        if ($i ~ /id/) {
            idle=$i
            gsub(/[^0-9.]/, "", idle)
            printf "%.0f", 100 - idle
            exit
        }
    }
}')

MEM_USAGE=$(free | awk '/Mem:/ {
    printf "%.0f", ($3/$2) * 100
}')

DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

DOCKER_STATUS=$(systemctl is-active docker)
APP_STATUS=$(docker inspect -f '{{.State.Running}}' devops-app 2>/dev/null)

echo "=========================================="
echo "Infrastructure Health Check"
echo "Timestamp: $TIMESTAMP"
echo "=========================================="
echo "CPU Usage       : ${CPU_USAGE}%"
echo "Memory Usage    : ${MEM_USAGE}%"
echo "Root Disk Usage : ${DISK_USAGE}%"
echo "Docker Status   : ${DOCKER_STATUS}"
echo "App Container   : ${APP_STATUS}"
echo "=========================================="

WARNING=false

if [ "$DISK_USAGE" -gt 85 ]; then
    echo "[WARNING] Root disk usage is ${DISK_USAGE}%" 
    WARNING=true
fi

if [ "$APP_STATUS" != "true" ]; then
    echo "[WARNING] devops-app container is not running"
    WARNING=true
fi

if [ "$DOCKER_STATUS" != "active" ]; then
    echo "[WARNING] Docker service is not active"
    WARNING=true
fi

if [ "$WARNING" = false ]; then
    echo "[OK] $TIMESTAMP - All monitored services are healthy" | sudo tee -a "$LOG_FILE" > /dev/null
else
    echo "[WARNING] $TIMESTAMP - Infrastructure health check detected an issue" | sudo tee -a "$LOG_FILE" > /dev/null
fi
