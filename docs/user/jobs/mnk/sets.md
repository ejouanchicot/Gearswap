# MNK — set names and automatic gear

Every set name the Monk code reads, and everything the job puts on by itself.
Modes and keys: [states.md](states.md). Names every job shares (subjob
actions, movement, Doom, Treasure Hunter...): [set names](../../guides/sets.md).

Your file: `<YourName>/mnk/sets/mnk_sets.lua`. The provided file has every set the
code reads, empty: fill in your pieces. With `//gs c trace on`, each engaged
set chosen is logged with the buff sets laid on top, and each weaponskill with
its Impetus / Footwork layers.

## Weapons

| Set | Worn when |
|---|---|
| `sets['<Weapon>']` | Main Weapon (`^numpad1`) is that value: one set per value you add in `MNK_STATES.lua`, named exactly like the value (`sets['Godhands'] = {main = "Godhands"}`) |

`Free` (default) has no set: you keep the weapon you wear. The weapon set goes
on top of the idle and engaged sets, in town too.

## Idle

| Set | Worn when |
|---|---|
| `sets.idle` | Standing, not fighting |
| `sets.idle.DT` | Hybrid Mode DT (`^numpad9`) |
| `sets.idle.Town` | In a city (Dynamis excluded), on top of the idle set; `sets.Adoulin` in the Adoulin cities (checked first, if you add it) |
| `sets.resting` | Resting (`/heal`) |

Then Mote's defense (F10 / F11) and Kiting (Alt+F10) sets, your weapon, and
`sets.MoveSpeed` while moving outside a city. No buff set goes on idle.

## Engaged

Built in this order, each step on top of the one before:

1. **Base**: `sets.engaged`, or `sets.engaged.Acc` with Offense Mode Acc
   (`^numpad3`). With Hybrid Mode DT or Counter, that set's `.DT` / `.Counter`
   (`sets.engaged.Acc.DT`), else `sets.engaged.DT` / `sets.engaged.Counter`.
2. **Buffs**, each while its buff is up: `sets.buff.Counterstance`,
   `sets.buff.Footwork`, `sets.buff.Impetus`, `sets.buff['Hundred Fists']`.
   A later one wins a slot both use (Hundred Fists over Impetus over
   Footwork over Counterstance).
3. Mote's defense and Kiting sets, then your weapon.

| Set | Worn when |
|---|---|
| `sets.engaged` | Fighting |
| `sets.engaged.Acc` | Offense Mode Acc |
| `sets.engaged.DT` | Hybrid Mode DT |
| `sets.engaged.Counter` | Hybrid Mode Counter |
| `sets.engaged.Acc.DT`, `sets.engaged.Acc.Counter` | Offense Mode Acc with that Hybrid Mode, if you add them |

## Buffs

| Set | Worn when |
|---|---|
| `sets.buff.Counterstance` | Counterstance up, on top of the engaged set (counter gear) |
| `sets.buff.Footwork` | Footwork up, on top of the engaged set, and on Dragon Kick / Tornado Kick |
| `sets.buff.Impetus` | Impetus up, on top of the engaged set and of every weaponskill (the Bhikku Cyclas body is the usual piece) |
| `sets.buff['Hundred Fists']` | Hundred Fists up, on top of the engaged set |
| `sets.buff.Impetus.DT` (or `.Counter`, and the same for the other three) | Worn **instead of** that buff set while you fight in that Hybrid Mode. Commented in the provided file |
| `sets.buff.Doom` | Doomed |

The buff sets go on or come off a moment after the buff comes or goes.

## Job abilities

| Set | Worn when |
|---|---|
| `sets.precast.JA['Hundred Fists']`, `['Boost']`, `['Dodge']`, `['Focus']`, `['Chakra']`, `['Chi Blast']`, `['Counterstance']`, `['Footwork']`, `['Mantra']`, `['Formless Strikes']`, `['Perfect Counter']`, `['Impetus']`, `['Inner Strength']` | That ability. Counterstance's counter-rate feet and Hundred Fists' duration legs count when the ability is used; Chakra heals from VIT and Chakra potency |
| `sets.precast.JA['<name>']` | Any other ability (subjob: Berserk, Hasso...), if you add it |
| `sets.precast.Waltz`, `sets.precast.Waltz['Healing Waltz']` | /DNC waltzes |

## Weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.WS` | Any weaponskill without its own set |
| `sets.precast.WS['Victory Smite']`, `['Shijin Spiral']`, `['Asuran Fists']`, `['Raging Fists']`, `['Howling Fist']`, `['Tornado Kick']`, `['Dragon Kick']`, `["Ascetic's Fury"]`, `['Final Heaven']` | That weaponskill |
| `sets.precast.WS.Acc`, `sets.precast.WS['Name'].Acc` | WS Mode Acc, or Offense Mode Acc |
| `sets.precast.WS['Victory Smite'].Impetus`, `["Ascetic's Fury"].Impetus` | That weaponskill with Impetus up, on top of it and of `sets.buff.Impetus`: **only the pieces that change**. Add one for any weaponskill |
| `sets.precast.WS['Dragon Kick'].Footwork`, `['Tornado Kick'].Footwork` | That kick with Footwork up, on top of it and of `sets.buff.Footwork`: only the pieces that change |

Moonshade Earring is added by itself when it reaches the next TP step, after
the Impetus / Footwork sets: [TP bonus](../../features/tp-bonus.md) (`MNK_TP_CONFIG.lua`).

## Spells (subjob)

| Set | Worn when |
|---|---|
| `sets.precast.FC`, `sets.precast.FC.Utsusemi` | Cast start (Fast Cast); Utsusemi |
| `sets.midcast.FastRecast` | First, under every spell's set |
| `sets.midcast.Utsusemi` | Utsusemi (/NIN) |
| `sets.midcast['Spell Name']`, `sets.midcast.Ninjutsu`... | Other subjob spells, as on every job ([set names](../../guides/sets.md)) |

## Movement and town

`sets.MoveSpeed` (moving, idle, outside a city), `sets.Kiting` (Alt+F10),
`sets.idle.Town`, `sets.Adoulin` (commented in the provided file).

## Names the code reads that the provided file lacks

- `sets.Adoulin`, `sets.CombatMode`, `sets.TreasureHunter`,
  `sets.buff.Impetus.DT`, `sets.engaged.Acc.DT` (all commented),
  `sets.defense.PDT` / `.MDT`.
- `sets.engaged.Acc.Counter`, `sets.idle.Counter` (Hybrid Mode Counter
  standing; without it, your normal idle).
- `.Impetus` / `.Footwork` layers for the other weaponskills.
