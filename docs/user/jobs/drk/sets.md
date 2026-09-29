# DRK — set names and automatic gear

Every set name DRK reads in `<YourName>/sets/drk_sets.lua`, and everything the
job does by itself. Keys and modes: [states.md](states.md); Dark Seal and
Nether Void in detail: [abilities.md](abilities.md). Names every job
understands (Fast Cast, subjob actions, Doom, Treasure Hunter...):
[set names](../../guides/sets.md).

## Idle

| Set | Worn when |
|---|---|
| `sets.idle` | Standing, not fighting (the provided file also names it `sets.idle.Normal`) |
| `sets.idle.Town` | In a town, Adoulin included. It replaces the whole idle set: in the provided file it is the movement set (legs only), so the other slots keep what you wore before |
| `sets.idle.Weak` | Weakened after a raise (not in the provided file) |
| `sets.<Main Weapon>` | On top, always |
| `sets.MoveSpeed` | On top while running, **in town too** (most jobs skip it in town) |

`sets.Adoulin` is not read on DRK. The Hybrid Mode does not touch idle gear.

## Engaged

The base is the first of these that exists:

| Set | Worn when |
|---|---|
| `sets.engaged.AM3` | Aftermath: Lv.3 is up and your Main Weapon mode is Liberator, whatever the Hybrid Mode |
| `sets.engaged.PDT` | Hybrid Mode PDT (the default) |
| `sets.engaged.Accu` | Hybrid Mode Accu (in the provided file, a copy of `sets.engaged` to fill with accuracy) |
| `sets.engaged` | A mode whose set is missing |

Then, on top: `sets.<Main Weapon>`, then the Dark Seal / Nether Void pieces
below. Other engaged names (`sets.engaged.Normal`, an Offense Mode...) are not
read on DRK.

When Aftermath: Lv.3 starts or ends, the engaged set is rebuilt at once
(unless you are Doomed). If a spell or weaponskill is under way, it is rebuilt
when that action ends.

## Dark Seal and Nether Void

| Set | Worn when |
|---|---|
| `sets.precast.JA['Dark Seal']`, `sets.precast.JA['Nether Void']` | The moment you use the ability |
| `sets.buff['Dark Seal']` | Dark Magic midcast while Dark Seal is up, on top of the spell's set (only the head until 2026-09-29) |
| `sets.buff['Nether Void']` | Midcast of any spell whose name contains Absorb, Drain or Aspir while Nether Void is up (Absorb-TP included, Dread Spikes not), on top of the spell's set (only the legs until 2026-09-29) |
| `sets.engaged.<Weapon>.<PDT or Accu>.DarkSeal` | Engaged, Dark Seal up: added on top of the engaged set |
| `sets.engaged.<Weapon>.<PDT or Accu>.NetherVoid` | Engaged, Nether Void up |
| `sets.engaged.<Weapon>.<PDT or Accu>.DarkSealNetherVoid` | Engaged, both up. Missing: `.DarkSeal`, then `.NetherVoid` |

- `<Weapon>` is the Main Weapon mode: `sets.engaged.Caladbolg.PDT.DarkSeal`.
  With no `sets.engaged.Caladbolg.PDT`, the `.Accu` one is looked at.
- The engaged pieces go on as soon as you press the ability (the game is slow
  to report the buff) and come off if it was refused. Once the buff is used by
  your next dark spell or wears off, they are no longer added (from the next
  gear change: nothing re-equips the moment the buff goes).
- None of the engaged versions is in the provided file: until you write one,
  the engaged set does not change.

## Weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.WS` | Any weaponskill without its own set (the provided file: VIT gear) |
| `sets.precast.WS['<name>']` | That weaponskill. The provided file has Entropy, Origin, Resolution, Torcleaver, Quietus, Judgment, Savage Blade |
| `sets.precast.WS['<name>'].Acc` | WS Mode Acc, for that weaponskill |
| `sets.precast.WS.Acc` | WS Mode Acc, for a weaponskill without its own set. A named weaponskill without `.Acc` keeps its own set |

TP bonus (Moonshade Earring; Anguta counted when held):
[TP bonus](../war/tp-bonus.md).

## Job abilities

`sets.precast.JA['<Name>']` for any ability. The provided file has Blood Weapon,
Arcane Circle, Last Resort, Weapon Bash, Souleater, Dark Seal, Diabolic Eye,
Nether Void, and Jump / High Jump for /DRG (a copy of `sets.engaged`).

## Spells

| Set | Worn when |
|---|---|
| `sets.precast.FC` | Casting any spell |
| `sets.midcast['Dark Magic']` | Dark Magic without a more precise set |
| `sets.midcast['Dread Spikes']` | Dread Spikes |
| `sets.midcast.Absorb` | Every Absorb spell. `sets.midcast['Absorb-TP']` (or any exact Absorb name) wins over it |
| `sets.midcast.Drain`, `sets.midcast['Drain III']`, `sets.midcast.Aspir` | By name (Drain II uses `sets.midcast.Drain`) |
| `sets.midcast.Stun` | Stun, when you add it (else the Dark Magic set) |
| `sets.midcast['Enfeebling Magic']` | Enfeebling spells (Sleep, Bind, Poison...) |
| `sets.midcast['Elemental Magic']` | Elemental spells (Fire, Blizzard...); not in the provided file, so only a set named after the spell is used |

`sets.buff['Dark Seal']` and `sets.buff['Nether Void']` (whole sets) go on top
of these, see above. Absorb, Drain and Dread Spikes without their own set fall
back to `sets.midcast['Dark Magic']`.

## Weapons

| Set | Worn when |
|---|---|
| `sets.Caladbolg`, `sets.Liberator`, `sets.Redemption`, `sets.Lycurgos`, `sets.Loxotic` | The Main Weapon mode of that name, idle and engaged. Put the grip or shield in the same set: DRK has no Sub Weapon mode |

- A weapon value with no set is skipped: the weapon you hold stays. With
  `equip_without_set = true` in `WEAPON_CONFIG.lua`, that weapon is put in the
  main hand by name instead (keep a set for an augmented weapon or a grip).
- Apocalypse, Foenaria and Naegling are commented out in `DRK_STATES.lua`;
  their sets are in the provided file.

## What the job does by itself

- **Dark Seal head** on every Dark Magic spell while Dark Seal is up.
- **Nether Void legs** on Absorb, Drain and Aspir spells while Nether Void is up.
- **Dark Seal / Nether Void engaged versions**, from the press of the ability,
  when you write them.
- **Aftermath Lv.3 with Liberator** swaps the engaged base to
  `sets.engaged.AM3`, and the gear changes the moment Aftermath starts or ends.
  Remove `sets.engaged.AM3` to stop it.
- **Weapon** re-equipped on every idle and engaged set.
- **Movement gear** while running, in town as well.

DRK uses no ability by itself.

## Sets in the provided file that nothing reads

- `sets.idle.PDT`: the Hybrid Mode does not change idle gear.
- `sets.Apocalypse`, `sets.Foenaria`, `sets.Tokko`, `sets.Naegling`: no active
  Main Weapon value has these names (uncomment the line in `DRK_STATES.lua`;
  Tokko has no line, add `'Tokko'`).

## Names the code reads that the provided file lacks

- `sets.engaged.<Weapon>.<PDT or Accu>.DarkSeal` / `.NetherVoid` /
  `.DarkSealNetherVoid`.
- `sets.midcast['Elemental Magic']`, `sets.midcast.Stun`.
- `sets.idle.Weak`.
- `.Acc` versions of the named weaponskills.
- `sets.TreasureHunter` ([set names](../../guides/sets.md)).
