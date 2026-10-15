#!/usr/bin/env bash
set -u

LOG_DIR="$(dirname "$0")/logs"
mkdir -p "$LOG_DIR"

if [ $# -lt 1 ]; then
    echo "Usage: ./network-check.sh <hostname-or-ip> [port]" >&2
    exit 2
fi

HOST="$1"
PORT="${2:-}"

if [ -z "$HOST" ]; then
    echo "Error: Hostname or IP address is required." >&2
    exit 2
fi

echo "=== Network Check for $HOST ==="
echo ""

echo "--- Host Resolution ---"
if command -v getent >/dev/null 2>&1; then
    RESOLVED=$(getent hosts "$HOST" 2>/dev/null | awk '{print $1}')
elif command -v dig >/dev/null 2>&1; then
    RESOLVED=$(dig +short "$HOST" 2>/dev/null | head -1)
elif command -v nslookup >/dev/null 2>&1; then
    RESOLVED=$(nslookup "$HOST" 2>/dev/null | awk '/^Address: / { print $2 }' | tail -1)
else
    RESOLVED=""
fi

if [ -n "$RESOLVED" ]; then
    echo "Resolved address: $RESOLVED"
else
    echo "Could not resolve host: $HOST"
fi
echo ""

echo "--- Connectivity Check ---"
if command -v ping >/dev/null 2>&1; then
    if ping -c 2 -W 3 "$HOST" >/dev/null 2>&1; then
        echo "Ping to $HOST: SUCCESS"
    else
        echo "Ping to $HOST: FAILED"
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

if [ -n "$PORT" ]; then
    if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
        echo "Error: Port must be a numeric value." >&2
        exit 2
    fi

    if [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
        echo "Error: Port must be between 1 and 65535." >&2
        exit 2
    fi

    echo "--- TCP Port Check ($HOST:$PORT) ---"
    if command -v bash >/dev/null 2>&1; then
        if (echo >/dev/tcp/"$HOST"/"$PORT") 2>/dev/null; then
            echo "TCP connection to $HOST:$PORT: SUCCESS"
        else
            echo "TCP connection to $HOST:$PORT: FAILED"
        fi
    elif command -v nc >/dev/null 2>&1; then
        if nc -z -w 3 "$HOST" "$PORT" 2>/dev/null; then
            echo "TCP connection to $HOST:$PORT: SUCCESS"
        else
            echo "TCP connection to $HOST:$PORT: FAILED"
        fi
    else
        echo "No TCP check tool available"
    fi
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "$TIMESTAMP - network-check executed for $HOST${PORT:+ port $PORT}" >> "$LOG_DIR/network-check.log"

exit 0
