# Assignment 1 - Linux Diagnostic Toolkit

Bash scripts for gathering system info, checking disk usage, and running basic network diagnostics on a Linux machine.

## Setup

Clone the repo and make the scripts executable:

```bash
git clone <repository-url>
cd assignment-1
chmod +x system-info.sh disk-check.sh network-check.sh grade.sh
```

The `logs/` directory gets created automatically when any script runs.

## Usage

### system-info.sh

Prints hostname, current user, date/time, OS, kernel version, uptime, CPU and memory info, and the current working directory.

```bash
./system-info.sh
```

### disk-check.sh

Checks if disk usage is above a given threshold. The threshold must be between 1 and 100. You can optionally pass a path (defaults to `/`).

```bash
./disk-check.sh 80           # check root filesystem at 80%
./disk-check.sh 90 /home     # check /home at 90%
```

- Exits `0` if usage is below the threshold
- Exits `1` if usage is at or above the threshold
- Exits `2` for bad input (non-numeric, out of range, path doesn't exist)

### network-check.sh

Runs DNS resolution, a ping check, and lists network interfaces for a host. Optionally checks a TCP port.

```bash
./network-check.sh google.com
./network-check.sh 192.168.1.1 22    # also test port 22
```

- Port must be between 1 and 65535
- Exits `2` for invalid input

## Testing

Run the grader to check everything works:

```bash
./grade.sh
```

This checks that all files exist, scripts have valid syntax and are executable, outputs contain the right info, bad inputs are rejected properly, logs are being created, and git history meets the requirements.

## Logging

Each script writes a timestamped entry to a log file under `logs/` (e.g. `logs/disk-check.log`).

## Assumptions

- Designed for Linux -- commands like `free`, `ip`, and `/proc/cpuinfo` might not work on macOS or Windows without WSL
- Standard utilities (`hostname`, `whoami`, `date`, `uname`, `df`, `ping`) are available
- DNS resolution tries `getent`, then `dig`, then `nslookup` depending on what's installed
- TCP port check uses bash `/dev/tcp` or falls back to `nc`
- No hardcoded machine-specific values
