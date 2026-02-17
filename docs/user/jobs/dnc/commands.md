# DNC - Commands Reference

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

## DNC-Specific Commands

**File**: `shared/jobs/dnc/functions/DNC_COMMANDS.lua`

| Command | Description | Usage |
|---------|-------------|-------|
| `smartbuff` | Smartbuff action | `//gs c smartbuff` |
| `step` | Step action | `//gs c step` |

---

## Debug Commands

| Command | Purpose |
|---------|---------|
| `//gs c debugmidcast` | Show set selection logic |
| `//gs c watchdog` | Check watchdog status |
| `//gs c state [StateName]` | Show current state value |
