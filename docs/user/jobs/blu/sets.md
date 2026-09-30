# BLU — set names and automatic gear

Every set name the Blue Mage code reads, and everything the job puts on or does
by itself. Modes and keys: [states.md](states.md). Names every job shares
(subjob actions, movement, Doom, Dual Wield tiers, Treasure Hunter, Obi and
Orpheus): [set names](../../guides/sets.md).

Your file: `<YourName>/blu/blu_sets.lua`. The provided file has every set the
code reads, empty: fill in your pieces. `//gs c debugmidcast` shows, for each
spell, which set was chosen and why.

## Weapons

| Set | Worn when |
|---|---|
| `sets['<Weapon>']` | Main Weapon (`^numpad1`) or Sub Weapon (`^numpad2`) is that value: one set per value you add in `BLU_STATES.lua`, named exactly like the value (`sets['Naegling'] = {main = "Naegling"}`, `sets['Thibron'] = {sub = "Thibron"}`) |

- The value `Free` (default) has no set: you keep the weapon you wear.
- With `equip_without_set = true` in `common/combat/WEAPON_CONFIG.lua`, a value that is
  a real weapon name needs no set.
- The weapon sets go on top of the idle and engaged sets, in town too.
- A weapon set chosen as the Sub Weapon only moves the off hand, even if it
  also names a main hand (with `equip_without_set` on).
- Combat Mode (hidden on BLU, `//gs c combatmode show`) locks main, sub and
  range: the weapon pieces of every set are then ignored.

## Idle

| Set | Worn when |
|---|---|
| `sets.idle` | Idle Mode `Normal` (default, `^numpad4`), unless you define `sets.idle.Normal` |
| `sets.idle.Evasion`, `sets.idle.DT`, `sets.idle.Regain` | Idle Mode `Evasion` / `DT` / `Regain` |
| `sets.idle.Town` | In a city (Dynamis excluded), when you define it (not in the provided file) |
| `sets.Adoulin` | In Western / Eastern Adoulin, when you define it; checked before `sets.idle.Town` |
| `sets.MoveSpeed` | Moving, outside a city |
| `sets.resting` | Resting (`/heal`) |

In Idle Mode `Normal`, Mote's own idle choice is kept, so `sets.idle.Weak`
(weakened after a Raise, outside a city) also works if you define it.

## Engaged

The engaged set is found by walking down, each level used only if it exists:

1. `sets.engaged`
2. `.SW` when you **single wield**: nothing, a shield or a grip in the off hand
   (`sets.engaged.SW`)
3. the Offense Mode (`^numpad3`: `Normal`, `Acc`, `DT`, `Subtle Blow`, `Refresh`):
   `sets.engaged.Acc`, `sets.engaged.DT`, `sets.engaged['Subtle Blow']` (with a
   space), `sets.engaged.Refresh`; single wielding: `sets.engaged.SW.Acc`...

| Set | Worn when |
|---|---|
| `sets.engaged` | Dual wield, Offense Mode `Normal` (or a mode with no set) |
| `sets.engaged.Acc`, `.DT`, `['Subtle Blow']`, `.Refresh` | Dual wield, that Offense Mode |
| `sets.engaged.SW` | Single wield, Offense Mode `Normal`, or a mode with no `.SW` version (the provided file has only `.SW.Acc` and `.SW.Refresh`) |
| `sets.engaged.SW.Acc`, `.SW.Refresh` (and any `.SW.<Mode>` you add) | Single wield, that mode |

The off hand checked is the item of the Sub Weapon set; with `Free`, a value
with no item, or Combat Mode On, it is the item you actually wear. The game's
item list decides weapon or not; your subjob is not checked.

Mote's F10 / F11 defense sets (`sets.defense.PDT`, `sets.defense.MDT`, Alt+F12
to stop) and `sets.Kiting` (Alt+F10) go on top of the idle and engaged set,
under the weapons. The shared Dual Wield tier sets go on top of the engaged set
while dual wielding: see [set names](../../guides/sets.md).

## Precast (Fast Cast)

Chosen by Mote under `sets.precast.FC`, by spell name, then spell category,
then skill:

| Set | Worn when |
|---|---|
| `sets.precast.FC['Spell Name']` | That spell |
| `sets.precast.FC.<Category>` | Any Blue Magic spell of that category (categories below), when you define it |
| `sets.precast.FC['Blue Magic']` | Any Blue Magic spell otherwise; under it, `sets.precast.FC['Blue Magic'].<Category>` or `['Spell Name']` also work |
| `sets.precast.FC` | Any other spell |

With Casting Mode `Resistant`, a `.Resistant` child of the chosen set is used
when it exists (`sets.precast.FC['Blue Magic'].Resistant`).

## Blue Magic

At the start of every spell `sets.midcast.FastRecast` goes on first, under the
spell's set: a spell set that leaves slots empty keeps FastRecast pieces there.

Each spell has a **category**, read from your `blu/combat/BLU_SPELL_MAP.lua`;
a spell the map does not list takes the broad category of the project's Blue
Magic list: `Physical`, `Magical`, `Buff`, `Breath`, `Healing`, or
`MagicAccuracy` for a debuff. Order, first found wins:

1. `sets.midcast['Spell Name']` (the provided file: Sound Blast, Restoral, White Wind)
2. `sets.midcast['Blue Magic'].<Category>.Resistant` with Casting Mode `Resistant`
   (`^numpad5`); the provided file has only `.Magical.Resistant`
3. `sets.midcast['Blue Magic'].<Category>`
4. `sets.midcast['Blue Magic'].Resistant` with Casting Mode `Resistant`, for a
   spell whose category has no set
5. `sets.midcast['Blue Magic']`

In Casting Mode `Normal`, a `.Normal` child is looked up at the same places
(`sets.midcast['Blue Magic'].Magical.Normal`); you do not need one.

Do not name a set at the root of `sets.midcast` after a category
(`sets.midcast.Magical`): it is found before `sets.midcast['Blue Magic'].Magical`.

### Categories (template map)

| Category | Spells |
|---|---|
| `Physical` | Bilgestorm |
| `PhysicalAcc` | Heavy Strike |
| `PhysicalStr` | Battle Dance, Bloodrake, Death Scissors, Dimensional Death, Empty Thrash, Quadrastrike, Saurian Slide, Sinker Drill, Spinal Cleave, Uppercut, Vertical Cleave |
| `PhysicalDex` | Amorphic Spikes, Asuran Claws, Barbed Crescent, Claw Cyclone, Disseverment, Foot Kick, Frenetic Rip, Goblin Rush, Hysteric Barrage, Paralyzing Triad, Seedspray, Sickle Slash, Smite of Rage, Terror Touch, Thrashing Assault, Vanity Dive |
| `PhysicalVit` | Body Slam, Cannonball, Delta Thrust, Glutinous Dart, Grand Slam, Power Attack, Quad. Continuum, Sprout Smack, Sub-zero Smash, Sweeping Gouge |
| `PhysicalAgi` | Benthic Typhoon, Feather Storm, Helldive, Hydro Shot, Jet Stream, Pinecone Bomb, Spiral Spin, Wild Oats |
| `PhysicalInt` | Mandibular Bite, Queasyshroom |
| `PhysicalMnd` | Ram Charge, Screwdriver |
| `PhysicalChr` | Bludgeon |
| `PhysicalHP` | Final Sting |
| `Magical` | Blastbomb, Blazing Bound, Bomb Toss, Cursed Sphere, Dark Orb, Death Ray, Diffusion Ray, Droning Whirlwind, Embalming Earth, Firespit, Foul Waters, Ice Break, Leafstorm, Maelstrom, Rail Cannon, Regurgitation, Rending Deluge, Retinal Glare, Subduction, Tem. Upheaval, Water Bomb, Molting Plumage, Nectarous Deluge, Searing Tempest, Blinding Fulgor, Spectral Floe, Scouring Spate, Anvil Lightning, Tenebral Crush, Palling Salvo, Crashing Thunder, Polar Roar, Tearing Gust, Cesspool |
| `MagicalEarth` | Entomb |
| `MagicalMnd` | Acrid Stream, Evryone. Grudge, Magic Hammer, Mind Blast |
| `MagicalChr` | Eyes On Me, Mysterious Light |
| `MagicalVit` | Thermal Pulse, Uproot |
| `MagicalDex` | Charged Whisker, Gates of Hades |
| `MagicAccuracy` | 1000 Needles, Absolute Terror, Auroral Drape, Awful Eye, Blank Gaze, Blistering Roar, Blood Drain, Blood Saber, Chaotic Eye, Cimicine Discharge, Cold Wave, Corrosive Ooze, Demoralizing Roar, Digest, Dream Flower, Enervation, Filamented Hold, Frightful Roar, Geist Wall, Infrasonics, Jettatura, Light of Penance, Lowing, Mortal Ray, MP Drainkiss, Osmosis, Sandspin, Sandspray, Sheep Song, Soporific, Stinking Gas, Venom Shell, Voracious Trunk, Yawn, Cruel Joke, Silent Storm, Tourbillion, Atra. Libations, Sound Blast |
| `TPRemoval` | Reaving Wind, Feather Tickle |
| `Enmity` | Actinic Burst, Temporal Shift, Fantod, Exuviation |
| `Breath` | Bad Breath, Flying Hip Press, Frost Breath, Heat Breath, Hecatomb Wave, Magnetite Cloud, Poison Breath, Radiant Breath, Self-Destruct, Thunder Breath, Vapor Spray, Wind Breath |
| `Stun` | Blitzstrahl, Frypan, Head Butt, Sudden Lunge, Tail Slap, Thunderbolt, Whirl of Rage |
| `Healing` | Healing Breeze, Magic Fruit, Plenilune Embrace, Pollen, Wild Carrot |
| `HealingHP` | White Wind (scales with max HP) |
| `HealingSkill` | Restoral (scales with Blue Magic skill) |
| `SkillBasedBuff` | Barrier Tusk, Diamondhide, Magic Barrier, Metallic Body, Occultation, Plasma Charge, Pyric Bulwark, Reactor Cool |
| `Buff` | Amplification, Animating Wail, Battery Charge, Carcharian Verve, Cocoon, Erratic Flutter, Feather Barrier, Harden Shell, Memento Mori, Nat. Meditation, Refueling, Regeneration, Saline Coat, Triumphant Roar, Warm-Up, Winds of Promy., Zephyr Mantle, Mighty Guard, O. Counterstance |

You can rename, add or remove categories in the map: a new category `Foo`
simply wears `sets.midcast['Blue Magic'].Foo`. Rules for the map (game short
names, a spell listed twice, reload after editing): [states.md](states.md#how-blue-magic-picks-its-gear).

### On top of the Blue Magic set

| Set | Worn when |
|---|---|
| `sets.buff['Burst Affinity']`, `sets.buff['Chain Affinity']`, `sets.buff.Convergence`, `sets.buff.Diffusion`, `sets.buff.Efflux` | That buff is up, on **every** Blue Magic spell (not only the ones the buff affects). Several up: put on in this order, the later wins a shared slot |
| `sets.self_healing` | A `Healing` category spell cast on yourself. It goes on top of everything, the spell's own set included: White Wind and Restoral are kept out of `Healing` (categories `HealingHP` / `HealingSkill`) so their own set stays. Built on the Healing set, it replaces it entirely |

## Subjob magic

| Skill | Sets |
|---|---|
| Enfeebling Magic (/RDM, /BLM...) | Same order as RDM with Casting Mode as the mode: `sets.midcast['Spell Name']`, name without tier, `sets.midcast['Enfeebling Magic'].<type>.Resistant`, `.<type>`, `sets.midcast['Enfeebling Magic'].Resistant`, then `sets.midcast['Enfeebling Magic']` (types: [RDM sets](../rdm/sets.md#enfeebling-magic)) |
| Enhancing Magic (/RDM, /WHM) | Name, name without tier, family (`sets.midcast.Refresh`, `sets.midcast.Phalanx`, `sets.midcast.BarElement`...), then `sets.midcast['Enhancing Magic']` |
| Healing Magic, Dark, Elemental, Ninjutsu... | `sets.midcast['Spell Name']`, then its name without tier or family (`sets.midcast.Cure`, `sets.midcast.Utsusemi`), then `sets.midcast['<Skill>']` |
| White or Black Magic with none of the above | `sets.midcast.WhiteMagic` (the provided file uses it for WHM / RDM spells), `sets.midcast.BlackMagic` |

When `sets.midcast['<Skill>']` does not exist (Enhancing and Healing in the
provided file), only the set found by spell name, by Mote's family name
(`Refresh`, `Regen`, `BarElement`, `Protect`, `Cure`, `Utsusemi`...) or by
`WhiteMagic` / `BlackMagic` applies.

## Weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.WS` | Any weaponskill without its own set |
| `sets.precast.WS['Name']` | That weaponskill (the provided file: Expiacion, Savage Blade, Chant du Cygne, Requiescat, Sanguine Blade) |
| `sets.precast.WS.Acc`, `sets.precast.WS['Name'].Acc` | WS Mode `Acc` (`^numpad6`), or Offense Mode `Acc` while WS Mode is `Normal` |

Moonshade Earring is added by itself when it reaches the next TP step:
[TP bonus](../war/tp-bonus.md) (`BLU_TP_CONFIG.lua`).

## Job abilities

`sets.precast.JA['Azure Lore']` in the provided file; any other ability by its
name: `sets.precast.JA['Chain Affinity']`, `['Burst Affinity']`, `['Diffusion']`,
`['Efflux']`, `['Unbridled Learning']`... `sets.precast.Waltz` and
`sets.precast.Waltz['Healing Waltz']` for /DNC.

## What the job does by itself

- **Blue Magic by category**: every spell wears its category's set; change a
  spell's category in `BLU_SPELL_MAP.lua`, no set to rename.
- **Buff layers** (Chain Affinity, Burst Affinity, Convergence, Diffusion,
  Efflux) on every Blue Magic spell while the buff is up. Leave a set empty to
  turn its layer off.
- **Self healing set** on Healing spells cast on yourself.
- **Single wield** picks the `.SW` engaged sets by itself from your off hand.
- **Weapons**: Main / Sub Weapon sets on top of idle and engaged.
- **Unbridled Learning before an unbridled spell** and **the Expiacion
  window**: off unless turned on in `common/combat/AUTO_ABILITIES.lua`, see
  [states.md](states.md#automatic-abilities). They change no gear.
- **AzureSets addon** loaded with BLU, unloaded when you leave it.

## Sets in the provided file that nothing reads

- `sets.Learning`: worn only by hand, `//gs equip sets.Learning` (Blue Magic
  skill for learning spells).
- `sets.midcast['Enfeebling Magic']`: read for subjob enfeebles; empty.

## Names the code reads that the provided file lacks

- `sets.idle.Town`, `sets.Adoulin`, `sets.idle.Normal`, `sets.engaged.Normal`.
- `.Resistant` versions of the categories other than `Magical`, and
  `sets.midcast['Blue Magic'].Resistant`.
- `sets.engaged.SW.DT`, `sets.engaged.SW['Subtle Blow']`.
- `sets.precast.FC.<Category>`, `sets.midcast['Enhancing Magic']`,
  `sets.midcast['Healing Magic']`, `sets.defense.PDT` / `.MDT`.
- `sets.DW.*`, `sets.TreasureHunter` (see [set names](../../guides/sets.md)).
