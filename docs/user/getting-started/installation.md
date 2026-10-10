# Installation

From a fresh Windower to your first job loaded.

## 1. Requirements

- [Windower 4](https://www.windower.net/) with the GearSwap addon.
- Python 3, to run the clone script (once per character).
- Dual-box only: the `send` addon loaded on both characters. See the
  [dual-box guide](../guides/dualbox.md).

## 2. Copy the files

Download the repository ([github.com/ejouanchicot/Gearswap](https://github.com/ejouanchicot/Gearswap),
**Code** > **Download ZIP**) and copy its content into:

```
<Windower>/addons/GearSwap/data/
```

Or clone it with git (`git clone https://github.com/ejouanchicot/Gearswap.git`)
and copy the content the same way.

Check that `data/` now contains `_master/`, `shared/`, `docs/`,
`clone_character.py` and `CLONE_CHARACTER.bat`.

## 3. Create your character

Double-click `CLONE_CHARACTER.bat`. The prompts are in French by default;
from a command prompt in `data/`, `CLONE_CHARACTER.bat en` (or
`python clone_character.py --lang en`) gives English prompts.

The script asks:

1. **Character name** (letters and digits, 2-15 characters). If
   `data/<Name>/` already exists, it asks whether to replace it.
2. **Jobs**, comma-separated (any case), among BLM, BLU, BRD, BST, COR, DNC,
   DRG, DRK, GEO, MNK, NIN, PLD, PUP, RDM, RNG, RUN, SAM, SCH, SMN, THF, WAR,
   WHM (DRG, MNK, NIN, PUP, RNG and SCH load but have not been tested in game
   yet). A name that is not in
   this list is dropped without a message. If your character is already listed
   in `character_db.lua`, its jobs are taken from there and this question is
   skipped.
3. **Role**: `main` or `alt`. A main is asked for its alt's name (empty = no
   dual-box); an alt must give its main's name.
4. **Region**: US, EU or JP.
5. A summary and a **final confirmation**. Nothing is written before it.

It creates:

```
data/<Name>/
├── <Name>_<JOB>.lua      one entry file per job (one line, nothing to edit)
├── _WHERE-IS-WHAT.txt    every file of the folder and what it holds
├── _common/              settings of the whole character, by theme:
│                         display/, keys/, combat/, gear/, travel/, tools/,
│                         inventory/, sets/,
│                         dualbox/ (DUALBOX_CONFIG.lua, written from your
│                         answers; alt/ = alt commands, main only);
│                         REGION_CONFIG.lua (written from your answers) is in display/
├── <job>/                one folder per job: display/ (HUD, lockstyle, macro
│                         book), keys/ (keys, modes, CUSTOM), combat/ (the job's
│                         own settings), inventory/, and sets/<job>_sets.lua
└── saved/                written in game (HUD position, message modes, ...)
```

The template's character name inside the copied `.lua` files is replaced with yours.

**Running it again** for the same name: after the confirmation, the old
folder is moved to `addons/GearSwap/clone_backups/<Name>_<date>/` (never
deleted), a fresh one is built, and these files, written in game, are copied
back from the backup: `saved/ui_settings.lua` (HUD), `saved/message_modes.lua`,
`saved/alt_window.lua`, `saved/alt_state.lua`, `saved/WARP_ITEMS_OWNED.lua`,
`saved/gear_augments.lua`,
`saved/combat_mode.lua`, `saved/treasure_mode.lua`,
`_common/travel/STEALTH_CONFIG.lua`, every `<job>/display/<JOB>_HUD.lua` and
`saved/temp_binds.lua`. Anything else you edited (sets, keybinds, modes, custom
files) is only in the backup: copy it back yourself.

## 4. Put in your gear

Open `data/<Name>/<job>/sets/<job>_sets.lua`. It holds the author's gear; replace it
with yours.

- Item names must match the game exactly.
- Augmented items need their exact `augments = {...}` list.
- Two copies of the same ring, earring or weapon: just write the name on both
  sides. Each side keeps its own copy as long as the copies sit in different
  bags, and `//gs c wo` puts them there. `bag = 'wardrobe 2'` on a piece is no
  longer needed (still respected).

## 5. Load it in game

With GearSwap loaded (`//lua load gearswap`), log in or change job: GearSwap
loads `data/<Name>/<Name>_<JOB>.lua` for your current job by itself.

On load you get a `<JOB> SYSTEM LOADED` block in chat listing the job's keys,
the keybind HUD appears after a few seconds, the job's macro book is selected,
and 8 seconds after the load the lockstyle is applied.

Then check:

```
//gs c checksets     lists set items you do not have in inventory or wardrobes
//gs c ui            shows / hides the HUD
//gs c syscheck      health check of the loaded systems
```

## Lockstyle and DressUp

The lockstyle is sent as `/lockstyleset <number>`, using the number in
`<job>/display/<JOB>_LOCKSTYLE.lua`. DressUp is not needed. By default the
setup unloads DressUp just before `/lockstyleset` and loads it again 3 seconds
later. If you do not use DressUp,
turn that off once with `//gs c dressup` (the choice is kept, for every
character).

## Troubleshooting

**A job does not load, or chat shows a Lua error.** Check that the entry file
is `data/<Name>/<Name>_<JOB>.lua` with your exact in-game name, and that
`data/shared/` exists. `//lua reload gearswap` reloads everything.

**Keys do nothing.** A warning `<JOB> keybinds: ...` in chat at load names the
bad entry. `//gs c reload` reloads the job file. See
[keybinds](../guides/keybinds.md).

## Next

- [Quick start](quick-start.md)
- [Commands](../guides/commands.md)
- [Configuration](../guides/configuration.md)
