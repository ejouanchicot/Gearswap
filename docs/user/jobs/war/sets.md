# WAR — set names and automatic gear

Every set name Warrior reads, and everything it puts on by itself. Modes and keys are on
[states.md](states.md); TP bonus pieces on [tp-bonus.md](../../features/tp-bonus.md); names shared by
every job (movement, town, Doom, Dual Wield, Treasure Hunter, subjob actions, how a name
is chosen) are on [the sets guide](../../guides/sets.md).

## Weapons

The weapon mode (`MainWeapon`, Ctrl+Numpad1) wears the set with the same name as the
value, over your idle and engaged gear (in town too):

| Set | Worn when |
|---|---|
| `sets.Ukonvasara` | `MainWeapon` Ukonvasara |
| `sets.Naegling` | `MainWeapon` Naegling |
| `sets.NaeglingKC` | `MainWeapon` NaeglingKC (the provided one is Naegling + Kraken Club) |
| `sets.LoxoticKC` | `MainWeapon` LoxoticKC (the provided one is Loxotic Mace +1 + Kraken Club) |
| `sets.Shining` | `MainWeapon` Shining |
| `sets.Chango` | `MainWeapon` Chango |
| `sets.Ikenga` | `MainWeapon` Ikenga |
| `sets.Loxotic` | `MainWeapon` Loxotic |

Give each weapon set both `main` and `sub`. A weapon you add to `MainWeapon` in
`WAR_STATES.lua` works the same way (also add its weaponskills to
`WAR_WS_CONFIG.lua`). If `_common/gear/WEAPON_CONFIG.lua` has `equip_without_set = true`, a
value that is an exact weapon name is put in the main hand without a set.

**The weapon you hold at load picks the mode.** After every load, reload or job change,
`MainWeapon` is set to the option whose set has the same `main` and `sub` as what you
are holding (same `main` only, if no sub matches); Naegling and NaeglingKC are told
apart by the off hand. Nothing matches: the mode stays on its first option
(Ukonvasara), and that weapon goes on at the next gear change. The weapon sets can
write `main` and `sub` either as plain item names (`main = 'Naegling'`) or as
`{name = ..., augments = ...}` tables, in any capitals, with the short or the long
item name.

## Idle

| Set | Worn when |
|---|---|
| `sets.idle.PDT` | `HybridMode` PDT. It **replaces** `sets.idle` (not laid over it) |
| `sets.idle` | `HybridMode` Normal (the provided file has no `sets.idle.Normal`), or any mode without its own idle set |
| `sets.idle.<Mode>` | Any other `HybridMode` value you add (for example `sets.idle.Hoxne`) |

Order: town set or mode set, then the weapon, then `sets.MoveSpeed` when running
outside town. In town: `sets.idle` with `sets.Adoulin` or `sets.idle.Town` on top, plus
the weapon, no `sets.MoveSpeed`.

## Engaged

The first line that matches wins, then the weapon set goes on top:

| Set | Worn when |
|---|---|
| `sets.engaged.NaeglingKC`, `sets.engaged.LoxoticKC` (`.<Weapon>KC`) | `MainWeapon` NaeglingKC / LoxoticKC, **or a Kraken Club in your off hand** under that weapon when its weapon set has no `sub` of its own, whatever the mode. Named after the weapon value, as `LaphriaAFM3` (`PDTKC` until 2026-10-03). The provided LoxoticKC starts as NaeglingKC's |
| `sets.engaged.SubtleBlow` / `sets.engaged.Hoxne` | `HybridMode` SubtleBlow / Hoxne, if you add those values (not in the provided states). Under Aftermath: Lv.3 with Ukonvasara, `sets.engaged.SubtleBlowAFM3` / `sets.engaged.HoxneAFM3` first |
| `sets.engaged.<Weapon>AFM3` (e.g. `sets.engaged.LaphriaAFM3`, `sets.engaged.UkonvasaraAFM3`) | Aftermath up (Lv.3, or the plain "Aftermath" of a Prime weapon) with that weapon, while `AftermathSet` is AFM3 (the default is FastTP). With `AftermathSet` FastTP, `sets.engaged.<Weapon>` stays on. The same rule serves SAM, DRK and THF (without their `AftermathSet` key) |
| `sets.engaged.<Weapon>` | A set named after the weapon mode (`sets.engaged.Naegling`, `sets.engaged.Ukonvasara`...). None in the provided file |
| `sets.engaged.PDT` / `sets.engaged.Normal` | `HybridMode` PDT / Normal |
| `sets.engaged` | None of the above exists |

Two consequences worth knowing:

- A weapon engaged set (`sets.engaged.Naegling`) wins over `HybridMode`: with it,
  PDT and Normal wear the same set for that weapon.
- A weapon's Aftermath set (`sets.engaged.UkonvasaraAFM3`, `.LaphriaAFM3`) goes on in PDT as in
  Normal, while `AftermathSet` is AFM3 (FastTP, the default, keeps your TP set). Gaining or
  losing the Aftermath re-equips your gear about 0.1 s later (not while Doomed;
  if a spell or weaponskill is under way, when it ends).

`sets.engaged.PDTTP` in the provided file is not read by name: `sets.engaged.PDT` is the
same set, and UkonvasaraAFM3 / NaeglingKC are built from it.

## Weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.WS` | Any weaponskill without its own set |
| `sets.precast.WS['Name']` | That weaponskill. Provided: Armor Break, Ukko's Fury, Upheaval, Fell Cleave, King's Justice, Impulse Drive, Stardiver, Savage Blade, Calamity, Judgment |

Weaponskills in your slots without a set of their own (Steel Cyclone, Decimation, Sonic
Thrust, Black Halo...) use `sets.precast.WS`. TP bonus pieces (Moonshade Earring, Boii
Cuisses +3) are added only when they reach the next TP step: see
[tp-bonus.md](../../features/tp-bonus.md).

## Job abilities

| Set | Worn when |
|---|---|
| `sets.precast.JA['Name']` | That ability. Provided: Provoke, Jump, High Jump (/DRG), Berserk, Defender, Warcry, Aggressor, Blood Rage, Tomahawk |
| `sets.precast.JA` | Any ability without its own set. **Empty in the provided file**: Retaliation, Restraint, Mighty Strikes... swap nothing |

In the provided file Jump and High Jump wear `sets.engaged.PDT`'s gear (same set as
PDTTP), Provoke wears `sets.FullEnmity`. `sets.FullEnmity` and `sets.LessEnmity` are
not read by name: they are the bases the ability sets are built from.

## Spells

WAR casts only its subjob's spells. The WAR code sends Healing Magic and Enhancing
Magic to the normal lookup, which needs `sets.midcast['Healing Magic']` and
`sets.midcast['Enhancing Magic']`; everything else (Utsusemi, /DRK Drain...) follows
the [sets guide](../../guides/sets.md). The provided file has **no Fast Cast and no
midcast set at all**: spells are cast in whatever you are wearing.

## What the job does by itself

- **Weapon from your hands**: at load, the weapon mode is set to the weapon you hold
  (see *Weapons*), and the five weaponskill slots follow it. Changing the weapon mode
  refills the slots.
- **Kraken Club in the off hand forces the weapon's KC set** (`sets.engaged.NaeglingKC`,
  `.LoxoticKC`), whatever `HybridMode`, also when the chosen weapon set does not name a `sub`
  (a club you put on by hand: `sets.engaged.<Weapon>KC`). Leaving NaeglingKC for a weapon that
  has its own sub drops it at once.
- **Aftermath: Lv.3 on Ukonvasara** switches to `sets.engaged.UkonvasaraAFM3` while `AftermathSet`
  is AFM3 (a stance's AFM3 set whatever it is) and back about 0.1 s after the buff comes or goes.
- **Hoxne stance** (only if you add `Hoxne` to `HybridMode` in `WAR_STATES.lua`): once
  Hoxne Ampulla is actually in your ammo slot, the **ammo slot is locked** so
  weaponskill and ability sets cannot swap it out. As on PLD, WAR puts the Ampulla on
  for you in idle (town included) and engaged: your Hoxne sets do not need to name it.
  If it is not worn within about 5 seconds (not in your bags, for example), the slot
  stays unlocked and a warning says what is worn instead. Leaving the stance, a job change, a
  reload or `//gs c wo` unlocks it (after `wo`, choose the stance again). `//po`
  (PorterPacker) frees every slot when it ends; while the stance is on, the Ampulla goes back on
  and is locked again the next time GearSwap changes your gear (an action, engaging, a mode
  change).
- **Auto Jump (/DRG, `JumpAuto` On)**: a weaponskill pressed under 1000 TP is held
  back, Jump / High Jump go out (in their `sets.precast.JA` sets), then the weaponskill
  is sent again.
- **Retaliation cancel**: with Retaliation up, moving for 5 seconds while not engaged
  cancels it (needs the Windower `Cancel` addon). No gear involved.
- **TP bonus**: Moonshade Earring and Boii Cuisses +3 only when they reach the next TP
  step; Chango, Warcry and Fencer are counted ([tp-bonus.md](../../features/tp-bonus.md)).
- `//gs c berserk`, `defender`, `thirdeye`, `tp` only send abilities; each one then
  wears its own `sets.precast.JA` set.

## Sets in the provided file that nothing reads

- `sets.Lycurgos`: no `MainWeapon` value uses it (add `Lycurgos` to the weapon list to
  use it).
- `sets['Blurred Shield +1']`, `sets['Telopanos Grip']`, `sets['Alber Strap']`,
  `sets['Aurgelmir Orb +1']`: no mode reads them.
- `sets.engaged.PDTTP`, `sets.FullEnmity`, `sets.LessEnmity`: building blocks other
  sets are made from.

## Names the code reads that the provided file lacks

- `sets.idle.Normal` (Normal idles in `sets.idle` without it)
- `sets.engaged.<Weapon>` for any weapon (optional, see *Engaged*)
- `sets.engaged.SubtleBlow`, `sets.engaged.Hoxne`, their `AFM3` versions and
  `sets.idle.Hoxne` (only if you add those stances)
- `sets.precast.FC`, `sets.midcast['Healing Magic']`,
  `sets.midcast['Enhancing Magic']` (subjob spells)
