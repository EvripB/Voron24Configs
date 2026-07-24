#!/usr/bin/env bash

LOG="/home/pi/printer_data/logs/wifi_watchdog.log"
IFACE="wlan0"
DATE="$(date '+%Y-%m-%d %H:%M:%S')"

mkdir -p "$(dirname "$LOG")"

GW="$(ip route | awk '/default/ {print $3; exit}')"

if ip link show "$IFACE" >/dev/null 2>&1 && \
   ip -4 addr show "$IFACE" | grep -q "inet " && \
   ping -I "$IFACE" -c 1 -W 3 "$GW" >/dev/null 2>&1; then
    echo "$DATE OK: WiFi connected on $IFACE, gateway $GW reachable" >> "$LOG"
    exit 0
fi

echo "$DATE FAIL: WiFi appears down. Restarting $IFACE..." >> "$LOG"

ip link set "$IFACE" down
sleep 3
ip link set "$IFACE" up
sleep 5

if systemctl is-active --quiet NetworkManager; then
    systemctl restart NetworkManager
elif systemctl is-active --quiet dhcpcd; then
    systemctl restart dhcpcd
elif systemctl is-active --quiet wpa_supplicant; then
    systemctl restart wpa_supplicant
fi

sleep 10

if ip -4 addr show "$IFACE" | grep -q "inet "; then
    echo "$DATE RECOVERY: $IFACE has IP again" >> "$LOG"
else
    echo "$DATE RECOVERY_FAILED: $IFACE still has no IP" >> "$LOG"
fi
