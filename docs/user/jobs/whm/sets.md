# WHM — set names and automatic gear

Every set name the White Mage code reads, and everything the job puts on or does
by itself. Modes and keys: [states.md](states.md). Names every job shares
(subjob actions, movement, Doom, Dual Wield tiers, Treasure Hunter, Obi and
Orpheus): [set names](../../guides/sets.md).

Your file: `<YourName>/whm/whm_sets.lua`. `//gs c debugmidcast` shows, for each
spell, which set was chosen and why.

## Idle

| Set | Worn when |
|---|---|
| `sets.idle.PDT` | Idle Mode `PDT` (default, `^numpad1`) |
| `sets.idle.Refresh` | Idle Mode `Refresh` |
| `sets.idle.Weak` | Weakened (after a Raise), outside a city, when you define it; the Idle Mode set under it (`sets.idle.Weak.PDT`) if you define that too |
| `sets.idle.Town` | In a city (Dynamis excluded), whatever the Idle Mode. Adoulin counts as a city: WHM uses `sets.Adoulin` there only if you add one |
| `sets.latent_refresh` | Idle with less than 51 % MP (`refresh_mp_below` in `_common/combat/TUNING.lua`), on top of the idle set, in town too (empty in the provided file) |
| `sets.MoveSpeed` | Moving, on top of the idle set. On WHM this also applies in town |
| `sets.Kiting` | Mote's Kiting toggle (Alt+F10), on top of the idle and engaged sets outside a city |
| `sets.resting` | Resting (`/heal`) (empty in the provided file) |

Mote's defense keys also work on WHM outside a city: F10 puts `sets.defense.PDT`
on top of the idle or engaged set, F11 `sets.defense.MDT`, Alt+F12 turns it off.
None of these sets is in the provided file.

## Engaged

| Set | Worn when |
|---|---|
| `sets.engaged.Normal` | Engaged, always (the only engaged set the provided file uses) |
| `sets.engaged['Melee ON']` | Offense Mode `Melee ON`, if you define it (then `sets.engaged['Melee ON'].Normal` if that exists) |

The job adds nothing to the engaged set: no weapon sets, no dual-wield set.
Offense Mode `Melee ON` locks main, sub and range; Combat Mode On locks main,
sub, range and ammo ([states.md](states.md)). Each lock holds until you turn
it off: with Melee ON, Combat Mode Off does not free main, sub and range.
`sets.CombatMode`, if you define it (the provided file has none), is put on
when you turn Combat Mode On, just before the lock. While locked, the weapon
and ammo pieces of every set are ignored; while free, a set that holds `main` / `sub`
swaps your weapon (the provided Cure, Enhancing and Cursna sets do).

## Precast (Fast Cast)

Chosen by Mote under `sets.precast.FC`, by spell name, then spell map, then skill:

| Set | Worn when |
|---|---|
| `sets.precast.FC` | Any spell with nothing more precise |
| `sets.precast.FC.Cure` | Cure ... Cure VI, Full Cure |
| `sets.precast.FC.Curaga` | Curaga ..., Cura ... |
| `sets.precast.FC.CureSolace` | A Cure (not a Curaga) while Afflatus Solace is up |
| `sets.precast.FC.StatusRemoval` | Poisona, Paralyna, Blindna, Silena, Stona, Viruna, Cursna, Erase |
| `sets.precast.FC.MndEnfeebles`, `.IntEnfeebles` | Enfeebles (see below), if you define them |
| `sets.precast.FC['Healing Magic']`, `['Enhancing Magic']`... | By skill |
| `sets.precast.FC['Stoneskin']` | That spell (any spell works by its name) |

- Casting Mode `Resistant` (`^numpad6`) also picks a `.Resistant` child of the
  chosen Fast Cast set when it exists (`sets.precast.FC.Cure.Resistant`).
- An engaged Cure with a filled `sets.midcast.CureMelee` looks for
  `sets.precast.FC.CureMelee`, then falls to `sets.precast.FC['Healing Magic']`
  (not `FC.Cure`).
- **Paralyna while you are paralysed** puts on no precast set at all: a
  paralysed Paralyna is retried until it lands, and this avoids the gear
  blinking on and off at each try.

## Spells

At the start of every spell, `sets.midcast.FastRecast` is put on first (empty in
the provided file), under the spell's own set: a spell set that leaves slots
empty keeps FastRecast pieces there, or else the Fast Cast gear.

### Cure and Curaga

Chosen by the job itself, before anything else:

| Set | Worn when |
|---|---|
| `sets.midcast.Cure` | Cure ... Cure VI, Full Cure, Cure Mode `Potency` (`^numpad3`, default) |
| `sets.midcast.CureSIRD` | Same cures, Cure Mode `SIRD` (spell interruption down). Missing: `sets.midcast.Cure` |
| `sets.midcast.Curaga` | Curaga ..., Cura ..., Cure Mode `Potency` |
| `sets.midcast.CuragaSIRD` | Same, Cure Mode `SIRD`. Missing: `sets.midcast.Curaga` |
| `sets.midcast.CureSolace` | A Cure (not a Curaga) while Afflatus Solace is up, Cure Mode `Potency`. In `SIRD`: `sets.midcast.CureSIRD` (missing: `CureSolace`) |
| `sets.midcast.CureMelee` | Any Cure or Curaga while you are engaged, but only when this set has at least one piece. It wins over Cure Mode and Afflatus Solace. Missing or empty (as in the provided file): the normal choice above |
| `sets.buff['Afflatus Solace']` | On top of the Cure, Curaga or CureSolace set while Afflatus Solace is up (not on top of CureMelee) |

- These sets are equipped as they are: nothing else fills their empty slots
  (only FastRecast and precast gear remain there). Make them full sets.
- Casting Mode does not affect cures.
- No `sets.midcast['Spell Name']` is looked up for cures:
  `sets.midcast['Cure IV']` is never worn.

### Status removal

Poisona, Paralyna, Blindna, Silena, Stona, Viruna, Cursna, Erase:

1. `sets.midcast['Spell Name']` (the provided file has `sets.midcast['Cursna']`)
2. `sets.midcast.StatusRemoval` (the provided file holds 3 slots: the others
   keep the Fast Cast gear)

Then `sets.buff['Divine Caress']` on top while Divine Caress is up (empty in
the provided file: put your Divine Caress pieces there, such as Ebers Mitts).

Esuna and Sacrifice are not in this group: see "Other Healing Magic".

### Other Healing Magic (Raise, Reraise, Arise, Esuna, Sacrifice)

Chosen by Mote only, by name or family: `sets.midcast.Raise` (Raise, Raise II,
Raise III, Arise), `sets.midcast.Reraise` (Reraise ... IV), or the exact name
(`sets.midcast['Arise']`, `sets.midcast.Esuna`, `sets.midcast.Sacrifice`). Then
the skill set `sets.midcast['Healing Magic']` (not in the provided file), then
`sets.midcast.WhiteMagic` (any white magic without a set). Casting Mode
`Resistant` picks a `.Resistant` child of that set when it exists, as long as
you have no `sets.midcast['Healing Magic']` (once it exists, the spell's own set
is put back over the `.Resistant` one).

### Enhancing Magic

Each spell has a family (Refresh, Regen, BarElement, BarAilment, Boost,
Stoneskin, Aquaveil, Spikes...; list in [RDM sets](../rdm/sets.md#enhancing-magic)).
Order, first found wins:

1. `sets.midcast['Spell Name']` (the provided file: Haste, Sneak, Invisible,
   Stoneskin, Aquaveil, Refresh, Auspice)
2. the name without tier: `sets.midcast.Regen` (Regen ... Regen V),
   `sets.midcast.Protect`, `sets.midcast.Shell`, `sets.midcast.Protectra`...
3. the family: `sets.midcast.BarElement` (Barfire ... Barwatera),
   `sets.midcast.BarAilment` (Barsleep ... Barvira), `sets.midcast.Boost`
   (Boost-STR ...), then the same names under `sets.midcast['Enhancing Magic']`
4. `sets.midcast['Enhancing Magic']`

Then `sets.buff['Afflatus Solace']` on top of every spell whose name starts with
"Bar" (Bar-element and Bar-ailment spells) while Afflatus Solace is up.

There is no self / others split on WHM and no mode for enhancing.

### Divine Magic

1. `sets.midcast['Spell Name']` (the provided file: Holy, Holy II, Repose)
2. the name without tier: `sets.midcast.Banish` (Banish, II, III), `sets.midcast.Holy`
3. `sets.midcast['Divine Magic'].Resistant` with Casting Mode `Resistant`
4. `sets.midcast.Banish` again for Banishga and Banishga II (their family)
5. `sets.midcast['Divine Magic']` (Flash...)

A spell with its own set uses that set's `.Resistant` version in Resistant:
`sets.midcast['Repose'].Resistant` (a copy of the Repose set in the provided file).

### Enfeebling Magic

Enfeebles are split by the kind of magic, not by the enfeebling type list:

| Group | Spells |
|---|---|
| `MndEnfeebles` | White Magic enfeebles: Paralyze, Slow, Silence, Addle, Dia, Diaga... |
| `IntEnfeebles` | Black Magic enfeebles: Dispelga, and from a subjob Blind, Poison, Bind, Sleep, Gravity, Break, Dispel... |

1. `sets.midcast['Spell Name']`, then the name without tier (`sets.midcast.Slow`)
2. `sets.midcast.MndEnfeebles.Resistant` / `sets.midcast.IntEnfeebles.Resistant`
   with Casting Mode `Resistant`
3. `sets.midcast.MndEnfeebles` / `sets.midcast.IntEnfeebles`

`sets.midcast['Enfeebling Magic']` is never used on WHM.

Dispelga gets no special handling on WHM: put Daybreak in
`sets.precast.FC.Dispelga` and `sets.midcast.Dispelga` yourself. With Combat
Mode On or Melee ON the weapon cannot change, and GearSwap refuses Dispelga
unless Daybreak is already in hand. (RDM has a dedicated command for this.)

### Dark and Elemental Magic (subjob)

`sets.midcast['Spell Name']`, the name without tier (`sets.midcast.Aspir`,
`sets.midcast.Stone`...), then `sets.midcast['Dark Magic']` /
`sets.midcast['Elemental Magic']`. No mode.

## Weaponskills

`sets.precast.WS`, `sets.precast.WS['Name']` (the provided file: Mystic Boon,
Flash Nova). Moonshade Earring is added by itself when it reaches the next TP
step: [TP bonus](../war/tp-bonus.md) (`WHM_TP_CONFIG.lua`).

## Job abilities

`sets.precast.JA['Benediction']`, `['Devotion']`, `['Martyr']`,
`['Afflatus Solace']`, `['Afflatus Misery']` (the last two empty in the
provided file), and any other ability by its name (`['Divine Caress']`,
`['Sacrosanctity']`...). `sets.precast.Waltz` is in the provided file for /DNC.

## What the job does by itself

- **Cure tier by missing HP** (Cure Auto-Tier On, `^numpad4`): the Cure or
  Curaga you press is cancelled and re-sent with the tier that fits the
  target's missing HP (`WHM_CURE_CONFIG.lua`). Full HP: the lowest tier.
- **Cure tier on recast** (always, even with Auto-Tier Off): if the tier is on
  recast, the next lower ready tier goes, else a higher one.
- **Full Cure** is never replaced: the auto-tier only handles Cure and Curaga.
- **CureMelee** on engaged cures, once that set has gear. Leave it empty to
  keep the normal cure sets while engaged.
- **Afflatus Solace set** on cures and Bar-spells while the buff is up;
  **CureSolace** for Cures. Empty `sets.buff['Afflatus Solace']` turns the
  layer off.
- **Divine Caress set** on status removal while the buff is up.
- **Latent refresh** below 51 % MP while idle.
- **Paralyna while paralysed**: no precast gear swap.
- `//gs c afflatus` casts the stance chosen by Afflatus Mode.

## Sets in the provided file that nothing reads

- `sets.engaged.PDT`: Mote's hybrid mode has no `PDT` value on WHM.
- `sets.midcast.CureMelee`, `sets.latent_refresh`, `sets.midcast.FastRecast`,
  `sets.buff['Divine Caress']`, `sets.resting`, `sets.precast.JA['Afflatus Solace']`
  / `['Afflatus Misery']`: read, but empty until you fill them.

## Names the code reads that the provided file lacks

- `sets.midcast['Healing Magic']` (Esuna, Sacrifice), `sets.midcast.Protect`,
  `.Shell`, `.BarAilment`, `.Boost`.
- `sets.midcast.Banish` (Banish goes to the Divine base).
- `sets.Adoulin`, `sets.idle.Weak`, `sets.defense.PDT` / `.MDT`.
- `.Resistant` children of the Fast Cast sets.
- `sets.DW.*`, `sets.TreasureHunter` (see [set names](../../guides/sets.md)).
