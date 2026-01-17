#!/bin/bash
# memory_manager_tool.sh
# Memory monitoring + alerts + cache clearing

LOG_FILE="memory_alerts.log"

show_memory_usage() {
    echo "=== Current memory usage (free -m) ==="
    free -m
}

list_high_memory_processes() {
    read -p "Show processes using more than how many MB? " THRESHOLD
    if [[ -z "$THRESHOLD" ]]; then
        echo "No threshold entered."
        return
    fi

    echo "=== Processes using more than ${THRESHOLD}MB of RAM ==="
    # RSS is in KB (column 6 in ps aux)
    ps aux | awk -v th="$THRESHOLD" '
        NR==1 {
            print $0; next
        }
        {
            mem_mb = $6 / 1024;
            if (mem_mb > th) print $0
        }'
}

clear_caches() {
    echo "This action clears filesystem caches and needs root privileges."
    if [[ $EUID -ne 0 ]]; then
        echo "Please run this script as root (or with sudo) for this option."
        return
    fi

    echo "Syncing and dropping caches..."
    sync
    echo 3 > /proc/sys/vm/drop_caches
    echo "Caches cleared."
}

memory_alert() {
    read -p "Low memory threshold in MB (default 100): " THRESHOLD
    if [[ -z "$THRESHOLD" ]]; then
        THRESHOLD=100
    fi

    echo "Alert will trigger if available memory < ${THRESHOLD}MB."
    echo "Press Ctrl + C to stop."

    while true; do
        avail_kb=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        avail_mb=$((avail_kb / 1024))

        if (( avail_mb < THRESHOLD )); then
            msg="[$(date)] ALERT: Low memory! Available: ${avail_mb}MB"
            echo "$msg"
            echo "$msg" >> "$LOG_FILE"
        else
            echo "[$(date)] Available memory: ${avail_mb}MB"
        fi

        sleep 5
    done
}

while true; do
    echo
    echo "====== Memory Manager Tool ======"
    echo "1) Display current memory usage"
    echo "2) List processes above a memory threshold"
    echo "3) Clear cache and buffers (requires root)"
    echo "4) Alert on low available memory"
    echo "0) Exit"
    read -p "Choose an option: " CHOICE

    case "$CHOICE" in
        1) show_memory_usage ;;
        2) list_high_memory_processes ;;
        3) clear_caches ;;
        4) memory_alert ;;
        0) echo "Bye."; exit 0 ;;
        *) echo "Invalid option." ;;
    esac
done
