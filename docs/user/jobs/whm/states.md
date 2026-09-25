# WHM — modes and keys

White Mage: cure potency or spell interruption, automatic cure tier, Afflatus
choice, and a weapon lock.

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each
mode's current value; this page says what each value does. `#numpad0` (Auto
Medicine) and Alt+Numpad7-9 (alts) are common to every job, see
[keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad3` | Cure Mode (`CureMode`) | **Potency**, SIRD | Midcast set for Cure / Curaga: `sets.midcast.Cure` / `Curaga`, or `CureSIRD` / `CuragaSIRD` (spell interruption down) in SIRD, falling back to the normal set if the SIRD one is missing. |
| `^numpad4` | Cure Auto-Tier (`CureAutoTier`) | **On**, Off | On: the Cure tier you press is replaced by the one that fits the target's missing HP (see Notes). Off: the tier you press is cast. |
| `^numpad5` | Afflatus Mode (`AfflatusMode`) | **Solace**, Misery | Which stance `//gs c afflatus` uses. |
| `^numpad1` | Idle Mode (`IdleMode`) | **PDT**, Refresh | Idle set: `sets.idle.PDT` or `sets.idle.Refresh`. |
| `^numpad2` | Combat Mode (`CombatMode`) | **Off**, On | On locks main, sub, range and ammo so your weapons stay on. |
| `^numpad6` | Casting Mode (`CastingMode`) | **Normal**, Resistant | Mote's casting mode: looks for `.Resistant` versions of the precast / midcast sets. The template set file has none. |

## Other modes (no key)

| Mode | Values | What it does |
|---|---|---|
| `OffenseMode` | **None**, Melee ON | Melee ON locks main, sub and range. Cycle it with F9 (Mote's key) or `//gs c cycle OffenseMode`. |
| `FastCast` | 0 to 80 in steps of 10, default **80** | Fast Cast %, used by the midcast watchdog to time your casts. |

## Commands

| Command | What it does |
|---|---|
| `//gs c afflatus` | Casts Afflatus Solace or Afflatus Misery, following Afflatus Mode. |

## Notes

- **Cure auto-tier** (Cure Auto-Tier On): the thresholds are in
  `WHM_CURE_CONFIG.lua`. Your own missing HP is exact; a party member's is
  estimated from their HP % (assuming 2000 max HP). A 50 HP safety margin is
  added. If the chosen tier is on recast, the next lower one is used, then a
  higher one. The Cure is cancelled and re-sent with the new tier.
- **Engaged cures** use `sets.midcast.CureMelee` when that set has gear in it.
- **Afflatus Solace up**: cures use `sets.midcast.CureSolace`, and the Solace
  set is added to cures and Bar-spells.
- Status removal spells use `sets.midcast.StatusRemoval` (Cursna its own set),
  plus the Divine Caress set when that buff is up.
- Paralyna while you are paralysed skips its precast gear.
- A reload or job change releases the Combat Mode and Melee ON locks.
- Weaponskill TP bonus gear: see [TP bonus](../war/tp-bonus.md).
- Every mode goes back to its default on each job change, subjob change or reload.

## Files

In `<Char>/config/whm/`: `WHM_STATES.lua` (modes and defaults),
`WHM_KEYBINDS.lua` (keys), `WHM_CURE_CONFIG.lua` (cure tier thresholds),
`WHM_CUSTOM.lua` (your own modes and gear, see
[keybinds](../../guides/keybinds.md)), `WHM_LOCKSTYLE.lua`, `WHM_MACROBOOK.lua`,
`WHM_TP_CONFIG.lua`. See [configuration](../../guides/configuration.md).
