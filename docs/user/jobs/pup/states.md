# PUP — modes and keys

Puppetmaster: your weapon, your engaged and damage-taken modes, the
automaton's role (Pet Mode, set by itself from its head) and its weaponskill
gear (Pet WS).

Set names and automatic gear: [sets.md](sets.md).

Keys: Ctrl = `^`, Alt = `!`, Apps = `#` (the menu key), Shift = `~`, Win = `@`.
The HUD (`//gs c ui`) shows each mode's current value; this page says what each
value does. `#numpad0` (Auto Medicine) and Alt+Numpad7-9 (alts) are common to
every job, see [keybinds](../../guides/keybinds.md).

This page describes the provided template (`_master/config/pup/`). Every key and
command of the job, on one page: [README.md](README.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad1` | Main Weapon (`MainWeapon`) | **Free** | Main hand. Add your weapons in `PUP_STATES.lua`: each value is `sets.<Weapon>` from your set file (or the plain weapon, if `WEAPON_CONFIG.lua` has `equip_without_set = true`). `Free` keeps the weapon you wear. |
| `^numpad2` | Offense Mode (`OffenseMode`) | **Normal**, Acc | Engaged gear: `sets.engaged.Acc` (or `sets.engaged.Pet.Acc` while the automaton fights too) when your set file has it. |
| `^numpad3` | Hybrid Mode (`HybridMode`) | **Normal**, DT | DT: `sets.idle.DT` when no automaton is out, and the `.DT` engaged set (`sets.engaged.DT`, `sets.engaged.Pet.DT`). |
| `^numpad4` | Pet Mode (`PetMode`) | Melee, Tank, Ranged, Magic, Heal, Nuke | The automaton's role. Chooses `sets.idle.Pet.Engaged.<Pet Mode>` and `sets.midcast.Pet.WeaponSkill.<Pet Mode>` when they exist. Set by itself, see below. |
| `^numpad5` | Pet WS (`PetWS`) | **On**, Off | On: the automaton's weaponskill set goes on while it fights with enough TP. Off: never. |

Mote-Include's F-keys reach the same modes: F9 Offense Mode, Ctrl+F9 Hybrid Mode.

### Pet Mode is set from the automaton's head

| Head | Pet Mode |
|---|---|
| Harlequin Head | Melee |
| Valoredge Head | Tank |
| Sharpshot Head | Ranged |
| Stormwaker Head | Magic |
| Soulsoother Head | Heal |
| Spiritreaver Head | Nuke |

With another head, the frame decides (Harlequin, Valoredge, Sharpshot,
Stormwaker Frame: Melee, Tank, Ranged, Magic).

It is read when the job loads, whenever the gear is refreshed and you changed
the head or frame since the last reading, and each time a new automaton comes
out (Activate, Deus Ex Automata). **A value you cycle by hand stays** until
one of those changes happens; `//gs c petmode auto` goes back to the head's
value at once.

### Pet WS

The automaton's weaponskill goes off the moment its TP allows, faster than
GearSwap can react to it. So the job puts its weaponskill set on **before**:
while Pet WS is On, the automaton is fighting and its TP is at least
`pet_ws_tp` (1000, in `PUP_TP_CONFIG.lua`), `sets.midcast.Pet.WeaponSkill
.<Pet Mode>` (or `sets.midcast.Pet.WeaponSkill`) goes on top of your idle or
engaged gear. The job checks the automaton's TP every half second while it is
out; nothing is checked when no automaton is out or Pet WS is Off. After the
weaponskill its TP drops and your gear comes back.

If your automaton keeps its TP past 1000 before using its weaponskill, raise
`pet_ws_tp` (for example to 1500) so the WS gear does not stay on for nothing.

## Other modes (no key)

| Mode | Values | What it does |
|---|---|---|
| `FastCast` | 0 to 80 in steps of 10, default **0** | Your Fast Cast %, used only by the midcast watchdog when it cannot read the Fast Cast of your precast set. |

Change modes with Mote's `//gs c cycle <Mode>` or `//gs c set <Mode> <Value>`, or add
your own in `PUP_CUSTOM.lua`.

## Commands

`//gs c petmode` shows the automaton (head, frame, Pet Mode, Pet WS, its TP);
`//gs c petmode auto` sets Pet Mode from the head again. The common commands
work as on every job: [README.md](README.md#all-commands-on-this-job).

## Notes

- Every mode goes back to its default on each job change, subjob change or
  reload; Pet Mode is then read from the head again.
- Idle: `sets.idle.Town` / `sets.Adoulin` in a city, `sets.MoveSpeed` while
  moving outside a city.
- Weaponskill TP bonus (yours): `PUP_TP_CONFIG.lua` (Moonshade Earring +250).

## Files

In `<YourChar>/config/pup/`: `PUP_STATES.lua` (modes and defaults),
`PUP_KEYBINDS.lua` (keys), `PUP_CUSTOM.lua` (your own modes and gear, see
[keybinds](../../guides/keybinds.md)), `PUP_TP_CONFIG.lua` (TP bonus, `pet_ws_tp`),
`PUP_LOCKSTYLE.lua` (lockstyle 1), `PUP_MACROBOOK.lua` (book 1, page 1). See
[configuration](../../guides/configuration.md).
