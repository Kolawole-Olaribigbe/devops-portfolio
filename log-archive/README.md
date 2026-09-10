# Log Archive Tool

A Bash-based CLI tool that archives log files into compressed `.tar.gz` files with timestamped filenames and records each successful archive operation.

## Features

* Accepts a log directory as a command-line argument
* Validates that the specified directory exists
* Creates an archive directory automatically
* Compresses logs using `tar` and gzip
* Generates timestamped archive filenames
* Records archive date and time in a log file
* Handles archive failures
* Prevents generated `.tar.gz` files from being committed to Git

## Usage

Make the script executable:

```bash
chmod +x log-archive.sh
```

Run the tool:

```bash
./log-archive.sh /var/log
```

Example output:

```text
Archive created successfully: ./archives/logs_archive_20260910_180727.tar.gz
```

## Archive Format

Archives are generated using the following naming format:

```text
logs_archive_YYYYMMDD_HHMMSS.tar.gz
```

Example:

```text
logs_archive_20260910_180727.tar.gz
```

## Archive Log

Successful archive operations are recorded in:

```text
archives/archive.log
```

Example:

```text
2026-09-10 18:07:32 - Archived /var/log to ./archives/logs_archive_20260910_180727.tar.gz
```

## Error Handling

The script checks for:

* Missing log directory argument
* Non-existent log directory
* Failed archive operations

## Technologies

* Bash
* Linux
* tar
* gzip
* CLI automation

## Project Purpose

This project demonstrates practical Linux administration and Bash scripting skills by automating a common system administration task: log archiving and management.

