#!/bin/bash
set -e

LOG_FILE="/var/log/proxmigrate-install.log"

# === Verificare si instalare dependinte esentiale ===
LOG_FILE="${LOG_FILE:-/var/log/proxmigrate-install.log}"
echo "🔍 Verificare dependinte - $(date)" >> "$LOG_FILE"

check_dep() {
  local cmd="$1"
  local pkg="$2"
  local desc="$3"

  if ! command -v "$cmd" &>/dev/null; then
    echo "📦 '$cmd' ($desc) lipseste. Incerc instalarea automata..." | tee -a "$LOG_FILE"
    if apt update && apt install -y "$pkg" >> "$LOG_FILE" 2>&1; then
      echo "✅ '$cmd' a fost instalat cu succes." | tee -a "$LOG_FILE"
    else
      echo "❌ Eroare la instalarea '$cmd'. Instaleaza-l manual si ruleaza din nou scriptul." | tee -a "$LOG_FILE"
      exit 1
    fi
  else
    echo "✅ '$cmd' este deja prezent." >> "$LOG_FILE"
  fi
}

# === Verificari esentiale ===
check_dep curl curl "utilitar pentru descarcare HTTP"
check_dep unzip unzip "utilitar pentru extragere arhive ZIP"
check_dep expect expect "automatizare sesiuni CLI (ex: tailmox)"

# === Verificare pentru systemctl ===
if ! command -v systemctl &>/dev/null; then
  echo "⚠️ 'systemctl' lipseste. Timerul systemd va fi sarit." | tee -a "$LOG_FILE"
  SKIP_SYSTEMD=1
else
  echo "✅ 'systemctl' este disponibil." >> "$LOG_FILE"
fi


echo "📥 Descarc ProxMigrate..." | tee -a "$LOG_FILE"

# Verificare si fallback pentru curl
if ! command -v curl &>/dev/null; then
  echo "📡 'curl' nu este instalat. Incerc instalarea automata..." | tee -a "$LOG_FILE"
  if apt update && apt install -y curl >> "$LOG_FILE" 2>&1; then
    echo "✅ 'curl' a fost instalat cu succes." | tee -a "$LOG_FILE"
  else
    echo "❌ Eroare la instalarea 'curl'. Instaleaza-l manual si ruleaza din nou scriptul." | tee -a "$LOG_FILE"
    exit 1
  fi
fi


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

# Verificare prezenta systemctl
if ! command -v systemctl &>/dev/null; then
  echo "⚠️ ATENTIE: 'systemctl' nu este disponibil. Omit activarea automata a timerului." | tee -a "$LOG_FILE"
  SKIP_SYSTEMD=1
fi


# Activare timer
if [[ -z "$SKIP_SYSTEMD" ]]; then
  systemctl daemon-reload
  systemctl enable --now proxmigrate-backup.timer || true
  echo "✅ Am creat symlink pentru proxmigrate-backup.timer!" | tee -a "$LOG_FILE"
else
  echo "⏭️ Timerul systemd nu a fost activat (lipseste systemctl)." | tee -a "$LOG_FILE"
fi

[[ -d /tmp/proxmigrate ]] && rm -rf /tmp/proxmigrate && echo "🧹 Directorul temporar /tmp/proxmigrate a fost curatat." | tee -a "$LOG_FILE"

# === Adaugare alias shell ===
if ! grep -q "alias pm=" ~/.bashrc; then
  echo "alias pm='proxmigrate'" >> ~/.bashrc
  echo "✅ Alias 'pm' adaugat in .bashrc" | tee -a "$LOG_FILE"
else
  echo "ℹ️ Alias 'pm' deja exista in .bashrc" | tee -a "$LOG_FILE"
fi

# === Instalare automata proxdoctor ===
if [[ ! -f /usr/local/bin/proxdoctor ]]; then
  echo "📥 Descarc si instalez proxdoctor..." | tee -a "$LOG_FILE"
  curl -sL https://raw.githubusercontent.com/Douche4426/proxmigrate/main/proxdoctor -o /usr/local/bin/proxdoctor
  chmod +x /usr/local/bin/proxdoctor
  echo "✅ proxdoctor a fost instalat cu succes." | tee -a "$LOG_FILE"
else
  echo "ℹ️ proxdoctor este deja instalat." | tee -a "$LOG_FILE"
fi

# === Setare versiune ProxMigrate ===
VERSION_FILE="/etc/proxmigrate/version.txt"

mkdir -p /etc/proxmigrate

# Extrage versiunea din Git (dacă există tag local), altfel fallback
if command -v git &>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null; then
    VERSION=$(git describe --tags --always 2>/dev/null)
else
    VERSION="v1.3.0"  # ← actualizeaza manual aici dacă rulezi din .zip
fi

echo "$VERSION" > "$VERSION_FILE"
echo "🧩 Versiunea ProxMigrate setata: $VERSION" | tee -a "$LOG_FILE"


echo "✅ Instalare completa!"
echo ""
echo "Instrucțiuni de utilizare:"
echo "📦 Ruleaza comanda:  proxmigrate"
echo "🔎 Vezi versiunea:   proxversion"
echo "📄 Istoric versiuni: proxversion --changelog"
echo "🐞 Debug log (daca e activ): /tmp/debug-proxmigrate.log"