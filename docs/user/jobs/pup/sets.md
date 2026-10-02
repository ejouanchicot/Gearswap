# PUP — set names and automatic gear

Every set name the Puppetmaster code reads, and everything the job puts on by
itself. Modes and keys: [states.md](states.md). Names every job shares (subjob
actions, movement, Doom, Treasure Hunter...): [set names](../../guides/sets.md).

Your file: `<YourName>/pup/sets/pup_sets.lua`. The provided file has every set the
code reads, empty: fill in your pieces. With `//gs c trace on`, each idle and
engaged set chosen is logged with the layers laid on top.

## Weapons

| Set | Worn when |
|---|---|
| `sets['<Weapon>']` | Main Weapon (`^numpad1`) is that value: one set per value you add in `PUP_STATES.lua`, named exactly like the value (`sets['Xiucoatl'] = {main = "Xiucoatl"}`) |

`Free` (default) has no set: you keep the weapon you wear. The weapon set goes
on top of the idle and engaged sets, in town too.

## Idle

Built in this order, each step on top of the one before:

1. **You**: `sets.idle`, or `sets.idle.DT` with Hybrid Mode DT.
2. **Town**: `sets.idle.Town` in a city (Dynamis excluded), `sets.Adoulin` in
   the Adoulin cities (checked first, if you add it).
3. **Automaton**: out and fighting, `sets.idle.Pet.Engaged.<Pet Mode>`, or
   `sets.idle.Pet.Engaged` when that Pet Mode has no set; out and not fighting,
   `sets.idle.Pet`; not out, nothing.
4. `sets.buff.Overdrive` while Overdrive is up.
5. The automaton's weaponskill set when due (see below).
6. Mote's defense (F10 / F11) and Kiting (Alt+F10) sets, then your weapon.
7. `sets.MoveSpeed` while moving, outside a city.

| Set | Worn when |
|---|---|
| `sets.idle` | No automaton out (under the automaton sets otherwise) |
| `sets.idle.DT` | Hybrid Mode DT (`^numpad9`) |
| `sets.idle.Town` | In a city, on top |
| `sets.idle.Pet` | Automaton out, not fighting |
| `sets.idle.Pet.Engaged` | Automaton fighting, you are not |
| `sets.idle.Pet.Engaged.Melee`, `.Tank`, `.RangedPet`, `.Magic`, `.Heal`, `.Nuke` | Same, with that Pet Mode (Ranged mode: `.RangedPet`, since GearSwap reads a `.Ranged` key as the range slot) |
| `sets.resting` | Resting (`/heal`) |

The automaton sets go **on top** of your idle set: a slot they leave empty keeps
your idle piece.

## Engaged

| Set | Worn when |
|---|---|
| `sets.engaged` | You fight, the automaton does not |
| `sets.engaged.Acc` | Same, Offense Mode Acc (`^numpad2`) |
| `sets.engaged.DT` | Same, Hybrid Mode DT |
| `sets.engaged.Pet` | You and the automaton both fight |
| `sets.engaged.Pet.DT` | Both fight, Hybrid Mode DT |

You can also add `sets.engaged.Pet.Acc` and `sets.engaged.Acc.DT` /
`sets.engaged.Pet.Acc.DT`: the Offense Mode level is used when it exists, and
with Hybrid Mode DT its `.DT`, else the `.DT` of `sets.engaged` (or of
`sets.engaged.Pet`). Then, on top: `sets.buff.Overdrive`, the automaton's
weaponskill set when due, Mote's defense and Kiting sets, your weapon.

## The automaton's weaponskills

| Set | Worn when |
|---|---|
| `sets.midcast.Pet.WeaponSkill.<Pet Mode>` | Pet WS On (`^numpad4`), the automaton fights and its TP is at least `pet_ws_tp` (1000, `PUP_TP_CONFIG.lua`): on top of your idle or engaged gear, **before** the weaponskill. The provided file has `.Melee`, `.Tank`, `.Ranged`; add any other Pet Mode |
| `sets.midcast.Pet.WeaponSkill` | Same, for a Pet Mode with no set of its own |
| `sets.midcast.Pet['<Weaponskill name>']` | As that weaponskill goes off (not in the provided file). Usually too late to matter: prefer the sets above |

The job checks the automaton's TP twice a second while it is out, and puts
your gear back once the TP drops.

## The automaton's spells

Worn when the automaton starts casting, the first found:

| Set | Spells |
|---|---|
| `sets.midcast.Pet['<Spell name>']` | That spell |
| `sets.midcast.Pet.Cure` | Cure I to VI |
| `sets.midcast.Pet['Elemental Magic']` | Nukes |
| `sets.midcast.Pet['Enfeebling Magic']` | Enfeebles |
| `sets.midcast.Pet['Healing Magic']`, `['Enhancing Magic']`, `['Dark Magic']` | Those skills, if you add them |

Your normal gear comes back when the spell ends.

## Buffs

| Set | Worn when |
|---|---|
| `sets.buff.Overdrive` | Overdrive is up, on top of idle and engaged |
| `sets.buff.Doom` | Doomed |

## Job abilities

| Set | Worn when |
|---|---|
| `sets.precast.JA['Activate']`, `['Deus Ex Automata']`, `['Repair']`, `['Maintenance']`, `['Overdrive']`, `['Tactical Switch']`, `['Ventriloquy']`, `['Role Reversal']`, `['Cooldown']` | That ability |
| `sets.precast.JA.Maneuver` | Any of the eight maneuvers; a set named after one maneuver (`sets.precast.JA['Fire Maneuver']`) wins |
| `sets.precast.JA['Deploy']`, `['Retrieve']`... | Any other ability, by its name, if you add it |
| `sets.precast.Waltz`, `sets.precast.Waltz['Healing Waltz']` | /DNC waltzes |

Do not create `sets.precast.PetCommand`: the maneuvers and Deploy would look
for their set there instead of `sets.precast.JA`.

## Your weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.WS` | Any weaponskill without its own set |
| `sets.precast.WS['Victory Smite']`, `['Shijin Spiral']`, `['Stringing Pummel']`, `['Howling Fist']`, `['Asuran Fists']` | That weaponskill |
| `sets.precast.WS.Acc`, `sets.precast.WS['Name'].Acc` | WS Mode Acc, or Offense Mode Acc |

Moonshade Earring is added by itself when it reaches the next TP step:
[TP bonus](../../features/tp-bonus.md) (`PUP_TP_CONFIG.lua`).

## Spells (subjob)

| Set | Worn when |
|---|---|
| `sets.precast.FC`, `sets.precast.FC.Utsusemi` | Cast start (Fast Cast); Utsusemi |
| `sets.midcast.FastRecast` | First, under every spell's set |
| `sets.midcast.Utsusemi` | Utsusemi (/NIN) |
| `sets.midcast['Spell Name']`, `sets.midcast.Cure`, `sets.midcast['Healing Magic']`... | Other subjob spells, as on every job ([set names](../../guides/sets.md)) |

## Movement and town

`sets.MoveSpeed` (moving, idle, outside a city), `sets.Kiting` (Alt+F10),
`sets.idle.Town`, `sets.Adoulin` (commented in the provided file).

## Names the code reads that the provided file lacks

- `sets.Adoulin`, `sets.TreasureHunter` (both commented), `sets.defense.PDT` /
  `.MDT`.
- `sets.idle.Pet.Engaged.<Pet Mode>` exist for all six; `sets.midcast.Pet
  .WeaponSkill` only for Melee, Tank, Ranged (`.RangedPet`).
- `sets.engaged.Pet.Acc`, `.Acc.DT` versions.
- `sets.midcast.Pet['Healing Magic']`, `['Enhancing Magic']`, `['Dark Magic']`,
  per-name automaton sets.
