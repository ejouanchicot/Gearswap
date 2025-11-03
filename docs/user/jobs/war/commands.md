# WAR - Commands Reference

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

## 🎯 WAR-Specific Commands

**File**: `shared/jobs/war/functions/WAR_COMMANDS.lua`

| Command | Description | Usage |
|---------|-------------|-------|
| `berserk` | Berserk action | `//gs c berserk` |
| `defender` | Defender action | `//gs c defender` |
| `thirdeye` | Thirdeye action | `//gs c thirdeye` |

---

## 🔍 Debug Commands

| Command | Purpose |
|---------|---------|
| `//gs c debugmidcast` | Show set selection logic |
| `//gs c watchdog` | Check watchdog status |
| `//gs c state [StateName]` | Show current state value |
