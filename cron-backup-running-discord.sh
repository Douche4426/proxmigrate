#!/bin/bash
# Backup pentru VM-urile si LXC-urile pornite + notificare Discord

DATE=$(date +%Y-%m-%d_%H-%M)
WEBHOOK_URL="https://discord.com/api/webhooks/1379904231372361818/aFI_MJGx-UlF_uKxzVoOh5rZauvmeKQf7hbaQzpDXrmwQ3kxbLIejBW5V5ivNIH2wBsf"  # ← inlocuieste cu webhookul tau
LOG_TEMP="/tmp/proxmigrate-${DATE}.log"
DEBUG_LOG="/tmp/debug-proxmigrate.log"
ERROR_FLAG=0

echo "[DEBUG] Pornesc scriptul la ${DATE}" >> $DEBUG_LOG

# Extrage VM-urile si LXC-urile pornite
RUNNING_VMS=($(qm list | awk '/running/ {print $1}'))
RUNNING_LXC=($(pct list | awk '/running/ {print $1}'))

echo "📦 [${DATE}] Backup pentru VM-urile pornite: ${RUNNING_VMS[*]}" >> $LOG_TEMP
echo "📦 [${DATE}] Backup pentru LXC-urile pornite: ${RUNNING_LXC[*]}" >> $LOG_TEMP

# Backup pentru VM-uri
for VM_ID in "${RUNNING_VMS[@]}"; do
  echo "[${DATE}] Incep backup VM $VM_ID" >> $LOG_TEMP
  if vzdump $VM_ID --compress zstd --mode snapshot --storage local >> $LOG_TEMP 2>&1; then
    echo "[${DATE}] ✅ Backup reusit pentru VM $VM_ID" >> $LOG_TEMP
  else
    echo "[${DATE}] ❌ Eroare la backup VM $VM_ID" >> $LOG_TEMP
    ERROR_FLAG=1
  fi
done

# Backup pentru LXC-uri
for CT_ID in "${RUNNING_LXC[@]}"; do
  echo "[${DATE}] Incep backup LXC $CT_ID" >> $LOG_TEMP
  if vzdump $CT_ID --compress zstd --mode snapshot --storage local >> $LOG_TEMP 2>&1; then
    echo "[${DATE}] ✅ Backup reusit pentru LXC $CT_ID" >> $LOG_TEMP
  else
    echo "[${DATE}] ❌ Eroare la backup LXC $CT_ID" >> $LOG_TEMP
    ERROR_FLAG=1
  fi
done

echo "[${DATE}] Backup complet pentru VM si LXC pornite." >> $LOG_TEMP

# Construieste mesajul
if [[ $ERROR_FLAG -eq 1 ]]; then
  STATUS="❌ Backup cu erori"
else
  STATUS="✅ Backup complet"
fi

# Trimite logul catre Discord
if [[ -f "$LOG_TEMP" ]]; then
  curl -s -X POST -H "Content-Type: multipart/form-data" \
    -F "payload_json={\"content\": \"[ProxMigrate] $STATUS pentru VM + LXC pornite\"}" \
    -F "file=@${LOG_TEMP}" \
    "$WEBHOOK_URL" >> $DEBUG_LOG 2>&1
else
  echo "[WARN] ⚠️ Log temporar lipseste: $LOG_TEMP" >> $DEBUG_LOG
fi

# Salveaza log permanent
if [[ -f "$LOG_TEMP" ]]; then
  cat "$LOG_TEMP" >> /var/log/proxmigrate.log
  rm -f "$LOG_TEMP"
else
  echo "[ERROR] Nu pot scrie in /var/log/proxmigrate.log - log lipsa." >> $DEBUG_LOG
fi

echo "[DEBUG] Script terminat la $(date)" >> $DEBUG_LOG