#!/bin/bash

# === Configurare fallback log ===
LOG_FILE="${LOG_FILE:-/var/log/proxmigrate-install.log}"
echo "🔍 Verificare dependinte - $(date)" >> "$LOG_FILE"

# === Functie generica de verificare si instalare automata ===
check_dep() {
  local cmd="$1"
  local pkg="$2"
  local desc="$3"

  if ! command -v "$cmd" &>/dev/null; then
    echo "📦 '$cmd' ($desc) lipseste. Incerc instalarea automata..." | tee -a "$LOG_FILE"
    if apt update && apt install -y "$pkg" >> "$LOG_FILE" 2>&1; then
      echo "✅ '$cmd' a fost instalat cu succes." | tee -a "$LOG_FILE"
    else
      echo "❌ Eroare la instalarea '$cmd'. Instaleaza-l manual si ruleaza din nou scriptul." | tee -a "$LOG_FILE"
      exit 1
    fi
  else
    echo "✅ '$cmd' este deja prezent." >> "$LOG_FILE"
  fi
}

# === Verificari esentiale ===
check_dep curl curl "utilitar pentru descarcare HTTP"
check_dep unzip unzip "utilitar pentru extragere arhive ZIP"

# === Verificare speciala pentru systemctl (fara instalare automata) ===
if ! command -v systemctl &>/dev/null; then
  echo "⚠️ 'systemctl' lipseste. Timerul systemd va fi sarit." | tee -a "$LOG_FILE"
  SKIP_SYSTEMD=1
else
  echo "✅ 'systemctl' este disponibil." >> "$LOG_FILE"
fi