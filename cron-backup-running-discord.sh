#!/bin/bash
# Backup pentru VM-urile si LXC-urile pornite + notificare Discord

DATE=$(date +%Y-%m-%d_%H-%M)
WEBHOOK_URL="https://discord.com/api/webhooks/1379904231372361818/aFI_MJGx-UlF_uKxzVoOh5rZauvmeKQf7hbaQzpDXrmwQ3kxbLIejBW5V5ivNIH2wBsf"  # ← Înlocuiește cu webhook-ul tău
LOG_TEMP="/tmp/proxmigrate-${DATE}.log"
ERROR_FLAG=0

# === Extrage VM-uri si LXC pornite ===
RUNNING_VMS=($(qm list | awk '/running/ {print $1}'))
RUNNING_LXC=($(pct list | awk '/running/ {print $1}'))

echo "[${DATE}] Backup pentru VM-uri pornite: ${RUNNING_VMS[*]}" > "$LOG_TEMP"
echo "[${DATE}] Backup pentru LXC-uri pornite: ${RUNNING_LXC[*]}" >> "$LOG_TEMP"

# === Backup pentru VM-uri ===
for VM_ID in "${RUNNING_VMS[@]}"; do
  echo "[${DATE}] 🌀 Incep backup VM ${VM_ID}" >> "$LOG_TEMP"
  if vzdump "$VM_ID" --compress zstd --mode snapshot --storage local >> "$LOG_TEMP" 2>&1; then
    echo "[${DATE}] ✅ Backup reusit pentru VM ${VM_ID}" >> "$LOG_TEMP"
  else
    echo "[${DATE}] ❌ Eroare la backup VM ${VM_ID}" >> "$LOG_TEMP"
    ERROR_FLAG=1
  fi
done

# === Backup pentru LXC-uri ===
for CT_ID in "${RUNNING_LXC[@]}"; do
  echo "[${DATE}] 🌀 Incep backup LXC ${CT_ID}" >> "$LOG_TEMP"
  if vzdump "$CT_ID" --compress zstd --mode snapshot --storage local >> "$LOG_TEMP" 2>&1; then
    echo "[${DATE}] ✅ Backup reusit pentru LXC ${CT_ID}" >> "$LOG_TEMP"
  else
    echo "[${DATE}] ❌ Eroare la backup LXC ${CT_ID}" >> "$LOG_TEMP"
    ERROR_FLAG=1
  fi
done

echo "[${DATE}] 📦 Backup complet pentru VM + LXC pornite." >> "$LOG_TEMP"

# === Construieste mesajul pentru Discord ===
if [[ $ERROR_FLAG -eq 1 ]]; then
  STATUS="❌ Backup cu erori"
else
  STATUS="✅ Backup complet"
fi

# === Trimite logul pe Discord ===
if [ -s "$LOG_TEMP" ]; then
  curl -X POST -H "Content-Type: multipart/form-data" \
    -F payload_json="{\"content\":\"🧠 [ProxMigrate] $STATUS pentru VM + LXC pornite\"}" \
    -F "file=@${LOG_TEMP}" \
    "$WEBHOOK_URL"
else
  echo "❌ Logul este gol, nu trimit pe Discord."
fi

# === Salveaza logul permanent si curata temporarul ===
cat "$LOG_TEMP" >> /var/log/proxmigrate.log
rm -f "$LOG_TEMP"