#!/bin/bash

set -e

echo "📥 Descarc ProxMigrate..."
rm -rf /tmp/proxmigrate
mkdir -p /tmp/proxmigrate && cd /tmp/proxmigrate
curl -sL https://github.com/Douche4426/proxmigrate/archive/refs/heads/main.zip -o proxmigrate.zip
unzip -o proxmigrate.zip >/dev/null
cd proxmigrate-main

echo "⚙️ Instalez fisiere binare..."

# Caut scriptul principal si il redenumesc daca e nevoie
if [ -f "proxmigrate.sh" ]; then
  mv proxmigrate.sh proxmigrate
fi

# Verific daca scriptul exista acum
if [ ! -f "proxmigrate" ]; then
  echo "❌ Eroare: fisierul 'proxmigrate' nu exista in arhiva!"
  echo "Asigura-te ca fisierul corect este prezent in root-ul arhivei GitHub."
  exit 1
fi

cp proxmigrate /usr/local/bin/proxmigrate
chmod +x /usr/local/bin/proxmigrate

cp cron-backup-running-discord.sh /usr/local/bin/
chmod +x /usr/local/bin/proxmigrate /usr/local/bin/cron-backup-running-discord.sh

echo "⚙️ Instalez serviciul systemd..."
cp proxmigrate-backup.service /etc/systemd/system/
cp proxmigrate-backup.timer /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now proxmigrate-backup.timer

echo "✅ Instalare completa!"
echo "Ruleaza comanda: proxmigrate"
