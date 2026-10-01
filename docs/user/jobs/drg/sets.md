# DRG — set names and automatic gear

Every set name the Dragoon code reads, and everything the job puts on by
itself. Modes and keys: [states.md](states.md). Names every job shares (subjob
actions, movement, Doom, Treasure Hunter...): [set names](../../guides/sets.md).

Your file: `<YourName>/drg/sets/drg_sets.lua`. The provided file has every set the
code reads, empty: fill in your pieces. With `//gs c trace on`, each idle and
engaged set chosen is logged.

## Weapons

| Set | Worn when |
|---|---|
| `sets['<Weapon>']` | Main Weapon (`^numpad1`) is that value: one set per value you add in `DRG_STATES.lua`, named exactly like the value (`sets['Trishula'] = {main = "Trishula", sub = "Utu Grip"}`) |
| `sets['<Grip>']` | Sub Weapon (`^numpad2`) is that value (`sets['Utu Grip'] = {sub = "Utu Grip"}`) |

`Free` (default) has no set: you keep what you wear. The weapon sets go on top
of the idle and engaged sets, in town too.

## Idle

Built in this order, each step on top of the one before:

1. `sets.idle`, or `sets.idle.DT` with Hybrid Mode DT.
2. In a city (Dynamis excluded): `sets.idle.Town`, `sets.Adoulin` in the
   Adoulin cities (checked first, if you add it). In a city the next step is
   skipped.
3. Outside a city, wyvern out: `sets.idle.Pet`, or `sets.idle.Pet.DT` with
   Hybrid Mode DT when you have it.
4. Mote's defense (F10 / F11) and Kiting (Alt+F10) sets, then your weapon and
   grip.
5. `sets.MoveSpeed` while moving, outside a city.

| Set | Worn when |
|---|---|
| `sets.idle` | Idle (under the wyvern set) |
| `sets.idle.DT` | Hybrid Mode DT (`^numpad9`) |
| `sets.idle.Town` | In a city, on top |
| `sets.idle.Pet` | Wyvern out, outside a city: on top of the idle set (wyvern regen, wyvern HP...) |
| `sets.idle.Pet.DT` | Same, Hybrid Mode DT |
| `sets.resting` | Resting (`/heal`) |

The wyvern set goes **on top** of your idle set: a slot it leaves empty keeps
your idle piece.

## Engaged

| Set | Worn when |
|---|---|
| `sets.engaged` | You fight |
| `sets.engaged.Acc` | Offense Mode Acc (`^numpad3`) |
| `sets.engaged.DT` | Hybrid Mode DT |

You can also add `sets.engaged.Acc.DT`: with Offense Mode Acc and Hybrid Mode
DT it is used when it exists, else `sets.engaged.DT`. Then, on top:
`sets.buff['Spirit Surge']`, Mote's defense and Kiting sets, your weapon and
grip.

## Buffs

| Set | Worn when |
|---|---|
| `sets.buff['Spirit Surge']` | Spirit Surge is up, on top of engaged |
| `sets.buff.Doom` | Doomed |

## Job abilities

| Set | Worn when |
|---|---|
| `sets.precast.JA['Jump']` | Jump |
| `sets.precast.JA['High Jump']`, `['Spirit Jump']`, `['Soul Jump']` | That jump. The provided file starts each one as a copy of `sets.precast.JA['Jump']` (fill Jump first) |
| `sets.precast.JA['Super Jump']` | Super Jump |
| `sets.precast.JA['Call Wyvern']`, `['Spirit Link']`, `['Spirit Surge']`, `['Angon']`, `['Ancient Circle']`, `['Deep Breathing']`, `['Dragon Breaker']`, `['Fly High']`, `['Spirit Bond']` | That ability (Spirit Surge: its duration gear goes here) |
| `sets.precast.JA['Restoring Breath']`, `['Smiting Breath']` | As you give the order to the wyvern |
| `sets.precast.Waltz`, `sets.precast.Waltz['Healing Waltz']` | /DNC waltzes |

No Steady Wing set: its barrier counts the wyvern HP gear worn a moment
**before** the order, so a swap at the order does nothing. Keep wyvern HP
pieces in `sets.idle.Pet` or your engaged sets.

Do not create `sets.precast.PetCommand`: Restoring Breath and Smiting Breath
would look for their set there instead of `sets.precast.JA`.

## Weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.WS` | Any weaponskill without its own set |
| `sets.precast.WS['Stardiver']`, `["Camlann's Torment"]`, `['Drakesbane']`, `['Impulse Drive']`, `['Geirskogul']`, `['Sonic Thrust']`, `['Savage Blade']` | That weaponskill |
| `sets.precast.WS.Acc` | WS Mode Acc (or Offense Mode Acc), weaponskill without its own set |
| `sets.precast.WS['<Name>'].Acc` | Same, for a weaponskill with its own set (add it) |

Moonshade Earring is added by itself when it reaches the next TP step:
[TP bonus](../../features/tp-bonus.md) (`DRG_TP_CONFIG.lua`).

## Spells (subjob) and the Healing Breath trigger

| Set | Worn when |
|---|---|
| `sets.precast.FC` | Cast start (Fast Cast) |
| `sets.midcast.FastRecast` | First, under every spell's set |
| `sets.midcast['Blue Magic']`, `sets.midcast.Utsusemi`... | Subjob spells, as on every job ([set names](../../guides/sets.md)); commented in the provided file |
| `sets.midcast.HealingBreathTrigger` | On top of any spell's set when the wyvern is out and your HP is under the line of your subjob (below) |

The wyvern cures you (Healing Breath) when you cast a spell and your HP at the
end of the cast is under a line set by your subjob. The Dragoon artifact head
raises that line:

| Subjob | Line | With the artifact head |
|---|---|---|
| WHM, BLM, RDM, SMN, BLU, SCH, GEO | 33.3% | 50% |
| PLD, DRK, BRD, NIN, RUN | 25% | 33.3% |
| any other | never | never |

The job puts `sets.midcast.HealingBreathTrigger` on under the "with the head"
line: put the artifact head in it.

## The wyvern's breaths

| Set | Worn when |
|---|---|
| `sets.midcast.HealingBreath` | The wyvern uses Healing Breath (I to IV) |
| `sets.midcast.ElementalBreath` | The wyvern uses Flame, Frost, Gust, Sand, Lightning or Hydro Breath |

"Enhances Breath" gear counts only if worn as the breath goes off. These sets
go on when GearSwap reports the breath; whether it does for the wyvern is
still to be checked in game. If GearSwap's `//gs showswaps` never shows them
when the wyvern breathes, keep your breath pieces in the engaged set instead.

## Movement and town

`sets.MoveSpeed` (moving, idle, outside a city), `sets.Kiting` (Alt+F10),
`sets.idle.Town`, `sets.Adoulin` (commented in the provided file).

## Names the code reads that the provided file lacks

- `sets.Adoulin`, `sets.TreasureHunter` (both commented), `sets.defense.PDT` /
  `.MDT`.
- `sets.engaged.Acc.DT` (commented), `sets.precast.WS['<Name>'].Acc`.
- `sets[<Weapon>]` for your weapons and grips.
