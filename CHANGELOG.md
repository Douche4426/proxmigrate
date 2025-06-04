# 📄 CHANGELOG

Toate modificările semnificative aduse scriptului ProxMigrate sunt documentate mai jos.

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
