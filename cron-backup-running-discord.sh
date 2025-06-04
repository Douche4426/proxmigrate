#!/bin/bash

# Backup doar pentru VM-urile pornite + notificare Discord

DATE=$(date +%Y-%m-%d_%H-%M)
WEBHOOK_URL="https://discord.com/api/webhooks/xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
LOG_TEMP="/tmp/proxmigrate-${DATE}.log"
ERROR_FLAG=0

# Extrage VM-urile pornite
RUNNING_VMS=($(qm list | awk '/running/ {print $1}'))

echo "[${DATE}] Backup pentru VM-uri pornite: ${RUNNING_VMS[*]}" > ${LOG_TEMP}

for VM_ID in "${RUNNING_VMS[@]}"; do
  echo "[${DATE}] Incep backup VM $VM_ID" >> ${LOG_TEMP}
  if vzdump $VM_ID --compress zstd --mode snapshot --storage local >> ${LOG_TEMP} 2>&1; then
    echo "[${DATE}] Backup reusit pentru VM $VM_ID" >> ${LOG_TEMP}
  else
    echo "[${DATE}] ❌ Eroare la backup VM $VM_ID" >> ${LOG_TEMP}
    ERROR_FLAG=1
  fi
done

echo "[${DATE}] Backup complet pentru VM-urile pornite." >> ${LOG_TEMP}

# Construim mesajul
if [ $ERROR_FLAG -eq 1 ]; then
  STATUS="❌ Backup cu erori"
else
  STATUS="✅ Backup complet"
fi

# Trimitem logul catre Discord ca fisier atasat
curl -X POST -H "Content-Type: multipart/form-data" \
  -F "payload_json={\"content\": \"[ProxMigrate] $STATUS pentru VM-urile pornite\"}" \
  -F "file=@${LOG_TEMP}" \
  "$WEBHOOK_URL"

# Salvare log permanent si curatare temporar
cat ${LOG_TEMP} >> /var/log/proxmigrate.log
rm -f ${LOG_TEMP}
