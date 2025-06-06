#!/bin/bash

echo "🧪 ProxDoctor - Verificare instalare ProxMigrate"
echo "---------------------------------------------"

check_file() {
  [[ -f "$1" ]] && echo "✅ Exista: $1" || echo "❌ Lipseste: $1"
}

check_dir() {
  [[ -d "$1" ]] && echo "📁 Director OK: $1" || echo "📁 Lipseste: $1"
}

check_command() {
  command -v "$1" &>/dev/null && echo "✅ Comanda '$1' disponibila" || echo "❌ Comanda '$1' lipseste"
}

check_alias() {
  grep -q "alias pm=" ~/.bashrc && echo "✅ Alias 'pm' gasit in .bashrc" || echo "❌ Alias 'pm' lipseste in .bashrc"
}

# 🔎 Begin checks
check_file /usr/local/bin/proxmigrate
check_file /usr/local/bin/proxversion
check_file /usr/local/bin/cron-backup-running-discord.sh
check_file /usr/local/bin/tailmox.sh

check_dir /usr/local/share/proxmigrate
check_dir /etc/proxmigrate

check_command proxmigrate
check_command proxversion
check_command curl
check_command unzip
check_command tailscale

check_alias

# 🔄 Verifica daca timerul este activ
echo ""
echo "⏱ Verific timer systemd:"
systemctl is-enabled proxmigrate-backup.timer &>/dev/null && \
  echo "✅ Timerul proxmigrate-backup.timer este activ" || \
  echo "❌ Timerul proxmigrate-backup.timer NU este activat"

echo ""
echo "🧩 Final verificare. Daca apar ❌, ruleaza din nou install.sh sau update.sh"
