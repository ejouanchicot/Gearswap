# Keybind HUD

An on-screen box listing every key of the current job, what it changes and the
mode's current value, for example `^numpad9  Hybrid Mode  PDT`. It is built
when the job loads (it waits up to 5 s for the job's modes) and repainted when
a mode changes. The rows come from the job's keybind file, your
`<JOB>_CUSTOM.lua` modes and the common keys, filtered by your current subjob.

## Commands

| Command | Alias | Effect |
|---|---|---|
| `ui` | | Show / hide (remembered) |
| `ui on` / `ui off` | `enable` / `disable` | Show / hide (remembered) |
| `ui header` | `ui h` | Title line |
| `ui legend` | `ui l` | Modifier legend (`^` Ctrl, `!` Alt...) |
| `ui columns` | `ui c` | Column headers |
| `ui footer` | `ui f` | Command reminder line |
| `ui font <name>` | | Font; keep a fixed-width one (`Consolas`, `Courier New`) |
| `ui theme <preset>` | `ui bg`, `ui background` | Background preset (`dark_blue`, `black`, `neon_green`...) |
| `ui theme list` | | List the presets |
| `ui theme toggle` | | Background on / off |
| `ui theme <r> <g> <b> <a>` | | Custom colour, 0-255 each |
| `ui save` | `ui s` | Save the position |
| `ui help` | `ui ?` | Help |

## Order of the sections and rows

Each row sits in a section (spells, enhancing, abilities, weapons, modes). The
order of the sections, and of the rows inside each section, can be set for
every job and, on top of that, per job:

| Where | What |
|---|---|
| `UI_CONFIG.lua`, `layout.section_order` / `layout.row_order` | The default of every job |
| `config/<job>/<JOB>_HUD.lua`, `section_order` / `row_order` | That job only: a list that is not empty replaces the default on that job |

Each `<JOB>_HUD.lua` explains itself at the top and lists the states of its
job (the names to use). Row names are the states as in the `_KEYBINDS` file,
or keys; case does not matter (`abyproc` = `AbyProc`). The rows named come
first in their section; the others follow in the keybind file's order.

| Command | Writes |
|---|---|
| `ui order weapons modes spells` | Section order of the job played now (its `_HUD.lua`) |
| `ui roworder TreasureMode HybridMode` | Row order of the job played now |
| `ui order all ...` / `ui roworder all ...` | The default of every job (`UI_CONFIG.lua`) |
| `ui order THF ...` / `ui roworder THF ...` | That job, from any job |
| `ui order reset` / `ui roworder reset` (`all reset`, `THF reset`) | Empties that list: back to the default |
| `ui style` | Shows the orders in force (this job and `all`) |

A command puts the names typed first and keeps the other names of the list
after them, in their order: `ui roworder AbyProc` moves AbyProc to the top
without losing the rest.

## Key conflicts

When two actions can sit on one key at the same time (a job key and a
partner's roll, two job keys...), the keys are not changed but:

- a `KEYS` block in chat says which one is bound and which one does nothing,
  when the job loads and when the partner changes job;
- the key of that row turns red in the HUD (`ui color conflict <r> <g> <b>`);
- `//gs c kc` (`keyconflicts`) lists every conflict the job can meet, on
  every subjob and partner job.

## Look of the HUD and the chat

`//gs c ui help` lists every look option (compact layout, gaps, margins,
colours, bullet, key style...) and `//gs c ui style` shows the current
values. They are saved in `UI_CONFIG.lua`. The chat options
(`ui separators on|off`, `ui sepchar`, `ui sepcolor`, `ui chatwidth`,
`ui jobtag`) apply to every chat message: with `separators off`, no `=====`
line is left anywhere, and every block follows the chat width.

## Position

Drag the box with the mouse, then `//gs c ui save`: a drag alone is not saved,
and the next load puts the box back at the last saved position. Showing or
hiding the header, legend or column headers moves the box so the key rows stay
in place, and saves.

## Where the settings live

| File | Content |
|---|---|
| `<YourName>/config/ui_settings.lua` | What `//gs c ui ...` changes: position, shown parts, background, font. Written by the commands; it wins over `UI_CONFIG.lua`. Delete it to go back to the `UI_CONFIG.lua` values. Kept by a re-clone |
| `<YourName>/config/UI_CONFIG.lua` | Defaults used when `ui_settings.lua` does not exist, plus the background presets, text outline, `flags` and `init_delay`, always read |
| `<YourName>/config/UI_COLOR_CONFIG.lua` | Colours of the values (elements, modes...) |

Defaults in the template `UI_CONFIG.lua`:

| Setting | Default |
|---|---|
| `enabled` | `true` |
| `show_header` | `false` |
| `show_legend` | `true` |
| `show_column_headers` | `false` |
| `show_footer` | `false` |
| `text.size`, `text.font` | `10`, `'Consolas'` |
| `background` | `r 15, g 15, b 35, a 180`, visible |
| `flags.draggable`, `flags.bold` | `true`, `true` |
| `sections` | `spells`, `enhancing`, `job_abilities`, `weapons`, `modes`: all `true` |
| `init_delay` | `5.0` (seconds the HUD waits for the job's modes) |

`auto_save_position`, `auto_save_delay`, `debug`, `update_throttle` and
`colors` are in the file but not used. A new character starts at position
1600, 300 (from `ui_settings.lua`).

## Troubleshooting

| Symptom | Try |
|---|---|
| No HUD | `//gs c ui on` |
| A mode shows `N/A` or is missing | `//gs c reload`; a row appears only if the keybind file lists it for your subjob |
| Columns misaligned | Use a fixed-width font: `//gs c ui font Consolas` |
| Wrong place after a reload | Drag it, then `//gs c ui save` |
