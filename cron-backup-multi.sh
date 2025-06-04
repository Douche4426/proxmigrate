#!/bin/bash
# Script pentru backup automat mai multe VM-uri

VM_LIST=(100 101 102)  # Adauga aici ID-urile VM-urilor tale
DATE=$(date +%Y-%m-%d_%H-%M)
LOG_FILE="/var/log/proxmigrate.log"

echo "[${DATE}] Incep backup pentru VM-urile: ${VM_LIST[*]}" >> ${LOG_FILE}

for VM_ID in "${VM_LIST[@]}"; do
  echo "[${DATE}] Incep backup VM $VM_ID" >> ${LOG_FILE}
  vzdump $VM_ID --compress zstd --mode snapshot --storage local >> ${LOG_FILE} 2>&1
  echo "[${DATE}] Finalizat VM $VM_ID" >> ${LOG_FILE}
done

echo "[${DATE}] Toate backupurile au fost finalizate." >> ${LOG_FILE}
