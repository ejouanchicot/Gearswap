# Keybinds

Three places give you keys, plus temporary keys made in game:

| File (in `<YourName>/config/`) | Keys |
|---|---|
| `<job>/<JOB>_KEYBINDS.lua` | The job's keys |
| `<job>/<JOB>_CUSTOM.lua` | Your own modes, with their key (empty by default) |
| `COMMON_KEYBINDS.lua` | Keys every job of this character gets |
| `//gs c tb` (in game) | Temporary keys on Ctrl/Alt+F1-F8 |

Keys are bound when the job loads and removed when you leave the job. The
keybind HUD (`//gs c ui`) lists the keys of the current job.

## The layout

| Keys | Use |
|---|---|
| `^numpad0`-`^numpad9`, `^numpad.`, `^numpad+`, `^numpad-`, `^numpad*`, `^numpad/` | The job's modes (Ctrl+Numpad) |
| `#numpad1`-`#numpad9` | Extra modes on some jobs (Apps+Numpad) |
| `#numpad0` | Auto Medicine on/off (common key) |
| `!numpad7`, `!numpad8`, `!numpad9` | Alts follow / automation on-off / mirror (common keys, see [dual-box](dualbox.md)) |
| F9-F12 with modifiers | Mote-Include's default keys (F9 Offense mode, Ctrl+F9 Hybrid mode, F12 gear refresh, Ctrl+F12 Idle mode...) |
| Ctrl+F1-F8, Alt+F1-F8 | Free for `//gs c tb` |

Modifiers: `^` Ctrl, `!` Alt, `@` Windows, `#` Apps (the menu key), `~` Shift.
They combine: `^!numpad1` = Ctrl+Alt+Numpad1.

Habits of the job files: Ctrl+Numpad9 is Hybrid Mode on every job that binds
it; Ctrl+Numpad1 / 2 are the weapons when the job has weapon modes;
Ctrl+Numpad3 is the job's most used mode. The bare keypad is never bound, so
the game and other addons keep it.

**Do not put a job key on `#numpad0` or `!numpad7-9`**: the job key wins and
the common key disappears on that job.

## The file format

A job's keybind file (here WAR, shortened):

```lua
local WARKeybinds = {}

WARKeybinds.binds = {
    { key = "^numpad1", command = "cyclestate MainWeapon", desc = "Main Weapon", state = "MainWeapon" },
    { key = "^numpad9", command = "cyclestate HybridMode", desc = "Hybrid Mode", state = "HybridMode" },
}

return require('shared/utils/keybinds/keybind_manager').create('WAR', WARKeybinds)
```

Keep the last line as it is. Fields of an entry:

| Field | Meaning |
|---|---|
| `key` | The key (`"^numpad1"`). `""` = a HUD line only, no key |
| `command` | What the key runs (see below) |
| `desc` | Label in the HUD and in chat |
| `state` | Mode shown with its current value in the HUD (optional) |
| `subjob` | Only with this subjob (`"RDM"` or a list) |
| `exclude_subjob` | Never with this subjob |
| `visible` | A function returning true / false, for keys that depend on a mode |
| `raw` | `true` = send `command` exactly as written |

What `command` sends:

| `command` starts with | Sent as | Example |
|---|---|---|
| `//` | A console command of any addon | `"//sm mirror"` |
| `/` | A game command | `"/p Ready!"` |
| anything else | A GearSwap command (`gs c ...`) | `"cyclestate HybridMode"` |

Useful GearSwap commands for a key:

| Command | Effect |
|---|---|
| `cyclestate <Mode>` | Next value, HUD updated, no chat line while the HUD is shown |
| `cyclestate <Mode> reverse` | Previous value |
| `toggle <Mode>` | On/off modes (Mote-Include) |
| `set <Mode> <Value>` | A given value (Mote-Include) |
| any job or common command | e.g. `"rf"`, `"alts follow"` |

The file is checked at load: an unknown key name, a missing command or a key
used twice prints a `<JOB> keybinds: ...` line in chat. Edit, then
`//gs c reload`.

## Common keys

`COMMON_KEYBINDS.lua` uses the same entry format, in `CommonKeybinds.binds`.
The template ships the four keys of the layout above and commented examples:

```lua
{ key = "!numpad4", command = "alts follow Tetsouo", desc = "Alts follow Tetsouo" },
{ key = "!numpad6", command = "//sm mirror", desc = "Mirror" },
{ key = "!numpad3", command = "/p Ready!", desc = "Party: ready" },
```

A common key whose key is already used by the job (or by your custom modes)
is skipped on that job.

## Your own modes (`<JOB>_CUSTOM.lua`)

Add modes and gear rules without touching the job's code. The file ships
empty, with the full instructions and examples in its header. Two kinds of
block:

```lua
return {
    -- A mode with a key: shown in the HUD, cycles its values
    {
        state  = 'TPMode', desc = 'TP Mode', key = '^numpad0',
        values = {'Normal', 'Acc'},
        Acc    = { engaged = { head = "Nyame Helm" } },
    },
    -- A rule: gear that goes on by itself when the conditions hold
    { when = { hp_below = 50 }, idle = { ring1 = "Gelatinous Ring +1" } },
}
```

- Moments: `idle`, `engaged`, `weaponskill`, `ability`, `precast`, `midcast`,
  `all`.
- Conditions (`when`): `buff`, `no_buff`, `weapon`, `sub`, `range`, `ammo`,
  `subjob`, `no_subjob`, `mode`, `hp_below/above`, `mp_below/above`,
  `tp_below/above`, `spell`, `skill`, `spell_type`, `element`, `day_weather`,
  `target`, `distance_below`, `obi_better`, `orpheus_better`, `obi_bonus_above`,
  `town`, `moving`, `pet`, `engaged`, `zone`.
- The better elemental belt, for nukes, elemental weaponskills and Quick Draw:

  ```lua
  { when = { obi_better = true }, midcast = { waist = "Hachirin-no-Obi" }, weaponskill = { waist = "Hachirin-no-Obi" } },
  { when = { orpheus_better = true }, midcast = { waist = "Orpheus's Sash" }, weaponskill = { waist = "Orpheus's Sash" } },
  ```

  Add `skill = 'Elemental Magic'` or `spell = {...}` to the `when` to limit
  which actions it applies to.
- Latent refresh: `{ when = { mp_below = 51 }, idle = { waist = "Fucho-no-Obi" } }`.
- Your pieces go on last, on top of the job's choice. Some slots are left
  alone on purpose (Doom, song instruments, Phantom Roll rings, Treasure Hunter
  pieces, locked slots...).
- `state = 'HybridMode'` (a mode the job already has) with no `values`
  adds gear to one of its values.
- `lock = {'main', 'sub'}` in a value keeps those slots locked while the value
  is on. A Capacity Points cape:

  ```lua
  { state = 'CP', desc = 'CP Cape', key = '!numpad1', values = 'onoff',
    On = { all = { back = "Mecisto. Mantle" }, lock = {'back'} } },
  ```

  For the weapons, use Combat Mode below.
- Mistakes are reported in chat at load as `<JOB>_CUSTOM: ...`.

Pick a key the job does not use (the job's page lists them), or the custom
key replaces the job's.

## Combat Mode (every job)

Combat Mode On keeps your weapons where they are (main, sub, range; ammo too on
BLM and WHM): no spell or set swaps them, the TP stays. It is on the HUD of BLM,
GEO, RDM and WHM by default, with their usual key, hidden elsewhere. Shown on
another job, its key is Alt+Numpad0 unless you pick one.

| Command | Effect |
|---|---|
| `//gs c combatmode` | Status on this job |
| `//gs c combatmode show` / `hide` | Use it on this job or not (HUD row, key, lock) |
| `//gs c combatmode key <key>` / `key none` | Its key on this job |

Saved per character in `config/combat_mode.lua`. To use it everywhere with
one key, write the file by hand:
`return { shown = {all = true}, hidden = {}, keys = {all = '~f9'} }`.

## Temporary keys (`//gs c tb`)

For a repetitive task, bind a key from the chat line; it lasts until you
remove it or restart the game.

| Command | Effect |
|---|---|
| `//gs c tb <key> <action> [target]` | Bind a key, e.g. `//gs c tb cf1 dia2 t` |
| `//gs c tb <action> [target]` | Same, on the first free key of Ctrl+F1-F8, then Alt+F1-F8 |
| `//gs c tb force <key> ...` | Bind even a key already in use |
| `//gs c tb list` / `del <key>` / `clear` | Show / remove one / remove all |
| `//gs c tb help` | Full help |

- Keys: `^f1`, `ctrl+f1`, `cf1`, `caf1` (Ctrl+Alt+F1), `cn1` (Ctrl+Numpad1)...
- Action: a spell, ability, weaponskill or item name, written loosely
  (`dia2` = Dia II); `//command` for a console command; `/command` for a game
  command. Anything else is sent to the console as typed (not to `gs c`).
- Target: `t`, `st`, `stnpc`, `bt`, `me`... or a name, looked up at each press
  (nearest match within 50 yalms).
- F9-F12, `^-`, `^=` and `^v` are refused unless you use `force`.

## After editing

- `<JOB>_KEYBINDS.lua`, `COMMON_KEYBINDS.lua`, `<JOB>_CUSTOM.lua`: `//gs c reload`
  (or change job).
- The files in `<YourName>/config/` are your copies; the templates in
  `_master/` are only read by the clone script.
