# SCH — set names and automatic gear

Every set name the Scholar code reads, and everything the job puts on by
itself. Modes and keys: [states.md](states.md). Names every job shares (subjob
actions, movement, Doom, Treasure Hunter...): [set names](../../guides/sets.md).

Your file: `<YourName>/sch/sets/sch_sets.lua`. The provided file has every set the
code reads, empty: fill in your pieces. With `//gs c trace on`, each idle and
engaged set chosen is logged.

## Weapons

| Set | Worn when |
|---|---|
| `sets['<Weapon>']` | Main Weapon (`^numpad1`) or Sub Weapon (`^numpad2`) is that value: one set per value you add in `SCH_STATES.lua`, named exactly like the value (`sets['Musa'] = {main = "Musa", sub = "Khonsu"}`) |
| `sets.CombatMode` | Put on when Combat Mode turns On, then locked (commented in the provided file) |

`Free` (default) has no set: you keep the weapon you wear.

## Idle

Built in this order, each step on top of the one before:

1. In a city: `sets.idle.Town` on top of `sets.idle` (`sets.Adoulin` in the
   Adoulin cities, if you add it). Elsewhere: `sets.idle.DT` with Hybrid Mode
   DT, else `sets.idle`.
2. `sets.buff.Sublimation` while Sublimation charges.
3. Mote's defense (F10 / F11) and Kiting (Alt+F10) sets, then your weapons.
4. `sets.MoveSpeed` while moving, outside a city.

| Set | Worn when |
|---|---|
| `sets.idle` | Idle |
| `sets.idle.DT` | Hybrid Mode DT (`^numpad9`), outside a city |
| `sets.idle.Town` | In a city, on top |
| `sets.resting` | Resting (`/heal`) |

## Engaged

| Set | Worn when |
|---|---|
| `sets.engaged` | Fighting |
| `sets.engaged.Acc` | Offense Mode Acc (`^numpad6`) |
| `sets.engaged.DT` | Hybrid Mode DT |

You can also add `sets.engaged.Acc.DT`: with Offense Mode Acc and Hybrid Mode
DT it is used when it exists, else `sets.engaged.DT`. Then Mote's defense and
Kiting sets and your weapons.

## Spells: cast start (precast)

Mote picks the first found: `sets.precast.FC['<Spell name>']`, the spell's map
(`sets.precast.FC.Cure`), its skill (`sets.precast.FC['Enhancing Magic']`), then
`sets.precast.FC`. Then, on top:

| Set | Worn when |
|---|---|
| `sets.precast.FC.Grimoire` | The spell is of the Arts you have up: white magic under Light Arts / Addendum: White, black magic under Dark Arts / Addendum: Black. For "Grimoire: spellcasting time" pieces |
| `sets.buff.Celerity` | Celerity up, white magic |
| `sets.buff.Alacrity` | Alacrity up, black magic |

The provided file has `sets.precast.FC`, `.Grimoire`, `['Enhancing Magic']`,
`['Elemental Magic']`, `.Cure`.

## Spells: as they land (midcast)

`sets.midcast.FastRecast` goes first, then the first found of: the spell's own
name, its name without the tier (`sets.midcast.Aspir` for Aspir II), its family
(`Regen`, `Storm`), its map (`Cure`, `Curaga`, `StatusRemoval`), its skill.

| Set | Worn when |
|---|---|
| `sets.midcast['Elemental Magic']` | Nukes |
| `sets.midcast['Elemental Magic'].MagicBurst` | Nukes, Magic Burst On |
| `sets.midcast.Helix` | Helices (Pyrohelix, Cryohelix...) |
| `sets.midcast.Helix.MagicBurst` | Helices, Magic Burst On |
| `sets.midcast.Helix.Dark` / `.Light` | Noctohelix / Luminohelix (`.Dark.MagicBurst`, `.Light.MagicBurst` if you add them) |
| `sets.midcast['Dark Magic']`, `sets.midcast.Drain`, `sets.midcast.Aspir` | Dark Magic, Drain, Aspir I-II |
| `sets.midcast.Kaustra`, `sets.midcast.Kaustra.MagicBurst` | Kaustra; with Magic Burst On |
| `sets.midcast['Enhancing Magic']` | Enhancing spells without their own set |
| `sets.midcast.Regen` | Regen I-V |
| `sets.midcast.Storm` | Firestorm ... Voidstorm, I and II |
| `sets.midcast.Stoneskin`, `sets.midcast.Aquaveil` | Those spells |
| `sets.midcast.MndEnfeebles` | White enfeebles (Paralyze, Slow, Silence...) |
| `sets.midcast.IntEnfeebles` | Black enfeebles (Sleep, Blind, Break, Dispel...) |
| `sets.midcast['Enfeebling Magic']` | Enfeebles when the two above are missing |
| `sets.midcast.Cure`, `sets.midcast.Curaga` | Cure I-IV; Curaga (/WHM) |
| `sets.midcast.StatusRemoval`, `sets.midcast.Cursna` | -na spells and Erase; Cursna |
| `sets.midcast['Healing Magic']` | Other Healing Magic (Raise...) |
| `sets.midcast['<Spell name>']` | Any spell, by name, if you add it (`sets.midcast['Sleep II']`) |

Then on top, while the stratagem is up (see Buffs), and at the end the shared
elemental belt (Hachirin-no-Obi / Orpheus's Sash on nukes and helices, `//gs c
belt`).

## Buffs

| Set | Worn when |
|---|---|
| `sets.buff.Sublimation` | Idle, while Sublimation charges (not once it is complete) |
| `sets.buff.Perpetuance` | Enhancing Magic cast under Perpetuance |
| `sets.buff.Rapture` | White magic cast under Rapture |
| `sets.buff.Ebullience` | Black magic cast under Ebullience |
| `sets.buff.Immanence` | Elemental Magic cast under Immanence |
| `sets.buff.Klimaform` | Elemental Magic of the weather's element, under Klimaform |
| `sets.buff.Celerity` / `.Alacrity` | White / black magic under Celerity / Alacrity, at cast start and as it lands |
| `sets.buff.Doom` | Doomed |

## Job abilities and weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.JA['Tabula Rasa']`, `['Enlightenment']` | That ability |
| `sets.precast.JA['<Name>']` | Any other ability, by its name, if you add it |
| `sets.precast.Waltz`, `sets.precast.Waltz['Healing Waltz']` | /DNC waltzes |
| `sets.precast.WS` | Any weaponskill without its own set |
| `sets.precast.WS['Myrkr']`, `['Omniscience']`, `['Cataclysm']`, `['Shattersoul']`, `['Black Halo']` | That weaponskill |

Moonshade Earring is added by itself when it reaches the next TP step:
[TP bonus](../war/tp-bonus.md) (`SCH_TP_CONFIG.lua`).

## Movement and town

`sets.MoveSpeed` (moving, idle, outside a city), `sets.Kiting` (Alt+F10),
`sets.idle.Town`, `sets.Adoulin` (commented in the provided file).

## Names the code reads that the provided file lacks

- `sets.Adoulin`, `sets.CombatMode`, `sets.TreasureHunter` (all commented),
  `sets.defense.PDT` / `.MDT`.
- `sets.engaged.Acc.DT`, `sets.midcast.Helix.Dark.MagicBurst` /
  `.Light.MagicBurst`, per-name sets.
