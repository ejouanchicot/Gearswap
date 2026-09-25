# DRK — modes and keys

Dark Knight has two modes of its own: the defensive stance and the weapon. Everything
else (weaponskill gear, Dark Magic gear, Dark Seal / Nether Void pieces) is automatic.

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each mode's
current value; this page says what each value does. `#numpad0` (Auto Medicine) and
Alt+Numpad7-9 (alts) are common to every job, see [keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad9` | `HybridMode` | **PDT**, Accu | Engaged gear. `PDT` = `sets.engaged.PDT`; `Accu` = the plain `sets.engaged` (accuracy). With Liberator and Aftermath Lv.3 up, `sets.engaged.AM3` wins over both |
| `^numpad1` | `MainWeapon` | **Caladbolg**, Liberator, Redemption, Lycurgos, Loxotic | Weapon to wield (`sets.<Weapon>` in your set file). In the template the two-handers go with Utu Grip, Loxotic (club) with Blurred Shield +1 |

Apocalypse, Foenaria and Naegling are listed in `DRK_STATES.lua` but commented out:
remove the `--` in front of a line to add that weapon to the cycle.

## Other modes (no key)

| Mode | Values | Use |
|---|---|---|
| `FastCast` | 0 to 80 by 10, default **0** | Your Fast Cast %. Only used by the midcast watchdog to know how long a cast should take. Set it once in `DRK_STATES.lua` |

## Commands

DRK has no job command of its own: the keys above run `//gs c cyclestate <Mode>`, and every
[common command](../../guides/commands.md) works.

## Notes

- All modes go back to their default on every job change, subjob change and reload.
- Dark Seal and Nether Void: see [abilities.md](abilities.md).

## Files

In `<YourChar>/config/drk/`:

| File | Content |
|---|---|
| `DRK_STATES.lua` | Modes, their values and defaults |
| `DRK_KEYBINDS.lua` | The keys above |
| `DRK_CUSTOM.lua` | Your own modes, keys and gear rules, without code (empty by default) |
| `DRK_LOCKSTYLE.lua` | Lockstyle number per subjob (default 1) |
| `DRK_MACROBOOK.lua` | Macro book/page per subjob, and per dual-box alt job |
| `DRK_TP_CONFIG.lua` | TP-bonus pieces used for weaponskill gear |
