
#!/bin/bash

LOGFILE="process_log.txt"

while true; do
    clear
    echo "===== PROCESS MANAGER TOOL ====="
    echo "1) List all running processes"
    echo "2) Kill a process by PID"
    echo "3) Display processes by specific user"
    echo "4) Show top 5 CPU and Memory consuming processes"
    echo "5) Start logging process status every 1 minute"
    echo "6) Exit"
    echo "================================"
    read -p "Enter your choice: " choice

    case $choice in

    1)
        echo "PID   USER       %CPU   %MEM   COMMAND"
        ps aux --sort=-%cpu | awk '{printf "%-6s %-10s %-6s %-6s %s\n", $2, $1, $3, $4, $11}'
        read -p "Press ENTER to continue..."
        ;;

    2)
        read -p "Enter PID to kill: " pid
        if kill $pid 2>/dev/null; then
            echo "Process $pid terminated successfully."
        else
            echo "Failed to kill process $pid. Try using sudo."
        fi
        read -p "Press ENTER to continue..."
        ;;

    3)
        read -p "Enter username: " user
        echo "Processes for $user:"
        ps -u $user -o pid,user,%cpu,%mem,command
        read -p "Press ENTER to continue..."
        ;;

    4)
        echo "Top 5 CPU consuming processes:"
        ps aux --sort=-%cpu | head -n 6

        echo -e "\nTop 5 Memory consuming processes:"
        ps aux --sort=-%mem | head -n 6

        read -p "Press ENTER to continue..."
        ;;

    5)
        echo "Logging process status every 1 minute to $LOGFILE"
        while true; do
            echo "===== $(date) =====" >> $LOGFILE
            ps aux >> $LOGFILE
            sleep 60
        done
        ;;

    6)
        echo "Exiting..."
        exit 0
        ;;

    *)
        echo "Invalid choice. Try again."
        sleep 1
        ;;

    esac
done
