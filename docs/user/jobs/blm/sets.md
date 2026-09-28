# BLM — set names and automatic gear

Every set name the Black Mage code reads, and everything it does to your gear
on its own. Modes and keys: [states.md](states.md). Names every job shares
(Fast Cast by skill, subjob actions, `sets.MoveSpeed`, `sets.idle.Town`,
`sets.buff.Doom`, Treasure Hunter, the automatic Obi / Orpheus belt):
[set names guide](../../guides/sets.md).

To see which set a spell picked: `//gs c debugmidcast`, then cast.

## Idle

| Set | Worn when |
|---|---|
| `sets.idle.Normal` | Standing, not fighting (the default) |
| `sets.idle.PDT` | `HybridMode` is PDT. Missing: `sets.idle.Normal` stays |
| `sets.idle.Death` | `DeathMode` is On. Wins over `sets.idle.PDT`. Missing: the PDT or Normal set stays. Fill it with max MP gear: Death hits for your current MP x 3 |
| `sets.buff['Mana Wall']` | Laid over the idle set while Mana Wall is up (idle only, not engaged) |
| `sets.Hvergelmir` | Laid over idle and engaged when it exists (it is the `MainWeapon` value). The provided file has none, so your idle sets choose the staff |
| `sets['Alber Strap']` | Same, for the `SubWeapon` value |

In a town (or Adoulin), `sets.idle.Town` / `sets.Adoulin` replace the idle set
entirely, Death and PDT included; `sets.buff['Mana Wall']` is still laid on top.

## Engaged

| Set | Worn when |
|---|---|
| `sets.engaged.Normal` | Weapon out (the default) |
| `sets.engaged.PDT` | `HybridMode` is PDT. Missing: `sets.engaged.Normal` stays |

`DeathMode` and Mana Wall change nothing while engaged. The weapon sets above
(`sets.Hvergelmir`, `sets['Alber Strap']`) are laid on top when they exist.

## Precast (Fast Cast)

The shared rules apply (`sets.precast.FC['Spell name']`, then the skill, then
`sets.precast.FC`). The provided file has:

| Set | Worn when |
|---|---|
| `sets.precast.FC` | Any spell without its own Fast Cast set |
| `sets.precast.FC['Elemental Magic']` | Nukes (a copy of `sets.precast.FC` in the provided file) |
| `sets.precast.FC['Enhancing Magic']` | Enhancing spells (a copy of `sets.precast.FC`) |
| `sets.precast.FC.Stoneskin` | Stoneskin |
| `sets.precast.FC.Cure`, `sets.precast.FC.Curaga` | Cures from /WHM, /RDM, /SCH |
| `sets.precast.FC.Impact` | Impact. **Must hold `body = 'Twilight Cloak'`**: the code puts the cloak on, but this set is equipped right after and its body wins |

## Spells

### Elemental Magic (nukes)

For a nuke, the most precise name wins:

1. its exact name: `sets.midcast['Fire VI']`
2. its name without the tier: `sets.midcast.Fire`, or
   `sets.midcast['Elemental Magic'].Fire`
3. when `MagicBurstMode` is On or Acc:
   `sets.midcast['Elemental Magic'].MagicBurst`
4. the skill set: `sets.midcast['Elemental Magic']`

Then, in this order, on top of what was chosen:

| Set | Laid on top when |
|---|---|
| `sets.midcast.MPConservation` | Your MP is below 1000 when the spell starts (`mp_threshold` in `BLM_MP_CONFIG.lua`) |
| `sets.midcast.ElementalMatch` | A storm, the day or the weather matches the spell's element. **Only when the shared automatic belt is turned off** (see below) |
| `sets.midcast.QuanpurStone` | Stone, Stone II to VI, Stoneja, Stonera I-III (not Stonega, not Quake). For Quanpur Necklace. **Not in the provided file**: add it |
| `sets.midcast['Elemental Magic'].MagicBurst.acc` | `MagicBurstMode` is Acc. Last, so it wins over the three sets above |

A set named after one spell (step 1 or 2) beats the Magic Burst set. The
provided file names several:

| Set | Worn for |
|---|---|
| `sets.midcast['Comet']` | Comet. A copy of the nuke set: with it, Comet never gets the Magic Burst set. Delete the line to let Comet use `MagicBurst` |
| `sets.midcast['Meteor']` | Meteor (copy of the nuke set) |
| `sets.midcast['Burn']` | Burn, and through copies Rasp, Shock, Drown, Choke, Frost (INT and magic accuracy). Acc mode still lays `MagicBurst.acc` over it |

### Impact

| Set | Worn when |
|---|---|
| `sets.midcast['Impact']` | Casting Impact. Missing: `sets.midcast['Elemental Magic']` |
| `sets.midcast['Impact'].MagicBurst` | `MagicBurstMode` is On (not Acc: Acc uses the plain Impact set) |

Twilight Cloak is put on the body whatever the set says, from the start of the
cast to the end. No MP, belt-match or Quanpur set is added to Impact.

**Known issue (found 2026-09-28, from the code, not tested in game):** a shared
step that runs at the end of every midcast puts `sets.midcast['Impact']` back on
after BLM's choice, so `.MagicBurst` is not worn and the cloak is only kept if
`sets.midcast['Impact']` itself holds `body = 'Twilight Cloak'` (the provided
file does). Keep the cloak in `sets.midcast['Impact']`.

### Dark Magic

`sets.midcast['Dark Magic']`, with a name per spell when you want one:
`sets.midcast.Drain` (Drain, Drain II, Drain III), `sets.midcast.Aspir`,
`sets.midcast.Stun`, `sets.midcast.Bio`, `sets.midcast['Drain III']`...

| Set | Worn for |
|---|---|
| `sets.midcast['Death']` | Death. It is a Dark Magic spell: no Magic Burst, MP or belt set is added. In the provided file it is a copy of the nuke set; missing, Death would use `sets.midcast['Dark Magic']` (the Drain / Aspir set) |
| `sets.midcast.Klimaform` | Klimaform (/SCH) is also Dark Magic: without this name it is cast in your Drain / Aspir set |

### Enfeebling Magic

The provided file has **no** `sets.midcast['Enfeebling Magic']`. Without it,
each spell only gets a set with its exact name. The provided file gives
these a copy of `sets.midcast.IntEnfeebles`:

`sets.midcast.Sleep`, `['Sleep II']`, `.Sleepga`, `['Sleepga II']`,
`.Break`, `.Breakga`, `.Blind`.

Any other enfeeble (Bind, Poison, Slow, Paralyze...) gets nothing until you add
`sets.midcast['Enfeebling Magic']` or a set with its name. Once the skill set
exists, the same order as nukes applies (exact name, then tier-less name, then
the skill set).

`sets.midcast.MndEnfeebles` is in the provided file but no spell reaches it:
write `sets.midcast.Slow = sets.midcast.MndEnfeebles` (and the same for
Paralyze, Silence...) to use it.

### Enhancing and healing

No BLM code here: the shared names apply. The provided file has
`sets.midcast['Enhancing Magic']`, `sets.midcast.Stoneskin`,
`sets.midcast.Aquaveil`, `sets.midcast.Phalanx`, `sets.midcast.Refresh`,
`sets.midcast.Haste`, `sets.midcast.Cure`, `sets.midcast.Curaga`,
`sets.midcast.Raise`. Storms (/SCH) use `sets.midcast.Storm` when you add it,
otherwise `sets.midcast['Enhancing Magic']`.

## Weaponskills

`sets.precast.WS` for all, or `sets.precast.WS['Myrkr']` (any weaponskill by
name). The provided file has only `sets.precast.WS`.

## Job abilities

| Set | Worn when |
|---|---|
| `sets.precast.JA['Mana Wall']` | Using Mana Wall |
| `sets.precast.JA.Manafont` | Using Manafont |
| `sets.precast.JA['Elemental Seal']` | Using Elemental Seal (empty in the provided file) |

Any other ability by name under `sets.precast.JA`.

## What the job does by itself

- **Magic Burst sets from the mode.** `MagicBurstMode` On: nukes use
  `sets.midcast['Elemental Magic'].MagicBurst`, Impact uses
  `sets.midcast['Impact'].MagicBurst`. Acc: the MagicBurst set, then
  `MagicBurst.acc` last (Impact ignores Acc). Off: the plain nuke set.
- **Party call.** With `MagicBurstMode` On (not Acc), every nuke posts
  `Casting: [<spell>] => Nuke` in party chat, at most once every 2.5 s, even
  when the cast then fails. Turn it off: set the mode to Off or Acc.
- **Low MP gear.** Below 1000 MP, `sets.midcast.MPConservation` goes on over
  every nuke (not Impact, not Death). Change the threshold in
  `BLM_MP_CONFIG.lua` (`mp_threshold`); leave the set out to never use it.
- **Belt for day, weather and storms.** The shared automatic belt
  (Hachirin-no-Obi / Orpheus's Sash) is on by default and does this job. BLM
  has its own older rule, `sets.midcast.ElementalMatch`, worn when a storm, the
  day or the (real) weather matches the nuke's element; it **steps aside
  whenever the shared belt is enabled**. It only works if you turn the shared
  belt off (`enabled = false` in `ELEMENTAL_BELT.lua`) and leave
  `auto_hachirin = true` in `BLM_ELEMENTAL_CONFIG.lua` (also `check_storm`,
  `check_day`, `check_weather` to pick the conditions). With the shared belt,
  the Obi's opposing-element penalty and Orpheus's Sash are taken into
  account; the BLM rule ignores both.
- **Quanpur Necklace.** On the Stone line only, `sets.midcast.QuanpurStone`
  goes on over the nuke set, when you add that set.
- **Twilight Cloak for Impact.** The code puts Twilight Cloak on for the whole
  Impact cast; keep it in `sets.precast.FC.Impact` too (see Precast).
- **Tier step-down.** A nuke on recast or too expensive becomes the next lower
  tier you can cast (Fire VI → Fire V ...; Firaja → Firaga III, II, then
  Firaga). Also for Sleep, Sleepga, Bind, Bio, Poison, Drain, Aspir, Burn,
  Frost, Choke, Rasp, Shock, Drown. Breakga on recast becomes Break. The
  replacement uses its own sets (a Fire V cast looks for
  `sets.midcast['Fire V']`).
- **Dark Arts first (/SCH).** A nuke cast while Dark Arts (or Addendum: Black)
  is down and ready is held back: Dark Arts goes up, then the nuke is sent
  again on `<t>`.
- **Combat Mode.** `CombatMode` On puts on Bunzi's Rod, Ammurapi Shield and
  Sroda Tathlum (written in the code, not a set) and locks main, sub, range
  and ammo so no set can change them. Off unlocks them.
- **Death Mode.** `DeathMode` On only changes the idle set
  (`sets.idle.Death`); casting Death always uses `sets.midcast['Death']`.

## Sets in the provided file that nothing reads

- `sets.midcast.MndEnfeebles`: no spell reaches it (see Enfeebling Magic).
- `sets.midcast['Death'].MagicBurst` and `sets.midcast['Comet'].MagicBurst`:
  both lines write into the nuke set itself (Death and Comet are copies of
  it), and no code looks for a Magic Burst set under Death or Comet.

## Names the code reads that the provided file lacks

- `sets.midcast.QuanpurStone` (Stone line, see above).
- `sets.midcast['Enfeebling Magic']` (skill set for enfeebles).
- `sets.Hvergelmir`, `sets['Alber Strap']` (weapon sets; left out on purpose so
  the idle sets pick the staff).
- `sets.midcast.Klimaform`, `sets.midcast.Storm` (/SCH).
