# Engine Purity Rule

**The `app/` directory is the MPT engine and must never be modified.**

This directory contains the core MoneyPrinterTurbo engine code. All changes must be additive only:
- ✅ `resource/fonts/` — fonts only
- ✅ `Dockerfile*`, `start-*.sh`, `config*.toml`, `RUNPOD.md` — deployment only
- ❌ `app/` — NEVER modify

If you need to change the engine, get explicit approval first.

**Pre-commit hook:** A local hook exists at `.git/hooks/pre-commit` that blocks commits touching `app/`. This is advisory only (hooks aren't pushed to git).
