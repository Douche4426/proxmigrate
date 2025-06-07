#!/bin/bash
# ProxMigrate - Meniu interactiv pentru migrare VM prin backup vzdump + qmrestore

BACKUP_DIR="/var/lib/vz/dump"
mkdir -p "$BACKUP_DIR"

main_menu() {
  while true; do
    clear
    if command -v proxversion &>/dev/null; then
      proxversion
    fi
    echo "=========== ProxMigrate ==========="
    echo "1) Listeaza toate VM/LXC disponibile"
    echo "2) Creeaza backup VM/LXC (vzdump)"
    echo "3) Transfera backup catre alt nod"
    echo "4) Restaureaza VM din backup"
    echo "5) Mentenanta ProxMigrate"
    echo "6) Setari Tailscale"
    echo "0) Iesire"
    echo "===================================="
    read -p "Selecteaza optiunea: " opt

    case $opt in
      1) list_vm_lxc;;
      2) create_backup;;
      3) transfer_backup;;
      4) restore_vm;;
      5) maintenance_submenu ;;
      6) settings_submenu ;;
      0) exit;;
      *) echo "Optiune invalida."; read -p "Apasa Enter pentru a continua...";;
    esac
  done
}

check_tailscale() {
  echo "🔌 Verific conexiunea Tailscale..."

  if ! tailscale status &>/dev/null; then
    echo "⚠️  Nu ești conectat la Tailscale."

    if [ -x /usr/local/bin/tailmox.sh ]; then
      if [[ -f /etc/proxmigrate/tailscale-auth-key ]]; then
        AUTH_KEY=$(cat /etc/proxmigrate/tailscale-auth-key)
        tailmox.sh --auth-key "$AUTH_KEY"
      else
        tailmox.sh
      fi
    else
      echo "❌ tailmox.sh nu este instalat în /usr/local/bin/"
      read -p "Apasa Enter pentru a reveni la meniu..."
      return 1
    fi

    sleep 5
    if tailscale status &>/dev/null; then
      echo "✅ Conectat cu succes la Tailscale!"
    else
      echo "❌ Conexiunea Tailscale a eșuat."
      read -p "Apasa Enter pentru a reveni la meniu..."
      return 1
    fi
  else
    echo "✅ Conexiune Tailscale activă."
  fi
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
  if ! command -v scp &>/dev/null; then
    echo "❌ Comanda 'scp' lipseste pe acest sistem."
    echo "ℹ️ Instaleaza-o cu: apt install openssh-client"
    read -p "Apasa Enter pentru a reveni la meniu..."
    return 1
  fi

  check_tailscale
  if ! tailscale status &>/dev/null; then
    return
  fi

  read -p "🔁 Apasa Enter pentru a continua procesul..."


  echo "📦 Backupuri disponibile:"
  ls -1t /var/lib/vz/dump/vzdump-{qemu,lxc}-*.zst 2>/dev/null | sed 's|.*/||' | awk '{print "  → " $1}'

  read -p "ID-ul VM/LXC de transferat: " VM_ID
  TS_IP=$(select_node_ip) || return

  BACKUP_FILE=$(ls -t ${BACKUP_DIR}/vzdump-{qemu,lxc}-${VM_ID}-*.zst 2>/dev/null | head -n 1)

  if [[ -z "$BACKUP_FILE" ]]; then
    echo "❌ Nu s-a gasit niciun backup pentru ID-ul $VM_ID!"
    read -p "Apasa Enter pentru a reveni la meniu..."
    return
  fi

  echo "🚀 Transfer fisier: ${BACKUP_FILE} catre ${TS_IP}..."
  scp "${BACKUP_FILE}" root@${TS_IP}:${BACKUP_DIR}/
  echo "✅ Transfer finalizat."
  read -p "Apasa Enter pentru a reveni la meniu..."
}


restore_vm() {
  if ! command -v qm &>/dev/null && ! command -v pct &>/dev/null; then
    echo "❌ Nici qm, nici pct nu sunt disponibile pe acest nod. Restore imposibil."
    read -p "Apasa Enter pentru a reveni la meniu..."
    return 1
  fi

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
  echo "📦 Spatiu ocupat de backupuri ramase:"
  du -sh ${BACKUP_DIR}/vzdump-* 2>/dev/null
  read -p "Apasa Enter pentru a reveni la meniu..."
}

set_tailscale_auth_key() {
  read -p "Introdu Tailscale Auth-Key (tskey-...): " AUTH
  if [[ $AUTH == tskey-* && ${#AUTH} -ge 25 ]]; then
    mkdir -p /etc/proxmigrate
    echo "$AUTH" > /etc/proxmigrate/tailscale-auth-key
    echo "✅ Auth-Key salvat cu succes in /etc/proxmigrate/tailscale-auth-key"
  else
    echo "❌ Cheia nu pare valida. Trebuie sa inceapa cu 'tskey-'"
  fi
  read -p "Apasa Enter pentru a reveni la meniu..."
}

configure_tailscale_nodes() {
  mkdir -p /etc/proxmigrate
  NODES_FILE="/etc/proxmigrate/nodes.conf"

  while true; do
    clear
    echo "🌐 Noduri Tailscale configurate:"
    if [[ -s "$NODES_FILE" ]]; then
      nl -w2 -s") " "$NODES_FILE"
    else
      echo "  (niciun nod salvat)"
    fi

    echo ""
    echo "1) Adauga nod nou"
    echo "2) Sterge un nod"
    echo "3) Iesire la meniu"
    read -p "Selecteaza optiunea: " opt

    case $opt in
      1)
        read -p "Nume nod (ex: belgia): " NODE_NAME
        read -p "IP Tailscale (ex: 100.x.x.x): " NODE_IP
        if grep -q "^$NODE_NAME=" "$NODES_FILE"; then
          sed -i "s|^$NODE_NAME=.*|$NODE_NAME=$NODE_IP|" "$NODES_FILE"
          echo "✏️ Nodul '$NODE_NAME' a fost actualizat."
        else
          echo "$NODE_NAME=$NODE_IP" >> "$NODES_FILE"
          echo "➕ Nodul '$NODE_NAME' a fost adaugat."
        fi
        sleep 1
        ;;
      2)
        read -p "Nume nod de sters: " DEL_NODE
        sed -i "/^$DEL_NODE=/d" "$NODES_FILE"
        echo "🗑️ Nodul '$DEL_NODE' a fost sters."
        sleep 1
        ;;
      3)
        break
        ;;
      *)
        echo "❌ Optiune invalida."
        sleep 1
        ;;
    esac
  done
}

select_node_ip() {
  NODES_FILE="/etc/proxmigrate/nodes.conf"
  if [[ ! -s "$NODES_FILE" ]]; then
    echo "❌ Nu exista noduri Tailscale salvate. Configureaza-le mai intai!"
    sleep 2
    return 1
  fi

  echo "🔗 Alege nodul de destinatie:"
  NODES=()
  INDEX=1

  while IFS='=' read -r name ip; do
    echo "$INDEX) $name ($ip)"
    NODES+=("$ip")
    INDEX=$((INDEX + 1))
  done < "$NODES_FILE"

  echo ""
  read -p "Selecteaza numarul nodului: " SELECTED
  if ! [[ "$SELECTED" =~ ^[0-9]+$ ]] || (( SELECTED < 1 || SELECTED > ${#NODES[@]} )); then
    echo "❌ Selectie invalida."
    sleep 2
    return 1
  fi
  NODE_IP="${NODES[$((SELECTED-1))]}"

  echo "📡 Nod selectat: $SELECTED_IP"
  echo "$SELECTED_IP"
}

reset_proxmigrate() {
  echo "🔁 Execut reset complet (uninstall + reinstall)..."
  curl -sL https://raw.githubusercontent.com/Douche4426/proxmigrate/main/reset.sh | bash
  read -p "Apasa Enter pentru a reveni la meniu..."
}

update_proxmigrate() {
  echo "⬆️ Execut update ProxMigrate..."
  curl -sL https://raw.githubusercontent.com/Douche4426/proxmigrate/main/update.sh | bash
  read -p "Apasa Enter pentru a reveni la meniu..."
}

verify_proxmigrate() {
  echo "🔍 Verificare ProxMigrate..."

  if command -v proxdoctor &>/dev/null; then
    proxdoctor
  else
    echo "❌ proxdoctor nu este instalat."
    echo "💡 Instaleaza-l cu:"
    echo "curl -sL https://raw.githubusercontent.com/Douche4426/proxmigrate/main/proxdoctor -o /usr/local/bin/proxdoctor && chmod +x /usr/local/bin/proxdoctor"
  fi

  echo ""
  echo "🌐 Verific daca exista versiune noua..."

  REMOTE_URL="https://raw.githubusercontent.com/Douche4426/proxmigrate/main/proxdoctor"
  LOCAL_FILE="/usr/local/bin/proxdoctor"

  if command -v curl &>/dev/null; then
    REMOTE_DATE=$(curl -sI "$REMOTE_URL" | grep -i '^last-modified:' | cut -d' ' -f2-)
    LOCAL_DATE=$(stat -c %y "$LOCAL_FILE" 2>/dev/null | cut -d'.' -f1)

    if [[ -n "$REMOTE_DATE" && -n "$LOCAL_DATE" ]]; then
      if [[ "$(date -d "$REMOTE_DATE" +%s)" -gt "$(date -d "$LOCAL_DATE" +%s)" ]]; then
        echo "⬆️ Exista o versiune mai noua a proxdoctor!"
      else
        echo "✅ proxdoctor este la zi."
      fi
    else
      echo "⚠️ Nu s-au putut compara versiunile."
    fi
  else
    echo "❌ comanda 'curl' lipseste."
  fi

  read -p "Apasa Enter pentru a reveni la meniu..."
}

maintenance_submenu() {
  while true; do
    clear
    echo "📕 Submeniul Mentenanta ProxMigrate"
    echo "1) Resetare completă (uninstall + reinstall)"
    echo "2) Actualizare ProxMigrate"
    echo "3) Verificare instalare (proxdoctor + versiune noua)"
    echo "4) Sterge backupuri vechi"
    echo "5) Iesire"
    echo "======================================"
    read -p "Selecteaza optiunea: " subopt

    case $subopt in
      1) reset_proxmigrate ;;
      2) update_proxmigrate ;;
      3) verify_proxmigrate ;;
      4) delete_old_backups ;;
      5) echo "📤 Iesire din submeniul mentenanta."; break ;;
      *) echo "❌ Optiune invalida!"; sleep 1 ;;
    esac
  done
}

settings_submenu() {
  while true; do
    clear
    echo "🛠 Submeniul Setari Tailscale"
    echo "1) Verifica conexiunea Tailscale"
    echo "2) Seteaza Auth-Key Tailscale"
    echo "3) Configureaza noduri Tailscale"
    echo "4) Iesire"
    echo "=============================="
    read -p "Selecteaza optiunea: " setopt

    case $setopt in
      1) check_tailscale ;;
      2) set_tailscale_auth_key ;;
      3) configure_tailscale_nodes ;;
      4) echo "📤 Iesire din setari."; break ;;
      *) echo "❌ Optiune invalida!"; sleep 1 ;;
    esac
  done
}



main_menu
