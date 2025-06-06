#!/bin/bash

LOG="/tmp/proxmigrate-uninstall.log"
echo "🔧 Start dezinstalare: $(date)" > "$LOG"


# Opreste si dezactiveaza timerul systemd
systemctl disable --now proxmigrate-backup.timer 2>/dev/null || true
rm -f /etc/systemd/system/proxmigrate-backup.service && echo "✔ proxmigrate-backup.service sters" >> "$LOG"
rm -f /etc/systemd/system/proxmigrate-backup.timer && echo "✔ proxmigrate-backup.timer sters" >> "$LOG"

# Sterge scripturi instalate
rm -f /usr/local/bin/proxmigrate && echo "✔ proxmigrate sters" >> "$LOG"
rm -f /usr/local/bin/proxmigrate-backup-100 && echo "✔ proxmigrate-backup-100 sters" >> "$LOG"
rm -f /usr/local/bin/proxmigrate-backup-multi && echo "✔ proxmigrate-backup-multi sters" >> "$LOG"
rm -f /usr/local/bin/proxmigrate-backup-with-mail && echo "✔ proxmigrate-backup-with-mail sters" >> "$LOG"
rm -f /usr/local/bin/cron-backup-running-discord.sh && echo "✔ cron-backup-running-discord.sh sters" >> "$LOG"
rm -f /usr/local/bin/proxversion && echo "✔ proxversion sters" >> "$LOG"
rm -f /usr/local/bin/tailmox.sh && echo "✔ tailmox.sh sters" >> "$LOG"
rm -f /usr/local/bin/maintenance.sh && echo "✔ maintenance.sh sters" >> "$LOG"
rm -f /usr/local/bin/update.sh && echo "✔ update.sh sters" >> "$LOG"
rm -f /usr/local/bin/reset.sh && echo "✔ reset.sh sters" >> "$LOG"
rm -f /usr/local/bin/dependencies.sh && echo "✔ dependencies.sh sters" >> "$LOG"


# Sterge foldere si fisiere auxiliare
rm -rf /usr/local/share/proxmigrate && echo "✔ /usr/local/share/proxmigrate sters" >> "$LOG"
rm -rf /etc/proxmigrate && echo "✔ /etc/proxmigrate sters" >> "$LOG"


# Sterge logul principal
read -p "Doresti sa stergi si logul principal (/var/log/proxmigrate.log)? [y/N]: " confirm1
if [[ $confirm1 =~ ^[Yy]$ ]]; then
  rm -f /var/log/proxmigrate.log && echo "🗑️ Logul principal a fost sters." >> "$LOG"
fi

# Sterge logul de instalare
read -p "Doresti sa stergi si logul de instalare (/var/log/proxmigrate-install.log)? [y/N]: " confirm3
if [[ $confirm3 =~ ^[Yy]$ ]]; then
  rm -f /var/log/proxmigrate-install.log && echo "🧽 Logul de instalare a fost sters." >> "$LOG"
fi


# Sterge logul de debug
read -p "Doresti sa stergi si logul de debug (/tmp/debug-proxmigrate.log)? [y/N]: " confirm2
if [[ $confirm2 =~ ^[Yy]$ ]]; then
  rm -f /tmp/debug-proxmigrate.log && echo "🧼 Logul de debug a fost sters." >> "$LOG"
fi

# Reload systemd
systemctl daemon-reload && echo "🔄 systemd reîncărcat." >> "$LOG"

echo "✅ ProxMigrate a fost dezinstalat complet. Log salvat in: $LOG"

