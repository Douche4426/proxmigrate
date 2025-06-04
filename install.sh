#!/bin/bash

set -e

echo "📥 Descarc ProxMigrate..."
mkdir -p /tmp/proxmigrate && cd /tmp/proxmigrate
curl -sL https://github.com/USERNAME/Douche4426/archive/refs/heads/main.zip -o proxmigrate.zip
unzip -q proxmigrate.zip
cd proxmigrate-main

echo "⚙️ Instalez fisiere binare..."
cp proxmigrate /usr/local/bin/proxmigrate
cp cron-backup-running-discord.sh /usr/local/bin/
chmod +x /usr/local/bin/proxmigrate /usr/local/bin/cron-backup-running-discord.sh

echo "⚙️ Instalez serviciul systemd..."
cp proxmigrate-backup.service /etc/systemd/system/
cp proxmigrate-backup.timer /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now proxmigrate-backup.timer

echo "✅ Instalare completa!"
echo "Ruleaza comanda: proxmigrate"
