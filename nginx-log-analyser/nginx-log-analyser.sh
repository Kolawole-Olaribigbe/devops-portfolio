#!/bin/bash

LOG_FILE="$1"

if [ -z "$LOG_FILE" ]; then
	echo "Usage: $0 <log-file>"
	exit 1
fi

if [ ! -f "$LOG_FILE" ]; then
	echo "Error: File does not exist: $LOG_FILE"
	exit 1
fi

echo "========================================"
echo "        NGINX LOG ANALYSER"
echo "========================================"

echo "Top 5 IP addresses with the most requests:"

awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -5

echo
echo "Top 5 requested paths:"

awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -5

echo
echo "Top 5 response status codes:"

awk '$9 ~ /^[0-9]+$/ {print $9}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -5

echo 
echo "Top 5 user agents:"

awk '{
	agent=$12
	for (i=13; i<=NF; i++) agent=agent " " $i
		print agent

}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -5
