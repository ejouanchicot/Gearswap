# Quick Start

You installed it (see [installation](installation.md)). Now you'll learn
the day-to-day commands. Five minutes.

---

## Loading a job

```
//console gs load <Yourname>_WAR
```

GearSwap automatically:

1. Loads the entry-point and the 12-module job package
2. Registers the per-job keybinds from `<JOB>_KEYBINDS.lua`
3. Sets the macrobook page from `<JOB>_MACROBOOK.lua`
4. Schedules the lockstyle (~2s after load) from `<JOB>_LOCKSTYLE.lua`
5. Wires the watchdog, automove, and shared systems

You don't run anything — once the entry-point loads, everything is hot.

---

## Day-to-day commands

```
//gs c                  Toggle the keybind UI overlay
//gs c checksets        Validate every set, list missing/storage items
//gs c reload           Hot-reload current GearSwap
//gs c info             Framework version + loaded modules
//gs c lockstyle / ls   Re-apply your lockstyle (DressUp must be loaded)
//gs c naked            Strip all equipment
```

### Inventory & wardrobe

```
//gs c rf               Refill consumables for the current job/subjob
//gs c wo               Wardrobe organize for the current job
//gs c wo preview       Dry-run wardrobe organize
//gs c wo verify        Read-only wardrobe layout check
//gs c wa               Wardrobe audit (find unused items per job)
```

### Craft & fishing

```
//gs c craft            Bonecraft HQ (default variant)
//gs c craft nq         Bonecraft NQ guarantee
//gs c craft success    Bonecraft success rate
//gs c craft wood       HQ + Carver's Torque (woodworking sub)
//gs c craft smith      HQ + Smithy's Torque (smithing sub)
//gs c craft leather    HQ + Tanner's Torque (leathercraft sub)
//gs c fish             Equip the fishing set
//gs c uncraft          Unlock slots, normal gear resumes
```

### Cross-job utility

```
//gs c jump             DRG-style jump (any job with /DRG sub)
//gs c waltz            Curing Waltz (any job with /DNC sub)
//gs c aoewaltz         Divine Waltz (any job with /DNC sub)
//gs c warp [dest]      ~50 destinations: w, ret, esc, tph, sd, ad, ...
```

### Debugging

```
//gs c debugmidcast     Trace MidcastManager set selection
//gs c debugjobchange   Trace job change events (or `djc`)
//gs c debugstate       Dump current state machine (or `ds`)
//gs c debugmsg         Toggle universal message logging
//gs c automovedebug    Trace movement decisions (or `amd`)
//gs c testcolors       Show the 509-color FFXI palette
//gs c syscheck         Validate all jobs and core systems (or `sc`)
//gs c fulltest         Run the comprehensive system suite (or `ft`)
```

> Full list: [commands guide](../guides/commands.md).

---

## Keybinds

Universal Mote keybinds (F9-F12, Alt-F9..F12) are **not** wired by this
framework. The project uses **per-job binds defined in
`<JOB>_KEYBINDS.lua`**, with one universal:

| Key | Action |
| --- | --- |
| Alt+F1 | Toggle the keybind UI overlay |

A few representative jobs (full table in [keybinds guide](../guides/keybinds.md)):

### WAR

| Key | Action |
| --- | --- |
| Alt+1 | Cycle MainWeapon (Ukonvasara, Naegling, Apocalypse, etc.) |
| Alt+2 | Cycle HybridMode (Normal / PDT / SubtleBlow) |

### DNC

| Key | Action |
| --- | --- |
| Alt+1 | Cycle MainWeapon |
| Ctrl+1 | Cycle SubWeaponOverride |
| Alt+2 | Cycle HybridMode |
| Alt+3 | Cycle MainStep |
| Alt+4 | Cycle AltStep |
| Alt+5 | Toggle UseAltStep |
| Alt+6 | Toggle ClimacticAuto |
| Alt+7 | Toggle JumpAuto |
| Alt+8 | Cycle Dance type |
| Ctrl+8 | Activate the selected dance |

### PLD

| Key | Action |
| --- | --- |
| Alt+1 | Cycle MainWeapon |
| Alt+2 | Cycle HybridMode |
| Alt+4 | (per subjob — see PLD_KEYBINDS.lua) |
| Alt+5 | (per subjob — see PLD_KEYBINDS.lua) |

> Open `<Yourname>/config/<job>/<JOB>_KEYBINDS.lua` to see all binds for
> the job you're playing — or invoke `//gs c` in-game to render the live
> overlay.

---

## State cycling cheat-sheet

Most jobs expose Mote-Include states cycled via `//gs c cycle <StateName>`:

```
//gs c cycle MainWeapon       Weapon cycling (per-job list)
//gs c cycle HybridMode       Normal / PDT / variants
//gs c cycle OffenseMode      Normal / Acc (where defined)
//gs c cycle CastingMode      Normal / Resistant (mages)
//gs c cycle EnfeebleMode     Potency / Acc (RDM)
//gs c cycle EnhancingMode    Standard / Composure (RDM)
//gs c cycle NukeMode         Normal / FreeNuke / MB (BLM/RDM)
//gs c cycle CureMode         Normal / Reraise (WHM)
```

Each job exposes only the cycles it defines in `<JOB>_STATES.lua`. Run
`//gs c debugstate` to dump the current state machine.

---

## What happens during a cast

The 5-phase combat lifecycle:

1. **PrecastGuard** — first thing checked. Blocks while silenced /
   amnesia / paralyzed / stunned, optionally auto-cures from
   `DEBUFF_AUTOCURE_CONFIG`.
2. **CooldownChecker** — validates the JA/spell recast (`spell.recast_id`).
   Cancels with a clear chat message if it isn't ready.
3. **WSPrecastHandler** (weaponskills only) — handles SA/TA, Climactic,
   Sange, Sneak Attack pre-triggers.
4. **MidcastManager.select_set(...)** — single mandatory entry-point that
   picks the right `sets.midcast.*` table via 9-level fallback.
5. **Aftercast** — restore idle/engaged with town detection, hybrid
   modes, aftermath sets (e.g. WAR Ukonvasara AM3 → `sets.engaged.PDTAFM3`).

If something looks wrong, run `//gs c debugmidcast` to trace the set
chosen for each cast.

---

## Common troubleshooting

| Symptom | Try |
| --- | --- |
| Gear didn't swap after spell | The watchdog auto-recovers stuck midcast (timeout = cast time + 1.5s). Run `//gs c info` to see watchdog status. |
| `[MISSING]` items in `checksets` | The item is named differently or you don't own it. Use the right `enl` form (e.g. `R. Curry Bun +1` vs `Red Curry Bun +1`). |
| Keybinds dead after subjob change | The 3.0s job-change debouncer is still settling. Wait, then `//gs c reload` if it still misfires. |
| Lockstyle didn't apply | DressUp not loaded → `//lua load dressup`, then `//gs c lockstyle`. |
| Wardrobe organize stalls | `//gs c wo recover` re-enables every slot if anything got stuck disabled. |

---

## Next steps

- [All commands](../guides/commands.md)
- [Per-job state docs](../jobs/README.md)
- [DualBox setup](../guides/dualbox.md) — main/alt IPC sync
- [UI overlay](../features/ui.md)
- [Watchdog](../features/watchdog.md)

---

**14 jobs implemented** (BLM, BRD, BST, COR, DNC, DRK, GEO, PLD, RDM, RUN,
SAM, THF, WAR, WHM). PUP is a scaffold-only stub.
