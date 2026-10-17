#!/usr/bin/env bash

set -u

LOGDIR="$(dirname "$0")/logs"
mkdir -p "$LOGDIR"

echo "=== System Information ==="
echo ""
echo "Hostname: $(hostname)"
echo "Current User: $(whoami)"
echo "Date/Time: $(date)"
echo "Operating System: $(uname -o 2>/dev/null || uname -s)"
echo "Kernel Version: $(uname -r)"
echo "Uptime: $(uptime -p 2>/dev/null || uptime)"

echo ""
echo "=== CPU Information ==="


if [ -f /proc/cpuinfo ]; then
    grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //'
    echo "CPU Cores: $(grep -c '^processor' /proc/cpuinfo)"
else
    echo "CPU info not available"
fi

echo ""
echo "==== Memory Information ===="
if command -v free >/dev/null 2>&1; then
    free -h
else
    echo "Memory info not available"
fi

echo ""
echo "Current Working Directory: $(pwd)"

ts=$(date '+%Y-%m-%d %H:%M:%S')
echo "$ts - system-info executed" >> "$LOGDIR/system-info.log"
