# MNK — modes and keys

Monk: your weapon, your weaponskill, engaged and damage-taken modes. The buff
gear (Impetus, Footwork, Hundred Fists, Counterstance) needs no mode: it goes
on by itself, see [sets.md](sets.md).

Keys: Ctrl = `^`, Alt = `!`, Apps = `#` (the menu key), Shift = `~`, Win = `@`.
The HUD (`//gs c ui`) shows each mode's current value; this page says what each
value does. `#numpad0` (Auto Medicine) and Alt+Numpad7-9 (alts) are common to
every job, see [keybinds](../../guides/keybinds.md).

This page describes the provided template (`_master/config/mnk/`). Every key and
command of the job, on one page: [README.md](README.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad1` | Main Weapon (`MainWeapon`) | **Free** | Main hand. Add your weapons in `MNK_STATES.lua`: each value is `sets.<Weapon>` from your set file (or the plain weapon, if `WEAPON_CONFIG.lua` has `equip_without_set = true`). `Free` keeps the weapon you wear. Monk has no off hand. |
| `^numpad2` | WS Mode (`WeaponskillMode`) | **Normal**, Acc | Acc: `sets.precast.WS['<name>'].Acc` (or `sets.precast.WS.Acc` for a weaponskill without its own set) when your set file has it. With Normal, Offense Mode Acc also picks the `.Acc` weaponskill set (Mote's rule). |
| `^numpad3` | Offense Mode (`OffenseMode`) | **Normal**, Acc | Engaged gear: `sets.engaged.Acc` when your set file has it. |
| `^numpad9` | Hybrid Mode (`HybridMode`) | **Normal**, DT, Counter | DT: `sets.engaged.DT` and, standing, `sets.idle.DT`. Counter: `sets.engaged.Counter` (counter gear); standing, your normal idle. With Offense Mode Acc, `sets.engaged.Acc.DT` / `.Acc.Counter` are used when you add them. |

Mote-Include's F-keys reach the same modes: F9 Offense Mode, Ctrl+F9 Hybrid
Mode, Win+F9 WS Mode.

### Hybrid Mode and the buff sets

A buff set can have a version for one Hybrid Mode value, worn instead of it
while you fight in that mode: `sets.buff.Impetus.DT` is what Impetus puts on
in Hybrid Mode DT (for example nothing, to keep your DT body). Without it,
`sets.buff.Impetus` goes on in every mode. Weaponskills always use
`sets.buff.Impetus` itself.

## Other modes (no key)

| Mode | Values | What it does |
|---|---|---|
| `FastCast` | 0 to 80 in steps of 10, default **0** | Your Fast Cast %, used only by the midcast watchdog when it cannot read the Fast Cast of your precast set. |

Change modes with Mote's `//gs c cycle <Mode>` or `//gs c set <Mode> <Value>`, or add
your own in `MNK_CUSTOM.lua`.

## Notes

- Every mode goes back to its default on each job change, subjob change or
  reload.
- Idle: `sets.idle.Town` / `sets.Adoulin` in a city, `sets.MoveSpeed` while
  moving outside a city.
- Weaponskill TP bonus: `MNK_TP_CONFIG.lua` (Moonshade Earring +250).

## Files

In `<YourChar>/config/mnk/`: `MNK_STATES.lua` (modes and defaults),
`MNK_KEYBINDS.lua` (keys), `MNK_CUSTOM.lua` (your own modes and gear, see
[keybinds](../../guides/keybinds.md)), `MNK_TP_CONFIG.lua` (TP bonus),
`MNK_LOCKSTYLE.lua` (lockstyle 1), `MNK_MACROBOOK.lua` (book 1, page 1). See
[configuration](../../guides/configuration.md).
