# RNG — set names and automatic gear

Every set name the Ranger code reads, and everything the job puts on by
itself. Modes and keys: [states.md](states.md). Names every job shares (subjob
actions, movement, Doom, Treasure Hunter...): [set names](../../guides/sets.md).

Your file: `<YourName>/rng/sets/rng_sets.lua`. The provided file has every set the
code reads, empty: fill in your pieces. With `//gs c trace on`, each idle and
engaged set chosen is logged, and each buff set laid on a ranged attack.

## Weapons

| Set | Worn when |
|---|---|
| `sets['<Range weapon>']` | Range Weapon (`^numpad2`) is that value. Holds the weapon and its ammo: `sets['Fomalhaut'] = {range = "Fomalhaut", ammo = "Chrono Bullet"}` |
| `sets['<Weapon>']` | Main Weapon (`^numpad1`) or Sub Weapon (`^numpad4`) is that value: `sets['Naegling'] = {main = "Naegling"}` |
| `sets.SingleWield` | Instead of the off-hand weapon when you have no Dual Wield (not /NIN or /DNC): `{sub = "Nusku Shield"}` (commented in the provided file) |

`Free` (default) has no set: you keep what you wear. One set per value you add
in `RNG_STATES.lua`, named exactly like the value. The weapon sets go on top
of the idle and engaged sets, in town too.

## Ranged attack

A ranged attack (`/ra`) has two steps: the aim (precast) and the shot
(midcast).

**Aim**, the first found in this order:

1. `sets.precast.RA`, then its Ranged Mode version (`sets.precast.RA.Acc`, if
   you add it), then `.Flurry1` or `.Flurry2` under it while Flurry I or
   Flurry II is on you (the job knows which one from the spell that landed).
2. On top: `sets.buff['Velocity Shot']` while Velocity Shot is up.

**Shot**:

1. `sets.midcast.RA.Acc` under Ranged Mode Acc, else `sets.midcast.RA`.
2. On top, each while its buff is up, in this order (a later one wins a slot
   both name):

| Set | Worn on the shot while |
|---|---|
| `sets.buff['Velocity Shot']` | Velocity Shot is up (also on the aim). Its gear (e.g. the Velocity Shot body or back) must stay on to count |
| `sets.buff['Hover Shot']` | Hover Shot is up (no gear enhances it: for your own choice) |
| `sets.buff['Decoy Shot']` | Decoy Shot is up (no gear enhances it: for your own choice) |
| `sets.buff['Unlimited Shot']` | Unlimited Shot is up (the shot spends no ammo; its feet remove the distance penalty) |
| `sets.buff['Double Shot']` | Double Shot is up (Double Shot damage / rate gear only counts then) |
| `sets.buff.Barrage` | Barrage is up (Barrage gear: more shots, accuracy); Barrage ends with that shot |

After the shot, when 15 or fewer of the ammo you wear are left (inventory and
wardrobes), its quiver or pouch is used by itself. It must be in your
inventory, else a warning says so. The 15 is `quiver_open_at` in
`_common/inventory/REFILL_CONFIG.lua` (`false`: never).

## Idle

1. `sets.idle`, or `sets.idle.DT` with Hybrid Mode DT (outside a city).
2. In a city (Dynamis excluded): `sets.idle.Town` on top, `sets.Adoulin` in
   the Adoulin cities (checked first, if you add it).
3. Mote's defense (F10 / F11) and Kiting (Alt+F10) sets, then your weapons.
4. `sets.MoveSpeed` while moving, outside a city.

| Set | Worn when |
|---|---|
| `sets.idle` | Standing, not fighting |
| `sets.idle.DT` | Hybrid Mode DT (`^numpad9`) |
| `sets.idle.Town` | In a city, on top |
| `sets.resting` | Resting (`/heal`) |

## Engaged

| Set | Worn when |
|---|---|
| `sets.engaged` | Fighting |
| `sets.engaged.Acc` | Offense Mode Acc (`^numpad5`) |
| `sets.engaged.DT` | Hybrid Mode DT (also under Acc, when you have no `sets.engaged.Acc.DT`) |
| `sets.engaged.Acc.DT` | Offense Mode Acc and Hybrid Mode DT (not in the provided file) |

Then, on top: Mote's defense and Kiting sets, your weapons; with /NIN or
/DNC and two weapons, your Dual Wield tier (below).

## Weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.WS` | Any weaponskill without its own set |
| `sets.precast.WS['Last Stand']`, `['Wildfire']`, `['Trueflight']`, `['Coronach']` | That gun / crossbow weaponskill |
| `sets.precast.WS["Jishnu's Radiance"]`, `['Empyreal Arrow']`, `['Apex Arrow']` | That bow weaponskill |
| `sets.precast.WS['Savage Blade']`, `['Evisceration']` | That melee weaponskill |
| `sets.precast.WS['<Name>']` | Any other weaponskill, if you add it |
| `sets.precast.WS.Acc`, `sets.precast.WS['Name'].Acc` | WS Mode Acc; with WS Mode Normal, Ranged Mode Acc (bow, gun, crossbow) or Offense Mode Acc (melee) |

Moonshade Earring is added by itself when it reaches the next TP step:
[TP bonus](../../features/tp-bonus.md) (`RNG_TP_CONFIG.lua`). Hachirin-no-Obi or
Orpheus's Sash goes on by itself for Trueflight and Wildfire when you own
them (`//gs c belt`).

## Job abilities

| Set | Worn when |
|---|---|
| `sets.precast.JA['Eagle Eye Shot']` | Eagle Eye Shot (the ability is the shot: ranged damage gear) |
| `sets.precast.JA['Bounty Shot']`, `['Scavenge']`, `['Camouflage']`, `['Shadowbind']`, `['Sharpshot']` | That ability |
| `sets.precast.JA['<Name>']` | Any other ability, if you add it |
| `sets.precast.Waltz`, `sets.precast.Waltz['Healing Waltz']` | /DNC waltzes |

Barrage, Double Shot, Velocity Shot and the other shot buffs need their gear
on the shot, not when you use the ability: use the `sets.buff` sets above.

## Spells (subjob)

| Set | Worn when |
|---|---|
| `sets.precast.FC`, `sets.precast.FC.Utsusemi` | Cast start (Fast Cast); Utsusemi |
| `sets.midcast.FastRecast` | First, under every spell's set |
| `sets.midcast.Utsusemi` | Utsusemi (/NIN) |
| `sets.midcast['Spell Name']`, `sets.midcast.Cure`, `sets.midcast['Healing Magic']`... | Other subjob spells, as on every job ([set names](../../guides/sets.md)) |

## Dual Wield tiers

With /NIN or /DNC, engaged with two weapons: `sets.DW.NoHaste`, `.Haste`,
`.HasteII`, `.MaxHaste` on top of the engaged set by your magic haste
(commented in the provided file; `//gs c dw`).

## Buffs

| Set | Worn when |
|---|---|
| `sets.buff.Doom` | Doomed |

## Movement and town

`sets.MoveSpeed` (moving, idle, outside a city), `sets.Kiting` (Alt+F10),
`sets.idle.Town`, `sets.Adoulin` (commented in the provided file).

## Names the code reads that the provided file lacks

- `sets.Adoulin`, `sets.SingleWield`, `sets.DW.*`, `sets.TreasureHunter` (all
  commented), `sets.defense.PDT` / `.MDT`.
- `sets.precast.RA.Acc` (commented) and its `.Flurry1` / `.Flurry2`.
- `sets.engaged.Acc.DT`.
