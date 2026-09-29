# RUN — modes and keys

Rune Fencer: a tank with a stance mode, a weapon and grip choice, and a rune selector.
The template exists in `_master/`, but no maintained character plays RUN today, so it
is untested in game in its current form.

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each mode's
current value; this page says what each value does. Every key of the job, common keys
included, is on the [RUN page](README.md).

Set names and automatic gear: [sets.md](sets.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad9` | `HybridMode` | **PDT**, MDT | Stance. Engaged: `sets.engaged.PDT` or `sets.engaged.MDT`. Idle outside town: `sets.idle.PDT` or `sets.idle.MDT` laid over your idle set |
| `^numpad1` | `MainWeapon` | **Epeolatry**, Lycurgos | Weapon set to wield (`sets.Epeolatry`, `sets.Lycurgos`), idle and engaged, in town too |
| `^numpad2` | `SubWeapon` | Utu, **Refined** | Grip (`sets.Utu`, `sets.Refined`), worn with every weapon, Lycurgos included |
| `^numpad3` | `RuneMode` | **Ignis**, Gelus, Flabra, Tellus, Sulpor, Unda, Lux, Tenebrae | Rune used by `//gs c rune` |

None of these keys depends on the subjob. Loxotic, Lionheart and Aettir are written in
`RUN_STATES.lua` but commented out.

## Other modes (no key)

| Mode | Values | Use |
|---|---|---|
| `FastCast` | 0 to 80 by 10, default **30** | Your Fast Cast %, used only by the midcast watchdog (how long it waits for a lost aftercast) |
| `AutoMedicine` | **On**, Off | Common to every job, key Apps+Numpad0: Echo Drops / Remedy when a debuff blocks your action |

## Commands

| Command | What it does |
|---|---|
| `//gs c rune` | Uses the `RuneMode` rune on yourself; if it is on recast, prints the time left instead |
| `//gs c aoe` | /BLU: casts the first ready spell of the Blue Magic enmity rotation (`RUN_BLU_MAGIC.lua`) on `<stnpc>`; when none is ready, lists the recasts and opens `/target <stnpc>`. Without /BLU it says so and casts nothing |

Every [common command](../../guides/commands.md) works too.

## Notes

- Cures come from the subjob (/WHM /RDM: Cure to Cure IV, /PLD /SCH: Cure to
  Cure III). On yourself: `sets.precast.FC.CureSelf` (Fast Cast with little
  max HP) then `sets.midcast.CureSelf` (HP back on), so the cure lands on a
  bigger HP gap: more healed, more enmity. On someone else:
  `sets.midcast.CureOther`.
- Runes and job abilities without a named set swap nothing: `sets.precast.JA` is
  empty in the template on purpose, so a rune keeps your tank gear.
- Every mode except `AutoMedicine` goes back to its default on every job change,
  subjob change and reload.
- The HUD takes about 5 seconds to appear after RUN loads (it waits for a mode RUN
  does not have, then gives up and shows).
- To set RUN up for a character, pick it in the clone script (see
  [installation](../../getting-started/installation.md)), then fill in
  `<YourName>/sets/run_sets.lua`.

## Files

In `<YourName>/config/run/`:

| File | Content |
|---|---|
| `RUN_STATES.lua` | Modes, their values and defaults |
| `RUN_KEYBINDS.lua` | The keys above |
| `RUN_CUSTOM.lua` | Your own modes, keys and gear rules, without code (empty by default) |
| `RUN_HUD.lua` | Order of the HUD sections and rows on RUN |
| `RUN_BLU_MAGIC.lua` | Blue Magic enmity rotation for `//gs c aoe` |
| `RUN_LOCKSTYLE.lua` | Lockstyle number per subjob (3 in the template) |
| `RUN_MACROBOOK.lua` | Macro book/page per subjob, and per dual-box alt job |
| `RUN_TP_CONFIG.lua` | TP-bonus pieces used for weaponskill gear ([TP bonus](../war/tp-bonus.md)) |
