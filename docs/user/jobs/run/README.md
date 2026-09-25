# RUN — modes and keys

Rune Fencer: a tank with a stance mode, a weapon and grip choice, and a rune selector.
The template exists in `_master/`, but no maintained character plays RUN today (only a
frozen one-off clone does), so it is untested in game in its current form.

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each mode's
current value; this page says what each value does. `#numpad0` (Auto Medicine) and
Alt+Numpad7-9 (alts) are common to every job, see [keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad9` | `HybridMode` | **PDT**, MDT | Stance: `sets.engaged.PDT` or `sets.engaged.MDT` laid over your engaged set |
| `^numpad1` | `MainWeapon` | **Epeolatry**, Lycurgos | Weapon set to wield (`sets.Epeolatry`, `sets.Lycurgos`) |
| `^numpad2` | `SubWeapon` | Utu, **Refined** | Grip (`sets.Utu`, `sets.Refined`). Not applied with Lycurgos |
| `^numpad3` | `RuneMode` | **Ignis**, Gelus, Flabra, Tellus, Sulpor, Unda, Lux, Tenebrae | Rune used by `//gs c rune` |

Loxotic, Lionheart and Aettir are listed in `RUN_STATES.lua` but commented out.

## Other modes (no key)

| Mode | Values | Use |
|---|---|---|
| `FastCast` | 0 to 80 by 10, default **30** | Your Fast Cast %, used only by the midcast watchdog |

## Commands

| Command | What it does |
|---|---|
| `//gs c rune` | Uses the `RuneMode` rune on yourself unless it is on recast |
| `//gs c aoe` | /BLU: casts the first ready spell of the Blue Magic enmity rotation (`RUN_BLU_MAGIC.lua`); without /BLU it says so and casts nothing |

Every [common command](../../guides/commands.md) works too.

## Notes

- Cure III and Cure IV use `sets.midcast.CureSelf` when cast on yourself and
  `sets.midcast.CureOther` on someone else, if those sets exist.
- All modes go back to their default on every job change, subjob change and reload.
- To set RUN up for a character, pick it in the clone script (see
  [installation](../../getting-started/installation.md)), then fill in
  `<YourChar>/sets/run_sets.lua`.

## Files

In `<YourChar>/config/run/`:

| File | Content |
|---|---|
| `RUN_STATES.lua` | Modes, their values and defaults |
| `RUN_KEYBINDS.lua` | The keys above |
| `RUN_CUSTOM.lua` | Your own modes, keys and gear rules, without code (empty by default) |
| `RUN_BLU_MAGIC.lua` | Blue Magic enmity rotation for `//gs c aoe` |
| `RUN_LOCKSTYLE.lua` | Lockstyle number per subjob |
| `RUN_MACROBOOK.lua` | Macro book/page per subjob, and per dual-box alt job |
| `RUN_TP_CONFIG.lua` | TP-bonus pieces used for weaponskill gear |
