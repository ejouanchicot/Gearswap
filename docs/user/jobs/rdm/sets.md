# RDM — set names and automatic gear

Every set name the Red Mage code reads, and everything the job puts on or does
by itself. Modes and keys: [states.md](states.md). Names every job shares
(subjob actions, movement, Doom, Dual Wield tiers, Treasure Hunter, Obi and
Orpheus): [set names](../../guides/sets.md).

Your file: `<YourName>/sets/rdm_sets.lua`. `//gs c debugmidcast` shows, for each
spell, which set was chosen and why.

## Weapons

| Set | Worn when |
|---|---|
| `sets['Naegling']`, `sets['Colada']`, `sets['Daybreak']` | Main Weapon (`^numpad1`) is that value: one set per value of `MainWeapon` in `RDM_STATES.lua`, named exactly like the value (`{main = 'Naegling'}`) |
| `sets['Ammurapi']`, `sets['Genmei']`, `sets['Malevolence']` | Sub Weapon (`^numpad2`) is that value (`{sub = 'Genmei Shield'}`) |
| `sets.shields` | Not a set: a list of off-hand names. Read only for an off-hand name the game's item list does not know, to decide shield (normal engaged set) or weapon (`.DW` set) |

- To add a weapon: add the value to `MainWeapon` / `SubWeapon` in `RDM_STATES.lua`
  and a set of the same name. With `equip_without_set = true` in
  `config/WEAPON_CONFIG.lua`, a value that is a real weapon name needs no set.
- The weapon sets go on top of the idle and engaged sets (in town too).
- With Combat Mode On the weapon sets are not applied and main, sub and range
  stay locked: whatever `main`, `sub` or `range` your other sets hold is ignored.
  With Combat Mode Off, every set that holds a weapon swaps it (the template's
  Enfeebling, Enhancing and Elemental sets hold `main` and `sub`, Enfeebling also
  `range`), and your TP is lost.

## Idle

| Set | Worn when |
|---|---|
| `sets.idle.Refresh` | Idle Mode `Refresh` (default) |
| `sets.idle.DT` | Idle Mode `DT` |
| `sets.idle.Town` | In a city (Dynamis excluded), whatever the Idle Mode |
| `sets.Adoulin` | In Western / Eastern Adoulin, checked before `sets.idle.Town` |
| `sets.MoveSpeed` | Moving, outside a city, on top of the idle set |

`sets.idle.Town` and `sets.Adoulin` go on top of the Idle Mode set. In the provided
file `sets.Adoulin` holds only legs and body: every other slot keeps your Idle Mode
piece.

A plain `sets.idle` is worn only if the current Idle Mode has no set of its own.

## Engaged

| Set | Worn when |
|---|---|
| `sets.engaged.DT` | Engaged Mode `DT` (default), one weapon (shield, grip or nothing in the off hand) |
| `sets.engaged.Acc`, `sets.engaged.TP`, `sets.engaged.Enspell` | Engaged Mode `Acc` / `TP` / `Enspell`, one weapon |
| `sets.engaged.DT.DW`, `.Acc.DW`, `.TP.DW`, `.Enspell.DW` | Same modes with a weapon in the off hand (dual wield, /NIN or /DNC only). Missing `.DW` set: the normal one is used |

What counts as dual wield: the off hand is the item of the Sub Weapon set
(`sets['Malevolence'].sub`), or, with Combat Mode On, the item you actually
wear. The game's item list decides whether it is a weapon. Your subjob must be
NIN or DNC: Red Mage has no Dual Wield of its own, so on any other subjob
`Malevolence` in the Sub Weapon mode keeps the normal (one weapon) sets.

The shared Dual Wield tier sets (`sets.DW.NoHaste` ... `sets.DW.MaxHaste`) go on
top of the `.DW` set: see [set names](../../guides/sets.md).

## Precast (Fast Cast)

| Set | Worn when |
|---|---|
| `sets.precast.FC` | Any spell |
| `sets.precast.FC['Spell Name']` | That spell (the provided file has `['Stoneskin']` and `['Dispelga']`). Put on again after the generic choice, so it always wins |
| `sets.precast.FC.Cure`, `.Curaga`, `.Refresh`... and `sets.precast.FC['Enfeebling Magic']`... | Name without tier and skill, by the common rule |

Chainspell does not skip the Fast Cast set.

## Spells

### Enfeebling Magic

Each enfeeble has a type, fixed by the project's enfeebling list. Its set is
chosen in this order, first found wins:

1. `sets.midcast['Spell Name']` (for example `sets.midcast.Dispelga`)
2. the name without tier: `sets.midcast.Slow` for Slow and Slow II,
   `sets.midcast.Dia`, `sets.midcast.Distract`...
3. `sets.midcast['Enfeebling Magic'].<type>.<mode>`: the type, then the
   Enfeeble Mode (`^numpad3`: `Potency`, `Skill`, `Duration`), for example
   `sets.midcast['Enfeebling Magic'].mnd_potency.Skill`
4. `sets.midcast.<type>`, then `sets.midcast['Enfeebling Magic'].<type>`
5. `sets.midcast['Enfeebling Magic'].<mode>` (`.Potency`, `.Skill`, `.Duration`):
   only for an enfeeble that has no type (not in the project's list)
6. `sets.midcast['Enfeebling Magic']`

Types and their spells:

| Type | Spells |
|---|---|
| `macc` (magic accuracy) | Paralyze, Slow, Blind, Gravity, Distract, Distract II, Frazzle, Frazzle II, Addle, Poison, Poisonga, Dispel, Dispelga |
| `mnd_potency` (MND) | Paralyze II, Slow II, Addle II |
| `int_potency` (INT) | Blind II |
| `skill_potency` (enfeebling skill) | Poison II |
| `skill_mnd_potency` (skill and MND) | Distract III, Frazzle III |
| `potency` | Dia, Dia II, Dia III, Diaga, Gravity II |
| `duration` | Sleep, Sleep II, Sleepga, Sleepga II, Break, Breakga, Bind, Silence |

**Enfeeble Mode** picks a set under the type: `sets.midcast['Enfeebling Magic'].mnd_potency.Skill`,
`.macc.Duration`, `.duration.Potency`... (the provided file shows an example in a
comment). The plain `.Potency` / `.Skill` / `.Duration` sets are only for an enfeeble
with no type (Slowga, Diaga II, Inundation and the other -ga). With the provided file
the mode changes no gear until you add such sets.

**Saboteur up**: after the set above, `sets.midcast['Enfeebling Magic'].Saboteur`
goes on top of every enfeeble. Put only the pieces that should change in it (the
provided file: Lethargy hands): every other slot keeps the type, mode or spell-name
set. A full set there would replace them all.

### Dispelga

Dispelga can only be cast with Daybreak in the main hand.

- `sets.precast.FC['Dispelga']` and `sets.midcast.Dispelga` hold the gear (the
  provided file: Fast Cast / the `macc` set, each with Daybreak).
- Whatever those sets say, Daybreak is put in the main hand at precast and held
  there for the whole cast, over any set (Saboteur set included).
- **Combat Mode On**: `//gs c dispelga [<target>]` (macro: `/console gs c dispelga`)
  frees the main hand, casts, and after the cast puts your previous weapon back
  and locks again. The TP is lost. Typed as `/ma "Dispelga"`, the spell is
  refused while Combat Mode locks your weapons, unless Daybreak is already in
  your hand.
- **Combat Mode Off**: `/ma "Dispelga"` works; your idle / engaged set brings
  your weapon back after the cast.

### Enhancing Magic

The target matters only while **Composure** is up and the spell is cast on
someone else: the "target" is then `Composure`. Without Composure, or on
yourself, there is no target level. Each spell also has a family:

| Family | Spells |
|---|---|
| `Enspell` | Enfire ... Enwater, and their II |
| `Gain` | Gain-STR ... Gain-CHR |
| `BarElement` | Barfire ... Barwater, Barfira ... Barwatera |
| `BarAilment` | Baramnesia ... Barvirus, Baramnesra ... Barvira |
| `Refresh` | Refresh, Refresh II, Refresh III |
| `Regen` | Regen ... Regen V |
| `Phalanx` | Phalanx, Phalanx II |
| `Stoneskin`, `Aquaveil` | that spell |
| `Spikes` | Blaze / Ice / Shock Spikes |
| `Boost` | Boost-STR ... Boost-CHR |
| `Storm` | the /SCH storms |
| (none) | Haste, Flurry, Protect, Shell, Temper, Blink, Sneak, Invisible, Klimaform... |

Order, first found wins:

1. `sets.midcast['Spell Name']`
2. name without tier: under Composure on someone else
   `sets.midcast.Refresh.Composure` (also `sets.midcast.Composure.Refresh`,
   `sets.midcast['Enhancing Magic'].Refresh.Composure`,
   `sets.midcast['Enhancing Magic'].Composure.Refresh`), then plain
   `sets.midcast.Refresh`; otherwise
   `sets.midcast.Refresh`, `sets.midcast.Haste`, `sets.midcast.Temper`,
   `sets.midcast.Phalanx`...
3. under Composure on someone else: `sets.midcast['Enhancing Magic'].Composure`
   (or `sets.midcast.Composure`)
4. the family: `sets.midcast.Enspell`, `sets.midcast.Gain`, `sets.midcast.BarElement`,
   `sets.midcast.BarAilment`, `sets.midcast.Spikes`, `sets.midcast.Boost`...,
   then `sets.midcast['Enhancing Magic'].<family>`
5. `sets.midcast['Enhancing Magic']`

Because the name comes first, Refresh, Regen, Phalanx, Stoneskin and Aquaveil
always use their name set. Build such a set on the Enhancing set
(`set_combine(sets.midcast['Enhancing Magic'], {...})`, as the provided file does for
Refresh and Regen): a set with only a few slots leaves the Fast Cast gear in the
others during the cast.

**Accession + Phalanx** (/SCH): Phalanx under Accession wears
`sets.midcast['Enhancing Magic']` itself, never the Phalanx or Composure set.

### Healing Magic

| Set | Worn when |
|---|---|
| `sets.midcast.Cure` | Cure, Cure II ... (name without tier) |
| `sets.midcast.Curaga` | Curaga ..., Cura ... |
| `sets.midcast.CureSelf` | A Cure (not a Curaga) cast on yourself: put on top of the Cure set. The provided file's is a full set, so on yourself it replaces the Cure set; give it only the pieces that differ |
| `sets.midcast.StatusRemoval` | Poisona, Paralyna, Cursna... (/WHM) |
| `sets.midcast['Healing Magic']` | Any other healing spell (Raise...), and the base the others fall back to. Without it the job adds nothing: only the set picked by spell name or map (`sets.midcast.Cure`...) stays, plus `CureSelf` |

### Elemental Magic

| Set | Worn when |
|---|---|
| `sets.midcast['Elemental Magic'].FreeNuke` | Nuke Mode `FreeNuke` (`^numpad7`, default) |
| `sets.midcast['Elemental Magic']['Magic Burst']` | Nuke Mode `Magic Burst` (the name has a space) |
| `sets.midcast['Elemental Magic']` | A nuke when the mode's set is missing |
| `sets.midcast['Fire']`, `sets.midcast.Impact`... | A spell with a set of its own wins over the mode (`sets.midcast.Fire` covers Fire ... Fire V) |

Impact needs the Twilight Cloak in body: nothing puts it on for you, write it in
`sets.midcast.Impact`.

### Dark Magic

`sets.midcast.Stun`, `sets.midcast.Drain` (Drain, Drain II, Drain III),
`sets.midcast.Aspir` (Aspir, II, III), `sets.midcast.Bio`..., else
`sets.midcast['Dark Magic']`. Without `sets.midcast['Dark Magic']` the job adds
nothing: only a set found by spell name stays.

## Weaponskills

`sets.precast.WS`, `sets.precast.WS['Name']` (the provided file: Savage Blade,
Sanguine Blade, Seraph Blade, Chant du Cygne, Requiescat). Moonshade Earring is
added by itself when it reaches the next TP step: [TP bonus](../war/tp-bonus.md)
(`RDM_TP_CONFIG.lua`).

## Job abilities

`sets.precast.JA['Chainspell']`, `sets.precast.JA['Convert']` (empty in the
provided file), and by the same rule `sets.precast.JA['Saboteur']`,
`['Composure']`, `['Stymie']`...

## What the job does by itself

- **Tier step-down** (Enfeeble Tier On, `^numpad9`): an enfeeble with tiers (Dia,
  Bio, Distract, Frazzle, Blind, Slow, Paralyze, Poison, Addle, Sleep, Gravity)
  that is on recast or short of MP is replaced by the next lower tier that can
  go. Nukes always step down. Enfeeble Tier Off: the enfeeble is cancelled and
  its recast shown. See [states.md](states.md).
- **Phalanx by target**: Phalanx II on yourself becomes Phalanx; Phalanx on
  someone else becomes Phalanx II. Always on.
- **Automatic Saboteur** (Saboteur Mode On, `^numpad0`): before the enfeebles
  listed in `RDM_SABOTEUR_CONFIG.lua` (Distract III, Gravity II), Saboteur goes
  out first when ready, then the enfeeble.
- **Saboteur set** on every enfeeble while Saboteur is up (see above). Remove
  `sets.midcast['Enfeebling Magic'].Saboteur` to turn it off.
- **CureSelf** on your own Cures (see above). Remove `sets.midcast.CureSelf` to
  turn it off.
- **Daybreak for Dispelga**, held through the cast and given back after (see
  above). Always on for Dispelga.
- **Composure sets** on buffs cast on others while Composure is up.
- **Weapons**: Main / Sub Weapon sets on top of idle and engaged, unless Combat
  Mode is On.
- Mote's defense keys (F10 / F11) and Kiting toggle (Alt+F10) change no gear on
  RDM: the job builds its idle and engaged sets from its own modes.

## Sets in the provided file that nothing reads

- `sets.precast.JA['Convert']`: read, but empty.

## Names the code reads that the provided file lacks

- The mode sets under a type: `sets.midcast['Enfeebling Magic'].<type>.Potency`,
  `.Skill`, `.Duration`.
- `sets.midcast['Enfeebling Magic'].Skill` and `.Duration` (enfeebles with no type).
- Family sets `sets.midcast.Boost`, and for /SCH `sets.midcast.Storm`.
- `sets.midcast.Haste`, `sets.midcast.Protect`, `sets.midcast.Shell`,
  `sets.midcast.StatusRemoval` (fall back to the Enhancing / Healing base).
- `sets.DW.*` tiers (commented at the end of the file), `sets.TreasureHunter`.
