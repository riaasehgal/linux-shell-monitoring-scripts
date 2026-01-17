# System Resource Management Tools

**Authors:** Riaa Sehgal & Nada Elshami  
**Course:** Operating Systems Design & Systems Programming  
**Project:** Linux System Monitoring & Management Scripts

---

## Overview

This project consists of **five Bash-based, menu-driven tools** designed to monitor and manage core Linux system resources, including **processes, CPU usage, memory usage, file system activity, and network activity**.

Each script provides an interactive command-line interface and demonstrates practical use of Linux system utilities, `/proc` filesystem data, and administrative operations.

---

## Included Scripts

### 1. `process_manager_tool.sh`

**Purpose:** Manage and monitor running system processes.

**How to Run:**

```bash
chmod +x process_manager_tool.sh
./process_manager_tool.sh
```

**Menu Options:**

* List all running processes
* Kill a process by PID
* Display processes for a specific user
* Show top 5 CPU- and memory-consuming processes
* Enable scheduled process logging
* Exit

---

### 2. `cpu_manager_tool.sh`

**Purpose:** Monitor CPU usage and manage CPU affinity.

**How to Run:**

```bash
chmod +x cpu_manager_tool.sh
./cpu_manager_tool.sh
```

**Menu Options:**

* Display current CPU usage
* Track CPU usage over time
* Set CPU affinity for a process
* Trigger alerts when CPU usage exceeds a threshold
* Exit

---

### 3. `memory_manager_tool.sh`

**Purpose:** Monitor memory usage and respond to low-memory conditions.

**How to Run:**

```bash
chmod +x memory_manager_tool.sh
./memory_manager_tool.sh
sudo ./memory_manager_tool.sh   # Required for cache clearing
```

**Menu Options:**

* Display current memory usage
* List high-memory-consuming processes
* Clear cache and buffers (requires root privileges)
* Trigger alerts when available memory is low
* Exit

---

### 4. `file_system_monitor_tool.sh`

**Purpose:** Analyze disk usage and file system activity.

**How to Run:**

```bash
chmod +x file_system_monitor_tool.sh
./file_system_monitor_tool.sh
```

**Menu Options:**

* Display disk usage statistics
* List the top 15 largest files in a directory
* Show files modified within the last 24 hours
* Clean temporary files when storage limits are exceeded
* Exit

---

### 5. `network_monitor_tool.sh`

**Purpose:** Monitor network interfaces, bandwidth usage, and active connections.

**How to Run:**

```bash
chmod +x network_monitor_tool.sh
./network_monitor_tool.sh
```

**Menu Options:**

* Display active network interfaces and IP addresses
* Monitor bandwidth usage per interface
* Alert on active connections involving a specific IP address
* Track network traffic over time and log results
* Exit

---

## System Requirements

* Linux-based operating system
* Bash shell
* Root privileges required for:

  * Clearing memory caches
  * Certain system-level monitoring actions

---

## Running All Scripts

To make all scripts executable at once:

```bash
chmod +x *.sh
```

Run any script using:

```bash
./script_name.sh
```

---

## Skills Demonstrated

* Linux system administration
* Bash scripting
* Process and resource management
* CPU, memory, disk, and network monitoring
* Use of system utilities (`ps`, `df`, `free`, `ip`, `ss`, `/proc`)
* Menu-driven CLI application design

---

## Notes

Log files generated during execution (e.g., `.log` files) are intentionally excluded from version control using `.gitignore`, following best practices.
