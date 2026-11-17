#!/usr/bin/env bash
# Workaround for the Intel e1000e "Detected Hardware Unit Hang" bug (seen on the
# I218-V in homelab1): under transmit load the NIC's TX queue locks up and the
# driver never resets it, so the wired network stays dead until a reboot.
# Turning off TCP/generic segmentation offload (TSO/GSO) avoids the hang.
#
# Installs a systemd template unit and enables it for every e1000e interface so
# the setting is re-applied on every boot. Safe to re-run; does nothing on
# machines without an e1000e NIC.
set -euo pipefail

ifaces=()
for dev in /sys/class/net/*; do
  [ -e "$dev/device/driver" ] || continue
  if [ "$(basename "$(readlink -f "$dev/device/driver")")" = "e1000e" ]; then
    ifaces+=("$(basename "$dev")")
  fi
done

if [ "${#ifaces[@]}" -eq 0 ]; then
  echo "e1000e-no-tso: no e1000e NICs found, skipping."
  exit 0
fi

if [ "$(id -u)" -ne 0 ]; then
  exec sudo bash "$0" "$@"
fi

ETHTOOL=$(command -v ethtool || true)
if [ -z "$ETHTOOL" ]; then
  echo "e1000e-no-tso: ethtool not found; install it (apt install ethtool) and re-run." >&2
  exit 1
fi

# %i is the systemd-escaped interface name (for the device unit), %I the raw name.
cat > /etc/systemd/system/e1000e-no-tso@.service <<EOF
[Unit]
Description=Disable TSO/GSO on %I (e1000e Hardware Unit Hang workaround)
BindsTo=sys-subsystem-net-devices-%i.device
After=sys-subsystem-net-devices-%i.device

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=${ETHTOOL} -K %I tso off gso off

[Install]
WantedBy=sys-subsystem-net-devices-%i.device
EOF
systemctl daemon-reload

for iface in "${ifaces[@]}"; do
  unit="e1000e-no-tso@$(systemd-escape "$iface").service"
  systemctl enable "$unit"
  systemctl restart "$unit"
  echo "e1000e-no-tso: $iface ->" \
    "$("$ETHTOOL" -k "$iface" | grep -E '^(tcp-segmentation-offload|generic-segmentation-offload):' | tr '\n' ' ')"
done
