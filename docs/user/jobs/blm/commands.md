# BLM - Commands Reference

---

## Universal Commands

These work on **all jobs**:

| Command | Description |
|---------|-------------|
| `//gs c checksets` | Validate equipment |
| `//gs c reload` | Full system reload |
| `//gs c lockstyle` | Reapply lockstyle |
| `//gs c ui` | Toggle UI overlay |
| `//gs c debugmidcast` | Toggle midcast debug |

---

## BLM-Specific Commands

**File**: `shared/jobs/blm/functions/BLM_COMMANDS.lua`

| Command | Description | Usage |
|---------|-------------|-------|
| `cyclemainlight` | Cyclemainlight action | `//gs c cyclemainlight` |
| `cyclemaindark` | Cyclemaindark action | `//gs c cyclemaindark` |
| `cyclesublight` | Cyclesublight action | `//gs c cyclesublight` |
| `cyclesubdark` | Cyclesubdark action | `//gs c cyclesubdark` |
| `buff` | Buff action | `//gs c buff` |
| `lightarts` | Lightarts action | `//gs c lightarts` |
| `darkarts` | Darkarts action | `//gs c darkarts` |
| `sneak` | Sneak action | `//gs c sneak` |
| `invi` | Invi action | `//gs c invi` |
| `light` | Light action | `//gs c light` |
| `dark` | Dark action | `//gs c dark` |
| `aoelight` | Aoelight action | `//gs c aoelight` |
| `aoedark` | Aoedark action | `//gs c aoedark` |
| `sublight` | Sublight action | `//gs c sublight` |
| `subdark` | Subdark action | `//gs c subdark` |
| `storm` | Storm action | `//gs c storm` |

---

## Debug Commands

| Command | Purpose |
|---------|---------|
| `//gs c debugmidcast` | Show set selection logic |
| `//gs c watchdog` | Check watchdog status |
| `//gs c state [StateName]` | Show current state value |
