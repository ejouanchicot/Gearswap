# NIN — set names and automatic gear

Every set name the Ninja code reads, and everything the job puts on or does by
itself. Modes and keys: [states.md](states.md). Names every job shares
(subjob actions, movement, Doom, Dual Wield tiers, Treasure Hunter, Obi and
Orpheus): [set names](../../guides/sets.md).

Your file: `<YourName>/sets/nin_sets.lua`. The provided file has every set the
code reads, empty: fill in your pieces. `//gs c debugmidcast` shows, for each
spell, which set was chosen and why.

## Weapons

| Set | Worn when |
|---|---|
| `sets['<Weapon>']` | Main Weapon (`^numpad1`) or Sub Weapon (`^numpad2`) is that value: one set per value you add in `NIN_STATES.lua`, named exactly like the value (`sets['Heishi Shorinken'] = {main = "Heishi Shorinken"}`, `sets['Kunimitsu'] = {sub = "Kunimitsu"}`) |

- The value `Free` (default) has no set: you keep the weapon you wear.
- With `equip_without_set = true` in `config/WEAPON_CONFIG.lua`, a value that is
  a real weapon name needs no set.
- The weapon sets go on top of the idle and engaged sets, in town too.
- Combat Mode (hidden, `//gs c combatmode show`) locks main, sub and range:
  the weapon pieces of every set are then ignored.

## Idle

| Set | Worn when |
|---|---|
| `sets.idle` | Idle, Hybrid Mode `Normal` |
| `sets.idle.DT` | Idle outside a city, Hybrid Mode `DT` (`^numpad9`) |
| `sets.idle.Town` | In a city (Dynamis excluded), on top of `sets.idle` |
| `sets.Adoulin` | In Western / Eastern Adoulin, when you define it; checked before `sets.idle.Town` |
| `sets.MoveSpeed` | Moving, outside a city, from 7:00 to 17:00 (Vana'diel time), and at night when you have no `sets.MoveSpeed.Night` |
| `sets.MoveSpeed.Night` | Moving, outside a city, from 17:00 to 7:00. It replaces `sets.MoveSpeed` (it does not go on top of it) |
| `sets.resting` | Resting (`/heal`) |

Dusk-to-dawn feet: the +1 upgrade and later give their speed from 17:00 to
7:00, the plain Ninja Kyahan only from 18:00 to 6:00. The set is chosen when
your gear is rebuilt (you start or stop moving, any action): crossing 17:00 or
7:00 while running keeps the previous set until then.

## Engaged

The engaged set is found by walking down, each level used only if it exists:

1. `sets.engaged`
2. the Offense Mode (`^numpad4`): `sets.engaged.Acc`
3. under Hybrid Mode `DT`: that level's `.DT` (`sets.engaged.Acc.DT`), else
   `sets.engaged.DT`

Then, on top, one layer per buff you have:

| Set | Worn when |
|---|---|
| `sets.buff.Yonin` | Yonin is up |
| `sets.buff.Innin` | Innin is up |
| `sets.buff.Sange` | Sange is up (every attack round throws a shuriken) |
| `sets.buff.Issekigan` | Issekigan is up |

Several up: put on in this order, the later wins a shared slot. The layer goes
on (or comes off) a moment after the buff changes. Then the weapons, then the
shared Dual Wield tier pieces (`sets.DW.*`, by your magic haste; Ninja has
Dual Wield V of its own, so it needs fewer pieces than a /NIN job).

Mote's F10 / F11 defense sets (`sets.defense.PDT`, `sets.defense.MDT`, Alt+F12
to stop) and `sets.Kiting` (Alt+F10) go on top of the idle and engaged set,
under the weapons.

## Precast

| Set | Worn when |
|---|---|
| `sets.precast.FC` | Any spell's cast start |
| `sets.precast.FC.Utsusemi` | Utsusemi's cast start |
| `sets.precast.FC['Spell Name']` | That spell (add it if you need it) |
| `sets.precast.RA` | A ranged attack (shuriken throw) starts |
| `sets.precast.JA['Mijin Gakure']`, `['Yonin']`, `['Innin']`, `['Futae']`, `['Sange']`, `['Issekigan']`, `['Mikage']` | That ability (Sange's enhancing gear counts when you use it) |
| `sets.precast.JA['Provoke']` | Provoke (/WAR) |
| `sets.precast.Waltz`, `sets.precast.Waltz['Healing Waltz']`, `sets.precast.Step` | /DNC waltzes and steps |

## Ninjutsu

At the start of every spell `sets.midcast.FastRecast` goes on first, under the
spell's set: a spell set that leaves slots empty keeps FastRecast pieces there.
Then, first found wins:

1. `sets.midcast['Spell Name']` (`sets.midcast['Katon: San']`), or its
   `.MagicBurst` child with Magic Burst On
2. by family:

| Set | Spells |
|---|---|
| `sets.midcast.Utsusemi` | Utsusemi: Ichi, Ni, San |
| `sets.midcast.Migawari` | Migawari: Ichi |
| `sets.midcast.Ninjutsu.Elemental.MagicBurst` | Katon, Suiton, Raiton, Doton, Huton, Hyoton, with Magic Burst On (`^numpad3`) |
| `sets.midcast.Ninjutsu.Elemental` | The same spells with Magic Burst Off, or On without a `.MagicBurst` set |
| `sets.midcast.Ninjutsu.Enfeebling` | Kurayami, Hojo, Dokumori, Jubaku, Aisha, Yurin |
| `sets.midcast.Ninjutsu.Enhancing` | Tonko, Monomi, Myoshu, Kakka, Gekka, Yain |

3. `sets.midcast.Ninjutsu` for a family without a set.

On top, for elemental ninjutsu only:

| Set | Worn when |
|---|---|
| `sets.buff.Futae` | Futae is up (it ends with that spell) |

Hachirin-no-Obi or Orpheus's Sash goes on by itself over elemental ninjutsu
when one of them adds enough (`//gs c belt`).

Do not name a set at the root of `sets.midcast` after a family other than
Utsusemi and Migawari (`sets.midcast.Elemental`): it would be found before
`sets.midcast.Ninjutsu.Elemental`.

## Ranged attack

| Set | Worn when |
|---|---|
| `sets.midcast.RA` | A shuriken throw goes off |

## Weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.WS` | Any weaponskill without its own set |
| `sets.precast.WS['Name']` | That weaponskill (the provided file: Blade: Hi, Shun, Metsu, Ku, Ten, Chi, Teki, To, Ei, Savage Blade, Aeolian Edge) |
| `sets.precast.WS.Acc`, `sets.precast.WS['Name'].Acc` | WS Mode `Acc` (`^numpad5`), or Offense Mode `Acc` while WS Mode is `Normal` |

Moonshade Earring is added by itself when it reaches the next TP step:
[TP bonus](../war/tp-bonus.md) (`NIN_TP_CONFIG.lua`). Blade: Chi, Teki, To,
Ei and Aeolian Edge also get the Obi / Orpheus belt by itself.

## What the job does by itself

- **Ninjutsu by family**, with the Magic Burst set for elemental ninjutsu
  under Magic Burst On.
- **Futae layer** on the elemental ninjutsu cast under Futae.
- **Yonin / Innin / Sange / Issekigan layers** on the engaged set while the
  buff is up. Leave a set empty to turn its layer off.
- **Night movement set** from 17:00 to 7:00.
- **Weapons**: Main / Sub Weapon sets on top of idle and engaged.

## Names the code reads that the provided file lacks

- `sets.Adoulin`, `sets.engaged.Acc.DT` (commented), `sets.precast.WS['Name'].Acc`
  (one commented example), `sets.midcast['Spell Name']`,
  `sets.defense.PDT` / `.MDT`.
- `sets.DW.*`, `sets.CombatMode`, `sets.TreasureHunter` (commented, see
  [set names](../../guides/sets.md)).
