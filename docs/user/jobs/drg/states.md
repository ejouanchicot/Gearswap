# DRG — modes and keys

Dragoon: your weapon and grip, your engaged, weaponskill and damage-taken
modes.

Set names and automatic gear: [sets.md](sets.md).

Keys: Ctrl = `^`, Alt = `!`, Apps = `#` (the menu key), Shift = `~`, Win = `@`.
The HUD (`//gs c ui`) shows each mode's current value; this page says what each
value does. `#numpad0` (Auto Medicine) and Alt+Numpad7-9 (alts) are common to
every job, see [keybinds](../../guides/keybinds.md).

This page describes the provided template (`_master/config/drg/`). Every key and
command of the job, on one page: [README.md](README.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad1` | Main Weapon (`MainWeapon`) | **Free** | Main hand. Add your weapons in `DRG_STATES.lua`: each value is `sets.<Weapon>` from your set file (or the plain weapon, if `WEAPON_CONFIG.lua` has `equip_without_set = true`). `Free` keeps the weapon you wear. |
| `^numpad2` | Sub Weapon (`SubWeapon`) | **Free** | The grip, the same way (`sets['Utu Grip'] = {sub = "Utu Grip"}`). A weapon set can also carry its grip (`sets['Trishula'] = {main = "Trishula", sub = "Utu Grip"}`). |
| `^numpad3` | Offense Mode (`OffenseMode`) | **Normal**, Acc | Engaged gear: `sets.engaged.Acc` when your set file has it. |
| `^numpad4` | WS Mode (`WeaponskillMode`) | **Normal**, Acc | Weaponskill gear: `sets.precast.WS['<Name>'].Acc` for a weaponskill with its own set (add it: the provided file has none), `sets.precast.WS.Acc` for one without. With WS Mode Normal and Offense Mode Acc, the Acc sets are used too. |
| `^numpad9` | Hybrid Mode (`HybridMode`) | **Normal**, DT | DT: `sets.idle.DT`, `sets.idle.Pet.DT` while the wyvern is out, and the `.DT` engaged set (`sets.engaged.Acc.DT`, else `sets.engaged.DT`). |

Mote-Include's F-keys reach the same modes: F9 Offense Mode, Ctrl+F9 Hybrid Mode.

## Other modes (no key)

| Mode | Values | What it does |
|---|---|---|
| `FastCast` | 0 to 80 in steps of 10, default **0** | Your Fast Cast %, used only by the midcast watchdog when it cannot read the Fast Cast of your precast set. |

Change modes with Mote's `//gs c cycle <Mode>` or `//gs c set <Mode> <Value>`, or add
your own in `DRG_CUSTOM.lua`.

## Commands

`//gs c jump` uses the first ready jump of your list (`jumps` in
`DRG_TP_CONFIG.lua`). The common commands work as on every job:
[README.md](README.md#all-commands-on-this-job).

## Notes

- Every mode goes back to its default on each job change, subjob change or
  reload.
- Idle: `sets.idle.Town` / `sets.Adoulin` in a city (no wyvern set there),
  `sets.MoveSpeed` while moving outside a city.
- Weaponskill TP bonus: `DRG_TP_CONFIG.lua` (Moonshade Earring +250).

## Files

In `<YourChar>/config/drg/`: `DRG_STATES.lua` (modes and defaults),
`DRG_KEYBINDS.lua` (keys), `DRG_CUSTOM.lua` (your own modes and gear, see
[keybinds](../../guides/keybinds.md)), `DRG_TP_CONFIG.lua` (TP bonus, jump
order), `DRG_LOCKSTYLE.lua` (lockstyle 1), `DRG_MACROBOOK.lua` (book 1,
page 1). See [configuration](../../guides/configuration.md).
