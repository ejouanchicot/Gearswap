# SMN — set names and automatic gear

Every set name the Summoner code reads, and everything it does to your gear on
its own. Modes and keys: [states.md](states.md). Names every job shares
(Fast Cast by skill, subjob actions, `sets.MoveSpeed`, `sets.idle.Town`,
`sets.buff.Doom`, Treasure Hunter, the automatic Obi / Orpheus belt):
[set names guide](../../guides/sets.md).

The "provided file" below is the SMN set file the clone script gives you:
every set in it except `sets.precast.FC` is an empty skeleton.

To see which set a spell or pact picked: `//gs c debugmidcast`, then cast.

## Empty sets: leave slots out, never `""`

In the provided file every set except the Fast Cast set starts empty
(`empty_set()` returns `{}`; the 16 slot names are listed above it). Until you fill
them, only the Fast Cast set ever goes on, and it stays on after a cast.

When you fill a set, **leave out the slots you do not use**; never write
`slot = ""`. Such a slot is not "leave as is": it replaces the piece another set
was about to put in that slot during the same action, then GearSwap ignores it,
so the gear you already wear stays. It matters most for `sets.MoveSpeed`, laid on
your idle set while you run: keep only the slots that give movement speed.
(Until 2026-09-29 the provided skeleton was all `""`.)

## Idle

| Set | Worn when |
|---|---|
| `sets.idle.Normal` | `IdleMode` Normal (the default) |
| `sets.idle.DT` | `IdleMode` DT |
| `sets.idle.Avatar` | `IdleMode` Avatar, **or** `AvatarFavor` On (which wins over every other idle set, the town set included) |

When the set of the current mode does not exist, the standard idle choice
stands (`sets.idle`, with `sets.idle.Pet` while a pet is out). As long as the
mode's own set exists, there is no separate "avatar out" idle: use
`IdleMode` Avatar or Avatar's Favor for that.

In a town (or Adoulin), `sets.idle.Town` / `sets.Adoulin` go on top of the mode set,
unless `AvatarFavor` is On. `sets.MoveSpeed` is laid on top while you run
outside town (over `sets.idle.Avatar` too).

## Engaged

| Set | Worn when |
|---|---|
| `sets.engaged` | You (not the avatar) are engaged. SMN adds nothing to it |

`sets.resting` is worn while you rest (/heal).

## Precast

| Set | Worn when |
|---|---|
| `sets.precast.FC` | Any spell without its own Fast Cast set |
| `sets.precast.FC['Summoning Magic']` | Summoning an avatar or a spirit |
| `sets.precast.FC['Healing Magic']`, `sets.precast.FC['Enhancing Magic']` | Subjob cures and buffs |
| `sets.precast.FC.Carbuncle`, `sets.precast.FC['Cait Sith']`... | One summon by name, when you add it |
| `sets.precast.FC['Summoning Magic'].Resistant` (and any FC set `.Resistant`) | `CastingMode` Resistant, when you add it |
| `sets.precast.BloodPactRage` | Using a Rage pact (Blood Pact delay gear). **Not in the provided file** |
| `sets.precast.BloodPactWard` | Using a Ward pact. **Not in the provided file** |
| `sets.precast.BloodPactRage['Flaming Crush']`... | One pact by name, under its type |

Without `sets.precast.BloodPactRage` / `BloodPactWard`, a pact looks for a set
with its name under `sets.precast.JA` (`sets.precast.JA['Flaming Crush']`),
and gets no precast gear otherwise.

## Blood Pacts

Each pact is sorted into a category, and the set of that category goes on
twice: when you give the order, and again when the avatar acts. A pact with no
set of its category gets nothing from this system.

| Set | Pacts |
|---|---|
| `sets.pet_midcast.BPRage.Physical` | Physical rage: Punch, Rock Throw, Barracuda Dive, Claw, Welt, Axe Kick, Shock Strike, Camisado, Regal Scratch, Poison Nails, Moonlit Charge, Crescent Fang, Rock Buster, Roundhouse, Tail Whip, Double Punch, Megalith Throw, Double Slap, Eclipse Bite, Mountain Buster, Spinning Dive, Predator Claws, Rush, Chaotic Strike, Volt Strike, Hysteric Assault, Crag Throw, Blindside, Regal Gash |
| `sets.pet_midcast.BPRage.Magical` | Magical rage: Fire II, Stone II, Water II, Aero II, Blizzard II, Thunder II, Thunderspark, Meteorite, Fire IV, Stone IV, Water IV, Aero IV, Blizzard IV, Thunder IV, Sonic Buffet, Nether Blast, Meteor Strike, Geocrush, Grand Fall, Wind Blade, Tornado II, Heavenly Strike, Thunderstorm, Level ? Holy, Holy Mist, Lunar Bay, Night Terror, Conflag Strike, Impact |
| `sets.pet_midcast.BPRage.Hybrid` | Burning Strike, Flaming Crush |
| `sets.pet_midcast.BPRage.AstralFlow` | Searing Light, Inferno, Earthen Fury, Tidal Wave, Aerial Blast, Diamond Dust, Judgment Bolt, Howling Moon, Ruinous Omen, Clarsach Call, Zantetsuken, Perfect Defense |
| `sets.pet_midcast.BPWard.Buff` | Shining Ruby, Glittering Ruby, Aerial Armor, Frost Armor, Rolling Thunder, Katabatic Blades, Ecliptic Growl, Lightning Armor, Noctoshield, Ecliptic Howl, Dream Shroud, Reraise II, Crimson Howl, Hastega, Earthen Ward, Earthen Armor, Fleet Wind, Inferno Howl, Wind's Blessing, Pacifying Ruby, Heavenward Howl, Hastega II, Crystal Blessing |
| `sets.pet_midcast.BPWard.Heal` | Healing Ruby, Whispering Wind, Spring Water, Healing Ruby II, Chinook, Soothing Ruby, Soothing Current, Altana's Favor |
| `sets.pet_midcast.BPWard.Debuff` | Lunatic Voice, Somnolence, Lunar Cry, Mewing Lullaby, Nightmare, Lunar Roar, Slowga, Ultimate Terror, Sleepga, Bitter Elegy, Eerie Eye, Tidal Roar, Shock Squall, Pavor Nocturnus, Deconstruction, Chronoshift, Diamond Storm |

There is no set per pact name and no mode: only these seven categories.
Raise II (Cait Sith) is in no list and gets no Blood Pact set. Deconstruction
and Chronoshift are rage pacts in the game but use the Ward Debuff set here.

At the moment you give the order, a set named after the pact
(`sets.midcast['Flaming Crush']`) or after its type
(`sets.midcast.BloodPactRage`, `sets.midcast.BloodPactWard`) is put on first
if you add one, and the category set goes over it. These names are not used
when the avatar acts.

`sets.midcast.Pet` is not needed. If you write one, it goes on only when the
avatar uses a pact that is not in the lists above; for every known pact the
Blood Pact set stays.

## Spells

Each skill below goes through the shared order: exact spell name, name without
the tier, the spell's usual group (`sets.midcast.Cure`, `.Refresh`...), then
the skill set.

| Set | Worn for |
|---|---|
| `sets.midcast['Summoning Magic']` | Summoning an avatar or a spirit. One by name: `sets.midcast.Carbuncle`, `sets.midcast['Cait Sith']` |
| `sets.midcast['Healing Magic']`, `sets.midcast.Cure`, `sets.midcast.Curaga` | Subjob cures |
| `sets.midcast['Enhancing Magic']`, `sets.midcast.Stoneskin`, `.Phalanx`, `.Refresh`, `.Haste` | Subjob buffs |
| `sets.midcast['Divine Magic']` | Divine spells (/WHM) |
| `sets.midcast['Dark Magic']` | Dark spells (/BLM, /DRK, /SCH) |
| `sets.midcast['Elemental Magic']` | Nukes (/BLM, /RDM, /SCH). `CastingMode` Resistant: `sets.midcast['Elemental Magic'].Resistant` |
| `sets.midcast['Enfeebling Magic']` | Enfeebles (/RDM, /BLM). `CastingMode` Resistant: `sets.midcast['Enfeebling Magic'].Resistant` |
| `sets.midcast['Elemental Siphon']` | Elemental Siphon (a job ability, geared by its name) |

## Weaponskills

`sets.precast.WS`, or `sets.precast.WS['Name']`. SMN has no TP bonus config.

## Job abilities

The provided file has `sets.precast.JA['Astral Flow']`, `['Astral Conduit']`,
`['Apogee']`, `['Elemental Siphon']`, `['Mana Cede']`, `["Avatar's Favor"]`,
`['Release']`. Any other by name under `sets.precast.JA`.

## What the job does by itself

- **Blood Pact sets by category.** Every pact in the lists above wears its
  category set when ordered and again when the avatar acts. Nothing to turn
  on; leave a category set out to wear nothing for it.
- **Avatar's Favor idle.** `AvatarFavor` follows the Avatar's Favor buff on its
  own: when the buff appears, `sets.idle.Avatar` becomes your idle set (even in
  town); when it wears off, the normal idle comes back. You can still flip it
  by hand with Ctrl+Numpad3.
- **Carbuncle auto-summon.** About 10 s after every load (and every subjob
  change), if no pet is out and you are not dead, Carbuncle is summoned. It is
  in the entry file; no mode turns it off.
- **Skill-up loop.** `//gs c skillup` casts Siren, releases her 5 s later, and
  starts again: the Summoning Magic sets above are what you wear for it.
- **Doom.** SMN runs the shared Doom handling itself: `sets.buff.Doom` works as
  on the other jobs, but the provided file has none.

## Sets in the provided file that nothing reads

- `sets.weapons`: no code looks for it.
- `sets.pet.Engaged`: no code looks for it (there is no set for the avatar's
  own melee).

## Names the code reads that the provided file lacks

- `sets.precast.BloodPactRage`, `sets.precast.BloodPactWard` (Blood Pact delay).
- `sets.buff.Doom`.
- `sets.Adoulin` (without it, Adoulin uses `sets.idle.Town`).
- `.Resistant` versions for `CastingMode` Resistant.
