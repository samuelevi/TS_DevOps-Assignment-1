## Assignment 1 - Linux Diagnostic Toolkit

A set of bash scripts that pull system info, check disk usage, and run basic network diagnostics. Written for Linux but should mostly work in WSL too.

## Getting started

Clone the repo and make the scripts executable:

```bash
git clone <repository-url>
cd assignment-1
chmod +x system-info.sh disk-check.sh network-check.sh grade.sh
```

The `logs/` folder is created automatically the first time any script runs.


### system-info.sh

Prints out some general info about the machine -- hostname, who's logged in, the date, OS/kernel details, uptime, CPU, memory, and the present working directory.

```bash
./system-info.sh
```

### disk-check.sh

Checks whether disk usage is over a certain threshold (between 1 and 100). You can optionally give it a path to check, otherwise it defaults.

```bash
./disk-check.sh 80           

./disk-check.sh 90 /home     ```

Exit codes:
- `0` -- usage is under the threshold
- `1` -- usage is at or above the threshold
- `2` -- something was wrong with the input

### network-check.sh

Does a DNS lookup, pings the host, and lists network interfaces. You can also pass a port number to test a TCP connection.

```bash
./network-check.sh google.com
./network-check.sh 192.168.1.1 22 
```

Port has to be between 1 and 65535, exits with `2` if it's not.

## Running the grader

There's a grading script that verifies everything works:

```bash
./grade.sh
```

It checks file existence, syntax, permissions, output content, input validation, logging, and git history.

## Logging

Every script appends a timestamped line to its own log file under `logs/` each time it runs.

## Notes

- This is built for Linux -- things like `free`, `ip`, and `/proc/cpuinfo` won't be available on macOS without changes
- For DNS resolution it tries `getent` first, then `dig`, then `nslookup` depending on what's installed
- The TCP port check uses bash's `/dev/tcp` trick, or falls back to `nc` if that's not available
- No hardcoded values that tie it to a specific machine
