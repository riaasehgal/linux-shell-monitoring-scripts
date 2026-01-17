#!/bin/bash
# file_system_monitor_tool.sh
# Disk usage, large files, recent files, temp cleanup

disk_usage() {
    echo "=== Disk usage (df -h) ==="
    df -h
}

largest_files() {
    read -p "Enter directory to scan for largest files: " DIR
    if [[ -z "$DIR" || ! -d "$DIR" ]]; then
        echo "Invalid directory."
        return
    fi

    echo "=== Top 15 largest files in $DIR ==="
    du -ah "$DIR" 2>/dev/null | sort -rh | head -n 15
}

recent_files() {
    read -p "Enter directory to search for files modified in last 24 hours: " DIR
    if [[ -z "$DIR" || ! -d "$DIR" ]]; then
        echo "Invalid directory."
        return
    fi

    echo "=== Files modified in last 24 hours in $DIR ==="
    find "$DIR" -type f -mtime -1 -print
}

clean_temp_files() {
    read -p "Enter temporary directory (e.g., /tmp): " DIR
    read -p "Enter max allowed size in MB: " LIMIT_MB

    if [[ -z "$DIR" || ! -d "$DIR" || -z "$LIMIT_MB" ]]; then
        echo "Invalid directory or size."
        return
    fi

    current_bytes=$(du -sb "$DIR" 2>/dev/null | awk '{print $1}')
    limit_bytes=$((LIMIT_MB * 1024 * 1024))

    echo "Current size of $DIR: $current_bytes bytes"
    echo "Limit: $limit_bytes bytes ($LIMIT_MB MB)"

    if (( current_bytes > limit_bytes )); then
        echo "Size exceeds limit. Cleaning temporary files (e.g., *.tmp, *.temp) in $DIR..."
        find "$DIR" -type f \( -name '*.tmp' -o -name '*.temp' \) -print -delete
        echo "Clean-up done."
    else
        echo "Size is within limit. No clean-up needed."
    fi
}

while true; do
    echo
    echo "====== File System Monitor Tool ======"
    echo "1) Display disk usage for each mounted filesystem"
    echo "2) List the top 15 largest files in a directory"
    echo "3) Show files modified in the last 24 hours"
    echo "4) Clean temporary files if directory size exceeds a limit"
    echo "0) Exit"
    read -p "Choose an option: " CHOICE

    case "$CHOICE" in
        1) disk_usage ;;
        2) largest_files ;;
        3) recent_files ;;
        4) clean_temp_files ;;
        0) echo "Bye."; exit 0 ;;
        *) echo "Invalid option." ;;
    esac
done
