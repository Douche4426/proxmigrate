#!/bin/bash

# === LOG ===
LOG_FILE="/var/log/proxmigrate-update.log"
echo "🔄 Pornit update ProxMigrate – $(date)" > "$LOG_FILE"

# === INCARCA VERIFICARI DE DEPENDINTE ===
if [[ -f "$(dirname "$0")/dependencies.sh" ]]; then
  source "$(dirname "$0")/dependencies.sh"
else
  echo "⚠️ Nu am gasit dependencies.sh local. Sar fallback-urile." | tee -a "$LOG_FILE"
fi

# === PREPARA DIRECTOR TEMPORAR ===
TMP_DIR="/tmp/proxmigrate-update"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

# === DESCARCA ULTIMA VERSIUNE ===
echo "📥 Descarc ultima versiune din GitHub..." | tee -a "$LOG_FILE"
curl -sL https://github.com/Douche4426/proxmigrate/archive/refs/heads/main.zip -o update.zip

if ! unzip -o update.zip >/dev/null; then
  echo "❌ Eroare la extragerea arhivei. Verifica conexiunea sau pachetul unzip." | tee -a "$LOG_FILE"
  exit 1
fi

cd proxmigrate-main

# === COPIAZA FISIERELE ACTUALIZATE ===
cp proxmigrate /usr/local/bin/ && chmod +x /usr/local/bin/proxmigrate
echo "✅ Scriptul principal a fost actualizat." | tee -a "$LOG_FILE"

cp proxversion /usr/local/bin/ && chmod +x /usr/local/bin/proxversion
echo "✅ proxversion a fost actualizat." | tee -a "$LOG_FILE"

cp cron-backup-running-discord.sh /usr/local/bin/ && chmod +x /usr/local/bin/cron-backup-running-discord.sh
echo "✅ Scriptul cron-backup-running-discord.sh a fost actualizat." | tee -a "$LOG_FILE"

# === FINAL ===
echo "🎉 Update finalizat. Verifica cu: proxversion" | tee -a "$LOG_FILE"
