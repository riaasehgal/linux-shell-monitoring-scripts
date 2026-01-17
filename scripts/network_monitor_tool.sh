#!/bin/bash
# network_monitor_tool.sh
# Manage and monitor network activity

LOG_FILE="network_traffic.log"

show_interfaces() {
    echo "=== Active network interfaces and IP addresses ==="
    if command -v ip >/dev/null 2>&1; then
        # Brief format, only UP interfaces
        ip -br addr show up
    else
        # Fallback to ifconfig if 'ip' is not available
        ifconfig | awk '
            /^[a-zA-Z0-9]/ {iface=$1}
            /inet / {print iface, $2}
        '
    fi
}

bandwidth_usage() {
    read -p "Enter sampling interval in seconds (default: 1): " INTERVAL
    if [[ -z "$INTERVAL" ]]; then
        INTERVAL=1
    fi

    echo "Measuring RX/TX for each interface over ${INTERVAL}s..."
    echo

    for IFACE in $(ls /sys/class/net); do
        # Skip loopback
        if [[ "$IFACE" == "lo" ]]; then
            continue
        fi

        RX1=$(cat /sys/class/net/"$IFACE"/statistics/rx_bytes 2>/dev/null)
        TX1=$(cat /sys/class/net/"$IFACE"/statistics/tx_bytes 2>/dev/null)

        # If stats not available, skip
        if [[ -z "$RX1" || -z "$TX1" ]]; then
            continue
        fi

        sleep "$INTERVAL"

        RX2=$(cat /sys/class/net/"$IFACE"/statistics/rx_bytes 2>/dev/null)
        TX2=$(cat /sys/class/net/"$IFACE"/statistics/tx_bytes 2>/dev/null)

        RX_RATE=$(( (RX2 - RX1) / INTERVAL ))
        TX_RATE=$(( (TX2 - TX1) / INTERVAL ))

        RX_KB=$(( RX_RATE / 1024 ))
        TX_KB=$(( TX_RATE / 1024 ))

        echo "Interface: $IFACE"
        echo "  RX: ${RX_KB} KB/s"
        echo "  TX: ${TX_KB} KB/s"
        echo
    done
}

monitor_ip_connection() {
    read -p "Enter IP address to monitor for connections: " TARGET_IP
    if [[ -z "$TARGET_IP" ]]; then
        echo "No IP entered."
        return
    fi

    read -p "Polling interval in seconds (default: 5): " INTERVAL
    if [[ -z "$INTERVAL" ]]; then
        INTERVAL=5
    fi

    echo "Monitoring active connections for IP: $TARGET_IP"
    echo "Press Ctrl + C to stop."

    while true; do
        if command -v ss >/dev/null 2>&1; then
            if ss -nt 2>/dev/null | grep -q "$TARGET_IP"; then
                echo "[$(date)] ALERT: Connection involving $TARGET_IP detected!"
            else
                echo "[$(date)] No active TCP connection with $TARGET_IP."
            fi
        else
            if netstat -nt 2>/dev/null | grep -q "$TARGET_IP"; then
                echo "[$(date)] ALERT: Connection involving $TARGET_IP detected!"
            else
                echo "[$(date)] No active TCP connection with $TARGET_IP."
            fi
        fi

        sleep "$INTERVAL"
    done
}

track_traffic_over_time() {
    read -p "Enter interface to monitor (e.g., eth0, ens33, wlan0): " IFACE
    if [[ -z "$IFACE" || ! -d "/sys/class/net/$IFACE" ]]; then
        echo "Invalid interface."
        return
    fi

    read -p "Enter total duration in seconds: " DURATION
    if [[ -z "$DURATION" || "$DURATION" -le 0 ]]; then
        echo "Invalid duration."
        return
    fi

    read -p "Enter sampling interval in seconds (default: 1): " INTERVAL
    if [[ -z "$INTERVAL" ]]; then
        INTERVAL=1
    fi

    read -p "Enter log file path (default: $LOG_FILE): " CUSTOM_LOG
    if [[ -n "$CUSTOM_LOG" ]]; then
        LOG_FILE="$CUSTOM_LOG"
    fi

    echo "Tracking traffic on interface $IFACE for $DURATION seconds..."
    echo "Logging to: $LOG_FILE"
    echo "timestamp,iface,rx_bytes,tx_bytes,rx_Bps,tx_Bps" >> "$LOG_FILE"

    RX_PREV=$(cat /sys/class/net/"$IFACE"/statistics/rx_bytes 2>/dev/null)
    TX_PREV=$(cat /sys/class/net/"$IFACE"/statistics/tx_bytes 2>/dev/null)
  
TIME_PREV=$SECONDS

    END_TIME=$((SECONDS + DURATION))

    while [[ $SECONDS -lt $END_TIME ]]; do
        sleep "$INTERVAL"

        RX_NOW=$(cat /sys/class/net/"$IFACE"/statistics/rx_bytes 2>/dev/null)
        TX_NOW=$(cat /sys/class/net/"$IFACE"/statistics/tx_bytes 2>/dev/null)
        TIME_NOW=$SECONDS

        DIFF_TIME=$((TIME_NOW - TIME_PREV))
        if (( DIFF_TIME <= 0 )); then
            continue
        fi

        RX_RATE=$(( (RX_NOW - RX_PREV) / DIFF_TIME ))
        TX_RATE=$(( (TX_NOW - TX_PREV) / DIFF_TIME ))

        TS=$(date +'%Y-%m-%d %H:%M:%S')
        echo "$TS,$IFACE,$RX_NOW,$TX_NOW,$RX_RATE,$TX_RATE" >> "$LOG_FILE"
        echo "[$TS] $IFACE RX: ${RX_RATE} B/s, TX: ${TX_RATE} B/s"

        RX_PREV=$RX_NOW
        TX_PREV=$TX_NOW
        TIME_PREV=$TIME_NOW
    done

    echo "Traffic tracking complete."
}

while true; do
    echo
    echo "====== Network Monitor Tool ======"
    echo "1) Display IP addresses and status of active network interfaces"
    echo "2) Show bandwidth usage for each interface (sampled)"
    echo "3) Monitor network connections and alert if a specific IP connects"
    echo "4) Track network traffic over time and log data"
    echo "0) Exit"
    read -p "Choose an option: " CHOICE

    case "$CHOICE" in
        1) show_interfaces ;;
        2) bandwidth_usage ;;
        3) monitor_ip_connection ;;
        4) track_traffic_over_time ;;
        0) echo "Bye."; exit 0 ;;
        *) echo "Invalid option." ;;
    esac
done
