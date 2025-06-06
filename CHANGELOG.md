# 📄 CHANGELOG

Toate modificările semnificative aduse scriptului ProxMigrate sunt documentate mai jos.

## [v1.2.0] - 2025-06-05
### Adaugat
- Submeniu nou "Mentenanta" în locul optiunilor 9 (reset) si 10 (update)
- Script nou `maintenance.sh` cu optiuni resetare si actualizare
- Fallback profesional pentru dependințe (curl, unzip, systemctl)
- Script `update.sh` pentru actualizare rapida
- Script `reset.sh` cu backup optional si reinstalare completa

### Imbunatatit
- Meniul principal ProxMigrate este acum mai curat si modular
- Mesaje de status și loguri extinse în `install.sh`

### Fix
- Corectat fallback unzip (pozitionare incorecta)
- Eliminat `read` duplicat din `check_tailscale()`

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
