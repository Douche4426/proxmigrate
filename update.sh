#!/bin/bash
set -e

# === DEFINIRE LOG ===
LOG_FILE="/var/log/proxmigrate-update.log"
echo "🔄 Pornit update ProxMigrate – $(date)" > "$LOG_FILE"

# === PREGATIRE TEMP ===
TMP_DIR="/tmp/proxmigrate-update"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

echo "📥 Descarc ultima versiune din GitHub..." | tee -a "$LOG_FILE"
if curl -sL https://github.com/Douche4426/proxmigrate/archive/refs/heads/main.zip -o update.zip; then
  echo "✅ Arhiva descarcata cu succes." | tee -a "$LOG_FILE"
else
  echo "❌ Eroare la descarcarea arhivei." | tee -a "$LOG_FILE"
  exit 1
fi

if unzip -o update.zip >/dev/null; then
  echo "✅ Arhiva extrasa cu succes." | tee -a "$LOG_FILE"
else
  echo "❌ Eroare la extragerea arhivei." | tee -a "$LOG_FILE"
  exit 1
fi

cd proxmigrate-main

# === ACTUALIZEAZA FISIERE ===
copy_script() {
  SRC="$1"
  DEST="/usr/local/bin/$1"
  if [[ -f "$SRC" ]]; then
    cp "$SRC" "$DEST" && chmod +x "$DEST"
    echo "✅ $SRC actualizat in $DEST." | tee -a "$LOG_FILE"
  else
    echo "⚠️ Fisierul $SRC lipseste in arhiva GitHub." | tee -a "$LOG_FILE"
  fi
}

copy_script proxmigrate
copy_script proxversion
copy_script cron-backup-running-discord.sh
copy_script tailmox.sh
copy_script proxdoctor

# === FINAL ===
echo "🎉 Update complet. Ruleaza 'proxmigrate' sau 'proxversion' pentru confirmare." | tee -a "$LOG_FILE"