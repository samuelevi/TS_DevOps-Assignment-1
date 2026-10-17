#!/usr/bin/env bash
# simple grading script that checks if everything is set up right
set -u

passed=0
failed=0

pass() { echo "PASS: $1"; passed=$((passed+1)); }
fail() { echo "FAIL: $1"; failed=$((failed+1)); }

echo "======================================"
echo " Assignment 1 - Local Grader"
echo " Linux / Bash / Networking / Git"
echo "======================================"
echo

# check that all the required files are there
for f in README.md system-info.sh disk-check.sh network-check.sh; do
    [[ -f "$f" ]] && pass "Required file exists: $f" || fail "Missing required file: $f"
done

mkdir -p logs

# syntax check each script
for f in system-info.sh disk-check.sh network-check.sh; do
    if [[ -f "$f" ]]; then
        bash -n "$f" >/dev/null 2>&1 && pass "Bash syntax: $f" || fail "Bash syntax error: $f"
    fi
done

# make sure they're all executable
for f in system-info.sh disk-check.sh network-check.sh; do
    if [[ -f "$f" && -x "$f" ]]; then
        pass "Executable: $f"
    else
        fail "Not executable: $f"
    fi
done

# --- system-info tests ---
if [[ -x ./system-info.sh ]]; then
    output=$(./system-info.sh 2>&1)
    rc=$?

    [[ $rc -eq 0 ]] && pass "system-info.sh exits successfully" || fail "system-info.sh exit code is $rc"

    for term in "hostname" "user" "kernel" "uptime"; do
        echo "$output" | grep -qi "$term" && \
            pass "system-info.sh contains '$term' information" || \
            fail "system-info.sh does not appear to contain '$term' information"
    done
fi

# --- disk-check tests ---
if [[ -x ./disk-check.sh ]]; then
    # bad inputs should all give exit code 2
    ./disk-check.sh 0 >/dev/null 2>&1
    [[ $? -eq 2 ]] && pass "disk-check rejects threshold 0 with exit code 2" || fail "disk-check should reject threshold 0 with exit code 2"

    ./disk-check.sh 101 >/dev/null 2>&1
    [[ $? -eq 2 ]] && pass "disk-check rejects threshold 101 with exit code 2" || fail "disk-check should reject threshold 101 with exit code 2"

    ./disk-check.sh abc >/dev/null 2>&1
    [[ $? -eq 2 ]] && pass "disk-check rejects non-numeric threshold" || fail "disk-check should reject non-numeric threshold"

    # valid input should work (exit 0 or 1 depending on actual usage)
    ./disk-check.sh 100 / >/dev/null 2>&1
    [[ $? -eq 0 || $? -eq 1 ]] && pass "disk-check accepts valid threshold/path" || fail "disk-check failed"
fi

# --- network-check tests ---
if [[ -x ./network-check.sh ]]; then
    ./network-check.sh localhost >/dev/null 2>&1
    [[ $rc -eq 0 || $rc -eq 1 ]] && pass "network-check accepts localhost" || fail "network-check failed localhost test unexpectedly"

    # port validation
    ./network-check.sh localhost 0 >/dev/null 2>&1
    [[ $? -eq 2 ]] && pass "network-check rejects port 0" || fail "network-check should reject port 0 with exit code 2"

    ./network-check.sh localhost 65536 >/dev/null 2>&1
    [[ $? -eq 2 ]] && pass "network-check rejects port 65536" || fail "network-check should reject port 65536 with exit code 2"

    ./network-check.sh localhost abc >/dev/null 2>&1
    [[ $? -eq 2 ]] && pass "network-check rejects non-numeric port" || fail "network-check should reject non-numeric port"
fi

# check that at least one log file got created
if find logs -type f -not -name '.gitkeep' -print -quit 2>/dev/null | grep -q .; then
    pass "Log file was created"
else
    fail "No log file found under logs/"
fi

# git history checks
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    commits=$(git rev-list --count HEAD 2>/dev/null || echo 0)
    [[ "$commits" -ge 5 ]] && pass "Git has at least 5 commits" || fail "Git has fewer than 5 commits"

    branches=$(git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null | grep -vE '^(main|master)$' | wc -l | tr -d ' ')
    [[ "$branches" -ge 1 ]] && pass "At least one non-main local branch exists" || echo "WARN: no local feature branch found; inspect Git history manually"
else
    echo "WARN: Git repository checks skipped"
fi

echo
echo "======================================"
echo "Passed: $passed"
echo "Failed: $failed"
echo "======================================"

[[ $failed -eq 0 ]]
