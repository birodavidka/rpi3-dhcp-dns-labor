cat > ~/dhcp-dns-labor/scripts/restore_network.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
BASE="$HOME/dhcp-dns-labor/backups/network"

if [ $# -lt 1 ]; then
  echo "Használat: $0 <STAMP vagy tar.gz>"
  echo "Példa: $0 2025-10-25_10-30-00   vagy   $0 network_backup_2025-10-25_10-30-00.tar.gz"
  exit 1
fi

ARG="$1"
SRC=""
if [[ "$ARG" == *.tar.gz ]]; then
  echo "[*] Kicsomagolás ideiglenesen..."
  TMPDIR="$(mktemp -d)"
  tar -C "$TMPDIR" -xzf "$BASE/$ARG"
  SRC="$TMPDIR"/*
else
  SRC="$BASE/$ARG"
fi

# Visszamásolások (csak ha a fájl létezik a mentésben)
sudo test -d "$SRC/systemd-network.backup" && sudo cp -r "$SRC/systemd-network.backup/"* /etc/systemd/network/ || true
sudo test -f "$SRC/NetworkManager.conf.backup" && sudo cp "$SRC/NetworkManager.conf.backup" /etc/NetworkManager/NetworkManager.conf || true
sudo test -d "$SRC/system-connections.backup" && sudo cp -r "$SRC/system-connections.backup/"* /etc/NetworkManager/system-connections/ || true

sudo test -f "$SRC/dhcpcd.conf.backup" && sudo cp "$SRC/dhcpcd.conf.backup" /etc/dhcpcd.conf || true
sudo test -f "$SRC/interfaces.backup" && sudo cp "$SRC/interfaces.backup" /etc/network/interfaces || true

sudo test -f "$SRC/hosts.backup" && sudo cp "$SRC/hosts.backup" /etc/hosts || true
sudo test -f "$SRC/hostname.backup" && sudo cp "$SRC/hostname.backup" /etc/hostname || true
sudo test -f "$SRC/resolv.conf.backup" && sudo cp "$SRC/resolv.conf.backup" /etc/resolv.conf || true

# Szolgáltatások újraindítása, ha vannak
sudo systemctl restart systemd-networkd 2>/dev/null || true
sudo systemctl restart NetworkManager    2>/dev/null || true
sudo systemctl restart dhcpcd            2>/dev/null || true

echo "[OK] Visszaállítás kész. Lehet, hogy újra kell csatlakoznod SSH-val."
EOF
chmod +x ~/dhcp-dns-labor/scripts/restore_network.sh
