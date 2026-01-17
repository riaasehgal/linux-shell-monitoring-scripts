
#!/bin/bash

LOGFILE="cpu_usage.log"
THRESHOLD=90

# Function: Get current CPU usage %
get_cpu_usage() {
    # Using /proc/stat method
    CPU=(`grep '^cpu ' /proc/stat`)
    IDLE=${CPU[4]}
    TOTAL=0
    for VALUE in "${CPU[@]:1}"; do
        TOTAL=$((TOTAL+VALUE))
    done
    sleep 1
    CPU2=(`grep '^cpu ' /proc/stat`)
    IDLE2=${CPU2[4]}
    TOTAL2=0
    for VALUE in "${CPU2[@]:1}"; do
        TOTAL2=$((TOTAL2+VALUE))
    done
    DIFF_IDLE=$((IDLE2-IDLE))
    DIFF_TOTAL=$((TOTAL2-TOTAL))
    CPU_USAGE=$((100*(DIFF_TOTAL-DIFF_IDLE)/DIFF_TOTAL))
    echo $CPU_USAGE
}

# Option 1: Display CPU Usage Now
display_cpu() {
    usage=$(get_cpu_usage)
    echo "Current CPU Usage: $usage%"
}

# Option 2: Log CPU Usage Over Time
log_cpu_usage() {
    echo "How many times should I log?"
    read COUNT
    echo "Logging CPU usage to $LOGFILE..."
    for ((i=1;i<=COUNT;i++)); do
        usage=$(get_cpu_usage)
        echo "$(date +%T), CPU: $usage%" >> $LOGFILE
        echo "Logged: $usage%"
        sleep 1
    done
    echo "Done. Log saved to $LOGFILE"
}

# Option 3: Set CPU Affinity
set_affinity() {
    echo -n "Enter Process ID (PID): "
    read PID
    echo -n "Enter CPU core(s) to assign (e.g., 0 or 0,1): "
    read CORES
    taskset -cp $CORES $PID
}

# Option 4: Alert if usage > threshold
cpu_alert() {
    usage=$(get_cpu_usage)
    echo "Current Usage: $usage%"
    if (( usage > THRESHOLD )); then
        echo "⚠ ALERT: CPU usage $usage% exceeded threshold $THRESHOLD%!"
    else
        echo "CPU usage is stable."
    fi
}

# Menu Loop
while true; do
    echo ""
    echo "===== CPU Manager Tool ====="
    echo "1) Display current CPU usage"
    echo "2) Log CPU usage over time"
    echo "3) Set CPU affinity for a process"
    echo "4) Check & alert if CPU usage exceeds threshold ($THRESHOLD%)"
    echo "5) Exit"
    echo -n "Choose an option: "
    read CHOICE

    case $CHOICE in
        1) display_cpu ;;
        2) log_cpu_usage ;;
        3) set_affinity ;;
        4) cpu_alert ;;
        5) exit 0 ;;
        *) echo "Invalid option. Try again." ;;
    esac
done
