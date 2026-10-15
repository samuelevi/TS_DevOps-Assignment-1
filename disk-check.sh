#!/usr/bin/env bash
set -u

LOG_DIR="$(dirname "$0")/logs"
mkdir -p "$LOG_DIR"

if [ $# -lt 1 ]; then
    echo "Usage: ./disk-check.sh <threshold> [path]" >&2
    exit 2
fi

THRESHOLD="$1"
PATH_TO_CHECK="${2:-/}"

if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
    echo "Error: Threshold must be a numeric value." >&2
    exit 2
fi

if [ "$THRESHOLD" -lt 1 ] || [ "$THRESHOLD" -gt 100 ]; then
    echo "Error: Threshold must be between 1 and 100." >&2
    exit 2
fi

if [ ! -d "$PATH_TO_CHECK" ]; then
    echo "Error: Path '$PATH_TO_CHECK' does not exist." >&2
    exit 2
fi

USAGE=$(df "$PATH_TO_CHECK" 2>/dev/null | tail -1 | awk '{print $5}' | tr -d '%')

if [ -z "$USAGE" ]; then
    echo "Error: Could not determine disk usage for '$PATH_TO_CHECK'." >&2
    exit 1
fi

echo "Disk usage for $PATH_TO_CHECK: ${USAGE}%"
echo "Threshold: ${THRESHOLD}%"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "$TIMESTAMP - disk-check executed for $PATH_TO_CHECK (usage: ${USAGE}%, threshold: ${THRESHOLD}%)" >> "$LOG_DIR/disk-check.log"

if [ "$USAGE" -ge "$THRESHOLD" ]; then
    echo "WARNING: Disk usage (${USAGE}%) has reached or exceeded threshold (${THRESHOLD}%)."
    exit 1
else
    echo "OK: Disk usage (${USAGE}%) is below threshold (${THRESHOLD}%)."
    exit 0
fi
