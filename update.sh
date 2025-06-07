#!/bin/bash
set -e

# === CONFIGURARE ===
TMP_DIR="/tmp/proxmigrate-update"
REPO_ZIP="https://github.com/Douche4426/proxmigrate/archive/refs/heads/main.zip"
LOG="/var/log/proxmigrate-update.log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "🔄 Actualizare ProxMigrate ($DATE)" > "$LOG"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"
rm -rf "$TMP_DIR"/*

# === DESCARCA ===
echo "📥 Descarc ultima versiune din GitHub..." | tee -a "$LOG"
if curl -sL "$REPO_ZIP" -o main.zip; then
  echo "✅ Arhiva descarcata cu succes." | tee -a "$LOG"
else
  echo "❌ Eroare la descarcare!" | tee -a "$LOG"
  exit 1
fi

unzip -o main.zip >/dev/null
cd proxmigrate-main

FILES=(proxversion proxmigrate.sh proxdoctor tailmox.sh cron-backup-running-discord.sh)
REPO_DIR=$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d -iname "proxmigrate-*" | head -n1)

if [[ ! -d "$REPO_DIR" ]]; then
  echo "❌ Eroare: folderul extras cu scripturile nu a fost gasit!" | tee -a "$LOG"
  exit 1
fi


for f in "${FILES[@]}"; do
  REMOTE_FILE="$REPO_DIR/$f"

  if [[ -f "$REMOTE_FILE" ]]; then
    # Seteaza calea locală corecta
    case "$f" in
      proxversion) LOCAL_FILE="/usr/local/bin/proxversion" ;;
      proxmigrate.sh) LOCAL_FILE="/usr/local/bin/proxmigrate" ;;
      cron-backup-running-discord.sh) LOCAL_FILE="/usr/local/bin/cron-backup-running-discord.sh" ;;
      *) LOCAL_FILE="/usr/local/bin/$f" ;;
    esac

    # Compara si actualizeaza doar daca difera
    if cmp -s "$REMOTE_FILE" "$LOCAL_FILE"; then
      echo "⏩ $f este deja la zi (fara modificari)." | tee -a "$LOG"
    else
      cp "$REMOTE_FILE" "$LOCAL_FILE"
      chmod +x "$LOCAL_FILE"
      echo "✅ $f a fost actualizat in $LOCAL_FILE." | tee -a "$LOG"
    fi
  else
    echo "⚠️ Fisierul $f lipseste in arhiva!" | tee -a "$LOG"
  fi
done

echo "" | tee -a "$LOG"
echo "🎉 Actualizare finalizata. Ruleaza 'proxmigrate' pentru a verifica." | tee -a "$LOG"

if command -v proxversion &>/dev/null; then
  echo "" | tee -a "$LOG"
  echo "📌 Versiunea curenta instalata:" | tee -a "$LOG"
  proxversion | tee -a "$LOG"
else
  echo "⚠️ proxversion nu este instalat sau nu a fost actualizat corect." | tee -a "$LOG"
fi
