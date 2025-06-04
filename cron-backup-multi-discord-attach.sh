#!/bin/bash

# Backup VM-uri + notificare Discord cu log atasat

VM_LIST=(100 101 102)
DATE=$(date +%Y-%m-%d_%H-%M)
WEBHOOK_URL="https://discord.com/api/webhooks/xxxxxxxxxxxxxxxxxxxxxxxxxxxx"

LOG_TEMP="/tmp/proxmigrate-${DATE}.log"
ERROR_FLAG=0

echo "[${DATE}] Incep backup pentru VM-urile: ${VM_LIST[*]}" > ${LOG_TEMP}

for VM_ID in "${VM_LIST[@]}"; do
  echo "[${DATE}] Incep backup VM $VM_ID" >> ${LOG_TEMP}
  if vzdump $VM_ID --compress zstd --mode snapshot --storage local >> ${LOG_TEMP} 2>&1; then
    echo "[${DATE}] Backup reusit pentru VM $VM_ID" >> ${LOG_TEMP}
  else
    echo "[${DATE}] ❌ Eroare la backup VM $VM_ID" >> ${LOG_TEMP}
    ERROR_FLAG=1
  fi
done

echo "[${DATE}] Final backupuri VM." >> ${LOG_TEMP}

# Construim mesajul
if [ $ERROR_FLAG -eq 1 ]; then
  STATUS="❌ Backup cu erori"
else
  STATUS="✅ Backup complet"
fi

# Trimitem logul catre Discord ca fisier
curl -X POST -H "Content-Type: multipart/form-data" \
  -F "payload_json={\"content\": \"[ProxMigrate] $STATUS\"}" \
  -F "file=@${LOG_TEMP}" \
  "$WEBHOOK_URL"

# Adaugam logul si in log permanent
cat ${LOG_TEMP} >> /var/log/proxmigrate.log
rm -f ${LOG_TEMP}
