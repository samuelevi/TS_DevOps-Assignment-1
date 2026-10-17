#!/usr/bin/env bash

set -u

LOGDIR="$(dirname "$0")/logs"
mkdir -p "$LOGDIR"

if [ $# -lt 1 ]; then
    echo "Usage: ./network-check.sh <hostname-or-ip> [port]" >&2
    exit 2
fi

host="$1"
port="${2:-}"

if [ -z "$host" ]; then
    echo "Error: Hostname or IP address is required." >&2
    exit 2
fi

echo "=== Network Check for $host ==="
echo ""


echo "--- Host Resolution ---"
resolved=""
if command -v getent >/dev/null 2>&1; then
    resolved=$(getent hosts "$host" 2>/dev/null | awk '{print $1}')
elif command -v dig >/dev/null 2>&1; then
    resolved=$(dig +short "$host" 2>/dev/null | head -1)
elif command -v nslookup >/dev/null 2>&1; then
    resolved=$(nslookup "$host" 2>/dev/null | awk '/^Address: / { print $2 }' | tail -1)
fi

if [ -n "$resolved" ]; then
    echo "Resolved address: $resolved"
else
    echo "Could not resolve host: $host"
fi
echo ""


echo "--- Connectivity Check ---"
if command -v ping >/dev/null 2>&1; then
    if ping -c 2 -W 3 "$host" >/dev/null 2>&1; then
        echo "Ping to $host: SUCCESS"
    else
        echo "Ping to $host: FAILED"
    fi
else
    echo "ping command not available"
fi
echo ""


echo "--- Network Interfaces ---"
if command -v ip >/dev/null 2>&1; then
    ip -brief addr show 2>/dev/null
elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig 2>/dev/null
else
    echo "No network interface tool available"
fi
echo ""


if [ -n "$port" ]; then
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo "Error: Port must be a numeric value." >&2
        exit 2
    fi

    if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo "Error: Port must be between 1 and 65535." >&2
        exit 2
    fi

    echo "--- TCP Port Check ($host:$port) ---"
    
    if command -v bash >/dev/null 2>&1; then
        if (echo >/dev/tcp/"$host"/"$port") 2>/dev/null; then
            echo "TCP connection to $host:$port: SUCCESS"
        else
            echo "TCP connection to $host:$port: FAILED"
        fi
    elif command -v nc >/dev/null 2>&1; then
        if nc -z -w 3 "$host" "$port" 2>/dev/null; then
            echo "TCP connection to $host:$port: SUCCESS"
        else
            echo "TCP connection to $host:$port: FAILED"
        fi
    else
        echo "No TCP check tool available"
    fi
fi

ts=$(date '+%Y-%m-%d %H:%M:%S')
echo "$ts - network-check executed for $host${port:+ port $port}" >> "$LOGDIR/network-check.log"

exit 0
