#!/usr/bin/env bash
# suspend-toggle.sh
# Toggle a systemd inhibit lock that blocks suspend/sleep (incl. idle).
# First run: inhibits. Second run: releases.
# Check status with: systemd-inhibit --list

PIDFILE=/tmp/suspend-inhibit.pid

if [[ -f $PIDFILE ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    pid=$(cat "$PIDFILE")
    kill "$pid" && rm -f "$PIDFILE"
    echo "suspend inhibit released (pid $pid)"
else
    rm -f "$PIDFILE"
    setsid systemd-inhibit \
        --what=sleep:idle \
        --who="$USER" \
        --why="manual suspend-toggle" \
        --mode=block \
        sleep infinity </dev/null >/dev/null 2>&1 &
    echo $! > "$PIDFILE"
    disown
    echo "suspend inhibited (pid $(cat "$PIDFILE"))"
fi
