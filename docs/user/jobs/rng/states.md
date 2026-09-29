# RNG — modes and keys

Ranger: your three weapons (range, main, sub), the ranged attack mode, and your
melee, damage-taken and weaponskill modes.

Set names and automatic gear: [sets.md](sets.md).

Keys: Ctrl = `^`, Alt = `!`, Apps = `#` (the menu key), Shift = `~`, Win = `@`.
The HUD (`//gs c ui`) shows each mode's current value; this page says what each
value does. `#numpad0` (Auto Medicine) and Alt+Numpad7-9 (alts) are common to
every job, see [keybinds](../../guides/keybinds.md).

This page describes the provided template (`_master/config/rng/`). Every key and
command of the job, on one page: [README.md](README.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad1` | Main Weapon (`MainWeapon`) | **Free** | Main hand. Add your weapons in `RNG_STATES.lua`: each value is `sets.<Weapon>` from your set file (or the plain weapon, if `WEAPON_CONFIG.lua` has `equip_without_set = true`). `Free` keeps the weapon you wear. |
| `^numpad2` | Range Weapon (`RangeWeapon`) | **Free** | Bow, gun or crossbow. Same rules; its set also names the ammo you shoot with it (`sets['Gastraphetes'] = {range = "Gastraphetes", ammo = "Quelling Bolt"}`). A plain weapon without a set brings no ammo. |
| `^numpad3` | Ranged Mode (`RangedMode`) | **Normal**, Acc | Ranged attacks: `sets.precast.RA.Acc` and `sets.midcast.RA.Acc` when your set file has them. Also the WS mode of bow / gun / crossbow weaponskills while WS Mode is Normal (`sets.precast.WS['Last Stand'].Acc`...). |
| `^numpad9` | Hybrid Mode (`HybridMode`) | **Normal**, DT | DT: `sets.idle.DT` outside a city, and the `.DT` engaged set (`sets.engaged.DT`, or `sets.engaged.Acc.DT` under Offense Mode Acc if you add it). |
| `^numpad4` | Sub Weapon (`SubWeapon`) | **Free** | Off hand. A weapon there is held only with Dual Wield (/NIN, /DNC); without it, `sets.SingleWield`'s sub goes there instead, or the off hand stays as it is. |
| `^numpad5` | Offense Mode (`OffenseMode`) | **Normal**, Acc | Melee: `sets.engaged.Acc` when your set file has it. Also the WS mode of melee weaponskills while WS Mode is Normal. |
| `^numpad6` | WS Mode (`WeaponskillMode`) | **Normal**, Acc | Weaponskills: `sets.precast.WS.Acc` / `sets.precast.WS['Name'].Acc`. |

Mote-Include's F-keys reach the same modes: F9 Offense Mode, Ctrl+F9 Hybrid
Mode, Alt+F9 Ranged Mode, Win+F9 WS Mode.

### Weapons and Combat Mode

The weapon sets go on top of your idle and engaged gear, in town too, in the
order main, sub, range. Your precast and midcast sets should not name `range`
or `ammo`: the weapon set holds them, and a ranged set that names an ammo
changes the ammo you shoot with. With Combat Mode On (`//gs c combatmode show`, then
Alt+Numpad0) main, sub and range stay where they are.

## Other modes (no key)

| Mode | Values | What it does |
|---|---|---|
| `FastCast` | 0 to 80 in steps of 10, default **0** | Your Fast Cast %, used only by the midcast watchdog when it cannot read the Fast Cast of your precast set. |

Change modes with Mote's `//gs c cycle <Mode>` or `//gs c set <Mode> <Value>`, or add
your own in `RNG_CUSTOM.lua` (a mode or rule there never changes a ranged
attack).

## Commands

Ranger has no command of its own. The common commands work as on every job:
[README.md](README.md#all-commands-on-this-job).

## Notes

- Every mode goes back to its default on each job change, subjob change or
  reload.
- Idle: `sets.idle.Town` / `sets.Adoulin` in a city, `sets.MoveSpeed` while
  moving outside a city.
- Weaponskill TP bonus: `RNG_TP_CONFIG.lua` (Moonshade Earring +250). The TP
  bonus of a range weapon is not counted.

## Files

In `<YourChar>/config/rng/`: `RNG_STATES.lua` (modes and defaults),
`RNG_KEYBINDS.lua` (keys), `RNG_CUSTOM.lua` (your own modes and gear, see
[keybinds](../../guides/keybinds.md)), `RNG_TP_CONFIG.lua` (TP bonus),
`RNG_LOCKSTYLE.lua` (lockstyle 1), `RNG_MACROBOOK.lua` (book 1, page 1). See
[configuration](../../guides/configuration.md).
