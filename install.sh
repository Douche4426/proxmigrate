#!/bin/bash

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="proxmigrate"

echo "🔧 Instalare ProxMigrate în ${INSTALL_DIR}..."

# Copiere script
cp proxmigrate.sh "${INSTALL_DIR}/${SCRIPT_NAME}"

# Permisiuni
chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"

echo "✅ Instalare completă!"
echo "ℹ️ Acum poți rula comanda: proxmigrate"
