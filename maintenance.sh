#!/bin/bash

while true; do
  clear
  echo "🔧 Submeniu Mentenanta ProxMigrate"
  echo "====================================="
  echo "1) Resetare completă (uninstall + reinstall)"
  echo "2) Actualizare ProxMigrate"
  echo "3) Verificare instalare (proxdoctor + versiune nouă)"
  echo "4) Iesire"
  echo "====================================="
  echo ""

  read -p "Alege o optiune: " subopt

  case "$subopt" in
    1)
      echo "🔁 Rulez reset.sh..."
      curl -sL https://raw.githubusercontent.com/Douche4426/proxmigrate/main/reset.sh | bash
      read -p "Apasa Enter pentru a reveni la meniu..."
      ;;
    2)
      echo "⬆️  Actualizez ProxMigrate..."
      curl -sL https://raw.githubusercontent.com/Douche4426/proxmigrate/main/update.sh | bash
      read -p "Apasa Enter pentru a reveni la meniu..."
      ;;
    3)
      echo "🔍 Verific instalarea..."
      if command -v proxdoctor &>/dev/null; then
        proxdoctor
      else
        echo "❌ proxdoctor nu este instalat."
        echo "💡 Instaleaza-l cu:"
        echo "curl -sL https://raw.githubusercontent.com/Douche4426/proxmigrate/main/proxdoctor -o /usr/local/bin/proxdoctor && chmod +x /usr/local/bin/proxdoctor"
      fi

      echo ""
      echo "🌐 Verific versiune online..."
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
          echo "⚠️ Nu s-a putut compara versiunile."
        fi
      else
        echo "❌ 'curl' nu este disponibil."
      fi

      read -p "Apasa Enter pentru a reveni la meniu..."
      ;;
    4)
      echo "📤 Iesire din submeniul mentenanta."
      break
      ;;
    *)
      echo "❌ Optiune invalida."
      sleep 1
      ;;
  esac
done