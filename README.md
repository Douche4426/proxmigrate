# ProxMigrate

Un script interactiv pentru migrarea VM-urilor între noduri Proxmox folosind backup (`vzdump`) și restaurare (`qmrestore`). Ideal pentru utilizatori care folosesc Tailscale pentru conectarea nodurilor la distanță.

---

## 🚀 Instalare rapidă

Rulează comanda de mai jos pe nodul Proxmox:

```bash
bash <(curl -s https://raw.githubusercontent.com/Douche4426/proxmigrate/main/install.sh)
````

---

## 🛠️ Ce face ProxMigrate?

* ✅ Backup manual sau automat (VM-uri alese sau doar cele pornite)
* 🔁 Restaurare rapidă a VM-urilor
* 📡 Transfer între noduri prin Tailscale
* 🔔 Notificări prin **Discord webhook**
* 🎛️ Meniu interactiv în terminal
* ⏱️ Serviciu `systemd` zilnic pentru backup automat
* 🧹 Script de dezinstalare completă

---

## 📦 Structura

| Script/Fisier                    | Rol                                                                |
| -------------------------------- | ------------------------------------------------------------------ |
| `proxmigrate`                    | Meniul interactiv principal                                        |
| `cron-backup-running-discord.sh` | Backup automat doar pentru VM-urile pornite, cu notificare Discord |
| `proxmigrate-backup.service`     | Serviciu systemd pentru backup                                     |
| `proxmigrate-backup.timer`       | Timer zilnic la ora 03:00                                          |
| `install.sh`                     | Script de instalare                                                |
| `uninstall-proxmigrate.sh`       | Script de dezinstalare                                             |

---

## 📋 Cerințe
- Proxmox VE 7.x sau 8.x
- Acces `root` pe ambele noduri
- Rețea privată funcțională (Tailscale recomandat)
- Spațiu suficient pentru backupuri în `/var/lib/vz/dump`

---

## 📤 Notificări Discord

Configurează `WEBHOOK_URL` în `cron-backup-running-discord.sh` cu linkul tău personalizat de webhook Discord:

```bash
WEBHOOK_URL="https://discord.com/api/webhooks/xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

---

## 🧹 Dezinstalare

Rulează:

```bash
bash uninstall-proxmigrate.sh
```

---

## 📋 Capturi de ecran

![Meniul ProxMigrate](https://raw.githubusercontent.com/alexs/proxmigrate/main/screenshots/menu.png)

---

## 📄 Licență
MIT

---

Pentru întrebări sau contribuții, contactează autorul original sau deschide un issue în repo.
