# COR - Commands Reference

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

## 🎯 COR-Specific Commands

**File**: `shared/jobs/cor/functions/COR_COMMANDS.lua`

| Command | Description | Usage |
|---------|-------------|-------|
| `rolls` | Rolls action | `//gs c rolls` |
| `clearrolls` | Clearrolls action | `//gs c clearrolls` |
| `party` | Party action | `//gs c party` |
| `clearparty` | Clearparty action | `//gs c clearparty` |
| `shot` | Shot action | `//gs c shot` |

---

## 🔍 Debug Commands

| Command | Purpose |
|---------|---------|
| `//gs c debugmidcast` | Show set selection logic |
| `//gs c watchdog` | Check watchdog status |
| `//gs c state [StateName]` | Show current state value |
