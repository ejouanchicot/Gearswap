# SAM — set names and automatic gear

Every set name SAM reads in `<YourName>/sets/sam_sets.lua`, and everything the
job does by itself. Keys and modes: [states.md](states.md). Names every job
understands (Fast Cast, subjob actions, Doom, Treasure Hunter...):
[set names](../../guides/sets.md).

## Idle

The base is chosen first:

| Set | Worn when |
|---|---|
| `sets.idle.Normal` | Standing, not fighting (the provided file leaves `sets.idle` itself empty) |
| `sets.idle.Weak` | Weakened after a raise |

Then SAM adds, in this order:

| Set | Worn when |
|---|---|
| `sets.idle.PDT` | Hybrid Mode is PDT (the default) |
| `sets.idle.Weak` | Your HP is below 50 % (on top of everything above, PDT included) |
| `sets.idle.Regen` | Your HP is between 50 % and 79 % (on top of PDT too) |
| `sets.<Main Weapon>` | Always |
| `sets.MoveSpeed` | You are running (on top of everything above) |

In the provided file `sets.idle.Regen` and `sets.idle.Weak` are whole sets
(built on `sets.idle.Normal`), so below 80 % HP they replace your PDT pieces.
To keep your DT pieces at low HP, list only the pieces to change in `Regen` /
`Weak`.

In a town, Adoulin included, `sets.idle.Town` goes on top of the idle set,
then your weapon, and nothing else: no Weak, Regen or PDT, no `sets.MoveSpeed`.
In Western / Eastern Adoulin `sets.Adoulin` takes its place when it exists. The
provided file has neither set, so until you add one, a town gets the same idle
as outside, `sets.MoveSpeed` included.

## Engaged

The base is the first of these that exists:

| Set | Worn when |
|---|---|
| `sets.engaged.AM3` | Aftermath: Lv.3 is up and your Main Weapon mode is Masamune (or Kogarasumaru, if you add it). Replaces the other base sets below. Not in the provided file: write a whole set, an empty one would drop your PDT gear |
| `sets.engaged.<Offense>.<Hybrid>` | Both modes have a set, e.g. `sets.engaged.Acc.PDT` |
| `sets.engaged.<Hybrid>` | Hybrid Mode PDT or MDT when the Offense Mode set has no version for it: `sets.engaged.PDT`, `sets.engaged.MDT` |
| `sets.engaged.<Offense>` | Hybrid Mode Normal: `sets.engaged.Normal`, `.Mid`, `.Acc`, `.SuBlow` |
| `sets.engaged.Normal` | An Offense Mode with no set |

With the default Hybrid Mode (PDT), each Offense Mode wears its PDT version:
`sets.engaged.Acc.PDT`, `.Mid.PDT`, `.SuBlow.PDT` (the last two are copies of
`sets.engaged.PDT` in the provided file: give them their pieces, SuBlow's Subtle
Blow above all). Normal wears `sets.engaged.PDT`. A mode without its variant wears
the Hybrid Mode's set.

Then, on top, in this order (a later layer wins a slot):

| Set | Worn when |
|---|---|
| `sets.thirdeye` | Seigan is up and Hybrid Mode is PDT |
| `sets.seigan` | Seigan is up and Hybrid Mode is Normal or MDT (empty in the provided file) |
| `sets.<Main Weapon>` | Always |
| `sets.bow` | Yoichinoyumi is in your range slot (empty in the provided file) |

## Weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.WS` | Any weaponskill without its own set |
| `sets.precast.WS['<name>']` | That weaponskill. The provided file has Tachi: Fudo, Shoha, Mumei, Jinpu, Goten, Kagero, Koki, Rana, Ageha, Impulse Drive, Aeolian Edge |
| `sets.precast.WS['<name>'].Mid` / `.Acc` | WS Mode Mid / Acc (the provided file: Tachi: Shoha and Tachi: Rana). Missing: the weaponskill's own set |
| `sets.buff.Sekkanoki` | Added on the weaponskill while Sekkanoki is up |
| `sets.buff['Meikyo Shisui']` | Added on the weaponskill while Meikyo Shisui is up |

- With WS Mode **Normal** and Offense Mode **Mid** or **Acc**, the weaponskill
  takes the `.Mid` / `.Acc` version of the same name: the Offense Mode picks it
  for you. A WS Mode other than Normal always wins over it.
- The TP bonus pieces (Moonshade Earring, Mpaca's Cap; Hagakure and
  Dojikiri Yasutsuna counted) go on first, the Sekkanoki / Meikyo Shisui pieces
  after them: [TP bonus](../war/tp-bonus.md).

## Job abilities

`sets.precast.JA['<Name>']` for any ability. The provided file has Meditate,
Hasso, Seigan, Warding Circle, Third Eye and Blade Bash.

## Spells

| Set | Worn when |
|---|---|
| `sets.precast.FC`, `sets.precast.FC.Utsusemi` | Casting (/NIN, /WHM...) |
| `sets.midcast.Phalanx` | Phalanx (/RDM) |
| `sets.midcast['Healing Magic']`, `sets.midcast['Enhancing Magic']` | Read first for those skills; not in the provided file, so the spell or family name decides ([set names](../../guides/sets.md)) |

## Weapons

| Set | Worn when |
|---|---|
| `sets.Masamune`, `sets.Kusanagi`, `sets.Shining`, `sets.Dojikiri`, `sets.Soboro`, `sets.Norifusa` | The Main Weapon mode of that name, idle and engaged. Put the grip in the same set (`sub = 'Utu Grip'`): SAM has no Sub Weapon mode |

- A weapon value with no set is skipped: the weapon you hold stays.
- With `equip_without_set = true` in `<YourName>/config/WEAPON_CONFIG.lua`, a
  value that is the exact name of a weapon is equipped without any set (main
  hand only, no grip).

## What the job does by itself

- **Third Eye before a weaponskill.** When Third Eye is not up and is ready,
  your weaponskill is held back, Third Eye goes out (with
  `sets.precast.JA['Third Eye']`), then the weaponskill is sent again as soon
  as Third Eye is up, or refused. Only for a weaponskill that can go (in range,
  1000 TP): a refused one does not use Third Eye. This cannot be turned off.
- **The stance is remembered.** Any Hasso or Seigan you use (or
  `//gs c hasso` / `//gs c seigan`) becomes the chosen stance. Default: Hasso.
  - Hasso stance: Third Eye always goes out alone, Hasso is never replaced.
  - Seigan stance: when Seigan is down, your Third Eye is replaced by Seigan,
    then Third Eye 1 s later, every time.
- **Seigan gear.** While Seigan is up and you are engaged: `sets.thirdeye`
  (PDT) or `sets.seigan` (Normal, MDT).
- **Sekkanoki / Meikyo Shisui pieces** on the weaponskill while the buff is up.
- **Aftermath Lv.3** with Masamune: `sets.engaged.AM3` when you write it.
- **Yoichinoyumi** in the range slot adds `sets.bow` while engaged.
- **HP-based idle**: `sets.idle.Weak` below 50 % HP, `sets.idle.Regen` below 80 %,
  on top of `sets.idle.PDT`.
- **Your stance when you engage** (optional): `sam_hasso = true` in
  `<YourName>/config/AUTO_ABILITIES.lua`. On engaging with neither Hasso nor
  Seigan up, your chosen stance goes out (Hasso, or Seigan after
  `//gs c seigan`) once it is ready. Off by default.

## Sets in the provided file that nothing reads

- `sets.Malevolence`, `sets.Onion`, `sets.Utu`: no Main Weapon value has these
  names.
- `sets.buff.Sengikori`: nothing puts it on.
- `sets.defense.PDT`, `sets.defense.MDT`: only for GearSwap's own defense mode,
  which has no key or HUD row here; while engaged, SAM's engaged choice
  replaces it.

## Names the code reads that the provided file lacks

- `sets.engaged.AM3`.
- Any `sets.engaged.<Offense>.MDT` (MDT wears `sets.engaged.MDT` whatever the
  Offense Mode).
- `sets.idle.Town`, `sets.Adoulin`.
- `.Mid` / `.Acc` versions for the weaponskills other than Shoha and Rana.
- `sets.midcast['Healing Magic']`, `sets.midcast['Enhancing Magic']`.
- `sets.seigan` and `sets.bow` exist but are empty.
- `sets.TreasureHunter` ([set names](../../guides/sets.md)).
