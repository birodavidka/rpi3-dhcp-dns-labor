mkdir -p ~/dhcp-dns-labor/scripts
cat > ~/dhcp-dns-labor/scripts/backup_network.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
BASE="$HOME/dhcp-dns-labor/backups/network"
STAMP="$(date +%Y-%m-%d_%H-%M-%S)"
DEST="$BASE/$STAMP"
mkdir -p "$DEST"

log(){ echo "[$(date +%H:%M:%S)] $*"; }

log "Mentési mappa: $DEST"

# Konfig fájlok (ha léteznek)
sudo test -d /etc/systemd/network && sudo cp -r /etc/systemd/network "$DEST/systemd-network.backup" || true
sudo test -f /etc/NetworkManager/NetworkManager.conf && sudo cp /etc/NetworkManager/NetworkManager.conf "$DEST/NetworkManager.conf.backup" || true
sudo test -d /etc/NetworkManager/system-connections && sudo cp -r /etc/NetworkManager/system-connections "$DEST/system-connections.backup" || true
sudo test -f /etc/dhcpcd.conf && sudo cp /etc/dhcpcd.conf "$DEST/dhcpcd.conf.backup" || true
sudo test -f /etc/network/interfaces && sudo cp /etc/network/interfaces "$DEST/interfaces.backup" || true

# Alap fájlok
sudo cp /etc/hosts "$DEST/hosts.backup"
sudo cp /etc/hostname "$DEST/hostname.backup"
sudo cp /etc/resolv.conf "$DEST/resolv.conf.backup"

# Állapot snapshotok
if command -v ifconfig >/dev/null 2>&1; then
  ifconfig > "$DEST/ifconfig_snapshot.txt" 2>/dev/null || true
fi
ip addr show  > "$DEST/ip_addr_snapshot.txt"
ip route show > "$DEST/ip_route_snapshot.txt"

# Összecsomagolás archivnak (jogosultságok megőrzése)
tar -C "$BASE" -czf "$BASE/network_backup_${STAMP}.tar.gz" "$STAMP"

echo
log "Kész: $BASE/network_backup_${STAMP}.tar.gz"
EOF
chmod +x ~/dhcp-dns-labor/scripts/backup_network.sh
