# 📄 CHANGELOG

Toate modificările semnificative aduse scriptului ProxMigrate sunt documentate mai jos.


---

## [v1.3.0] - 2025-06-06

### Adaugat
- Script nou `proxdoctor` pentru verificarea completă a instalării:
  - Verifică existența fișierelor principale, directoare, comenzi și servicii
  - Include verificarea aliasului `pm` în `.bashrc`
- Instalare automată a `proxdoctor` în `install.sh` dacă lipsește
- Alias automat `pm='proxmigrate'` adăugat în `.bashrc` la instalare
- Integrare `proxdoctor` în `maintenance.sh` (opțiunea 3)
- Verificare automată dacă există o versiune mai nouă a `proxdoctor` pe GitHub (prin `Last-Modified`)
- Combinație a diagnosticului + verificării de versiune într-o singură opțiune din `maintenance.sh`

### Îmbunătățit
- Meniu de mentenanță simplificat: opțiunea 3 unifică `proxdoctor` și update check
- Separare clară între rolul scripturilor: operațional (`proxmigrate`), mentenanță (`maintenance.sh`), versiune (`proxversion`), diagnostic (`proxdoctor`)
- Claritate și feedback detaliat în loguri și în terminal

---

## [v1.2.0] - 2025-06-05

### Adaugat
- Submeniu nou **Mentenanta** în locul opțiunilor directe de Reset și Update
- Script nou `maintenance.sh` cu opțiuni:
  - Resetare completă (`reset.sh`)
  - Actualizare simplă (`update.sh`)
- Fallback profesional pentru dependințe:
  - `curl`, `unzip`, `systemctl`
- Script nou `dependencies.sh` care centralizează validările
- Script `reset.sh` cu backup opțional și reinstalare completă
- Script `update.sh` care actualizează doar binarele, fără reinstalare
- Funcție nouă `verifica_update()` integrată în `proxversion`
- Opțiune CLI: `proxversion --check-update`

### Îmbunătățit
- Separare clară între logică de operare (`proxmigrate`) și meta-informație (`proxversion`)
- Meniul principal curățat și profesionalizat
- Mesaje clare și log extins în `install.sh`
- Pauzele (`read -p`) refactorizate în `case`, nu în funcții

### Fix
- Corectare poziționare fallback `unzip`
- Eliminare `read` duplicat din `check_tailscale()`
- Detectare lipsă `scp` în `transfer_backup()`

---

## [v0.3.0] – 2025-06-04
### ✅ Adăugat
- Restaurare VM sau LXC în funcție de ID, cu detectare automată și confirmare de suprascriere
- Restaurare curată folosind `qmrestore` sau `pct restore`
- Ștergere automată a instanței existente, dacă este confirmată

---

## [v0.2.0] – 2025-06-03
### ✅ Adăugat
- Backup pentru LXC detectat automat
- Suport shutdown pentru `pct` și `qm`
- Listare sortată a VM și LXC după VMID în meniu

---

## [v0.1.0] – 2025-06-02
### ✅ Inițial
- Suport backup VM (`qm`) + restaurare VM
- Interfață în shell interactivă cu meniu text
- Instalator automat via `curl` și systemd service
