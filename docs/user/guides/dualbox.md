# Dual-box guide

Two characters on the same PC, both running this setup, one **main** and one
(or more) **alt**. What you get:

- **Job exchange**: each box tells the other its job and levels about 2
  seconds after every load, and asks for the other's. The macro book can then
  follow the partner's job, and the main knows which alt commands exist.
- **Alt commands**: short `//gs c <spell>` commands typed on the main that the
  alt casts on your target.
- **Box group orders**: `//gs c alts ...` sends follow / automation / mirror
  orders, or any console command, to every other character of the group.
- **Role swap**: `//gs c main` makes the current character the main.
- **Alt window** on the main: each alt's job and whether it is in your party.
- `//gs c rf`, `//gs c ls` and the warp `...all` commands also run on the
  other GearSwap instances of the PC.

## Requirements

- The Windower **`send`** addon, loaded on both characters: every exchange
  goes through `send <Name> ...`.
- For `alts on / off / toggle / follow / mirror`: an automation addon that
  answers the console commands `sm on`, `sm off`, `sm follow <name>`,
  `sm follow off` and `sm mirror`. Without it those orders do nothing;
  `alts do <command>` works with any addon.
- Both characters created with the clone script, as main and alt.

## Setup

1. Clone the main: role `main`, and give the alt's name when asked.
2. Clone the alt: role `alt`, and give the main's name.
3. Load both characters. About 2 seconds after the load, each box sends its
   job to the other.

The script writes `<Name>/config/DUALBOX_CONFIG.lua`. On the main:

```lua
DualBoxConfig.role = "main"
DualBoxConfig.character_name = "Bob"
DualBoxConfig.alt_character = "Alice"
DualBoxConfig.group = {"Bob", "Alice"}
DualBoxConfig.enabled = true
DualBoxConfig.timeout = 30
DualBoxConfig.debug = false
```

On the alt, `role = "alt"` and `main_character = "Bob"` instead of
`alt_character`.

| Setting | Meaning |
|---|---|
| `role` | `"main"` or `"alt"` (overridden by `//gs c main`, see below) |
| `alt_character` / `main_character` | The partner for the job exchange and the alt commands |
| `group` | Every character of the box group: `alts` orders go to all of them but yourself. Add a third name here for a third box |
| `enabled` | `false` turns dual-box off for this character |
| `timeout` | Seconds without news from the partner before it counts as offline (for the macro book choice) |
| `debug` | More chat output |

The job exchange and the alt commands work with one partner; the `alts`
orders and the alt window work with every member of `group`.

Only the main gets `config/alt/` (the alt command files) from the clone
script.

## Box group orders (`//gs c alts`)

Work from either box: they go to every other member of `group`.

| Command | Default key | Effect |
|---|---|---|
| `alts follow` | Alt+Numpad7 | Alts follow you; again to stop |
| `alts follow <name>` / `alts follow off` | | Follow that character / stop |
| `alts toggle` | Alt+Numpad8 | Automation on / off |
| `alts on` / `alts off` | | Automation on / off |
| `alts mirror` | Alt+Numpad9 | Mirror request, sent from this character |
| `alts do <console command>` | | Any console command, on every alt |
| `alts window` | | Show / hide the alt window (main only) |

The state shown (and used by `toggle` and `follow`) is the last order sent
from this box; an order sent another way (a macro, the alt's own keys) is not
seen, so a toggle can need one extra press. The keys are in
`COMMON_KEYBINDS.lua` ([keybinds](keybinds.md#common-keys)).

## Swapping roles (`//gs c main`)

Type `//gs c main` on the character that should lead. It becomes the main,
the other members of the group become its alts (each is told with
`gs c setalt <you>`), and the jobs are exchanged again. The role is saved in
`<Name>/config/dualbox_role.lua` and wins over `DUALBOX_CONFIG.lua` until you
delete that file or swap again.

## The alt window

Shown on the main only. For each alt: its job (the last one it reported),
whether it is in your party (and its zone when it differs), and the last
Auto / Follow / Mirror order sent from this box (`?` until one is sent).
While the window is on screen, those orders print nothing in chat.
Drag it with the mouse; the position is saved a few seconds later.
`//gs c alts window` shows or hides it.

## Alt commands: drive the alt from the main

Type a short command on the MAIN and the ALT performs it, on whatever you have
selected. With a RDM alt, `//gs c haste` becomes one line, sent immediately:

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

The command set follows the ALT's main job and subjob automatically, and each
spell tier follows the level the ALT reported: put the alt on RDM and
`//gs c haste` casts Haste II (Haste below level 96); put it on COR and the
roll commands appear instead. Nothing to reload.

Local commands always win a name conflict: on a main whose job already has
`//gs c dispel` (BLM, GEO), `//gs c dispel` runs on the main and
`//gs c alt dispel` reaches the alt. `altcmds` lists apart the names that
only work as `//gs c alt <name>`.

### Finding a command

`//gs c altcmds` lists the alt's commands grouped by school
(enfeebling, enhancing, healing...). `//gs c altcmds <group>` shows one group
in full, and `//gs c altcmds <word>` searches command names and spell names
alike.

Most of the time you will not open the list at all: **the command name is the
spell name**, lowercase, no spaces - `//gs c haste`, `//gs c dia`,
`//gs c poisona`.

### Changing the commands

The command files are in the MAIN's folder, `<Main>/config/alt/`.
`<JOB>_ALT_COMMANDS.lua` is **generated** from the game data and gets rebuilt
whenever the spell list changes - anything you write in it is lost.

Yours go in `<JOB>_ALT_CUSTOM.lua`, in the same folder. It is never
regenerated, and it is merged on top of the generated file. A commented
`.example` ships for BLM, COR, GEO, RDM, SCH and WHM: copy it without the
`.example` and edit. BLM, GEO, RDM, SCH and SMN already have a
`_ALT_CUSTOM.lua` in use.

```
<Main>/config/alt/RDM_ALT_CUSTOM.lua
```

Three things it can do:

```lua
M.commands = {
    -- add: a name the generator does not produce
    h = { action = 'ma', spell = 'Haste II', target = 'lastst' },

    -- change: reuse an existing name, yours wins
    dia = { action = 'ma', spell = 'Dia III', target = 'lastst' },

    -- remove: false drops a generated command
    aero = false,
}
```

Commands you do not mention are untouched. `//gs c altcmds` prints the path to
the file for the job the alt is on, so you never have to remember it.

Reload with `//lua reload gearswap` after editing - `require` caches the file.

| Field | Values |
|-------|--------|
| `action` | `ma` `ja` `ws` `so` `item` `pet` `ra` `ninjutsu` `raw` |
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

**Entrust is tracked.** While the main believes the alt has Entrust up, every
`//gs c indi*` command aims at your last subtarget instead of the alt - same
macro either way:

```
/target <stal>
/console gs c indihaste
```

Without Entrust the selection is ignored and the spell lands on the alt.

How the main knows: `//gs c altentrust` marks Entrust as up at once (for at
most 60 s) and asks the alt for its buffs 3 s later, because the game signals
Entrust only when it wears off, not when it is gained. The alt then reports
its tracked buffs, and reports losing Entrust. Once the alt has reported for
real, the main stops guessing.

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

## Troubleshooting

| Symptom | Check |
|---|---|
| "Dual-box not initialised yet" | Wait: the first 2 seconds after a load, nothing dual-box works |
| "No alt set" / nothing sent | `enabled = true` and the names in `DUALBOX_CONFIG.lua` (or `dualbox_role.lua`) match the characters exactly |
| Alt commands unknown on the main | The alt must have reported its job: reload the alt (`//gs c reload`) so it sends it; check the `send` addon is loaded on both |
| An alt command runs on the main | A local command has that name: use `//gs c alt <name>` |
| `alts follow` does nothing | Your automation addon must answer `sm follow <name>` |
| Wrong character leads after a swap | `//gs c main` on the right one, or delete `<Name>/config/dualbox_role.lua` |

Tracing: `//gs c altdebug` (alt buff reports, on both characters), and
`DualBoxConfig.debug = true` for more messages.

## Further reading

- [Commands](commands.md#dual-box)
- [Keybinds](keybinds.md)
- Developer page: [dualbox.md](../../dev/systems/dualbox.md)
