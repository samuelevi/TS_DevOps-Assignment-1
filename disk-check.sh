#!/usr/bin/env bash
# checks disk usage against a given threshold percentage
set -u

LOGDIR="$(dirname "$0")/logs"
mkdir -p "$LOGDIR"

# need at least a threshold argument
if [ $# -lt 1 ]; then
    echo "Usage: ./disk-check.sh <threshold> [path]" >&2
    exit 2
fi

threshold="$1"
target="${2:-/}"

# validate that threshold is actually a number
if ! [[ "$threshold" =~ ^[0-9]+$ ]]; then
    echo "Error: Threshold must be a numeric value." >&2
    exit 2
fi

if [ "$threshold" -lt 1 ] || [ "$threshold" -gt 100 ]; then
    echo "Error: Threshold must be between 1 and 100." >&2
    exit 2
fi

if [ ! -d "$target" ]; then
    echo "Error: Path '$target' does not exist." >&2
    exit 2
fi

# grab the usage % from df, strip the trailing % sign
usage=$(df "$target" 2>/dev/null | tail -1 | awk '{print $5}' | tr -d '%')

if [ -z "$usage" ]; then
    echo "Error: Could not determine disk usage for '$target'." >&2
    exit 1
fi

echo "Disk usage for $target: ${usage}%"
echo "Threshold: ${threshold}%"

ts=$(date '+%Y-%m-%d %H:%M:%S')
echo "$ts - disk-check executed for $target (usage: ${usage}%, threshold: ${threshold}%)" >> "$LOGDIR/disk-check.log"

if [ "$usage" -ge "$threshold" ]; then
    echo "WARNING: Disk usage (${usage}%) has reached or exceeded threshold (${threshold}%)."
    exit 1
else
    echo "OK: Disk usage (${usage}%) is below threshold (${threshold}%)."
    exit 0
fi
