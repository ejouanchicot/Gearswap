# BRD - Commands Reference

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

## BRD-Specific Commands

**File**: `shared/jobs/brd/functions/BRD_COMMANDS.lua`

| Command | Description | Usage |
|---------|-------------|-------|
| `nt` | Nt action | `//gs c nt` |
| `lullaby` | Lullaby action | `//gs c lullaby` |
| `elegy` | Elegy action | `//gs c elegy` |
| `requiem` | Requiem action | `//gs c requiem` |
| `dummy1` | Dummy1 action | `//gs c dummy1` |
| `dummy2` | Dummy2 action | `//gs c dummy2` |
| `threnody` | Threnody action | `//gs c threnody` |
| `carol` | Carol action | `//gs c carol` |
| `etude` | Etude action | `//gs c etude` |
| `song1` | Song1 action | `//gs c song1` |
| `song2` | Song2 action | `//gs c song2` |
| `song3` | Song3 action | `//gs c song3` |
| `song4` | Song4 action | `//gs c song4` |
| `song5` | Song5 action | `//gs c song5` |

---

## Debug Commands

| Command | Purpose |
|---------|---------|
| `//gs c debugmidcast` | Show set selection logic |
| `//gs c watchdog` | Check watchdog status |
| `//gs c state [StateName]` | Show current state value |
