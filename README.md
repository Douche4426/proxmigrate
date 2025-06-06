Perfect, Alex! Mai jos ai versiunea **actualizată și profesionistă a `README.md`**, în acord cu toate modificările recente:

---

# ProxMigrate

Un tool interactiv pentru backup, restaurare și migrare VM/LXC între noduri Proxmox — local sau remote — folosind Tailscale. Include notificări Discord, alias shell, submeniuri de mentenanță și diagnostic complet (`proxdoctor`).

---

## 🚀 Instalare rapidă

Rulează comanda de mai jos pe nodul Proxmox:

```bash
bash <(curl -s https://raw.githubusercontent.com/Douche4426/proxmigrate/main/install.sh)
```

Aliasul `pm` va fi creat automat pentru rulare rapidă:

```bash
pm
```

---

## 🛠️ Ce face ProxMigrate?

* ✅ Backup VM sau LXC (manual sau automat doar cele pornite)
* 🔁 Restaurare rapidă din backupuri locale
* 📡 Transfer între noduri Proxmox prin Tailscale (VM + LXC)
* 🔔 Notificări în timp real prin **Discord webhook**
* 🧰 Submeniu „Mentenanta” (resetare, actualizare, diagnostic)
* ⏱️ Serviciu `systemd` zilnic pentru backup automat
* 🧪 Script `proxdoctor` pentru verificare completă instalare
* 📦 Alias rapid: `pm` = `proxmigrate`

---

## 🧰 Submeniu Mentenanta

Accesibil din meniul principal (opțiunea 9):

* Resetare completă (dezinstalare + reinstalare)
* Actualizare scripturi din GitHub
* Diagnostic complet cu `proxdoctor`
* Verificare dacă există o versiune mai nouă a `proxdoctor`

---

## 📦 Structura

| Script/Fisier                    | Rol                                                          |
| -------------------------------- | ------------------------------------------------------------ |
| `proxmigrate`                    | Meniul principal                                             |
| `maintenance.sh`                 | Submeniu cu opțiuni de reset/update/diagnostic               |
| `proxversion`                    | Afișează versiunea și changelog-ul                           |
| `proxdoctor`                     | Diagnostic complet: fișiere, comenzi, servicii, alias        |
| `cron-backup-running-discord.sh` | Backup automat doar pentru cele pornite + notificare Discord |
| `install.sh`                     | Instalează tot pachetul ProxMigrate                          |
| `reset.sh`                       | Dezinstalare + reinstalare curată cu backup opțional         |
| `update.sh`                      | Actualizează scripturile fără reinstalare completă           |
| `uninstall-proxmigrate.sh`       | Dezinstalare completă                                        |

---

## 📋 Cerințe

* Proxmox VE 7.x sau 8.x
* Acces root
* Tailscale activ pe ambele noduri
* `curl`, `unzip`, `scp`, `qm`, `pct` disponibile
* Spațiu suficient în `/var/lib/vz/dump`

---

## 🔔 Notificări Discord

Configurează webhook-ul în:

```bash
/etc/proxmigrate/discord-webhook.conf
```

Exemplu:

```bash
WEBHOOK_URL="https://discord.com/api/webhooks/xxxxxxxxxxxxxxxxxxxx"
```

---

## 🧹 Dezinstalare

```bash
bash <(curl -s https://raw.githubusercontent.com/Douche4426/proxmigrate/main/uninstall-proxmigrate.sh)
```

---

## 📄 Licență

MIT

---

## 💬 Suport

Deschide un issue în GitHub sau contactează creatorul scriptului pentru întrebări/contribuții.

---
