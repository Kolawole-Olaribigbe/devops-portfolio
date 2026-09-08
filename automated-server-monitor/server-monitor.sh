#!/bin/bash

CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80
STATUS=0

LOG_FILE="/var/log/server-monitor.log"

if [ "$EUID" -ne 0 ]; then
	echo "Please run the script with sudo"
	exit 1
fi

# Functions
# ----------

show_header () {
	echo "==================================================="
	echo "AUTOMATED SERVER MONITOR: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "==================================================="
}

get_cpu_usage () {
	CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | sed 's/.*, *\([0-9.]*\) id.*/\1/')
	CPU_USAGE=$(awk -v idle="$CPU_IDLE" 'BEGIN {printf "%.1f", 100 - idle}')

	printf "%-15s %s\n" "CPU Usage:" "${CPU_USAGE}%"

	if awk -v cpu="$CPU_USAGE" -v threshold="$CPU_THRESHOLD" 'BEGIN {exit !(cpu > threshold)}'; then
		echo "WARNING: CPU Usage is high!"
		logger -t server-monitor "WARNING: CPU Usage is high: ${CPU_USAGE}% (threshold: ${CPU_THRESHOLD}%)"
		STATUS=1
	fi
}

get_memory_usage () {
	MEM_TOTAL=$(free | awk '/Mem:/ {print $2}')
	MEM_USED=$(free | awk '/Mem:/ {print $3}')
	MEM_USAGE=$(awk "BEGIN {printf \"%.1f\", ($MEM_USED/$MEM_TOTAL)*100}")

	printf "%-15s %s\n" "Memory Usage:" "${MEM_USAGE}%"

	if awk -v mem="$MEM_USAGE" -v threshold="$MEMORY_THRESHOLD" 'BEGIN {exit !(mem > 80)}'; then
		echo "WARNING: Memory Usage is high"
		logger -t server-monitor "WARNING: Memory Usage is high: ${MEM_USAGE}% (threshold: ${MEMORY_THRESHOLD}%)"
		STATUS=1
	fi
}

get_disk_usage () {
	DISK_USAGE=$(df -h / | awk 'NR == 2 {print $5}')

	printf "%-15s %s\n" "Disk Usage:" "${DISK_USAGE}"

	DISK_NUMBER=${DISK_USAGE%\%}

	if [ "$DISK_NUMBER" -gt "$DISK_THRESHOLD" ]; then
		echo "WARNING: Disk Usage is high"
		logger -t server-monitor "WARNING: Disk Usage is high: ${DISK_NUMBER}% (threshold: ${DISK_THRESHOLD}%)"
		STATUS=1
	fi
}

get_load_avg () {
	LOAD_AVG=$(awk '{print $1, $2, $3}' /proc/loadavg)

	printf "%-15s %s\n" "Load Average:" "${LOAD_AVG}"
}

get_top_cpu_processes () {
	echo
	echo "Top 5 CPU Processes: "
	ps aux --sort=-%cpu | grep -v "ps aux" | head -n 6 | awk '{print $1, $2, $3, $4, $11}'
}

get_top_memory_processes () {
	echo
	echo "Top 5 Memory Processes: "
	ps aux --sort=-%mem | grep -v "ps aux"| head -n 6 | awk '{print $1, $2, $3, $4, $11}'
}

get_logged_in_users () {
	LOGGED_IN_USERS=$(who | wc -l)

	printf "%-15s %s\n" "Logged-in Users: " "$LOGGED_IN_USERS"
}

get_process_count () {
	PROCESS_COUNT=$(ps aux --no-headers | wc -l)

	printf "%-15s %s\n" "Process Count: " "$PROCESS_COUNT"
}

get_network_status () {
	IP_ADDRESS=$(ip -4 addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1)

	printf "%-15s %s\n" "IP Address: " "$IP_ADDRESS"

	if ping -c 2 google.com > /dev/null 2>&1; then
		printf "%-15s %s\n" "Connectivity: " "Online"
	else
		printf "%-15s %s\n" "Connectivity: " "Offline"
	fi

}

get_running_services () {
	echo
	echo "Important Services:"

	printf "%-15s %s\n" "SSH:" "$(systemctl is-active ssh)"
	printf "%-15s %s\n" "Docker:" "$(systemctl is-active docker)"
	printf "%-15s %s\n" "Snapd:" "$(systemctl is-active snapd)"
}


# Main
# ----------

{

	show_header

	# System information
	#printf "%-15s %s\n" "Hostname:" "$(hostname)"
	#printf "%-15s %s\n" "OS:" "$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
	#printf "%-15s %s\n" "Uptime:" "$(uptime -p)"

	# Performance Metrics
	get_cpu_usage
	get_memory_usage
	get_disk_usage
	get_load_avg
	get_top_cpu_processes
	get_top_memory_processes
	get_logged_in_users
	get_process_count
	get_network_status
	get_running_services

	if [ "$STATUS" -eq 0 ]; then
		echo "OVERALL STATUS: HEALTHY"
	else
		echo "OVERALL STATUS: WARNING"
	fi
	exit "$STATUS"
} | tee -a "$LOG_FILE"

PIPE_STATUS=${PIPESTATUS[0]}
exit $PIPE_STATUS
