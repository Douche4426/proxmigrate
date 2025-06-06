#!/bin/bash

echo ""
echo "🧰 Submeniu Mentenanta ProxMigrate"
echo "1) Resetare completă (uninstall + reinstall)"
echo "2) Actualizare ProxMigrate"
echo "3) Verifica instalarea (ProxDoctor)"
echo "4) Iesire"
echo ""

read -p "Alege o optiune: " opt

case $opt in
  1)
    curl -sL https://raw.githubusercontent.com/Douche4426/proxmigrate/main/reset.sh | bash
    ;;
  2)
    curl -sL https://raw.githubusercontent.com/Douche4426/proxmigrate/main/update.sh | bash
    ;;
  3)
    if [[ -f /usr/local/bin/proxdoctor ]]; then
      proxdoctor
    else
      curl -sL https://raw.githubusercontent.com/Douche4426/proxmigrate/main/proxdoctor -o /usr/local/bin/proxdoctor
      chmod +x /usr/local/bin/proxdoctor
      proxdoctor
    fi
    ;;
  *)
    echo "📤 Iesire din submeniu mentenanta."
    ;;
esac

