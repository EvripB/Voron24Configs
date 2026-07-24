#!/bin/bash
set -u

OUTDIR="/home/pi/disconnect_debug"
TS="$(date +%Y-%m-%d_%H-%M-%S)"
HOST="$(hostname)"
OUTFILE="$OUTDIR/disconnect_debug_${HOST}_${TS}.log"

mkdir -p "$OUTDIR"

exec > >(tee -a "$OUTFILE") 2>&1

echo "=================================================="
echo "Moonraker disconnect debug snapshot"
echo "Timestamp: $(date)"
echo "Host: $HOST"
echo "=================================================="
echo

run_section() {
    local title="$1"
    shift
    echo
    echo "##################################################"
    echo "# $title"
    echo "##################################################"
    "$@" || echo "[command failed with exit code $?]"
    echo
}

echo "Collecting recent history, not just current state."
echo "Output file: $OUTFILE"
echo

run_section "UPTIME" uptime
run_section "DATE" date
run_section "LAST BOOT" who -b
run_section "DISK SPACE" df -h
run_section "MEMORY" free -h
run_section "TOP CPU SNAPSHOT" sh -c 'ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 25'
run_section "TOP MEMORY SNAPSHOT" sh -c 'ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 25'
run_section "LOAD / VMSTAT" vmstat 1 5

run_section "IP ADDRESSES" ip addr
run_section "ROUTES" ip route
run_section "WIFI LINK" iw dev wlan0 link
run_section "WIFI POWER SAVE" iw dev wlan0 get power_save
run_section "WIRELESS INFO" iwconfig wlan0
run_section "NETWORKMANAGER DEVICE STATUS" nmcli device status
run_section "NETWORKMANAGER ACTIVE CONNECTIONS" nmcli connection show --active
run_section "NETWORKMANAGER WLAN DETAILS" nmcli -f GENERAL,IP4,WIFI-PROPERTIES,AP dev show wlan0

run_section "PING GATEWAY (20 pings)" sh -c '
GW="$(ip route | awk "/default/ {print \$3; exit}")"
echo "Gateway: ${GW:-not found}"
if [ -n "${GW:-}" ]; then
    ping -c 20 -W 2 "$GW"
else
    echo "No default gateway found"
fi
'

run_section "PING 8.8.8.8 (20 pings)" ping -c 20 -W 2 8.8.8.8

run_section "MOONRAKER SERVICE STATUS" systemctl status moonraker --no-pager -l
run_section "KLIPPER SERVICE STATUS" systemctl status klipper --no-pager -l
run_section "WIFI WATCHDOG SERVICE STATUS" systemctl status wifi_watchdog.service --no-pager -l
run_section "WIFI WATCHDOG TIMER STATUS" systemctl status wifi_watchdog.timer --no-pager -l

run_section "MOONRAKER JOURNAL - LAST 15 MINUTES" journalctl -u moonraker --since "-15 min" --no-pager -o short-iso
run_section "KLIPPER JOURNAL - LAST 15 MINUTES" journalctl -u klipper --since "-15 min" --no-pager -o short-iso
run_section "NETWORKMANAGER JOURNAL - LAST 15 MINUTES" journalctl -u NetworkManager --since "-15 min" --no-pager -o short-iso
run_section "WIFI WATCHDOG JOURNAL - LAST 15 MINUTES" journalctl -u wifi_watchdog.service --since "-15 min" --no-pager -o short-iso
run_section "KERNEL JOURNAL - LAST 15 MINUTES" journalctl -k --since "-15 min" --no-pager -o short-iso

run_section "MOONRAKER LOG - LAST 200 LINES" tail -n 200 /home/pi/printer_data/logs/moonraker.log
run_section "KLIPPER LOG - LAST 200 LINES" tail -n 200 /home/pi/printer_data/logs/klippy.log

run_section "RECENT REBOOTS / SERVICE EVENTS" sh -c '
journalctl --since "-30 min" --no-pager -o short-iso | egrep -i "moonraker|klipper|NetworkManager|wlan0|brcmfmac|disconnect|deauth|reconnect|timeout|watchdog|oom|killed process|segfault|dns|dhcp" || true
'

echo
echo "=================================================="
echo "Snapshot complete"
echo "Saved to: $OUTFILE"
echo "=================================================="
