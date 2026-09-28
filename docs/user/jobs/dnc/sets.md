# DNC — set names and automatic gear

Every set name the Dancer code reads, and everything it does with your gear on its
own. Mode meanings and keys: [states.md](states.md). Names shared by every job
(Fast Cast, subjob actions, movement, Doom, Dual Wield tiers, Treasure Hunter,
Obi/Orpheus): [set names](../../guides/sets.md).

## Weapons

Your weapons are sets named after the value of the `MainWeapon` mode. The set is put
on top of your idle and engaged gear every time they are rebuilt, so the weapons
stay in your hands.

| Set | Worn when |
|---|---|
| `sets['Mpu Gandring']` | `MainWeapon` is Mpu Gandring (main + sub) |
| `sets['Twashtar']` | `MainWeapon` is Twashtar |
| `sets['Demersal']` | `MainWeapon` is Demersal |
| `sets['Blurred']` | `SubWeaponOverride` is Blurred: only its `sub` piece is used, it replaces the off-hand of the weapon set |

- Add a weapon: add its name to `MainWeapon` in `DNC_STATES.lua` and a set with that
  exact name, holding `main` and `sub`.
- Add an off-hand override: a value in `SubWeaponOverride` and a set of that name with
  a `sub` piece. A set without `sub` gives a warning and the off-hand is left alone.
- A value with no set of that name forces no weapon. If your
  `config/WEAPON_CONFIG.lua` has `equip_without_set = true`, a `MainWeapon` value that
  is an exact weapon name (for example `Twashtar`) is put in the main hand without a
  set. `SubWeaponOverride` always needs its set.
- Weapons are only forced on the idle and engaged gear. Weaponskill and ability sets
  should not name `main` or `sub`.

## Idle

| Set | Worn when |
|---|---|
| `sets.idle` | Standing, not fighting |
| `sets.idle.Town` | Idle in a town (see [set names](../../guides/sets.md)). It **replaces** `sets.idle`: slots it leaves out keep whatever you wore before |
| `sets.Adoulin` | Idle in Western / Eastern Adoulin, checked before `sets.idle.Town` |
| `sets.MoveSpeed` | Running, idle, outside town |

`HybridMode` does not change the idle set: PDT and Normal both wear `sets.idle`.

## Engaged

The engaged set follows the dance you have up and `HybridMode`. The first line that
matches wins:

| Set | Worn when |
|---|---|
| `sets.engaged.SaberDance.PDT` | Saber Dance up, `HybridMode` PDT |
| `sets.engaged.SaberDance` | Saber Dance up (Normal, or PDT without the set above) |
| `sets.engaged.FanDance` | Fan Dance up, `HybridMode` PDT |
| `sets.engaged.PDT` | `HybridMode` PDT, no dance up (or Fan Dance up without `sets.engaged.FanDance`) |
| `sets.engaged.Normal` | `HybridMode` Normal (Fan Dance changes nothing in Normal) |
| `sets.engaged` | None of the above exists |

Then the weapon set, then the Dual Wield tier pieces (common, they also go on during
Saber Dance), then Treasure Hunter.

## Weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.WS` | Any weaponskill without its own set |
| `sets.precast.WS['Name']` | That weaponskill |
| `sets.precast.WS['Name'].SaberDance` | That weaponskill with Saber Dance up |
| `sets.precast.WS['Name'].FanDance` | That weaponskill with Fan Dance up |
| `sets.precast.WS['Name'].Clim` | That weaponskill with Climactic Flourish in effect |
| `sets.precast.WS['Name'].SaberDance.Clim` | Saber Dance + Climactic Flourish |
| `sets.precast.WS['Name'].FanDance.Clim` | Fan Dance + Climactic Flourish |

These variants work for **any** weaponskill that has its own `sets.precast.WS['Name']`
(not for the plain `sets.precast.WS`). With a dance and Climactic both in effect, the
code takes the combined set, else the dance set, else `.Clim`. A variant you leave out
simply keeps the weaponskill's own set.

"Climactic in effect" means the buff is up, or you used Climactic Flourish less than
5 seconds ago (a macro firing both back to back reaches the weaponskill before the
buff shows). That 5-second window is used by one weaponskill only.

The provided file has all six for Ruthless Stroke, Dancing Edge, Rudra's Storm and
Shark Bite, and a plain set for Pyrrhic Kleos, Evisceration, Exenterator and Aeolian
Edge.

**Moonshade Earring**: after the weaponskill set, the code puts Moonshade Earring in
the left ear only when its +250 TP lifts you to the next step (2000 or 3000 TP). The
TP Bonus of the weapons you hold is counted first (Aeneas +500, Centovente +1000, in
either hand). Piece, slot and weapons are in `DNC_TP_CONFIG.lua`. Leave Moonshade out
of your weaponskill sets: the code adds it when it helps.

## Dancer abilities

| Set | Worn when |
|---|---|
| `sets.precast.Step` | Any step (Box Step, Quickstep, Feather Step, Stutter Step) |
| `sets.precast.Step['Name']` | That step: `sets.precast.Step['Box Step']`, `['Quickstep']` (one word), `['Feather Step']` |
| `sets.precast.Flourish1['Name']` | Violent, Animated, Desperate Flourish |
| `sets.precast.Flourish2['Name']` | Reverse, Building, Wild Flourish |
| `sets.precast.Flourish3['Name']` | Climactic, Striking, Ternary Flourish (see below) |
| `sets.precast.Waltz` | Any waltz (Curing Waltz, Divine Waltz, Healing Waltz) |
| `sets.precast.Waltz['Name']` | That waltz: `sets.precast.Waltz['Healing Waltz']`, `['Curing Waltz III']` |
| `sets.precast.Samba` | Any samba |
| `sets.precast.Jig` | Spectral Jig, Chocobo Jig |
| `sets.precast.JA['Name']` | Other job abilities: `['Trance']`, `['No Foot Rise']`, `['Saber Dance']`, `['Fan Dance']`, `['Presto']`, `['Contradance']`, `['Grand Pas']` |

Each family (`Step`, `Flourish1`, `Flourish2`, `Flourish3`, `Waltz`, `Samba`, `Jig`)
that does not exist in your file falls back to `sets.precast.JA['Name']`. The provided
file has no `sets.precast.Flourish3`, so Climactic Flourish uses
`sets.precast.JA['Climactic Flourish']`, which it does not have either: add one of the
two for Climactic gear. If you create `sets.precast.Flourish3`, the `JA` names are no
longer read for those three flourishes.

/DRG and /WAR: `sets.precast.JA.Jump`, `sets.precast.JA['High Jump']` (also used by
the automatic jump below), `sets.precast.JA['Provoke']`.

## Spells

Fast Cast and subjob spells use the common names ([set names](../../guides/sets.md)).
The provided file has `sets.precast.FC`, `sets.precast.FC.Utsusemi` (the same set) and
`sets.midcast.Utsusemi` (Fast Cast again). `sets.midcast.FastRecast` is empty: nothing
is worn on spells without a set of their own.

## What the job does by itself

- **Engaged gear follows your dance at once.** When Saber Dance or Fan Dance starts or
  ends while you are fighting, the engaged set is rebuilt right away (not at your next
  action). Skipped during an action: the gear comes back after it.
- **Climactic Flourish before a weaponskill** (`ClimacticAuto` On, the default). When
  you use Rudra's Storm, Ruthless Stroke or Shark Bite with at least 1000 TP (read
  live), the target above 25% HP and 3 or more Finishing Moves, the weaponskill is
  held, Climactic Flourish is used, and the weaponskill is sent again on `<t>` once the
  flourish lands. Tried once per weaponskill; if the flourish is refused the
  weaponskill still goes. The list, the minimum TP (can only be raised above 1000) and
  the target HP are in `DNC_WS_CONFIG.lua`. A weaponskill out of range is refused
  without using the flourish. Off: Ctrl+Numpad6.
- **Jump before a weaponskill** (/DRG only, `JumpAuto` On). Under 1000 TP with Jump or
  High Jump ready, the weaponskill is held, the jump (then High Jump if still short) is
  used on `<t>`, and the weaponskill follows. A weaponskill out of range is refused
  without using a jump. Off: Ctrl+Numpad7.
- **Weaponskill variant by buff**: see Weaponskills. Always on; leave the variant sets
  out to disable.
- **Moonshade Earring** added only when it reaches the next TP step (Weaponskills).
- **Samba cancelled when you lack the TP**: a samba is stopped with a message when your
  TP is below its cost (Drain Samba 100, II 250, III 400, Aspir Samba 100, II 250,
  Haste Samba 350). Never under Trance.
- **Waltzes are never changed or blocked**: a waltz you type or macro goes out as is,
  even on a target at full HP (to wake someone up). Tier choice only happens with
  `//gs c waltz` / `aoewaltz`, which also cancel Saber Dance first.
- **Dances are not cancelled for you**: the game refuses a waltz under Saber Dance and a
  samba under Fan Dance. Only `//gs c waltz` / `aoewaltz` cancel Saber Dance; Trance,
  a hand-typed waltz or a samba do not.
- **Kept buff cancels**: Spectral Jig and a Sneak on yourself cancel your Sneak first;
  Stoneskin cancels your old Stoneskin 1 second after the cast starts. (Monomi no
  longer cancels Sneak on DNC.)
- **`//gs c step`**: uses Presto first when it is ready and you are level 77+, then the
  step; alternates `MainStep` / `AltStep` when `UseAltStep` is On. Gear: the Step and
  `JA['Presto']` sets.
- **`//gs c smartbuff`**: the dance, the samba (skipped with Fan Dance selected or TP
  short), then /WAR Berserk, Aggressor, Warcry; /NIN Utsusemi: Ni (or Ichi); /SAM Hasso,
  2 seconds apart. Each one wears its own set above.

## Sets in the provided file that nothing reads

| Set | Why |
|---|---|
| `sets.idle.PDT` | No idle mode picks it; `HybridMode` does not change idle |
| `sets.buff['Saber Dance']` | Not read. Put Saber Dance pieces in `sets.engaged.SaberDance` or in `sets.precast.Waltz` |
| `sets.buff['Climactic Flourish']` | Not read. Put Climactic pieces in the `.Clim` weaponskill sets |

## Names the code reads that the provided file lacks

| Set | What it would do |
|---|---|
| `sets.precast.JA['Climactic Flourish']` (or `sets.precast.Flourish3['Climactic Flourish']`) | Gear when using Climactic Flourish |
| `sets.precast.JA['Saber Dance']`, `['Presto']`, `['Contradance']`, `['Grand Pas']` | Gear for those abilities |
| `sets.precast.Flourish2['Building Flourish']`, `['Wild Flourish']` | Gear for those flourishes |
| `sets.precast.WS['Name'].SaberDance` / `.FanDance` / `.Clim`... for Pyrrhic Kleos, Evisceration, Exenterator, Aeolian Edge | Buff variants for those weaponskills |
| `sets.midcast['Ninjutsu']`, `['Healing Magic']`, `['Enhancing Magic']` | Subjob spell gear (common names) |
| `sets.DW.NoHaste` ... `sets.DW.MaxHaste` | Dual Wield pieces by haste (commented out at the end of the file) |
