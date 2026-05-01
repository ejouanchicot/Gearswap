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

The Watchdog auto-recovers stuck midcast on a dynamic timeout (the spell's
cast time + 1.5s buffer). If it persists, run `//gs c update` to force a
gear refresh, or `//gs c info` to see the watchdog state. Use
`//gs c checksets` to verify your items are in inventory.

See [Watchdog Guide](../features/watchdog.md) for details.

### Q: How do I validate my equipment?

Run `//gs c checksets`. Items marked `[STORAGE]` need to be retrieved from Mog House. Items marked `[MISSING]` must be acquired or removed from your sets file.

### Q: Gear swaps too slowly or I see equipment flashing

This is normal. The system swaps through precast (Fast Cast), midcast (potency), then aftercast (idle/engaged) in sequence. If your client FPS is below 30, address that first.

---

## Lockstyle

### Q: Lockstyle not applying

Verify DressUp is loaded (`//lua list`). The default delay is 2.0s after
job load (configurable in `config/LOCKSTYLE_CONFIG.lua`); FFXI also
enforces a 15s minimum between applies. To apply manually:
`//gs c lockstyle`.

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

Toggle with `//gs c ui` or Alt+F1. If the UI appears off-screen, delete
`<Yourname>/config/ui_settings.lua` and reload — it will reset to defaults
and rewrite when you next save with `//gs c ui save`.

See [UI Guide](../features/ui.md) for customization.

### Q: Keybinds not showing in UI

Each keybind entry needs a valid `state` field that matches a defined `state.StateName` in your job file.

### Q: UI position resets every login

Run `//gs c ui save` after positioning. For automatic saving, set `UIConfig.auto_save_position = true` in `config/UI_CONFIG.lua`.

---

## Watchdog

### Q: What is the Watchdog?

Automatic recovery for stuck midcast gear caused by network packet loss.
It scans periodically and forces cleanup on a dynamic timeout (the
spell's cast time + 1.5s buffer).

See [Watchdog Guide](../features/watchdog.md).

### Q: Watchdog cleaning up too early during long spells

Override with `//gs c watchdog timeout <seconds>` (e.g. `4.5`). The
default is dynamic based on the cast time of the actual spell.

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

Use `//gs c cyclestate GainSpell` (and similar for `Barspell`,
`BarAilment`, `Spike`) to cycle through options. The UI shows the current
selection; cast manually after cycling. `Storm` cycle is exposed only
when subjob is /SCH.

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
| Trace midcast set selection | `//gs c debugmidcast` |
| Trace job-change debounce | `//gs c debugjobchange` (or `djc`) |
| System health check | `//gs c syscheck` (or `sc`) |
| Load GearSwap | `//lua load gearswap` |

---

## Further Reading

- [Installation Guide](../getting-started/installation.md) - Complete setup
- [Quick Start](../getting-started/quick-start.md) - 5-minute guide
- [Commands Reference](commands.md) - All commands
- [Keybinds Guide](keybinds.md) - Customize shortcuts
- [Configuration Guide](configuration.md) - Advanced settings

---
