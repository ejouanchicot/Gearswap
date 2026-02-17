# FAQ

Quick answers to common questions. For detailed guides, see the links below.

---

## Getting Started

### Q: The system does not load when I log in

See [Installation Guide](../getting-started/installation.md) for full setup steps.

Short checklist: verify GearSwap is loaded (`//lua list`), check your character file is named exactly `YOURNAME_JOB.lua` (case-sensitive), and look for red error text in chat.

### Q: I get Lua errors when loading

Run `//gs c reload` first. If the error persists, check the file and line number mentioned in the error message. Verify that the `shared/` folder exists at `addons/GearSwap/data/shared/` and has not been modified.

### Q: How do I update to the latest version?

Back up your character folder, extract the new version to `addons/GearSwap/data/` (overwrite `shared/`, keep your character folder), then `//lua reload gearswap`.

---

## Equipment

### Q: Gear not swapping after a spell or weaponskill

The Watchdog system auto-recovers stuck midcast after 3.5 seconds. If it persists, run `//gs c watchdog clear` or `//gs c update`. Use `//gs c checksets` to verify your items are in inventory.

See [Watchdog Guide](../features/watchdog.md) for details.

### Q: How do I validate my equipment?

Run `//gs c checksets`. Items marked `[STORAGE]` need to be retrieved from Mog House. Items marked `[MISSING]` must be acquired or removed from your sets file.

### Q: Gear swaps too slowly or I see equipment flashing

This is normal. The system swaps through precast (Fast Cast), midcast (potency), then aftercast (idle/engaged) in sequence. If your client FPS is below 30, address that first.

---

## Lockstyle

### Q: Lockstyle not applying

Verify DressUp is loaded (`//lua list`). The default delay is 8 seconds after job load. To apply manually: `//gs c lockstyle`.

See [Configuration Guide](configuration.md) for delay tuning.

### Q: Lockstyle changes on subjob change

This is intentional. Per-subjob lockstyle is configured in `config/[job]/[JOB]_LOCKSTYLE.lua`. Set all subjob entries to the same number if you want one style for all.

---

## Keybinds

### Q: Keybinds not working

See [Keybinds Guide](keybinds.md) for full setup.

Quick checks: reload with `//gs c reload`, test the command manually (`//gs c cycle HybridMode`), and check for conflicts with other Windower addons.

### Q: What are the modifier key symbols?

| Symbol | Key |
|--------|-----|
| `!` | Alt |
| `^` | Ctrl |
| `@` | Windows |
| `#` | Shift |

Example: `!1` = Alt+1, `^f9` = Ctrl+F9.

### Q: Keybind executes the wrong command

State names are case-sensitive. `cycle MainWeapon` works, `cycle mainweapon` does not. Verify the state is defined in your job file (`state.MainWeapon = M{...}`).

---

## UI

### Q: UI not displaying

Toggle with `//gs c ui` or Alt+F1. If the UI appears off-screen, delete `ui_position.lua` from your character folder and reload.

See [UI Guide](../features/ui.md) for customization.

### Q: Keybinds not showing in UI

Each keybind entry needs a valid `state` field that matches a defined `state.StateName` in your job file.

### Q: UI position resets every login

Run `//gs c ui save` after positioning. For automatic saving, set `UIConfig.auto_save_position = true` in `config/UI_CONFIG.lua`.

---

## Watchdog

### Q: What is the Watchdog?

Automatic recovery for stuck midcast gear caused by network packet loss. It checks every 0.5 seconds and forces cleanup after 3.5 seconds.

See [Watchdog Guide](../features/watchdog.md).

### Q: Watchdog cleaning up too early during long spells

Increase the timeout: `//gs c watchdog timeout 4.5`. Default is 3.5 seconds.

---

## DualBox

### Q: How do I set up DualBox?

See [DualBox Guide](dualbox.md).

---

## Job-Specific

### Q: DNC - Waltz not selecting the correct tier

The system selects tier based on missing HP. To force a specific tier, use the macro directly: `/ja "Curing Waltz III" <stpc>`.

### Q: BST - How does the Ready Move system work?

Use `//gs c rdylist` to list available moves and `//gs c rdymove [1-6]` to execute by index. The system auto-sequences fight/move/heel based on pet and player engagement state.

### Q: RDM - How do enhancement spell cycles work?

Use `//gs c cycle GainSpell` (and similar for Barspell, BarAilment, Spike, Storm) to cycle through options. The UI shows the current selection; cast manually after cycling.

---

## Quick Troubleshooting

| Step | Command |
|------|---------|
| Reload system | `//gs c reload` |
| Validate equipment | `//gs c checksets` |
| Force gear update | `//gs c update` |
| Apply lockstyle | `//gs c lockstyle` |
| Toggle UI | `//gs c ui` |
| Test Watchdog | `//gs c watchdog test` |
| Enable debug | `//gs debugmode` |
| Load GearSwap | `//lua load gearswap` |

---

## Further Reading

- [Installation Guide](../getting-started/installation.md) - Complete setup
- [Quick Start](../getting-started/quick-start.md) - 5-minute guide
- [Commands Reference](commands.md) - All commands
- [Keybinds Guide](keybinds.md) - Customize shortcuts
- [Configuration Guide](configuration.md) - Advanced settings

---
