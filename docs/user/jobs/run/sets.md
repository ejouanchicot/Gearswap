# RUN — set names and automatic gear

Every set name Rune Fencer reads, and everything it puts on by itself. Modes are on
[states.md](states.md), every key and command on the [RUN page](README.md); names
shared by every job (movement, town, Doom, Dual
Wield, Treasure Hunter, subjob actions, how a name is chosen) are on
[the sets guide](../../guides/sets.md).

RUN is simpler than PLD: no automatic abilities, no locked slots, no enmity swap. What
it does by itself is choosing the stance, weapon and grip sets, and the cure set by
target.

## Weapons and grips

| Set | Worn when |
|---|---|
| `sets.Epeolatry` | `MainWeapon` Epeolatry |
| `sets.Lycurgos` | `MainWeapon` Lycurgos |
| `sets.Utu` | `SubWeapon` Utu (grip), with every weapon, Lycurgos included |
| `sets.Refined` | `SubWeapon` Refined (grip), with every weapon, Lycurgos included |

The weapon and grip sets are laid over your idle and engaged sets every time they are
rebuilt, in town too. A weapon or grip you add to the lists in `RUN_STATES.lua` works
the same way: name its set after the value.

If `_common/gear/WEAPON_CONFIG.lua` has `equip_without_set = true`, a value that is an exact
item name is put on without a set. For `SubWeapon`, a set that also names a `main`
gives only its `sub`.

## Idle

| Set | Worn when |
|---|---|
| `sets.idle` | Standing, not fighting (the base) |
| `sets.idle.PDT` | Stance PDT: laid over `sets.idle` |
| `sets.idle.MDT` | Stance MDT: laid over `sets.idle` |

Order: `sets.idle`, stance set, weapon, grip, then `sets.MoveSpeed` when running.

**In town**, RUN wears `sets.idle` with `sets.idle.Town` on top (`sets.Adoulin` in Adoulin)
plus the weapon and grip, and nothing else: no stance set, no `sets.MoveSpeed`. In the
provided file `sets.idle.Town` is only the movement-speed legs, so the other slots keep
your `sets.idle` pieces.

## Engaged

| Set | Worn when |
|---|---|
| `sets.engaged` | Fighting (the base) |
| `sets.engaged.PDT` | Stance PDT |
| `sets.engaged.MDT` | Stance MDT |

Order: stance set (or `sets.engaged` when it is missing), weapon, grip.

## Weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.WS` | Any weaponskill without its own set |
| `sets.precast.WS['Name']` | That weaponskill. Provided: Resolution, Dimidiation, Herculean Slash, Spinning Slash, Ground Strike (all copies of `sets.precast.WS` for now), Armor Break |

Write a weaponskill set as `set_combine(sets.precast.WS, {...})`, never `{}`: an empty
set with the weaponskill's name is still "its own set", so it would hide
`sets.precast.WS` and change nothing.

TP bonus: a Moonshade Earring is added only when it reaches the next TP step, and a held
Lionheart counts +500 ([TP bonus gear](../../features/tp-bonus.md), `RUN_TP_CONFIG.lua`).

## Job abilities

| Set | Worn when |
|---|---|
| `sets.precast.JA['Name']` | That ability. Provided: Vallation, Valiance, Pflug, Swordplay, Swipe, Lunge, Embolden, Vivacious Pulse, Gambit, Battuta, Rayke, Liement, One for All, Elemental Sforzo, Odyllic Subterfuge |
| `sets.precast.JA` | Any ability without its own set. **Empty in the provided file**, on purpose: runes (Ignis, Gelus...) and any ability without a set keep your tank gear |
| `sets.precast.Rune` | All runes, if you want gear on them |
| `sets.precast.Ward` | Wards (Vallation, Valiance, Pflug, Battuta, Liement) |
| `sets.precast.Effusion` | Effusions (Swipe, Lunge, Gambit, Rayke) |

Careful: once `sets.precast.Ward` or `sets.precast.Effusion` exists, the abilities of
that family look for their named set **inside it** (`sets.precast.Ward['Vallation']`),
no longer under `sets.precast.JA`. The provided file has neither, so its named sets
under `sets.precast.JA` are used.

`sets.FullEnmity` is not read by name: it is the base the provided ability sets are
built on.

## Spells

### Fast Cast

`sets.precast.FC` and `sets.precast.FC['Name']` / `['Skill']` as on the
[sets guide](../../guides/sets.md). The provided file has only `sets.precast.FC` and:

| Set | Worn when |
|---|---|
| `sets.precast.FC.CureSelf` | Cure to Cure IV cast **on yourself** (subjob cures): put on over the Fast Cast set. Meant to be low on max HP: the midcast set puts the HP back, so the cure lands on a bigger HP gap (more healed, more enmity) |

### Cures (from the subjob)

| Set | Worn when |
|---|---|
| `sets.midcast.CureSelf` | Cure, Cure II, Cure III, Cure IV on yourself |
| `sets.midcast.CureOther` | Cure, Cure II, Cure III, Cure IV on someone else |
| `sets.midcast['Healing Magic']` | Curaga, -na spells, or a Cure whose CureSelf / CureOther is missing. `.Self` / `.Other` inside it are chosen by target |

`sets.Cure` in the provided file is only the base the three are built from.

### Enmity and enhancing

| Set | Worn when |
|---|---|
| `sets.midcast.Flash` | Flash |
| `sets.midcast.Phalanx` | Phalanx |
| `sets.midcast['Enhancing Magic']` | Any enhancing spell without a better set |
| `sets.midcast.Regen` | Regen, Regen II, III, IV (the tier is dropped) |
| `sets.midcast.Foil`, `sets.midcast.Crusade` | Those spells |

Other enhancing spells follow the normal lookup (spell name, name without tier,
family such as `sets.midcast.BarElement`, then the skill set).

### Divine and Blue Magic

| Set | Worn when |
|---|---|
| `sets.midcast['Divine Magic']` | Banish... from a /PLD subjob (not Flash). Not in the provided file: those spells keep their Fast Cast gear during the cast |
| `sets.midcast['Blue Magic']` | Every blue spell (/BLU). A spell's own set (`sets.midcast.Cocoon`) wins if you add one |

## What the job does by itself

- **Stance, weapon and grip** sets are rebuilt on every idle / engaged change (see the
  order above).
- **The grip goes on with every weapon**: Lycurgos (a Great Axe) takes your
  `SubWeapon` grip like Epeolatry.
- **Cures pick their set by target** (yourself or someone else), for Cure to Cure IV,
  in precast (`sets.precast.FC.CureSelf`) and midcast (CureSelf / CureOther).
- **Runes swap nothing** with the provided file: `sets.precast.JA` is empty, so your
  idle or engaged gear stays on.
- **TP bonus**: Moonshade Earring added to a weaponskill only when it reaches the next
  TP step ([TP bonus gear](../../features/tp-bonus.md)).
- `//gs c rune` and `//gs c aoe` only send the ability or spell; the gear is then chosen
  as for any other rune or blue spell.
- RUN has no automatic ability before a spell or weaponskill, no slot lock, no ward or
  rune tracking.

## Sets in the provided file that nothing reads

- `sets.midcast.Enmity`: read only for Enlight / Enlight II, which a Rune Fencer cannot
  cast.
- `sets.FullEnmity`, `sets.midcast.SIRDEnmity`, `sets.Cure`: building blocks other sets
  are made from.

## Names the code reads that the provided file lacks

- `sets.midcast['Divine Magic']` (Banish and other divine spells from /PLD)
- `sets.precast.Rune`, `sets.precast.Ward`, `sets.precast.Effusion` (optional, see
  *Job abilities*)
