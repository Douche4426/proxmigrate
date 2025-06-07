#!/bin/bash

while true; do
  echo ""
  echo "🧰 Submeniu Mentenanta ProxMigrate"
  echo "1) Resetare completă (uninstall + reinstall)"
  echo "2) Actualizare ProxMigrate"
  echo "3) Verificare instalare (proxdoctor + versiune noua)"
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
      echo ""
      echo "🔎 Verificare generala ProxMigrate + proxdoctor"

      if command -v proxdoctor &>/dev/null; then
        proxdoctor
      else
        echo "❌ proxdoctor nu este instalat."
        echo "💡 Ruleaza install.sh sau descarca manual:"
        echo "curl -sL https://raw.githubusercontent.com/Douche4426/proxmigrate/main/proxdoctor -o /usr/local/bin/proxdoctor && chmod +x /usr/local/bin/proxdoctor"
      fi

      echo ""
      echo "🌐 Verific daca exista o versiune mai noua a proxdoctor..."
      REMOTE_URL="https://raw.githubusercontent.com/Douche4426/proxmigrate/main/proxdoctor"
      LOCAL_FILE="/usr/local/bin/proxdoctor"

      if command -v curl &>/dev/null; then
        REMOTE_DATE=$(curl -sI "$REMOTE_URL" | grep -i '^last-modified:' | cut -d' ' -f2-)
        LOCAL_DATE=$(stat -c %y "$LOCAL_FILE" 2>/dev/null | cut -d'.' -f1)

        if [[ -n "$REMOTE_DATE" && -n "$LOCAL_DATE" ]]; then
          if [[ "$(date -d "$REMOTE_DATE" +%s)" -gt "$(date -d "$LOCAL_DATE" +%s)" ]]; then
            echo "⬆️  Exista o versiune noua a proxdoctor!"
            echo "💡 Actualizeaza cu:"
            echo "curl -sL $REMOTE_URL -o $LOCAL_FILE && chmod +x $LOCAL_FILE"
          else
            echo "✅ proxdoctor este la zi."
          fi
        else
          echo "⚠️ Nu am putut compara datele de versiune."
        fi
      else
        echo "❌ 'curl' lipseste. Nu pot verifica."
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
