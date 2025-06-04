# ProxMigrate

Un script interactiv pentru migrarea VM-urilor între noduri Proxmox folosind backup (`vzdump`) și restaurare (`qmrestore`). Ideal pentru utilizatori care folosesc Tailscale pentru conectarea nodurilor la distanță.

## 📦 Funcționalități
- Listarea VM-urilor
- Backup complet cu `vzdump`
- Transfer backup prin `scp`
- Restaurare VM pe alt nod
- Ștergerea backupurilor vechi

## ⚙️ Instalare rapidă

1. Clonează sau copiază fișierele în folderul `proxmigrate`:
   ```bash
   git clone https://github.com/tu/proxmigrate.git
   cd proxmigrate
   ```

2. Rulează scriptul de instalare:
   ```bash
   chmod +x install.sh
   sudo ./install.sh
   ```

3. Rulează comanda:
   ```bash
   proxmigrate
   ```

## 📋 Cerințe
- Proxmox VE 7.x sau 8.x
- Acces `root` pe ambele noduri
- Rețea privată funcțională (Tailscale recomandat)
- Spațiu suficient pentru backupuri în `/var/lib/vz/dump`

## 🧠 Sugestii
- Folosește backup în `--mode stop` pentru migrare completă (sigură)
- Pentru replicare periodică, folosește `cron` + `vzdump`

## 🔐 Securitate
- Transferul între noduri se face cu `scp`, folosește chei SSH securizate
- Scriptul NU folosește HA sau live migration (nu recomandat prin WAN)

## 📄 Licență
MIT

---

Pentru întrebări sau contribuții, contactează autorul original sau deschide un issue în repo.
