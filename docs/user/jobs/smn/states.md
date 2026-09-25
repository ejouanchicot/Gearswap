# SMN — modes and keys

> SMN ships only with the Tetsouo template (`_master/Tetsouo/`): a clone of
> another character does not get SMN files (`clone_character.py` prints
> `No entry file for: SMN`).

Summoner: Blood Pact gear picked by pact type, an Avatar's Favor idle, command
shortcuts for avatars and abilities, and a Summoning Magic skill-up loop.

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each
mode's current value; this page says what each value does. `#numpad0` (Auto
Medicine) and Alt+Numpad7-9 (alts) are common to every job, see
[keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad1` | Idle Mode (`IdleMode`) | **Normal**, DT, Avatar | Idle set: `sets.idle.Normal`, `sets.idle.DT` or `sets.idle.Avatar`. In town the town set replaces it. |
| `^numpad2` | Casting Mode (`CastingMode`) | **Normal**, Resistant | Mote's casting mode (`.Resistant` versions of precast / midcast sets, if you define them). |
| `^numpad3` | Avatar Favor (`AvatarFavor`) | **Off**, On | On: `sets.idle.Avatar` is used, even in town. It also turns itself on and off with the Avatar's Favor buff. |

## Other modes (no key)

| Mode | Values | What it does |
|---|---|---|
| `FastCast` | 0 to 80 in steps of 10, default **0** | Fast Cast %, used by the midcast watchdog to time your casts. |

## Commands

| Command | What it does |
|---|---|
| `//gs c smn summon <avatar>` | Summons an avatar or spirit by name, any case (`caitsith` or `cait sith`, `fire spirit`…). |
| `//gs c smn bp <pact>` | Uses a Blood Pact on `<me>` for ward buffs and heals, on `<t>` for everything else. |
| `//gs c smn astralflow` / `astralconduit` / `apogee` / `siphon` / `manacede` / `favor` / `release` / `retreat` | The matching ability on `<me>` (`siphon` = Elemental Siphon, `favor` = Avatar's Favor). |
| `//gs c smn assault` | Assault on `<t>`. |
| `//gs c skillup` | Starts or stops the skill-up loop: Siren, Release 5 s later, again 1.5 s after. `skillup start` / `stop` / `status`; `skillup <1-60>` sets the wait after Release and restarts. A reload or job change stops it. |

## Notes

- **Blood Pact gear**: the pact is sorted into Rage (Physical, Magical, Hybrid,
  Astral Flow) or Ward (Buff, Debuff, Heal), and
  `sets.pet_midcast.BPRage.<type>` / `sets.pet_midcast.BPWard.<type>` goes on
  when you use the pact and again when the avatar acts.
- **Carbuncle auto-summon**: about 10 s after loading (or a subjob change), if
  no pet is out, Carbuncle is summoned.
- Outside town, `sets.MoveSpeed` goes on while moving.
- SMN has no TP bonus config.
- Every mode goes back to its default on each job change, subjob change or reload.

## Files

In `Tetsouo/config/smn/` (template `_master/Tetsouo/config/smn/`):
`SMN_STATES.lua` (modes and defaults), `SMN_KEYBINDS.lua` (keys),
`SMN_CUSTOM.lua` (your own modes and gear, see
[keybinds](../../guides/keybinds.md)), `SMN_LOCKSTYLE.lua`, `SMN_MACROBOOK.lua`.
See [configuration](../../guides/configuration.md).
