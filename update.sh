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

# === LISTA FISIERE DE ACTUALIZAT ===
FILES=(
  proxmigrate
  proxversion
  proxdoctor
  tailmox.sh
  cron-backup-running-discord.sh
)

# === FUNCTIE COMPARE & COPY ===
compare_and_update() {
  SRC="$1"
  DEST="/usr/local/bin/$1"

  if [[ ! -f "$SRC" ]]; then
    echo "⚠️ Fisierul $SRC lipseste in repo!" | tee -a "$LOG"
    return
  fi

  if [[ ! -f "$DEST" ]]; then
    cp "$SRC" "$DEST"
    chmod +x "$DEST"
    echo "🆕 $SRC a fost instalat (nu exista local)." | tee -a "$LOG"
  else
    HASH_SRC=$(sha256sum "$SRC" | awk '{print $1}')
    HASH_DEST=$(sha256sum "$DEST" | awk '{print $1}')
    if [[ "$HASH_SRC" != "$HASH_DEST" ]]; then
      cp "$SRC" "$DEST"
      chmod +x "$DEST"
      echo "✅ $SRC a fost actualizat (diferente detectate)." | tee -a "$LOG"
    else
      echo "⏭ $SRC este deja la zi (fara modificari)." | tee -a "$LOG"
    fi
  fi
}

# === APLICARE ===
for file in "${FILES[@]}"; do
  compare_and_update "$file"
done

echo "" | tee -a "$LOG"
echo "🎉 Actualizare finalizata. Ruleaza 'proxmigrate' pentru a verifica." | tee -a "$LOG"