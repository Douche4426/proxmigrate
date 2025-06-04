#!/bin/bash

echo "🧹 Dezinstalare ProxMigrate..."

# Opreste si dezactiveaza timerul systemd
systemctl disable --now proxmigrate-backup.timer 2>/dev/null
rm -f /etc/systemd/system/proxmigrate-backup.service
rm -f /etc/systemd/system/proxmigrate-backup.timer

# Sterge scripturi instalate
rm -f /usr/local/bin/proxmigrate
rm -f /usr/local/bin/proxmigrate-backup-100
rm -f /usr/local/bin/proxmigrate-backup-multi
rm -f /usr/local/bin/proxmigrate-backup-with-mail
rm -f /usr/local/bin/cron-backup-running-discord.sh
rm -f /usr/local/bin/proxversion

# Sterge directorul auxiliar
rm -rf /usr/local/share/proxmigrate

# Optional: Sterge logul
read -p "Doresti sa stergi si logul? (/var/log/proxmigrate.log) [y/N]: " confirm
if [[ $confirm =~ ^[Yy]$ ]]; then
  rm -f /var/log/proxmigrate.log
  echo "🗑️ Log sters."
fi

# Reload systemd
systemctl daemon-reload

echo "✅ ProxMigrate a fost dezinstalat complet."
