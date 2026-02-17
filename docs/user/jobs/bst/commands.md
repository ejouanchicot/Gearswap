# BST - Commands Reference

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

## BST-Specific Commands

**File**: `shared/jobs/bst/functions/BST_COMMANDS.lua`

| Command | Description | Usage |
|---------|-------------|-------|
| `ecosystem` | Ecosystem action | `//gs c ecosystem` |
| `species` | Species action | `//gs c species` |
| `pet` | Pet action | `//gs c pet` |
| `rdylist` | Rdylist action | `//gs c rdylist` |
| `rdymove` | Rdymove action | `//gs c rdymove` |

---

## Debug Commands

| Command | Purpose |
|---------|---------|
| `//gs c debugmidcast` | Show set selection logic |
| `//gs c watchdog` | Check watchdog status |
| `//gs c state [StateName]` | Show current state value |
