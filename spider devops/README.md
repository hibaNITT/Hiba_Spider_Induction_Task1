# Project Vault Sweep

This project was made for my Spider DevOps Basic Task submission.  
The goal was to scan a directory, detect dangerous shell scripts, clean environment files, and log everything with timestamps.

---

## Files in This Repo

- **vault_sweep.sh** → Main script that:
  - Scans `.sh` files for destructive commands, suspicious downloads, or insecure permissions
  - Cleans `.env` files and outputs `.env.sanitized`
  - Logs all actions into `vault_sweep.log`

- **vault_sweep.log** → Log file showing warnings, fixes, and info with timestamps

- **REPORT.md** → Explains:
  - Dangerous patterns flagged and why
  - Why certain `.env` lines were rejected
  - Technical hurdles I faced and how I solved them

- **Test Inputs **
  - `.env` → Original environment file
  - `.env.sanitized` → Cleaned output file
  - `danger_rm` → Contains `rm -rf /` (destructive command)
  - `danger_pipe` → Contains `curl | sh` (suspicious download)
  - `.hidden_threat` → Hidden malicious script
  - `clean_script` → Safe script (valid test case)

---

## What the Scripts Detect

- **Destructive commands** like `rm -rf /`, `mkfs`, `shutdown`, `reboot`
- **Suspicious downloads** using `curl` or `wget` piped into `sh`/`bash`
- **Insecure permissions** (world‑writable files such as `chmod 777`)
- **Invalid `.env` lines** (spaces around `=`, hyphens in keys, quotes, PATH modifications, or secrets like PASSWORD/TOKEN)

---

## 🛠 How It Works

1. Run `vault_sweep.sh` on a target directory:
   ```bash
   ./vault_sweep.sh ./devops_test_sandbox
   ```
2. Script scans all files recursively.
3. Warnings are printed in the format:
   ```
   [WARN] scripts/danger_rm  Reason: contains rm -rf /
   ```
4. If permissions are insecure, script asks:
   ```
   Fix it? (y/n)
   ```
   If you type `y`, it fixes the permission and logs the action.
5. `.env` files are cleaned and saved as `.env.sanitized`.
6. All results are logged in `vault_sweep.log`.

---

### Created by Hiba for Spider DevOps Induction 2026.
