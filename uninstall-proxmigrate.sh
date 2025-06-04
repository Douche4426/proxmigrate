#!/bin/bash

echo "🧹 Dezinstalare ProxMigrate..."

# Opreste si dezactiveaza timerul systemd
systemctl disable --now proxmigrate-backup.timer 2>/dev/null || true
rm -f /etc/systemd/system/proxmigrate-backup.service
rm -f /etc/systemd/system/proxmigrate-backup.timer

# Sterge scripturi instalate
rm -f /usr/local/bin/proxmigrate
rm -f /usr/local/bin/proxmigrate-backup-100
rm -f /usr/local/bin/proxmigrate-backup-multi
rm -f /usr/local/bin/proxmigrate-backup-with-mail
rm -f /usr/local/bin/cron-backup-running-discord.sh
rm -f /usr/local/bin/proxversion

# Sterge folder changelog
rm -rf /usr/local/share/proxmigrate

# Optional: Sterge logul principal
read -p "Doresti sa stergi si logul principal (/var/log/proxmigrate.log)? [y/N]: " confirm1
if [[ $confirm1 =~ ^[Yy]$ ]]; then
  rm -f /var/log/proxmigrate.log
  echo "🗑️ Logul principal a fost sters."
fi

# Optional: Sterge logul de debug
read -p "Doresti sa stergi si logul de debug (/tmp/debug-proxmigrate.log)? [y/N]: " confirm2
if [[ $confirm2 =~ ^[Yy]$ ]]; then
  rm -f /tmp/debug-proxmigrate.log
  echo "🧼 Logul de debug a fost sters."
fi

# Reload systemd
systemctl daemon-reload

echo "✅ ProxMigrate a fost dezinstalat complet."