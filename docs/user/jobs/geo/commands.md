# GEO - Commands Reference

---

## 🌐 Universal Commands

These work on **all jobs**:

| Command | Description |
|---------|-------------|
| `//gs c checksets` | Validate equipment |
| `//gs c reload` | Full system reload |
| `//gs c lockstyle` | Reapply lockstyle |
| `//gs c ui` | Toggle UI overlay |
| `//gs c debugmidcast` | Toggle midcast debug |

---

## 🎯 GEO-Specific Commands

**File**: `shared/jobs/geo/functions/GEO_COMMANDS.lua`

| Command | Description | Usage |
|---------|-------------|-------|
| `indi` | Indi action | `//gs c indi` |
| `geo` | Geo action | `//gs c geo` |
| `entrust` | Entrust action | `//gs c entrust` |
| `lightspell` | Lightspell action | `//gs c lightspell` |
| `darkspell` | Darkspell action | `//gs c darkspell` |
| `lightaoe` | Lightaoe action | `//gs c lightaoe` |
| `darkaoe` | Darkaoe action | `//gs c darkaoe` |

---

## 🔍 Debug Commands

| Command | Purpose |
|---------|---------|
| `//gs c debugmidcast` | Show set selection logic |
| `//gs c watchdog` | Check watchdog status |
| `//gs c state [StateName]` | Show current state value |
