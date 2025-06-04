#!/bin/bash
# Script pentru backup automat VM (ex: VM_ID=100) rulabil prin cron

VM_ID=100
DATE=$(date +%Y-%m-%d_%H-%M)
BACKUP_DIR="/var/lib/vz/dump"

echo "[$DATE] Incep backup VM $VM_ID" >> /var/log/proxmigrate.log
vzdump $VM_ID --compress zstd --mode snapshot --storage local >> /var/log/proxmigrate.log 2>&1
echo "[$DATE] Finalizat" >> /var/log/proxmigrate.log
