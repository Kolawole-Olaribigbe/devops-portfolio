#!/bin/bash

LOG_DIR="$1"
ARCHIVE_DIR="./archives"

if [ -z "$LOG_DIR" ]; then
	echo "Usage: $0 <log-directory>"
	exit 1
fi

if [ ! -d "$LOG_DIR" ]; then
	echo "Error: Directory does not exist: $LOG_DIR"
       exit 1
fi

mkdir -p "$ARCHIVE_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_FILE="$ARCHIVE_DIR/logs_archive_${TIMESTAMP}.tar.gz"

if sudo tar -czf "$ARCHIVE_FILE" -C "$LOG_DIR" .; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Archived $LOG_DIR to $ARCHIVE_FILE" >> "$ARCHIVE_DIR/archive.log"
        echo "Archive created successfully: $ARCHIVE_FILE"
else
        echo "Error: Failed to create archive."
        exit 1
fi
