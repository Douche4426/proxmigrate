#!/bin/bash

# ProxMigrate - Meniu interactiv pentru migrare VM prin backup vzdump + qmrestore

BACKUP_DIR="/var/lib/vz/dump"

main_menu() {
  while true; do
    clear
    echo "=========== ProxMigrate ==========="
    echo "1) Listeaza toate VM-urile disponibile"
    echo "2) Creeaza backup VM (vzdump)"
    echo "3) Transfera backup catre alt nod"
    echo "4) Restaureaza VM din backup"
    echo "5) Sterge backupuri vechi"
    echo "6) Iesi"
    echo "===================================="
    read -p "Selecteaza optiunea: " opt

    case $opt in
      1) list_vm_lxc;;
      2) create_backup;;
      3) transfer_backup;;
      4) restore_vm;;
      5) delete_old_backups;;
      6) exit;;
      *) echo "Optiune invalida."; read -p "Apasa Enter pentru a continua...";;
    esac
  done
}

list_vm_lxc() {
  clear
  echo -e "============ ProxMigrate ============"
  
  echo -e "\033[1;36m📦 VM-uri KVM (qm list)\033[0m"
  qm list | (read -r; echo "$REPLY"; sort -n)

  echo ""
  echo -e "\033[1;36m📦 Containere LXC (pct list)\033[0m"
  pct list | (read -r; echo "$REPLY"; sort -n)

  echo ""
  read -p "Apasa Enter pentru a reveni la meniu..."
}



create_backup() {
  read -p "ID-ul VM-ului de backup: " VM_ID
  echo "Oprire VM ${VM_ID}..."
  qm shutdown ${VM_ID}
  sleep 10
  while qm status ${VM_ID} | grep -q "status: running"; do
    echo "Asteptam oprirea VM..."
    sleep 5
  done

  echo "Creare backup..."
  vzdump ${VM_ID} --compress zstd --mode stop --storage local
  echo "Backup creat in ${BACKUP_DIR}"
  read -p "Apasa Enter pentru a reveni la meniu..."
}

transfer_backup() {
  read -p "ID-ul VM-ului de transferat: " VM_ID
  read -p "IP-ul nodului destinatie (Tailscale): " TS_IP
  BACKUP_FILE=$(ls -t ${BACKUP_DIR}/vzdump-qemu-${VM_ID}*.zst | head -n 1)
  echo "Transfer fisier: ${BACKUP_FILE} catre ${TS_IP}..."
  scp "${BACKUP_FILE}" root@${TS_IP}:${BACKUP_DIR}/
  echo "Transfer finalizat."
  read -p "Apasa Enter pentru a reveni la meniu..."
}

restore_vm() {
  read -p "ID-ul VM-ului pentru restaurare: " VM_ID
  BACKUP_FILE=$(ls -t ${BACKUP_DIR}/vzdump-qemu-${VM_ID}*.zst | head -n 1)
  echo "Restaurare din ${BACKUP_FILE} pe ID: ${VM_ID}"
  qmrestore "${BACKUP_FILE}" ${VM_ID} --storage local
  qm start ${VM_ID}
  echo "VM restaurat si pornit."
  read -p "Apasa Enter pentru a reveni la meniu..."
}

delete_old_backups() {
  echo "📦 Backupuri existente:"
  ls -lh ${BACKUP_DIR}/vzdump-qemu-*.zst
  read -p "Vrei sa stergi toate backupurile vechi ale unei VM? (ID): " VM_ID
  find ${BACKUP_DIR} -name "vzdump-qemu-${VM_ID}*.zst" -exec rm -v {} \;
  echo "Backupurile pentru VM ${VM_ID} au fost sterse."
  read -p "Apasa Enter pentru a reveni la meniu..."
}

main_menu
