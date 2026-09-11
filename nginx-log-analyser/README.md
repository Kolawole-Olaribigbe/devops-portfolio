# Nginx Log Analyser

A beginner-friendly Bash script that analyzes Nginx access logs from the command line and displays the most common IP addresses, requested paths, HTTP response status codes, and user agents.

## Project Objectives

The goal of this project is to practice Bash scripting and command-line tools by analyzing an Nginx access log.

The script analyzes the log and displays:

* Top 5 IP addresses with the most requests
* Top 5 requested paths
* Top 5 HTTP response status codes
* Top 5 user agents

## Technologies Used

* Bash
* Linux command line
* `awk`
* `sort`
* `uniq`
* `head`

## How It Works

The script accepts an Nginx access log file as a command-line argument and processes the log using standard Linux command-line tools.

The analysis works by:

1. Extracting specific fields from the log using `awk`
2. Sorting the extracted data with `sort`
3. Counting duplicate entries using `uniq`
4. Sorting the results by frequency
5. Displaying the top 5 results using `head`

The script also validates that a log file was provided and that the specified file exists before performing the analysis.

## Usage

Make the script executable:

```bash
chmod +x nginx-log-analyser.sh
```

Run the script by providing the Nginx access log file:

```bash
./nginx-log-analyser.sh nginx-access.log
```

The script will analyze the log and display the top 5 results for each category.

## Example Output

```text
========================================
        NGINX LOG ANALYSER
========================================

Top 5 IP addresses with the most requests:
   1087 178.128.94.113
   1087 142.93.136.176
   1087 138.68.248.85
   1086 159.89.185.30
    277 86.134.118.70

Top 5 requested paths:
   4560 /v1-health
    270 /
    232 /v1-me
    127 /v1-list-workspaces
     75 /v1-list-timezone-teams

Top 5 response status codes:
   5740 200
    937 404
    621 304
    192 400
     30 166

Top 5 user agents:
   4347 "DigitalOcean Uptime Probe 0.22.0 (https://digitalocean.com)"
    513 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36"
    332 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36"
    294 "Custom-AsyncHttpClient"
    282 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
```

## Error Handling

The script checks for common input errors before processing the log.

### Missing log file

If no log file is provided:

```bash
./nginx-log-analyser.sh
```

The script displays:

```text
Usage: ./nginx-log-analyser.sh <log-file>
```

### File does not exist

If the specified log file cannot be found:

```bash
./nginx-log-analyser.sh does-not-exist.log
```

The script displays:

```text
Error: File does not exist: does-not-exist.log
```

## What I Learned

Through this project, I practiced:

* Writing Bash scripts with command-line arguments
* Validating user input and files
* Using `awk` to extract fields from structured log data
* Using `sort`, `uniq`, and `head` to analyze and summarize data
* Working with Nginx access log formats
* Handling user-agent strings containing spaces
* Building simple command-line automation tools
* Testing Bash scripts with valid and invalid inputs

