# Automated Server Monitor

A Bash-based server monitoring system that automatically checks CPU, memory, disk usage, system load, processes, users, network connectivity, and important services.

The system uses systemd to run automatically every 5 minutes, logs monitoring results, and sends warning messages to the system journal when resource thresholds are exceeded.

## Features

- CPU, memory, and disk monitoring
- System load monitoring
- Top CPU and memory processes
- Logged-in users and process count
- Network connectivity checks
- Important service checks
- Configurable thresholds
- Warning alerts through journald
- Dedicated monitoring log
- Exit codes for automation
- Automated execution with systemd timer

## Architecture

systemd timer → server-monitor.service → server-monitor.sh → health checks → logging and alerts

## Configuration

The default thresholds are:

- CPU: 80%
- Memory: 80%
- Disk: 80%

Log file:

`/var/log/server-monitor.log`

## Running Manually

```bash
sudo ./server-monitor.sh

Check the exit code:

```bash
echo $?

Exit codes:

0 = Healthy
1 = Warning
Logging

View monitoring results:

sudo tail -f /var/log/server-monitor.log

View warning alerts:

sudo journalctl -t server-monitor
Systemd Service

Service:

/etc/systemd/system/server-monitor.service

Start manually:

sudo systemctl start server-monitor.service

Check status:

systemctl status server-monitor.service --no-pager

View service logs:

sudo journalctl -u server-monitor.service
Systemd Timer

Timer:

/etc/systemd/system/server-monitor.timer

Check the timer:

systemctl status server-monitor.timer --no-pager

List timers:

systemctl list-timers --all

The monitor runs automatically every 5 minutes.

Technologies
Bash
Linux
systemd
systemd timers
journald
Linux command-line utilities
Project Structure
automated-server-monitor/
├── serveronitor.sh
sudo systemctl start server-monitor.service
Check status:

systemctl status server-monitor.service --no-pager
View service logs:

sudo journalctl -u server-monitor.service
Systemd Timer

Timer:

/etc/systemd/system/server-monitor.timer

Check the timer:

systemctl status server-monitor.timer --no-pager

List timers:

systemctl list-timers --all

The monitor runs automatically every 5 minutes.

Technologies
Bash
Linux
systemd
systemd timers
journald
Linux command-line utilities
Project Structure
automated-server-monitor/
├── server-monitor.sh
└── README.md
