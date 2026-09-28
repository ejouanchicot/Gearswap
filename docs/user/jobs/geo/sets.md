# GEO — set names and automatic gear

Every set name the Geomancer code reads, and everything it does to your gear
on its own. Modes and keys: [states.md](states.md). Names every job shares
(Fast Cast by skill, subjob actions, `sets.MoveSpeed`, `sets.idle.Town`,
`sets.buff.Doom`, Treasure Hunter, the automatic Obi / Orpheus belt):
[set names guide](../../guides/sets.md).

To see which set a spell picked: `//gs c debugmidcast`, then cast.

GEO builds its idle and engaged gear itself, from whether a luopan is out. The
usual `sets.idle` / `sets.engaged` picked by the game's modes are not used as
such: only the names below count.

## Idle

| Set | Worn when |
|---|---|
| `sets.idle.PDT` | No luopan, `HybridMode` PDT (the default). Missing: `sets.me.idle` |
| `sets.idle.Normal` | No luopan, `HybridMode` Normal. Missing: `sets.me.idle` |
| `sets.me.idle` | No luopan, when the set of the current `HybridMode` does not exist. In the provided file `sets.idle.Normal` **is** this set, and `sets.idle.PDT` a copy of it (so PDT and Normal wear the same gear until you fill the PDT copy) |
| `sets.luopan.idle` | A luopan is out (pet damage taken, pet regen). `HybridMode` is not read then. Missing: `sets.me.idle` |
| `sets['Idris']` | Laid over idle and engaged, luopan or not (it is the `MainWeapon` value). Provided file: Idris and Dunna |
| `sets['Genmei Shield']` | Same, for the `SubWeapon` value. Provided file: Genmei Shield |

In a town (or Adoulin), `sets.idle.Town` / `sets.Adoulin` replace the idle set
entirely, the luopan set included. The weapon sets are still laid on top. In
the provided file `sets.idle.Town` is the same table as `sets.me.idle.Town`.

## Engaged

| Set | Worn when |
|---|---|
| `sets.engaged.PDT` | No luopan, `HybridMode` PDT. Missing: `sets.me.engaged` |
| `sets.engaged.Normal` | No luopan, `HybridMode` Normal. Missing: `sets.me.engaged` |
| `sets.me.engaged` | No luopan, when the set of the current mode does not exist (the provided `sets.engaged.Normal` is this set, `sets.engaged.PDT` a copy) |
| `sets.luopan.engaged.DT` | A luopan is out, `LuopanMode` DT (the default) |
| `sets.luopan.engaged.DPS` | A luopan is out, `LuopanMode` DPS. Missing: `sets.luopan.engaged.DT`, then `sets.me.engaged` |

Keep `sets.luopan.engaged = {}` in your file even if you remove the DT and DPS
sets: the code reads it directly. The weapon sets are laid on top. No movement
gear while engaged.

When the luopan appears or disappears, the gear is re-chosen at once.

## Precast (Fast Cast)

Shared rules (`sets.precast.FC['Spell name']`, then the skill, then
`sets.precast.FC`). The provided file has `sets.precast.FC` and
`sets.precast.FC.Cure`. Add `sets.precast.FC.Geomancy` for Indi- and Geo-
spells if you want a different Fast Cast set for them.

## Spells

### Geomancy (Indi- and Geo-)

| Set | Worn for |
|---|---|
| `sets.midcast['Indi-Haste']`, `sets.midcast['Geo-Frailty']`... | That one spell (exact name), when you add it |
| `sets.midcast.Geomancy` | Every Indi- and Geo- spell without its own set |
| `sets.midcast.Indi.Entrust` | An Indi- cast on a party member (not yourself) while Entrust is up, or right after you used Entrust. Replaces everything above for that cast |

In the provided file `sets.midcast.Geomancy` **is** `sets.luopan.idle` (the
same table): editing one edits the other. Give it its own content if your
Geomancy skill / Indi- duration gear differs from your luopan idle set.

The Entrust set in the provided file starts from the luopan idle set and puts
Gada in the main hand. With `CombatMode` On, main and sub are locked and Gada
does not go on.

### Healing, Enhancing, Enfeebling, Elemental, Dark

For each spell, the most precise name wins:

1. its exact name: `sets.midcast['Fire V']`, `sets.midcast['Refresh II']`
2. its name without the tier: `sets.midcast.Fire`, `sets.midcast.Aspir`, or
   the same under the skill: `sets.midcast['Elemental Magic'].Fire`
3. Enhancing only, the spell's family, at the root or under the skill:
   `sets.midcast.Refresh` (Refresh I-III), `.Regen`, `.Phalanx`, `.Stoneskin`,
   `.Aquaveil`, `.Storm`, `.Spikes`, `.BarElement`, `.BarAilment`, `.Boost`,
   `.Gain`, `.Enspell`
4. the spell's usual group: `sets.midcast.Cure`, `sets.midcast.Curaga`,
   `sets.midcast.Protect`, `sets.midcast.Shell`, `sets.midcast.Raise`...
5. the skill set: `sets.midcast['Healing Magic']`,
   `sets.midcast['Enhancing Magic']`, `sets.midcast['Enfeebling Magic']`,
   `sets.midcast['Elemental Magic']`, `sets.midcast['Dark Magic']`

When the skill set does not exist, only a set with the exact spell name or its
group (step 4) is used.

The provided file has:

| Set | Worn for |
|---|---|
| `sets.midcast['Elemental Magic']` | Nukes (Aspir is Dark Magic, see below) |
| `sets.midcast.Cure` | Cure, Cure II... |
| `sets.midcast.Curaga` | Curaga (a copy of the Cure set) |
| `sets.midcast['Enhancing Magic']` | Empty: your Fast Cast gear stays on through the cast |
| `sets.midcast['Enfeebling Magic']` | Empty: same |

No `sets.midcast['Dark Magic']`: Aspir and Drain keep your Fast Cast gear
unless you add it (or `sets.midcast.Aspir`).

## Weaponskills

`sets.precast.WS` for all, `sets.precast.WS['Name']` for one. The provided file
has `sets.precast.WS` and `sets.precast.WS['Exudation']`.

## Job abilities

The provided file has `sets.precast.JA['Bolster']`, `['Life Cycle']`,
`['Blaze of Glory']`, `['Dematerialization']`, `['Entrust']`,
`['Ecliptic Attrition']`, `['Radial Arcana']`. Any other by name under
`sets.precast.JA` (`['Full Circle']`, `['Mending Halation']`...).

## What the job does by itself

- **Luopan gear.** With a luopan out, idle is `sets.luopan.idle` and engaged
  `sets.luopan.engaged.DT` / `.DPS` (`LuopanMode`); without one, the
  `HybridMode` sets. Nothing to turn off: leave a set out to fall back as the
  tables above say.
- **Entrust set.** An Indi- aimed at someone else right after Entrust wears
  `sets.midcast.Indi.Entrust` instead of the Geomancy set.
- **Entrust first (option, off by default).** With `geo_entrust = true` in
  `<YourName>/config/AUTO_ABILITIES.lua`, an Indi- cast on a party member
  (not yourself) while Entrust is ready is held back: Entrust goes up, then
  the Indi- is cast again (and gets the Entrust set).
- **Full Circle first (option, off by default).** With
  `geo_full_circle = true` in the same file, a Geo- cast while a luopan is out
  and Full Circle is ready is held back: Full Circle removes the old luopan,
  then the Geo- is cast 2 s later.
- **Tier step-down.** A nuke (Fire V to Fire, Fira III to Fira, and the same
  for every element) or Aspir (Aspir III, II, Aspir) on recast or too
  expensive becomes the next lower tier you know. The replacement uses its own
  sets.
- **Combat Mode.** `CombatMode` On locks main, sub, range and ammo: no set,
  Entrust set included, can change them. Unlike BLM, GEO does not put any
  weapon on by itself when you turn it On. Off unlocks them.
- **Automatic belt.** The shared Obi / Orpheus belt goes on over your nukes;
  GEO has no belt rule of its own.

## Sets in the provided file that nothing reads

- `sets.midcast.Indi` (only its `.Entrust` part is read) and
  `sets.midcast.Geo`: an Indi- or Geo- spell never looks for these names.
  Put the gear in `sets.midcast.Geomancy` or name the spell exactly.
- `sets.idle.Pet`: GEO chooses `sets.luopan.idle` itself.
- `sets.me.idle.Town`: only through `sets.idle.Town`, which is the same set.

Also note: `sets.midcast.Indi` is the same table as `sets.luopan.idle`, so the
line that creates `sets.midcast.Indi.Entrust` stores the Entrust set inside
`sets.luopan.idle`. It changes no gear.

## Names the code reads that the provided file lacks

- `sets.midcast['Dark Magic']` (Aspir, Drain, Stun).
- `sets.midcast['Healing Magic']` (only needed for healing spells other than
  Cure / Curaga).
