#!/bin/bash

# Backup VM-uri + notificare Discord (success/error)

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

# Construieste mesajul pentru Discord
if [ $ERROR_FLAG -eq 1 ]; then
  COLOR=15158332  # rosu
  STATUS="❌ Backup finalizat cu ERORI"
else
  COLOR=3066993   # verde
  STATUS="✅ Backup finalizat cu succes"
fi

# Trimite catre Discord
PAYLOAD=$(jq -n --arg content "**[ProxMigrate] $STATUS** la $DATE pentru VM-urile: ${VM_LIST[*]}" '{content: $content}')
curl -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$WEBHOOK_URL"

# Adauga logul in fisier permanent
cat ${LOG_TEMP} >> /var/log/proxmigrate.log
rm -f ${LOG_TEMP}
