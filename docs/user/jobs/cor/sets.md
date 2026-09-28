# COR — set names and automatic gear

Every set name the Corsair code reads, and everything it does to your gear on its
own. Modes and keys: [states.md](states.md). Names every job shares (subjob actions,
`sets.MoveSpeed`, `sets.idle.Town`, `sets.buff.Doom`, Dual Wield tiers, Treasure
Hunter, the automatic Obi / Orpheus belt): [set names guide](../../guides/sets.md).

To see which set a ranged attack or a spell picked: `//gs c debugmidcast`, then act.

## Weapons

Your weapons come from two modes, not from the idle or engaged sets: the set named
after the mode's value is laid on top of idle and engaged.

| Set | Worn when |
|---|---|
| `sets['Naegling']` | `MainWeapon` is Naegling. With /NIN or /DNC the whole set goes on (main and sub: Naegling + Demersal Degen +1 in the provided file). With any other subjob **only its `main` piece** is used, the sub is ignored |
| `sets['Anarchy']` | `RangeWeapon` is Anarchy (gun: Anarchy +2) |
| `sets['Compensator']` | `RangeWeapon` is Compensator |

- A new value you add to `MainWeapon` or `RangeWeapon` in `COR_STATES.lua` needs a set
  of the same name: `sets['Fomalhaut'] = { range = "Fomalhaut" }`. Without it, nothing
  is equipped for that value. (For the main weapon only, `equip_without_set` in
  `config/WEAPON_CONFIG.lua` lets a plain weapon name work without a set; the gun
  always needs one.)
- Changing either mode re-equips at once.
- Put no weapon in your idle and engaged sets: the weapon sets are laid on top anyway.

## Idle

| Set | Worn when |
|---|---|
| `sets.idle.Normal` | Standing, not fighting (the base) |
| `sets.idle.PDT` | `HybridMode` is PDT (the default). Laid on top of `sets.idle.Normal` |
| `sets.idle.Refresh` | Your MP is under 50 % and your subjob gives MP (not with /NIN, /DNC, /WAR...). Laid on top of everything above, **PDT included** |
| `sets.idle.Town` | In a town other than Adoulin (not in the provided file). Replaces the idle set: no PDT, no Refresh, no `sets.MoveSpeed` there, only your weapons on top |
| `sets.Adoulin` | In Western / Eastern Adoulin. Replaces the idle set the same way |

Order outside town: `sets.idle.Normal` → weapons → `sets.idle.PDT` → `sets.idle.Refresh`
→ `sets.MoveSpeed` (while running).

In the provided file:

- `sets.idle.Refresh` is empty. Put only the Refresh pieces in it
  (`sets.idle.Refresh = { body = "..." }`): it goes on top of PDT, so every slot you list
  replaces your PDT piece while your MP is under 50 %.
- `sets.Adoulin` starts from `sets.idle.Normal` plus `sets.MoveSpeed` and Councilor's Garb:
  in Adoulin it replaces the whole idle set, so it must fill every slot.

## Engaged

| Set | Worn when |
|---|---|
| `sets.engaged.Normal` | Weapon out (the base) |
| `sets.engaged.PDT` | `HybridMode` is PDT. Laid on top of `sets.engaged.Normal` |

Order: `sets.engaged.Normal` → `sets.engaged.PDT` → weapons → Dual Wield tier (with
/NIN or /DNC, see the guide). No movement gear while engaged.

`sets.engaged.DW` is not a name COR reads: dual wield is only the weapons (above) plus
the shared Dual Wield tiers.

## Phantom Roll and Double-Up

| Set | Worn when |
|---|---|
| `sets.precast.CorsairRoll` | Any Phantom Roll |
| `sets.precast.CorsairRoll["Roll name"]` | That roll. The provided file has `["Caster's Roll"]`, `["Courser's Roll"]`, `["Blitzer's Roll"]`, `["Tactician's Roll"]`, `["Allies' Roll"]`, each built on the base roll set. Write it with `set_combine(sets.precast.CorsairRoll, {...})`, or it holds only its own pieces |
| (Double-Up) | Wears the set of the roll it doubles: `sets.precast.CorsairRoll["<last roll>"]`, else `sets.precast.CorsairRoll` |
| `sets.precast.LuzafRing` | `LuzafRing` is ON, on a roll or Double-Up (not in the provided file). Without it, ON puts **Luzaf's Ring in the left ring** |
| `sets.precast.LuzafRingOff` | `LuzafRing` is OFF, on a roll or Double-Up (Gurebu's Ring in the left ring in the provided file). Without it, OFF changes nothing: your roll set's ring stays |

- **The provided roll set holds weapons**: `main = Rostam` and `range = Compensator`.
  Every roll and Double-Up swaps your main weapon to Rostam and your gun to Compensator
  (Rostam raises the roll's potency, Compensator its duration), then your weapons from
  the modes come back after the roll. In the game, changing the main, sub or ranged
  weapon **resets your TP to 0**. Rolling in the middle of a fight therefore costs your
  TP. If you do not want that, remove `main` and `range` from `sets.precast.CorsairRoll`
  (and from the roll-specific sets if you add them there).
- A `sets.precast.JA['Double-Up']`, if you write one, goes on **on top of** the roll set
  for Double-Up. The provided file has none, which is what you want in most cases.
- The Luzaf ring is put on after everything else (after the roll set and after
  Double-Up), so the `LuzafRing` mode always decides the ring.
- `sets.precast.CorsairRoll["Allies' Roll"]` in the provided file adds Chasseur's Gants
  +3, which the base roll set already wears: it changes nothing.

## Quick Draw

| Set | Worn when |
|---|---|
| `sets.precast.CorsairShot` | Any Quick Draw (Fire Shot, Light Shot...) |
| `sets.precast.CorsairShot['Fire Shot']` | That shot only (not in the provided file; the file shows the idea in a comment) |

Quick Draw is instant: no midcast. The damaging shots (all but Light Shot and Dark Shot)
get the automatic Obi / Orpheus belt when it helps.

## Ranged attacks

| Set | Worn when |
|---|---|
| `sets.precast.RA` | You shoot (Snapshot, Rapid Shot) |
| `sets.precast.RA.Flurry1` / `sets.precast.RA.Flurry2` | You shoot while Flurry / Flurry II is on you (less Snapshot needed). Not in the provided file. Missing: `sets.precast.RA` stays |
| `sets.midcast.RA` | While the shot flies (ranged accuracy, attack, Store TP) |
| `sets.midcast.RA.TripleShot` | While Triple Shot is up: laid on top of the ranged midcast set. Not in the provided file |
| `sets.midcast.RA.Acc` (any `RangedMode` value) | Only if you give `RangedMode` values in `COR_STATES.lua`: COR has none by default and no key for it |

## Weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.WS` | Any weaponskill without its own set |
| `sets.precast.WS['Savage Blade']` | Savage Blade (the provided file's melee weaponskill) |
| `sets.precast.WS.Marksmanship` | Any gun weaponskill without its own set (Leaden Salute, Last Stand, Wildfire, Hot Shot...). Empty in the provided file, so it is `sets.precast.WS` until you fill it |
| `sets.precast.WS['Name']` | One weaponskill: `['Leaden Salute']`, `['Last Stand']`, `['Evisceration']`... Checked first: a named set wins over `.Marksmanship` and `sets.precast.WS` |

- Moonshade Earring (TP bonus +250) goes on by itself in the left ear when it lifts your
  TP to the next step (2000 or 3000); the list is in `config/cor/COR_TP_CONFIG.lua`. It
  never removes a Moonshade your weaponskill set already wears.
- Your gun's TP bonus (Anarchy +2, Fomalhaut) is **not** counted in that calculation
  today, so Moonshade may go on when the gun already reaches the step.
- Leaden Salute, Wildfire and Hot Shot get the automatic Obi / Orpheus belt when it
  helps.

## Job abilities

| Set | Worn when |
|---|---|
| `sets.precast.JA['Snake Eye']` | Snake Eye |
| `sets.precast.JA['Fold']` | Fold, **only when two Busts are up** (see below) |
| `sets.precast.JA['Wild Card']` | Wild Card |
| `sets.precast.JA['Random Deal']` | Random Deal |
| `sets.precast.JA['Name']` | Any other: `['Triple Shot']`, `['Crooked Cards']`, `['Cutting Cards']`... (not in the provided file) |

## Spells (from your subjob)

COR casts only its subjob's spells. Healing, Enhancing, Elemental and Enfeebling Magic
use the names of the [guide](../../guides/sets.md) (`sets.midcast.Cure`,
`sets.midcast['Enhancing Magic']`...); none is in the provided file, so today a spell's
midcast keeps whatever was on.

## What the job does by itself

- **Roll gear held until the roll lands.** From the moment you press a roll or
  Double-Up until the roll takes effect, every gear change is held back: running
  (movement gear), the end of a fight, `//gs c update`. The automatic Dual Wield pieces,
  the Treasure Hunter pieces worn in a fight and your own `COR_CUSTOM.lua` idle / engaged
  gear wait as well. The roll set stays on, so the
  "Phantom Roll +" piece (Regal Necklace, Rostam) is worn when it counts. The hold ends
  when the roll lands, at the latest after 5 seconds.
- **Engage / disengage during a roll waits.** If you draw or sheathe your weapon while a
  roll (or any action) goes out, the engaged or idle set goes on after the action, not
  over the roll gear (at the latest 3 seconds later).
- **Weapons swap for every roll** when your roll set holds weapons (the provided one
  does: Rostam and Compensator), and they come back after. This costs your TP (see
  Phantom Roll above).
- **Double-Up wears the gear of the roll it doubles.** After `//gs reload`, a subjob
  change or `//gs c clearrolls`, the last roll is forgotten: a Double-Up before your
  next roll then wears no roll set, only the Luzaf ring.
- **Pressing a roll that is already up becomes a Double-Up**, when Double-Up is possible
  and that roll is the last one rolled. Otherwise the roll is cancelled with a message
  saying why.
- **Luzaf's Ring by mode.** On every roll and Double-Up: ON wears `sets.precast.LuzafRing`
  (or Luzaf's Ring in the left ring), OFF wears `sets.precast.LuzafRingOff` if you have
  it. Your own gear rules in `COR_CUSTOM.lua` never change the rings of a roll.
- **Fold's gear only with two Busts.** Fold's set (Lanun Gants) lets one Fold remove
  both Busts; with one Bust or none, the slots of `sets.precast.JA['Fold']` keep what
  you wear.
- **Sub weapon only with /NIN or /DNC.** With another subjob only the main hand of the
  weapon set is equipped.
- **Refresh under 50 % MP** when idle outside town and your subjob gives MP
  (`sets.idle.Refresh`, see above).
- **Flurry noticed.** Flurry or Flurry II cast on you is recognised, and your shots use
  `sets.precast.RA.Flurry1` / `Flurry2` when you have them.
- **Triple Shot**: `sets.midcast.RA.TripleShot` on top of the ranged midcast set while
  it is up.
- **Moonshade by TP** on weaponskills (see Weaponskills).
- **Bullet pouches opened for you.** After a ranged attack, when 15 or fewer of the
  bullets you wear are left (inventory and wardrobes), their pouch in your inventory is
  used (Bronze Bullet -> `Brz. Bull. Pouch`, Eminent Bullet -> `Em. Bul. Pouch`...). No
  pouch in the inventory: a warning. Chrono, Living and Devastating Bullet pouches are
  waist equipment, not items you use from the inventory: they are not opened for you.
- **Gear rules of `COR_CUSTOM.lua`** leave ranged attacks alone (a rule never changes
  your gear during a shot).

## Sets in the provided file that nothing reads

None: every set in the provided file is used. (`sets.precast.CorsairRoll["Allies' Roll"]`
is read but equal to the base roll set, see above.)

## Names the code reads that the provided file lacks

| Set | What it would do |
|---|---|
| `sets.idle.Town` | Your town set (other than Adoulin) |
| `sets.precast.LuzafRing` | Where Luzaf's Ring goes when `LuzafRing` is ON (default: left ring) |
| `sets.precast.CorsairRoll["<other roll>"]` | Gear for any of the other rolls (Chaos, Samurai, Hunter's...) |
| `sets.precast.CorsairShot['<Element> Shot']` | One Quick Draw element |
| `sets.precast.RA.Flurry1`, `sets.precast.RA.Flurry2` | Shooting under Flurry / Flurry II |
| `sets.midcast.RA.TripleShot` | Ranged midcast under Triple Shot |
| `sets.precast.JA['Triple Shot']`, `['Crooked Cards']`, `['Cutting Cards']` | Those abilities |
| `sets.DW.NoHaste` ... `sets.DW.MaxHaste` | Dual Wield pieces with /NIN or /DNC (commented example at the end of the file) |
| `sets.midcast.Cure`, `sets.midcast['Enhancing Magic']`... | Subjob spells ([guide](../../guides/sets.md)) |
| `sets.precast.FC` | Fast Cast for subjob spells |
