# COR — modes and keys

Corsair modes pick your weapons, the Quick Draw element and the two Phantom Rolls, which
the `shot`, `roll1` and `roll2` commands then use.

Start page for this job (every key, command and automatic feature): [README.md](README.md).
Set names and automatic gear: [sets.md](sets.md).

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each mode's
current value; this page says what each value does. `#numpad0` (Auto Medicine) and
Alt+Numpad7-9 (alts) are common to every job, see [keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| Ctrl+Numpad1 `^numpad1` | `MainWeapon` | **Naegling** | Main weapon, equipped as soon as you change it |
| Ctrl+Numpad2 `^numpad2` | `RangeWeapon` | **Anarchy**, Compensator | Gun, equipped as soon as you change it |
| Ctrl+Numpad3 `^numpad3` | `QuickDraw` | **Light**, Fire, Ice, Wind, Earth, Thunder, Water, Dark | Element fired by `//gs c shot` |
| Ctrl+Numpad9 `^numpad9` | `HybridMode` | **PDT**, Normal | PDT lays `sets.engaged.PDT` on your engaged set and `sets.idle.PDT` on your idle set outside town. Normal: neither |
| Ctrl+Numpad4 `^numpad4` | `MainRoll` | **Chaos Roll** and 19 others | Roll used by `//gs c roll1` |
| Ctrl+Numpad5 `^numpad5` | `SubRoll` | **Samurai Roll** and 19 others | Roll used by `//gs c roll2` |
| Ctrl+Numpad6 `^numpad6` | `LuzafRing` | **ON**, OFF | On a Phantom Roll or Double-Up: ON wears Luzaf's Ring (16 yalm range): `sets.precast.LuzafRing` if your sets define it, else Luzaf's Ring in the left ring. OFF wears `sets.precast.LuzafRingOff` if defined (Gurebu's Ring in the provided sets), else your roll set's ring stays (8 yalms) |

The 20 rolls: Chaos, Samurai, Hunter's, Tactician's, Allies', Wizard's, Warlock's,
Corsair's, Caster's, Courser's, Blitzer's, Fighter's, Rogue's, Gallant's, Evoker's,
Bolter's, Miser's, Companion's, Avenger's, Naturalist's.

## Other modes (no key)

| Mode | Values | Notes |
|---|---|---|
| `FastCast` | 0 to 80 by 10, default **0** | Your Fast Cast %, used by the midcast watchdog (`//gs c cycle FastCast`, or its default in `COR_STATES.lua`) |
| `RangedMode` (Mote) | Normal only | Picks `sets.midcast.RA.<value>` for ranged attacks once you give it more values in `COR_STATES.lua` (Mote's `Alt+F9` cycles it) |

## Commands

| Command | What it does |
|---|---|
| `//gs c shot` | `/ja "<QuickDraw> Shot" <t>` |
| `//gs c roll1` / `roll2` | `/ja "<MainRoll>" <me>` / `/ja "<SubRoll>" <me>` |
| `//gs c rolls` | Shows your active rolls |
| `//gs c doubleup` (`du`) | Shows whether Double-Up is still possible (45 s window after the last roll or Double-Up) |
| `//gs c clearrolls` | Forgets the tracked rolls |
| `//gs c party` / `clearparty` | Shows / empties the party jobs used for the roll job bonus |
| `//gs c rolldebug` | Roll check on / off. For each roll: every piece of the roll set that was NOT worn when the roll landed, gear updates held back during the roll, pieces not in the inventory / wardrobes, locked slots, status and movement, "Phantom Roll +" worn. Switching it off prints a summary. Also written to `<Char>/logs/rolls/rolldebug.log` |

`shot`, `roll1` and `roll2` send a normal `/ja`, so they go through the same checks as a
macro (debuffs, recast, roll gear, Luzaf ring).

A roll pressed while it is already up (key, macro or `roll1` / `roll2`) is turned into
a Double-Up when Double-Up Chance is up and that roll is the last one you rolled.
Otherwise it is cancelled with a message: no Double-Up chance, or Double-Up would go to
the other roll (the game always doubles the last roll).

## Notes

- Each roll you cast is tracked from the game's action data: the result line shows the
  bonus (gear, Crooked Cards and job bonus included), Lucky/Unlucky and the bust risk of
  the next Double-Up. The job bonus counts your party's main jobs and the dual-box
  partner's job.
- The roll set stays on until the roll lands: a gear update in between (running, the
  end of a fight) waits, so the "Phantom Roll +" piece is worn when the roll takes
  effect.
- A roll pressed while Phantom Roll is on recast can tell the party when it will be
  ready: in `_common/combat/RECAST_CONFIG.lua`,
  `RECAST_CONFIG.party_announce = { ['Phantom Roll'] = "{action} : roll ready in <recast=Phantom Roll>" }`
  (`{action}` = the roll tried; see [configuration](../../guides/configuration.md)).

## Roll messages

The roll result can be shown in three styles, each detail on or off and in
your order (saved in `UI_CONFIG.lua`, `//gs c ui help`):

| Command | Effect |
|---|---|
| `//gs c ui rollstyle full\|compact\|line` | Framed block, two lines, or one line |
| `//gs c ui rollorder bust party lucky 11` | Order of the details (those left out follow) |
| `//gs c ui rolllucky` / `rollparty` / `rollbust` / `roll11` `[on\|off]` | Each detail |
| `//gs c ui rollremote same\|full\|compact\|line\|off` | A roll your COR alt sends to this box |

`L4 U8` = lucky / unlucky numbers (green / red), `PT 3/4` = party members hit
out of the party, `Bust 12.5%` in the colour of its risk, `[CC]` = Crooked
Cards. The one-line style leaves the bust risk out. Every line follows the chat
width.

When your COR is the alt, each roll result and bust is also shown on the main,
tagged with the COR's name (for example `[Alt COR]`), as long as the main runs this
GearSwap.

## Files

`<Char>/cor/`: `COR_STATES.lua`, `COR_KEYBINDS.lua`, `COR_CUSTOM.lua` (your own
modes and keys, see [keybinds](../../guides/keybinds.md)), `COR_HUD.lua` (HUD order),
`COR_LOCKSTYLE.lua` (style 3), `COR_MACROBOOK.lua` (book 3 page 1), `COR_TP_CONFIG.lua`,
and `COR_REFILL.lua` (every line commented at first: the common refill list applies). What each file holds: [README.md](README.md#configuration-files-for-this-job).
