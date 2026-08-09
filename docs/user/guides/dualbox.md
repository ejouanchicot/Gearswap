# DualBox Guide

Setup guide for dual-box communication between two characters.

---

## Overview

The DualBox system provides automatic one-way communication from an ALT character to a MAIN character:

- MAIN receives the ALT's current job and subjob.
- ALT sends job updates automatically on every job/subjob change.
- MAIN can display the ALT's job in the UI overlay.

**Requirements**: Both characters logged in with Windower 4.2+ and GearSwap loaded.

---

## Setup

### 1. Create the Alt Character Folder

**Using the clone script** (recommended):

```cmd
cd "D:\Windower Tetsouo\addons\GearSwap\data"
python clone_character.py
```

Enter the source name (e.g., `Tetsouo`) and the new name (e.g., `Kaories`). The script copies all job files, renames them, and updates config paths.

Manual alternative: copy the character folder, rename all `Source_*.lua` files to `Alt_*.lua`, and find-replace config path references.

### 2. Configure MAIN Character

Edit `Tetsouo/config/DUALBOX_CONFIG.lua`:

```lua
local DualBoxConfig = {}

DualBoxConfig.role = "main"
DualBoxConfig.character_name = "Tetsouo"
DualBoxConfig.alt_character = "Kaories"

DualBoxConfig.enabled = true
DualBoxConfig.timeout = 30
DualBoxConfig.debug = false

return DualBoxConfig
```

### 3. Configure ALT Character

Edit `Kaories/config/DUALBOX_CONFIG.lua`:

```lua
local DualBoxConfig = {}

DualBoxConfig.role = "alt"
DualBoxConfig.character_name = "Kaories"
DualBoxConfig.main_character = "Tetsouo"

DualBoxConfig.enabled = true
DualBoxConfig.timeout = 30
DualBoxConfig.debug = false

return DualBoxConfig
```

**Key difference**: MAIN sets `role = "main"` and `alt_character`. ALT sets `role = "alt"` and `main_character`.

### 4. Reload and Test

Reload GearSwap on both characters:

```
//gs c reload
```

On the MAIN character, request the ALT's job:

```
//gs c altjob
```

Expected output:

```
[DualBox] Requesting alt job info...
[DualBox] Alt job received: GEO/RDM
```

---

## Daily Usage

1. Log in both characters and load GearSwap.
2. The system auto-connects. No manual commands needed.
3. When the ALT changes jobs, MAIN is updated automatically.

---

## Commands

| Command | Run On | Description |
|---------|--------|-------------|
| `//gs c altjob` | MAIN | Request ALT's current job |
| `//gs c requestjob` | ALT | Respond to MAIN's request (auto-triggered) |
| `//gs c altjobupdate [job] [subjob]` | MAIN | Receive job update (auto-triggered) |

In normal use, no manual commands are needed. Use `//gs c altjob` only if the connection seems stale.

---

## Driving the ALT from the MAIN

Type a short command on the MAIN and the ALT performs it, on whatever you have
targeted. `//gs c haste` becomes one line, sent immediately:

```
send Kaories input /ma "Haste II" <laststid>
```

The `send` addon rewrites `<...id>` into a numeric mob id **on your client**
before transmitting, so the ALT receives a plain id and never needs the target
selected on its own side. Nothing is deferred and nothing is polled.

You do the aiming, with any of `/ta <stpc>`, `/ta <stnpc>` or `/ta <stal>` — all
three feed the same `lastst` slot. Select once and every command applies to that
entity until you pick another.

### Pick and fire in one button

Put the selection on its own macro line. FFXI does not run the next line until
you confirm the cursor, so by the time the command fires, `lastst` holds your
pick:

```
/target <stal>
/console gs c haste
```

This is the standard trick (the SubTarget addon works the same way). GearSwap
cannot do it on its own: `input /ta <stal>` returns immediately, and while the
cursor is open the game already reports the highlighted entity as your target —
so anything watching would fire on the first entry the cursor lands on, not the
one you confirm. The macro line is what makes the game wait.

### Using it

| Command | Description |
|---------|-------------|
| `//gs c altcmds` | List everything the ALT can do on its current job |
| `//gs c <name>` | Short form, e.g. `//gs c haste`, `//gs c chaos` |
| `//gs c alt <name>` | Explicit form, use if a name collides with a built-in |

The command set follows the ALT's job automatically: put the alt on RDM and
`//gs c haste` casts Haste II; put it on COR and the roll commands appear
instead. Nothing to reload.

Built-in commands always win a name conflict, so an entry called `dispel` would
be shadowed on a job that already has `//gs c dispel`. `//gs c alt dispel`
still reaches the alt.

### Finding a command

`//gs c altcmds` opens with the syntax, then the choices grouped by school:

```
=== Kaories (RDM/WHM) - 111 commands ===
  //gs c <name> and Kaories casts it - the name IS the spell name.
  enfeebling:     addle altdispel bind blind breakspell ... (16)
  enhancing:      altsneak aquaveil auspice baraera baraero ... (70)
  healing:        blindna cura curaga cure cursna ... (12)
  //gs c altcmds <group> for the rest, or search: //gs c altcmds haste
```

A group or a search word gives the full set, split by what you have to do
first rather than listed one per line:

```
//gs c altcmds healing

  //gs c <name> and Kaories casts it.
  needs a target: blindna curaga cure cursna paralyna poisona raise silena
                  stona viruna
  on Kaories:     cura reraise
  pick it with /ta <stpc> for an ally, /ta <stnpc> for a mob
```

Searching matches the command name and the spell alike, so `//gs c altcmds
haste` finds it wherever it lives.

Most of the time you will not open the list at all: **the command name is the
spell name**, lowercase, no spaces - `//gs c haste`, `//gs c dia`,
`//gs c poisona`. Names that would clash with an existing command take an `alt`
prefix (`altdispel`, `altsneak`).

### Changing the commands

`<JOB>_ALT_COMMANDS.lua` is **generated** from the game data and is rebuilt
whenever the spell list changes - edits to it are lost.

Put yours in `<JOB>_ALT_CUSTOM.lua` instead. It is never regenerated and is
merged on top:

```lua
M.commands = {
    h    = { action = 'ma', spell = 'Haste II', target = 'lastst' },  -- add
    dia  = { action = 'ma', spell = 'Dia', target = 'lastst' },       -- replace
    aero = false,                                                     -- remove
}
```

`RDM_ALT_CUSTOM.lua.example` ships as a commented template - copy it without
the `.example` to start. The file is optional; absent means no overrides.

| Field | Values |
|-------|--------|
| `action` | `ma` `ja` `ws` `so` `item` `pet` `ra` `raw` |
| `spell` | Name to use, or a function returning one |
| `target` | `lastst` (default) or `me` |
| `desc` | Shown by `//gs c altcmds` |
| `step_delay` | Seconds between the steps of a `chain` (default 2) |

In practice there are only two:

- **`lastst`** - whatever you last selected. `/ta <stpc>`, `/ta <stnpc>` and
  `/ta <stal>` all feed the same slot, so one token covers allies, mobs and
  NPCs alike. It goes out as `<laststid>`, which `send` turns into a numeric id
  **on your client**, so the alt acts on the entity you picked.
- **`me`** - the alt itself: its own buffs, COR rolls, GEO Indi- spells. It goes
  out as the literal `<me>`, which `send` leaves untouched (it only rewrites
  `<...id>`), so the alt resolves it to itself.

Never write a target expecting `<meid>`: that resolves to the **main's** id and
would aim every self-buff at the wrong character.

`t`, `bt`, `ft`, `scan` and `pet` stay accepted if you want them, but the
shipped configs use only `lastst` and `me`.

### GEO: Geocolure target types

A Geocolure refuses the wrong kind of target outright, so pick the right thing
before firing:

| Family | Select first | Examples |
|--------|--------------|----------|
| `Indi-` | nothing, it goes on the alt (`me`) | Indi-Fury, Indi-Haste |
| `Geo-` buffs - **PC only** | `/ta <stpc>` an ally | Geo-Fury, Haste, Refresh, Acumen, Focus, Regen, Precision |
| `Geo-` debuffs - **enemy only** | `/ta <stnpc>` the mob | Geo-Frailty, Malaise, Languor, Wilt, Torpor, Vex, Slow, Gravity |

Both `Geo-` families use `lastst`; only the selection you make beforehand
differs.

**Entrust is detected automatically.** The main cannot read an alt's buffs, so
the alt announces the ones that matter: gaining Entrust sends
`gs c altbuff Entrust 1` to the main, losing it sends `0`. While that buff is
up, every `//gs c indi*` command aims at your last subtarget instead of the
alt — same macro either way:

```
/target <stal>
/console gs c indihaste
```

Without Entrust the selection is simply ignored and the spell lands on the alt.

If the alt never reports (older code on its side, module not loaded), the main
falls back to assuming Entrust right after `//gs c altentrust`, with a 60s
expiry. As soon as one real report arrives, that guess is dropped for good and
the alt's own buffs are authoritative — which matters, because an Entrust that
failed (paralysed, mid-cast, on recast) must *not* be assumed to have landed.

Two diagnostics:

| Command | Shows |
|---------|-------|
| `//gs c altbuffs` | what the main believes, and whether the alt reports for real |
| `//gs c altdebug` | traces every send/receive — run it on **both** characters |

With tracing on, the alt prints a line for every buff change, including
untracked ones. Seeing those confirms `buff_change` fires at all; seeing
nothing means the module is not loaded on that side.

Buffs are reported only if listed in `TRACKED`
(`shared/utils/dualbox/alt_buff_reporter.lua`) — currently Entrust, Composure
and Bolter's Roll. Add a line there to expose another one.

**Mirror one of your own states.** `spell_from_state` reads a Mote state on the
MAIN, so the alt follows what you have selected:

```lua
altlight = {
    action = 'ma',
    spell_from_state = 'MainLightSpell',  -- your BLM light element
    fallback = 'Fire III',                -- when the main is not BLM
    target = 'lastst',
},
```

**Chain several actions.** Each step is sent separately, so a `;` cannot leak
back to your own client:

```lua
entrusthaste = {
    target = 'lastst', step_delay = 2,
    chain = {
        { action = 'ja', spell = 'Entrust', target = 'me' },
        { action = 'ma', spell = 'Indi-Haste' },  -- uses the entry's target
    },
},
```

---

## Configuration Reference

| Setting | MAIN | ALT |
|---------|------|-----|
| `role` | `"main"` | `"alt"` |
| `character_name` | Your main name | Your alt name |
| `alt_character` | Alt name | (not used) |
| `main_character` | (not used) | Main name |
| `enabled` | `true` | `true` |
| `timeout` | `30` | `30` |
| `debug` | `false` | `false` |

### Disabling DualBox

Set `DualBoxConfig.enabled = false` in the config file and reload (`//gs c reload`).

### Multiple Alts

The system supports 1 MAIN + 1 ALT. Multiple alts require custom modification.

### UI Position

The ALT job display is part of the main UI. Drag to position, then save with `//gs c ui save`.

---

## Troubleshooting

### ALT job not updating

1. Verify `DualBoxConfig.enabled = true` on both characters.
2. Check that character names match exactly (case-sensitive).
3. Reload both characters: `//gs c reload`.
4. Test manually: `//gs c altjob` on MAIN.

### UI not showing ALT job

1. Confirm MAIN config has `role = "main"` and `enabled = true`.
2. Toggle the UI: `//gs c ui` twice.
3. Reload: `//gs c reload`.

### Commands not working

1. Verify GearSwap is loaded on both characters (`//lua list`).
2. You should see `[DualBox] System initialized` on load.
3. Enable trace output (`//gs c debugjobchange` or its alias `djc`) and retry `//gs c altjob` to see error details.

### Updates delayed (more than 5 seconds)

Network delay of 1-3 seconds is normal. If consistently slow, force a manual update with `//gs c altjob`.

---

## Further Reading

- [Configuration Guide](configuration.md) - Advanced config options
- [Commands Reference](commands.md) - All available commands
- [UI Guide](../features/ui.md) - Customize UI appearance
- [FAQ](faq.md) - Common issues

---
