# DRK — modes and keys

Start page for DRK (every key, command and automatic feature):
[README.md](README.md). Set names and automatic gear: [sets.md](sets.md).

Dark Knight has three modes of its own: the weapon, the weaponskill accuracy
and the engaged stance. Everything
else (weaponskill gear, Dark Magic gear, Dark Seal / Nether Void pieces) is automatic.

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each mode's
current value; this page says what each value does. `#numpad0` (Auto Medicine) and
Alt+Numpad7-9 (alts) are common to every job, see [keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad2` | `WeaponskillMode` | **Normal**, Acc | `sets.precast.WS['<name>'].Acc` when it exists, else `sets.precast.WS.Acc` for a weaponskill without its own set (a copy of the base WS set in the template) |
| `^numpad9` | `HybridMode` | **PDT**, Accu | Engaged gear. `PDT` = `sets.engaged.PDT`; `Accu` = `sets.engaged.Accu` (a copy of the plain engaged set in the template, until you add accuracy pieces). With Liberator and Aftermath Lv.3 up, `sets.engaged.AM3` wins over both |
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
- `HybridMode` changes engaged gear only; `sets.idle.PDT` in the template is
  never used.
- Idle: your weapon set, plus `sets.MoveSpeed` whenever you move (in town
  too). In town Mote starts from `sets.idle.Town`.
- A weapon needs its `sets.<Weapon>`: on DRK, `equip_without_set` in
  `config/WEAPON_CONFIG.lua` has no effect. The template also has
  `sets.Tokko` (Tokko Chopper), with no Main Weapon value to reach it: add
  `'Tokko'` to the list in `DRK_STATES.lua` to use it.

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
