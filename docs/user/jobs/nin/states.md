# NIN — modes and keys

Ninja: your two weapons, your engaged, weaponskill and damage-taken modes, and
the Magic Burst mode of your elemental ninjutsu.

Set names and automatic gear: [sets.md](sets.md).

Keys: Ctrl = `^`, Alt = `!`, Apps = `#` (the menu key), Shift = `~`, Win = `@`.
The HUD (`//gs c ui`) shows each mode's current value; this page says what each
value does. `#numpad0` (Auto Medicine) and Alt+Numpad7-9 (alts) are common to
every job, see [keybinds](../../guides/keybinds.md).

This page describes the provided template (`_master/config/nin/`). Every key and
command of the job, on one page: [README.md](README.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad1` | Main Weapon (`MainWeapon`) | **Free** | Main hand. Add your weapons in `NIN_STATES.lua`: each value is `sets.<Weapon>` from your set file (or the plain weapon, if `WEAPON_CONFIG.lua` has `equip_without_set = true`). `Free` keeps the weapon you wear. |
| `^numpad2` | Sub Weapon (`SubWeapon`) | **Free** | Off hand, the same way. |
| `^numpad3` | Magic Burst (`MagicBurstMode`) | **Off**, On | On: elemental ninjutsu (Katon, Suiton, Raiton, Doton, Huton, Hyoton) wears `sets.midcast.Ninjutsu.Elemental.MagicBurst` when your set file has it. Other ninjutsu are not affected. |
| `^numpad4` | Offense Mode (`OffenseMode`) | **Normal**, Acc | Engaged gear: `sets.engaged.Acc` when your set file has it. |
| `^numpad5` | WS Mode (`WeaponskillMode`) | **Normal**, Acc | Weaponskill gear: `sets.precast.WS['<name>'].Acc`, or `sets.precast.WS.Acc` for a weaponskill without its own set. While WS Mode is Normal, Offense Mode Acc picks the same `.Acc` sets (Mote). |
| `^numpad9` | Hybrid Mode (`HybridMode`) | **Normal**, DT | DT: `sets.idle.DT` outside a city, and the `.DT` engaged set (`sets.engaged.Acc.DT` if you make one, else `sets.engaged.DT`). |

Mote-Include's F-keys reach the same modes: F9 Offense Mode, Ctrl+F9 Hybrid
Mode, Win+F9 WS Mode.

## Other modes (no key)

| Mode | Values | What it does |
|---|---|---|
| `FastCast` | 0 to 80 in steps of 10, default **0** | Your Fast Cast %, used only by the midcast watchdog when it cannot read the Fast Cast of your precast set. |

Change modes with Mote's `//gs c cycle <Mode>` or `//gs c set <Mode> <Value>`, or add
your own in `NIN_CUSTOM.lua`.

## Commands

Ninja has no command of its own. The common commands work as on every job:
[README.md](README.md#all-commands-on-this-job).

## Notes

- Every mode goes back to its default on each job change, subjob change or
  reload.
- Idle: `sets.idle.Town` / `sets.Adoulin` in a city; outside a city, while
  you move, `sets.MoveSpeed.Night` from 17:00 to 7:00 Vana'diel time and
  `sets.MoveSpeed` otherwise. Dusk-to-dawn feet from the +1 upgrade on work
  17:00-7:00; the plain Ninja Kyahan only 18:00-6:00.
- Weaponskill TP bonus: `NIN_TP_CONFIG.lua` (Moonshade Earring +250).

## Files

In `<YourChar>/config/nin/`: `NIN_STATES.lua` (modes and defaults),
`NIN_KEYBINDS.lua` (keys), `NIN_CUSTOM.lua` (your own modes and gear, see
[keybinds](../../guides/keybinds.md)), `NIN_TP_CONFIG.lua` (TP bonus),
`NIN_LOCKSTYLE.lua` (lockstyle 1), `NIN_MACROBOOK.lua` (book 1, page 1). See
[configuration](../../guides/configuration.md).
