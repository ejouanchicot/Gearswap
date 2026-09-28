# WHM — modes and keys

White Mage: cure potency or spell interruption, automatic cure tier, Afflatus
choice, and a weapon lock.

Set names and automatic gear: [sets.md](sets.md). Every key and command of
the job, on one page: [README.md](README.md).

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each
mode's current value; this page says what each value does. `#numpad0` (Auto
Medicine) and Alt+Numpad7-9 (alts) are common to every job, see
[keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad3` | Cure Mode (`CureMode`) | **Potency**, SIRD | Midcast set for Cure / Curaga: `sets.midcast.Cure` / `Curaga`, or `CureSIRD` / `CuragaSIRD` (spell interruption down) in SIRD, falling back to the normal set if the SIRD one is missing. Under Afflatus Solace, SIRD uses `CureSIRD` (else `CureSolace`) for a Cure. Not used for engaged cures when `sets.midcast.CureMelee` has gear. |
| `^numpad4` | Cure Auto-Tier (`CureAutoTier`) | **On**, Off | On: the Cure tier you press is replaced by the one that fits the target's missing HP (see Notes). Off: the tier you press is cast, unless it is on recast (then the next ready tier is used, in both values). |
| `^numpad5` | Afflatus Mode (`AfflatusMode`) | **Solace**, Misery | Which stance `//gs c afflatus` uses. |
| `^numpad1` | Idle Mode (`IdleMode`) | **PDT**, Refresh | Idle set: `sets.idle.PDT` or `sets.idle.Refresh`. |
| `^numpad2` | Combat Mode (`CombatMode`) | **Off**, On | On locks main, sub, range and ammo so your weapons stay on. |
| `^numpad6` | Casting Mode (`CastingMode`) | **Normal**, Resistant | Resistant: enfeebles and Divine Magic wear the `.Resistant` version of their set (`sets.midcast.MndEnfeebles.Resistant`, `.IntEnfeebles.Resistant`, `['Divine Magic'].Resistant`). A spell with a set of its own name keeps it: Repose, Holy and Holy II never wear a `.Resistant` set (so `sets.midcast.Repose.Resistant` is never used). Cures ignore it. In the template the `.Resistant` sets are copies of the normal ones until you add magic accuracy pieces. |

## Other modes (no key)

| Mode | Values | What it does |
|---|---|---|
| `OffenseMode` | **None**, Melee ON | Melee ON locks main, sub and range. Cycle it with F9 (Mote's key) or `//gs c cycle OffenseMode`. It changes no gear: the engaged set is always `sets.engaged.Normal`. |
| `FastCast` | 0 to 80 in steps of 10, default **80** | Fast Cast %, used by the midcast watchdog to time your casts when it cannot read the Fast Cast of your precast set. |

## Commands

| Command | What it does |
|---|---|
| `//gs c afflatus` | Casts Afflatus Solace or Afflatus Misery, following Afflatus Mode. |

## Notes

- **Cure auto-tier** (Cure Auto-Tier On): the thresholds are in
  `WHM_CURE_CONFIG.lua`. Your own missing HP is exact; a party member's is
  estimated from their HP % (assuming 2000 max HP). A 50 HP safety margin is
  added. If the chosen tier is on recast, the next lower one is used, then a
  higher one; if every tier is on recast, the Cure is cancelled with its recast
  time. The Cure is cancelled and re-sent with the new tier, and a chat line
  says why.
- **Full Cure** is never touched by the auto-tier: it always goes as Full Cure.
- **Engaged cures** use `sets.midcast.CureMelee` when that set has gear in it.
- **Afflatus Solace up**: a Cure (not a Curaga) uses `sets.midcast.CureSolace`,
  and `sets.buff['Afflatus Solace']` goes on top of Cures, Curagas and
  Bar-spells.
- Status removal spells use `sets.midcast.StatusRemoval` (Cursna its own set),
  plus the Divine Caress set when that buff is up.
- Paralyna while you are paralysed skips its precast gear.
- A reload, a main job change or a subjob change releases the Combat Mode and
  Melee ON locks (Offense Mode comes back at None).
- Idle: `sets.latent_refresh` goes on top while your MP is under 51 %, and
  `sets.MoveSpeed` while you move (in town too).
- Weaponskill TP bonus gear: see [TP bonus](../war/tp-bonus.md).
- Every mode goes back to its default on each job change, subjob change or reload.

## Files

In `<YourName>/config/whm/`: `WHM_STATES.lua` (modes and defaults),
`WHM_KEYBINDS.lua` (keys), `WHM_CURE_CONFIG.lua` (cure tier thresholds),
`WHM_CUSTOM.lua` (your own modes and gear, see
[keybinds](../../guides/keybinds.md)), `WHM_LOCKSTYLE.lua`, `WHM_MACROBOOK.lua`,
`WHM_TP_CONFIG.lua`. See [configuration](../../guides/configuration.md).
