#!/bin/bash
set -e

LOG_FILE="/var/log/proxmigrate-install.log"
echo "📥 Descarc ProxMigrate..." | tee -a "$LOG_FILE"

if curl -sL https://github.com/... -o proxmigrate.zip; then
  echo "✅ ProxMigrate a fost descarcat fara erori!" | tee -a "$LOG_FILE"
else
  echo "❌ Eroare la descarcarea ProxMigrate!" | tee -a "$LOG_FILE"
  exit 1
fi

rm -rf /tmp/proxmigrate
mkdir -p /tmp/proxmigrate && cd /tmp/proxmigrate
curl -sL https://github.com/Douche4426/proxmigrate/archive/refs/heads/main.zip -o proxmigrate.zip
if ! command -v unzip &>/dev/null; then
  echo "📦 'unzip' nu este instalat. Incerc instalarea automata..." | tee -a "$LOG_FILE"
  if apt update && apt install -y unzip >> "$LOG_FILE" 2>&1; then
    echo "✅ 'unzip' a fost instalat cu succes." | tee -a "$LOG_FILE"
  else
    echo "❌ Eroare la instalarea pachetului 'unzip'. Instaleaza-l manual si ruleaza din nou scriptul." | tee -a "$LOG_FILE"
    exit 1
  fi
fi
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
echo "✅ Scriptul principal 'proxmigrate' a fost instalat!" | tee -a "$LOG_FILE"

# Instaleaza CHANGELOG + proxversion
mkdir -p /usr/local/share/proxmigrate
cp CHANGELOG.md /usr/local/share/proxmigrate/
cp proxversion /usr/local/bin/
chmod +x /usr/local/bin/proxversion
echo "✅ proxversion si CHANGELOG.md instalate!" | tee -a "$LOG_FILE"

# Script backup cu notificare Discord
cp cron-backup-running-discord.sh /usr/local/bin/
chmod +x /usr/local/bin/cron-backup-running-discord.sh
echo "✅ Scriptul cron-backup-running-discord.sh a fost instalat!" | tee -a "$LOG_FILE"

# Injectam DEBUG=1 daca nu exista
if ! grep -q "DEBUG=1" /usr/local/bin/cron-backup-running-discord.sh; then
  sed -i '1a DEBUG=1' /usr/local/bin/cron-backup-running-discord.sh
fi

# Instaleaza tailmox.sh in /usr/local/bin
if [[ -f /usr/local/bin/tailmox.sh ]]; then
  echo "✅ tailmox.sh este deja instalat!" | tee -a "$LOG_FILE"
else
  curl -sL https://raw.githubusercontent.com/willjasen/tailmox/main/tailmox.sh -o /usr/local/bin/tailmox.sh && chmod +x /usr/local/bin/tailmox.sh
  echo "✅ tailmox.sh instalat fara erori!" | tee -a "$LOG_FILE"
fi

# Creeaza director pentru configurare auth-key (optional)
mkdir -p /etc/proxmigrate
echo "✅ Directorul /etc/proxmigrate a fost creat!" | tee -a "$LOG_FILE"

# Creare serviciu systemd
cat <<EOF > /etc/systemd/system/proxmigrate-backup.service
[Unit]
Description=Backup automat ProxMigrate
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/cron-backup-running-discord.sh
EOF

# Creare timer systemd
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
echo "🔄 systemd reîncărcat." | tee -a "$LOG_FILE"
systemctl enable --now proxmigrate-backup.timer || true
echo "✅ Am creat symlink pentru proxmigrate-backup.timer!" | tee -a "$LOG_FILE"

echo "✅ Instalare completa!"
echo ""
echo "Instrucțiuni de utilizare:"
echo "📦 Ruleaza comanda:  proxmigrate"
echo "🔎 Vezi versiunea:   proxversion"
echo "📄 Istoric versiuni: proxversion --changelog"
echo "🐞 Debug log (daca e activ): /tmp/debug-proxmigrate.log"