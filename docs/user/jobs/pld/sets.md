# PLD — set names and automatic gear

Every set name Paladin reads, and everything it puts on by itself. Modes and keys are on
[states.md](states.md); names shared by every job (movement, town, Doom, Dual Wield,
Treasure Hunter, subjob actions, how a name is chosen) are on
[the sets guide](../../guides/sets.md).

## Weapons

The weapon mode (`MainWeapon`, Ctrl+Numpad1) wears the set with the same name as the
value, in idle and engaged:

| Set | Worn when |
|---|---|
| `sets.Excalibur` | `MainWeapon` Excalibur |
| `sets.Burtgang` | `MainWeapon` Burtgang, and always in the /SCH Tanking stance |
| `sets.KC` | `MainWeapon` KC |
| `sets.BurtgangKC` | `MainWeapon` BurtgangKC (the provided one is Burtgang + Kraken Club in the off hand) |
| `sets.Naegling` | `MainWeapon` Naegling |
| `sets.Shining` | `MainWeapon` Shining (a polearm: the off hand gets `sets.Alber`) |
| `sets.Malevo` | `MainWeapon` Malevo |
| `sets.Alber` | With Shining, in place of a shield (grip) |

A weapon you add to the list in `PLD_STATES.lua` works the same way: name its set after
the value. PLD always needs the set: `equip_without_set` in `WEAPON_CONFIG.lua` does not
apply to it.

**The shield** normally comes from the stance's set (`sub` in `sets.idle.PDT`,
`sets.engaged.MDT`...). Two exceptions decide it by the weapon and win over the set:

| Stance | Weapon | Shield put on |
|---|---|---|
| Sortie | Burtgang | Aegis |
| Sortie | Naegling | Blurred Shield +1 |
| DPS, Tanking, Hoxne (/SCH) | Excalibur or Naegling | Duban |
| DPS, Tanking, Hoxne (/SCH) | Burtgang | Aegis |

These shield names are written in the job's code, not in your set file: a `sub` in a
Sortie or /SCH set is ignored.

## Idle

| Set | Worn when |
|---|---|
| `sets.idle.PDT` | Stance PDT |
| `sets.idle.MDT` | Stance MDT, Sortie, and all three /SCH stances (DPS, Tanking, Hoxne) |
| `sets.idle` | Only if the stance's set above is missing |
| `sets.idleXp` | `Xp` On (/RDM, Ctrl+Numpad4): laid over the idle set |
| `sets.idleRegen` | `Regen` On (/SCH only, Ctrl+Numpad2): laid over the idle set |

Order in which idle is built: town set or stance set, then the weapon, then `sets.idleXp`,
then `sets.idleRegen`, then `sets.MoveSpeed` when running, then the Sortie / /SCH shield
and the Hoxne ammo.

**In town**, PLD wears `sets.idle` with `sets.idle.Town` on top (`sets.Adoulin` in Adoulin) plus your weapon and the
shield of your stance's idle set (Alber Strap with Shining; the Sortie / /SCH shield
and the Hoxne ammo still apply), and nothing else: no stance set, no `Xp`, no `Regen`,
no `sets.MoveSpeed`. In the provided file `sets.idle.Town` is only the movement-speed
legs, so the other slots keep your `sets.idle` pieces.

## Engaged

| Set | Worn when |
|---|---|
| `sets.engaged.PDT` | Stance PDT |
| `sets.engaged.MDT` | Stance MDT, and /SCH Tanking |
| `sets.engaged.TP` | Stance Sortie |
| `sets.engaged.DPS` | /SCH stance DPS |
| `sets.engaged.Hoxne` | /SCH stance Hoxne |
| `sets.engaged.BurtgangKC` | `MainWeapon` BurtgangKC, **or a Kraken Club in your off hand** when the chosen weapon set has no `sub` of its own, whatever the stance |
| `sets.engaged` | Only if the stance's set above is missing |
| `sets.meleeXp` | `Xp` On: laid over the engaged set |

Order: stance set (or BurtgangKC), then the weapon, then `sets.Alber` for Shining, then
`sets.meleeXp`, then the Sortie / /SCH shield and the Hoxne ammo.

## Weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.WS` | Any weaponskill without its own set |
| `sets.precast.WS['Name']` | That weaponskill. Provided: Savage Blade, Requiescat, Chant du Cygne, Atonement, Sanguine Blade, Aeolian Edge, Circle Blade |
| `sets.precast.WS.SCH['Name']` | Under /SCH only: that weaponskill's /SCH version, put on over the normal one |

The provided `sets.precast.WS['Atonement']` is `sets.FullEnmity` (Atonement's damage
comes from enmity). Knights of Round has no set in the provided file and uses
`sets.precast.WS`.

Moonshade Earring (and the Sequence sword's bonus) are handled by the TP bonus system,
not by a set: see [TP bonus gear](../war/tp-bonus.md).

## Job abilities

| Set | Worn when |
|---|---|
| `sets.precast.JA['Name']` | That ability. Provided: Divine Emblem, Palisade, Cover, Provoke, Majesty, Chivalry, Vallation, Valiance, Pflug, Fealty, Invincible, Holy Circle, Shield Bash, Sentinel, Rampart |
| `sets.precast.JA` | Any job ability without its own set, including subjob abilities (Berserk, runes, Waltzes... when their own family set is missing) |
| `sets.FullEnmity` | Not read by name for abilities: it is the base the provided ability sets are built on |
| `sets.EnmityMax` | Stance Sortie or /SCH Tanking: see below |

In the provided file `sets.precast.JA` is `sets.FullEnmity`, so every ability without a
set of its own wears full enmity gear.

**`sets.EnmityMax` (Sortie and /SCH Tanking only).** When it exists and the stance is
Sortie or Tanking, every job ability (not weaponskills) keeps its own set and also gets
the slots where `sets.EnmityMax` differs from `sets.FullEnmity`. The provided
`sets.EnmityMax` is `sets.FullEnmity` plus the Srivatsa shield, so in those stances every
ability swaps your shield to Srivatsa. Spells: see *Enmity spells* below.

## Spells

### Fast Cast

`sets.precast.FC` and `sets.precast.FC['Name']` / `['Skill']` as on the
[sets guide](../../guides/sets.md). The provided file points Healing Magic, Enhancing
Magic, Phalanx, Crusade, Cocoon, Flash, Banish, Banishga, Blank Gaze, Jettatura, Sheep
Song, Geist Wall, Cold Wave, Stinking Gas, Frightful Roar, Metallic Body and Foil to
`sets.precast.FC`.

| Set | Worn when |
|---|---|
| `sets.precast.FC.CureSelf` | Cure III or Cure IV cast **on yourself**: put on over the Fast Cast set (meant as a low-HP Fast Cast set, so the cure is not wasted on overheal) |

### Cures

| Set | Worn when |
|---|---|
| `sets.midcast.CureSelf` | Cure, Cure II, Cure III, Cure IV on yourself |
| `sets.midcast.CureOther` | Cure, Cure II, Cure III, Cure IV on someone else |
| `sets.midcast['Healing Magic']` | Any other healing spell (Curaga, -na from a subjob), or a Cure whose CureSelf / CureOther is missing. With `.Self` / `.Other` inside it, chosen by target |

These two replace `sets.midcast.Cure` on PLD: the PLD code does not read
`sets.midcast.Cure` for Cure to Cure IV while CureSelf / CureOther exist.
`sets.Cure` in the provided file is only the base both are built from.

### Enmity spells

| Set | Worn when |
|---|---|
| `sets.midcast.Flash` | Flash |
| `sets.midcast.Enlight` | Enlight and Enlight II |
| `sets.midcast.Enmity` | Enlight / Enlight II when `sets.midcast.Enlight` is missing |

In the provided file `sets.midcast.Flash`, `sets.midcast.Enmity` and
`sets.midcast.Jettatura` **are** `sets.FullEnmity` (the same set, not a copy). That
matters in Sortie and /SCH Tanking: every spell whose set is exactly `sets.FullEnmity`
is cast in `sets.EnmityMax` instead. Write `sets.midcast.X = sets.FullEnmity` to add a
spell to that list; a `set_combine(sets.FullEnmity, {...})` copy is left out.

### Phalanx

| Set | Worn when |
|---|---|
| `sets.midcast.Phalanx` | Phalanx (potency) |
| `sets.midcast.SIRDPhalanx` | Phalanx when `PhalanxSIRD` is On **or** `Xp` is On: replaces the potency set entirely |

### Other enhancing

Normal lookup (spell name, name without tier, family, then
`sets.midcast['Enhancing Magic']`). Provided: `sets.midcast.Stoneskin`, `Crusade`,
`Reprisal`, `Protect` (all tiers), `Shell` (all tiers), `Refresh`, `Haste`, `Foil`
(/RUN).

### Divine and Blue Magic

| Set | Worn when |
|---|---|
| `sets.midcast['Divine Magic']` | Banish, Holy... (not Flash or Enlight, handled above). A spell with its own set (`sets.midcast.Banishga`) uses that |
| `sets.midcast.Cocoon` | Cocoon (/BLU) |
| `sets.midcast['Blue Magic']` | Any other blue spell. Provided by name: Jettatura, Geist Wall, Sheep Song, Frightful Roar, Cold Wave, Stinking Gas, Blank Gaze |

A blue spell without a set of its own and without `sets.midcast['Blue Magic']` keeps its
Fast Cast gear during the cast (Sound Blast and Soporific in the provided file, both in
the `//gs c aoe` rotation).

## What the job does by itself

- **Majesty before Protect III-V and Cure III/IV.** When Majesty is ready and not up,
  the spell is cancelled, Majesty is used, and the spell is sent again once the buff is
  on. Tried once per spell; not under Amnesia. Cure and Cure II do not trigger it.
- **Divine Emblem before Flash**, the same way.
- **Kraken Club in the off hand forces `sets.engaged.BurtgangKC`**, even when the weapon
  mode is something else, as long as that weapon's set names no off hand (a club you
  put on by hand). Leaving the BurtgangKC weapon mode for a weapon whose set has its own
  shield puts that weapon, its shield and the normal engaged set on at once.
- **Shining One**: the stance's shield is removed from your idle and engaged sets and
  `sets.Alber` is worn in its place. BurtgangKC also keeps its off hand in idle.
- **Sortie stance**: the shield follows the weapon (Aegis with Burtgang, Blurred Shield
  +1 with Naegling); abilities add `sets.EnmityMax`'s shield; spells worn in
  `sets.FullEnmity` are cast in `sets.EnmityMax`. The weapon and rune lists shrink and
  `PhalanxSIRD` turns On ([states.md](states.md)).
- **/SCH stances**: Tanking always wields Burtgang (weapon mode ignored) with Aegis and
  gets the same `sets.EnmityMax` treatment as Sortie; DPS and Hoxne wield your weapon
  mode with Duban and do not use `sets.EnmityMax`.
- **Hoxne stance (/SCH)**: Hoxne Ampulla is put in the ammo slot of your idle and
  engaged sets, then the **ammo slot is locked** once the Ampulla is actually worn, so
  weaponskill, spell and ability sets cannot swap it out. If it is not worn within
  about 5 seconds, the slot stays unlocked and a warning says what is worn instead. Any
  other stance, a job change, a reload or `//gs c wo` unlocks it (after `wo`, choose the
  stance again). `//po` (PorterPacker) frees every slot when it ends; while the stance is on,
  the Ampulla goes back on and is locked again the next time GearSwap changes your gear (an
  action, engaging, a mode change).
- **Phalanx SIRD**: `PhalanxSIRD` On or `Xp` On casts Phalanx in
  `sets.midcast.SIRDPhalanx`. `PhalanxSIRD` turns On by itself when you enter Sortie or
  /SCH and Off when you go back to PDT/MDT. `//gs c sortie <target>` also sets it
  (Off for Aminon, On for the others).
- **Weaponskill slots follow the weapon actually in hand** (Burtgang in Tanking,
  whatever `MainWeapon` says).
- **TP bonus**: a Moonshade Earring is added to a weaponskill only when it reaches the
  next TP step; Sequence counts as +500 when held
  ([TP bonus gear](../war/tp-bonus.md)).
- **No automatic HP ordering on PLD**: the `priority` values you write in the set file
  are kept as they are (the provided Stoneskin set orders its pieces so max HP never
  dips during the swap).

## Sets in the provided file that nothing reads

- `sets.Duban`, `sets.Aegis`, `sets['Blurred Shield +1']`: shields come from the stance
  sets or from the code (table above). Use them in your own sets if you like.
- `sets.precast.WS.TPBonus` and every `sets.precast.WS['Name'].TPBonus`: TP bonus gear
  comes from `PLD_TP_CONFIG.lua`, not from these.
- `sets.idleNormal`, `sets.midcast.SIRDEnmity`, `sets.midcast.PhalanxPotency`,
  `sets.Cure`, `sets.FullEnmity`: building blocks that other sets are made from (and
  `sets.FullEnmity` is compared against for the Sortie / Tanking enmity swap).

## Names the code reads that the provided file lacks

- `sets.precast.FC.CureSelf` (Cure III/IV on yourself, Fast Cast)
- `sets.precast.WS.SCH['Name']` (/SCH weaponskill versions)
- `sets.idleRegen` (/SCH `Regen` mode: the mode does nothing without it)
- `sets.midcast['Healing Magic']`, `sets.midcast['Divine Magic']`,
  `sets.midcast['Blue Magic']` (Curaga and -na spells, Banish and Holy, blue spells
  without their own set)
