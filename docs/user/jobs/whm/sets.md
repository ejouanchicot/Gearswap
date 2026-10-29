# WHM — set names and automatic gear

Every set name the White Mage code reads, and everything the job puts on or does
by itself. Modes and keys: [states.md](states.md). Names every job shares
(subjob actions, movement, Doom, Dual Wield tiers, Treasure Hunter, Obi and
Orpheus): [set names](../../guides/sets.md).

Your file: `<YourName>/whm/sets/whm_sets.lua`. `//gs c debugmidcast` shows, for each
spell, which set was chosen and why.

## Weapons

| Set | Worn when |
|---|---|
| `sets['<Weapon>']` | Main Weapon (`^numpad7`) is that value: one set per value you add in `WHM_STATES.lua`, named exactly like the value (`sets['Maxentius'] = {main = 'Maxentius'}`) |
| `sets['<Shield>']` | Sub Weapon (`^numpad8`) is that value (`sets['Genmei Shield'] = {sub = 'Genmei Shield'}`) |

`Free` (default) has no set: you keep what you wear. The weapon sets go on top
of the idle and engaged sets, in town too. A spell set with its own weapon
(Yagrush for Cursna) still wears it for the spell, unless Combat Mode is On.

## Idle

| Set | Worn when |
|---|---|
| `sets.idle.PDT` | Idle Mode `PDT` (default, `^numpad1`) |
| `sets.idle.Refresh` | Idle Mode `Refresh` |
| `sets.idle.Weak` | Weakened (after a Raise), outside a city, when you define it; the Idle Mode set under it (`sets.idle.Weak.PDT`) if you define that too |
| `sets.idle.Town` | In a city (Dynamis excluded), whatever the Idle Mode. Adoulin counts as a city: WHM uses `sets.Adoulin` there only if you add one |
| `sets.latent_refresh` | Idle with less than 51 % MP (`refresh_mp_below` in `whm/combat/WHM_CONFIG.lua`), on top of the idle set, in town too (empty in the provided file) |
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
| `sets.midcast.CureMPConservation` | Put on top of the Cure / Curaga set (any of the above but CureMelee) while your MP is under `mp_conservation_below` of `WHM_CURE_CONFIG.lua` (40 %). Empty in the provided file: nothing changes. Example: `main = 'Daybreak'` when your Cure sets hold a Raetic Rod +1 (stronger cures, 30 % more MP) |
| `sets.midcast.CureMelee` | Any Cure or Curaga while you are engaged, but only when this set has at least one piece. It wins over Cure Mode and Afflatus Solace. Missing or empty (as in the provided file): the normal choice above |
| `sets.midcast.CureSIRD.Solace` | A Cure under Afflatus Solace, Cure Mode `SIRD`. Missing: `sets.midcast.CureSIRD`. Key pieces of Solace (here and in CureSolace): Ebers Bliaut, Alaunus's Cape. Not on a Curaga, which gets no Solace Stoneskin |

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

Then, while Divine Caress is up and the spell is a -na (not Erase, Esuna nor
Sacrifice, which Divine Caress does not affect), its Caress version:
`sets.midcast.<spell>.Caress` (`Cursna.Caress`), else
`sets.midcast.StatusRemoval.Caress`. A copy of StatusRemoval in the provided
file: put your Divine Caress pieces in it, such as Ebers Mitts (worn during the
-na, not when you use the ability).

Esuna and Sacrifice are not in this group: see "Other Healing Magic".

### Other Healing Magic (Raise, Reraise, Arise, Esuna, Sacrifice)

Chosen by Mote only, by name or family: `sets.midcast.Raise` (Raise, Raise II,
Raise III, Arise), `sets.midcast.Reraise` (Reraise ... IV), or the exact name
(`sets.midcast['Arise']`, `sets.midcast.Esuna` (empty in the provided file: under
Afflatus Misery, Asclepius, Piety Wand and Cleric's Wand remove more effects),
`sets.midcast.Sacrifice`). Then
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
   `sets.midcast.Protect`, `.Protectra`, `.Shell`, `.Shellra` (all four in the
   provided file, copies of the Enhancing set)
3. the family: `sets.midcast.BarElement` (Barfire ... Barwatera),
   `sets.midcast.BarAilment` (Barsleep ... Barvira), `sets.midcast.Boost`
   (Boost-STR ...), then the same names under `sets.midcast['Enhancing Magic']`.
   The provided file has `BarElement`, `BarAilment` and `Boost`. Bar-status
   resistance is fixed (+30, +20 for the -ra): only Sroda Necklace adds to it
4. `sets.midcast['Enhancing Magic']`

Then, while Afflatus Solace is up and the spell is an element Bar-spell
(Barfire...; Solace adds nothing to the Bar-ailment ones), its Solace version:
`sets.midcast.<spell>.Solace`, else `sets.midcast.BarElement.Solace` (a copy of
BarElement in the provided file; key pieces: Ebers Bliaut, Alaunus's Cape).

There is no self / others split on WHM and no mode for enhancing.

### Divine Magic

1. `sets.midcast['Spell Name']` (the provided file: Holy, Holy II, Repose, Flash)
2. the name without tier: `sets.midcast.Banish` (Banish, II, III), `sets.midcast.Banishga`
   (Banishga, II), `sets.midcast.Holy`
3. `sets.midcast['Divine Magic'].Resistant` with Casting Mode `Resistant`
4. `sets.midcast.Banish` again for Banishga and Banishga II (their family), when
   you have no `Banishga` set
5. `sets.midcast['Divine Magic']`

A set found at step 1 or 2 uses its `.Resistant` version in Resistant when it has
one: `sets.midcast['Repose'].Resistant`, `sets.midcast.Banish.Resistant`. In the
provided file, Banish, Banishga and Flash (and their `.Resistant`) are copies of the
Divine sets.

### Enfeebling Magic

Enfeebles are split by the kind of magic, not by the enfeebling type list:

| Group | Spells |
|---|---|
| `MndEnfeebles` | White Magic enfeebles: Paralyze, Slow, Silence, Addle, Dia, Diaga... |
| `IntEnfeebles` | Black Magic enfeebles: Dispelga, and from a subjob Blind, Poison, Bind, Sleep, Gravity, Break, Dispel... |

1. `sets.midcast['Spell Name']`, then the name without tier (`sets.midcast.Slow`),
   its `.Resistant` version in Resistant when it has one. The provided file has
   `sets.midcast.Dia` (Dia, Dia II) and `sets.midcast.Diaga` (Diaga, Diaga II),
   copies of `MndEnfeebles` with their `.Resistant`: Dia's damage and Defense
   Down are fixed and never resisted, only Dia Wand adds to them. Treasure Hunter
   comes from Treasure Mode (`sets.TreasureHunter`)
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
step: [TP bonus](../../features/tp-bonus.md) (`WHM_TP_CONFIG.lua`).

## Job abilities

`sets.precast.JA['Benediction']`, `['Devotion']`, `['Martyr']`,
`['Afflatus Solace']`, `['Afflatus Misery']` (the last two empty in the
provided file), and any other ability by its name (`['Divine Caress']`,
`['Sacrosanctity']`...). `sets.precast.Waltz` is in the provided file for /DNC.

The piece that gives each its effect, worn when you use it: Piety Bliaut
(Benediction: Enmity -50), Piety Mitts (Martyr: up to 75 % of your HP instead of
50 %), Piety Cap (Devotion: up to 42.5 % of your HP as MP instead of 30 %).
Martyr and Devotion count your **current** HP: HP gear put on when you use them
raises only your max HP, not the current, so their provided sets hold the Piety
piece alone. Be at full HP in a high-HP idle set before using them.
Divine Caress and the Afflatus stances have no piece at the ability: theirs go
in the version of the spell they change (CureSolace, CureSIRD.Solace,
BarElement.Solace, StatusRemoval.Caress, Banish.Misery). The Atelier flags a set
that lacks its key piece while you own one.

## What the job does by itself

- **Cure tier by missing HP** (Cure Auto-Tier On, `^numpad4`): the Cure or
  Curaga you press is cancelled and re-sent with the tier that fits the
  target's missing HP (`WHM_CURE_CONFIG.lua`). Full HP: the lowest tier.
- **Cure tier on recast** (always, even with Auto-Tier Off): if the tier is on
  recast, the next lower ready tier goes, else a higher one.
- **Full Cure** is never replaced: the auto-tier only handles Cure and Curaga.
- **CureMelee** on engaged cures, once that set has gear. Leave it empty to
  keep the normal cure sets while engaged.
- **Banish.Misery** on Banish and Banishga while Afflatus Misery is up
  (Piety Pantaloons; empty copy of Banish in the provided file).
- **CureSolace** (CureSIRD.Solace in SIRD) for Cures and **BarElement.Solace**
  for element Bar-spells while Afflatus Solace is up.
- **StatusRemoval.Caress** on the -na spells while Divine Caress is up (not
  Erase, Esuna, Sacrifice).
- **MP economy on cures**: `sets.midcast.CureMPConservation` on top of the
  cure set under 40 % MP (`mp_conservation_below`, `WHM_CURE_CONFIG.lua`).
- **Latent refresh** below 51 % MP while idle.
- **Paralyna while paralysed**: no precast gear swap.
- `//gs c afflatus` casts the stance chosen by Afflatus Mode.

## Sets in the provided file that nothing reads

- `sets.engaged.PDT`: Mote's hybrid mode has no `PDT` value on WHM.
- `sets.midcast.CureMelee`, `sets.latent_refresh`, `sets.midcast.FastRecast`,
  `sets.resting`, `sets.precast.JA['Afflatus Solace']`
  / `['Afflatus Misery']`: read, but empty until you fill them.

## Names the code reads that the provided file lacks

- `sets.midcast['Healing Magic']` (Sacrifice).
- `sets.Adoulin`, `sets.idle.Weak`, `sets.defense.PDT` / `.MDT`.
- `.Resistant` children of the Fast Cast sets.
- `sets.DW.*`, `sets.TreasureHunter` (see [set names](../../guides/sets.md)).
