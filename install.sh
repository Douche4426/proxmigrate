#!/bin/bash
set -e

echo "📥 Descarc ProxMigrate..."
rm -rf /tmp/proxmigrate
mkdir -p /tmp/proxmigrate && cd /tmp/proxmigrate
curl -sL https://github.com/Douche4426/proxmigrate/archive/refs/heads/main.zip -o proxmigrate.zip
unzip -o proxmigrate.zip >/dev/null
cd proxmigrate-main

echo "⚙️ Instalez fisiere binare..."

# Daca fisierul e .sh, il redenumim
if [ -f "proxmigrate.sh" ]; then
  mv proxmigrate.sh proxmigrate
fi

# Verificam daca exista fisierul esential
if [ ! -f "proxmigrate" ]; then
  echo "❌ Eroare: fisierul 'proxmigrate' nu exista in arhiva!"
  echo "Asigura-te ca este corect prezent in root-ul arhivei GitHub."
  exit 1
fi

# Copiere script principal
cp proxmigrate /usr/local/bin/proxmigrate
chmod +x /usr/local/bin/proxmigrate

# Instaleaza CHANGELOG + proxversion
mkdir -p /usr/local/share/proxmigrate
cp CHANGELOG.md /usr/local/share/proxmigrate/
cp proxversion /usr/local/bin/
chmod +x /usr/local/bin/proxversion

# Script backup
cp cron-backup-running-discord.sh /usr/local/bin/
chmod +x /usr/local/bin/cron-backup-running-discord.sh

# Serviciu systemd
cat <<EOF > /etc/systemd/system/proxmigrate-backup.service
[Unit]
Description=Backup automat ProxMigrate
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/cron-backup-running-discord.sh
EOF

# Timer systemd
cat <<EOF > /etc/systemd/system/proxmigrate-backup.timer
[Unit]
Description=Ruleaza backup ProxMigrate zilnic

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Activare timer
systemctl daemon-reload
systemctl enable --now proxmigrate-backup.timer

echo "✅ Instalare completa!"
echo "📦 Ruleaza comanda:  proxmigrate"
echo "🔎 Vezi versiunea:   proxversion"
echo "📄 Istoric versiuni: proxversion --changelog"
