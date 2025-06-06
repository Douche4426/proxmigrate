#!/bin/bash

LOG_FILE="/var/log/proxmigrate-reset.log"
echo "🔁 Pornit reset ProxMigrate – $(date)" > "$LOG_FILE"

# 🔒 Confirmare initiala
read -p "⚠️ Aceasta operatiune va sterge complet ProxMigrate. Continui? [y/N]: " CONFIRM
[[ ! "$CONFIRM" =~ ^[Yy]$ ]] && echo "❌ Reset anulat." && exit 1

# 📦 Backup optional
BACKUP_DIR="/root/proxmigrate-backup-$(date +%Y%m%d-%H%M%S)"
read -p "Vrei sa faci backup la configurari si loguri inainte? [y/N]: " BACKUP_CONFIRM
if [[ "$BACKUP_CONFIRM" =~ ^[Yy]$ ]]; then
  mkdir -p "$BACKUP_DIR"
  cp -r /etc/proxmigrate "$BACKUP_DIR" 2>/dev/null
  cp -r /usr/local/share/proxmigrate "$BACKUP_DIR" 2>/dev/null
  cp /var/log/proxmigrate*.log "$BACKUP_DIR" 2>/dev/null
  echo "✅ Backup salvat in: $BACKUP_DIR" | tee -a "$LOG_FILE"
fi

# 🧹 Dezinstalare
echo "🧹 Rulez uninstall..." | tee -a "$LOG_FILE"
if [[ -f uninstall-proxmigrate.sh ]]; then
  bash uninstall-proxmigrate.sh >> "$LOG_FILE" 2>&1
else
  curl -sL https://raw.githubusercontent.com/Douche4426/proxmigrate/main/uninstall-proxmigrate.sh | bash >> "$LOG_FILE" 2>&1
fi
echo "✅ Dezinstalare completa." | tee -a "$LOG_FILE"

# 🔄 Instalare din GitHub
echo "📥 Rulez install.sh din GitHub..." | tee -a "$LOG_FILE"
curl -sL https://raw.githubusercontent.com/Douche4426/proxmigrate/main/install.sh | bash >> "$LOG_FILE" 2>&1

# 🟢 Final
echo "🎯 Reset finalizat complet." | tee -a "$LOG_FILE"
echo "📂 Log complet: $LOG_FILE"
