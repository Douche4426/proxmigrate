#!/bin/bash

# ProxMigrate - Meniu interactiv pentru migrare VM prin backup vzdump + qmrestore

BACKUP_DIR="/var/lib/vz/dump"

main_menu() {
  while true; do
    clear
    echo "=========== ProxMigrate ==========="
    echo "1) Listeaza toate VM/LXC disponibile"
    echo "2) Creeaza backup VM/LXC (vzdump)"
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
  read -p "ID-ul VM/LXC pentru backup: " VM_ID

  # Detecteaza tipul: vm (KVM) sau lxc
  if qm status ${VM_ID} &>/dev/null; then
    echo "🔌 Oprire VM ${VM_ID}..."
    qm shutdown ${VM_ID}
    while qm status ${VM_ID} | grep -q "status: running"; do
      echo "⏳ Asteptam oprirea VM..."
      sleep 5
    done
  elif pct status ${VM_ID} &>/dev/null; then
    echo "🔌 Oprire container LXC ${VM_ID}..."
    pct shutdown ${VM_ID}
    while pct status ${VM_ID} | grep -q "status: running"; do
      echo "⏳ Asteptam oprirea LXC..."
      sleep 5
    done
  else
    echo "❌ Nu s-a gasit nicio masina sau container cu ID-ul ${VM_ID}"
    read -p "Apasa Enter pentru a reveni la meniu..."
    return
  fi

  echo "💾 Creare backup..."
  vzdump ${VM_ID} --compress zstd --mode stop --storage local
  echo "✅ Backup creat pentru ${VM_ID}"
  read -p "Apasa Enter pentru a reveni la meniu..."
}


transfer_backup() {
  read -p "ID-ul VM/LXC de transferat: " VM_ID
  read -p "IP-ul nodului destinatie (Tailscale): " TS_IP

  BACKUP_FILE=$(ls -t ${BACKUP_DIR}/vzdump-{qemu,lxc}-${VM_ID}-*.zst 2>/dev/null | head -n 1)

  if [[ -z "$BACKUP_FILE" ]]; then
    echo "❌ Nu s-a gasit niciun backup pentru ID-ul $VM_ID!"
    read -p "Apasa Enter pentru a reveni la meniu..."
    return
  fi

  echo "Transfer fisier: ${BACKUP_FILE} catre ${TS_IP}..."
  scp "${BACKUP_FILE}" root@${TS_IP}:${BACKUP_DIR}/
  echo "✅ Transfer finalizat."
  read -p "Apasa Enter pentru a reveni la meniu..."
}


restore_vm() {
  read -p "ID-ul VM/LXC pentru restaurare: " VM_ID

  # Cauta fișierul de backup (LXC sau VM)
  BACKUP_FILE=$(ls -t ${BACKUP_DIR}/vzdump-qemu-${VM_ID}*.zst 2>/dev/null | head -n 1)
  TYPE="qemu"
  if [[ -z "$BACKUP_FILE" ]]; then
    BACKUP_FILE=$(ls -t ${BACKUP_DIR}/vzdump-lxc-${VM_ID}*.zst 2>/dev/null | head -n 1)
    TYPE="lxc"
  fi

  if [[ -z "$BACKUP_FILE" ]]; then
    echo "❌ Nu s-a gasit niciun backup pentru ID-ul ${VM_ID}."
    read -p "Apasa Enter pentru a reveni la meniu..."
    return
  fi

  # Daca VM sau LXC cu acest ID deja exista, cere confirmare pentru stergere
  if qm status ${VM_ID} &>/dev/null || pct status ${VM_ID} &>/dev/null; then
    echo "⚠️  Exista deja o instanta cu ID-ul ${VM_ID}."
    read -p "Doresti sa o stergi inainte de restaurare? [y/N]: " CONFIRM
    if [[ $CONFIRM =~ ^[Yy]$ ]]; then
      echo "🗑️ Stergere ${TYPE} ${VM_ID}..."
      if [[ $TYPE == "qemu" ]]; then
        qm destroy ${VM_ID} --purge
      else
        pct destroy ${VM_ID}
      fi
    else
      echo "❌ Restaurarea a fost anulata."
      read -p "Apasa Enter pentru a reveni la meniu..."
      return
    fi
  fi

  echo "📦 Restaurare din ${BACKUP_FILE}..."
  if [[ $TYPE == "qemu" ]]; then
    qmrestore "$BACKUP_FILE" ${VM_ID} --storage local
    qm start ${VM_ID}
    echo "✅ VM restaurata si pornita."
  else
    pct restore ${VM_ID} "$BACKUP_FILE" --storage local
    pct start ${VM_ID}
    echo "✅ Container LXC restaurat si pornit."
  fi

  read -p "Apasa Enter pentru a reveni la meniu..."
}


delete_old_backups() {
  echo "🗃️ Backupuri existente:"

  if ls ${BACKUP_DIR}/vzdump-{qemu,lxc}-*.zst &>/dev/null; then
    ls -lh ${BACKUP_DIR}/vzdump-{qemu,lxc}-*.zst
  else
    echo "❌ Nu exista backupuri in ${BACKUP_DIR}"
  fi

  read -p "Vrei sa stergi toate backupurile vechi ale unei VM/LXC? (ID): " VM_ID

  # Sterge atat backupurile pentru VM, cat si cele pentru LXC cu ID-ul dat
  find ${BACKUP_DIR} -type f \( -name "vzdump-qemu-${VM_ID}-*.zst" -o -name "vzdump-lxc-${VM_ID}-*.zst" \) -exec rm -v {} \;

  echo "🗑️ Backupurile pentru ID ${VM_ID} au fost sterse (daca existau)."
  read -p "Apasa Enter pentru a reveni la meniu..."
}


main_menu
