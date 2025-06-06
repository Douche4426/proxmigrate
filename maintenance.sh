#!/bin/bash

echo ""
echo "🧰 Submeniu Mentenanta ProxMigrate"
echo "1) Resetare completă (uninstall + reinstall)"
echo "2) Actualizare ProxMigrate"
echo "3) Iesire"
echo ""

read -p "Alege o optiune: " opt

case $opt in
  1)
    curl -sL https://raw.githubusercontent.com/Douche4426/proxmigrate/main/reset.sh | bash
    ;;
  2)
    curl -sL https://raw.githubusercontent.com/Douche4426/proxmigrate/main/update.sh | bash
    ;;
  *)
    echo "📤 Iesire din submeniu mentenanta."
    ;;
esac
