# Installation

This guide walks you through installing the Tetsouo GearSwap framework
end-to-end. It targets a fresh Windower 4 install. Allow ~5 minutes.

> Looking for a one-page overview? See the project [README](../../../README.md).

---

## 1. Prerequisites

| Requirement | Why |
| --- | --- |
| **Windower 4** | Required runtime. https://www.windower.net/ |
| **GearSwap addon** | Core dependency loaded with `//lua load gearswap` |
| **Python 3.8+** | Used by `clone_character.py` to generate your character files. |

Optional but recommended Windower addons:

- **DressUp** — needed for the lockstyle hot-swap feature (`//gs c lockstyle`)
- **ConsoleBG** / **InfoBar** — quality-of-life UI

---

## 2. Drop the framework into Windower

```bash
cd "<Windower>/addons/GearSwap/data/"
git clone https://github.com/Tetsouo/Gearswap.git temp
xcopy /E /Y temp\* .\
rmdir /S /Q temp
```

The end result should look like this:

```
<Windower>/addons/GearSwap/data/
├── _master/                Templates (entry, sets, config) + per-char overlays
├── shared/                 Core systems — never edit
│   ├── jobs/<job>/         12-module job structures
│   ├── utils/              9 mandatory systems + extras
│   ├── data/               Spell / ability / WS databases
│   └── hooks/              Auto-message handlers
├── docs/                   This documentation
├── clone_character.py      Smart character bootstrap
├── CLONE_CHARACTER.bat     Windows double-click launcher
└── README.md
```

If you already had a `GearSwap/data/` setup, **back it up first** — drop your
old `<Yourname>/` folder somewhere safe before running the copy.

---

## 3. Generate your character

You don't write entry files by hand. The generator reads the `_master/`
templates and produces a full per-character folder.

### Option A — Windows double-click

```
CLONE_CHARACTER.bat
```

### Option B — Command line

```bash
python clone_character.py
```

The script asks:

```
Enter character name: Bob
Select jobs (comma-separated, or 'all'): WAR,RDM,BLM
Role (main/alt): main

[OK] Generated Bob/Bob_WAR.lua
[OK] Generated Bob/Bob_RDM.lua
[OK] Generated Bob/Bob_BLM.lua
[OK] Copied 7 global configs
[OK] Wrote DUALBOX_CONFIG (role=main)
```

What it does:

- Copies the entry-points from `_master/entry/Tetsouo_<JOB>.lua` and renames
  them for your character.
- Copies set files from `_master/sets/<job>_sets.lua` (or pulls a Tetsouo
  overlay from `_master/Tetsouo/sets/` if you ran `--source Tetsouo`).
- Copies per-job configs from `_master/config/<job>/`.
- Writes `<Yourname>/config/DUALBOX_CONFIG.lua` for the role/partner.

> **Re-running the script** is safe — it skips files that already exist
> unless you pass `--force`.

### Option C — Manual copy (advanced)

If you don't want Python, you can copy by hand for a single job. Replace
`WAR` with the job you want.

1. `_master/entry/Tetsouo_WAR.lua` → `<Yourname>/<Yourname>_WAR.lua`
2. `_master/config/war/` → `<Yourname>/config/war/`
3. `_master/sets/war_sets.lua` → `<Yourname>/sets/war_sets.lua`
4. Edit step 1's file and replace every `Tetsouo` with `<Yourname>`.

---

## 4. Fill in your gear

Open `<Yourname>/sets/<job>_sets.lua` and replace the template item names
with **the items you actually own**. Things to know:

- Item names are **case-sensitive and exact**: `"Souveran Schaller +1"`,
  not `"souveran schaller +1"`.
- For augmented items, the `augments = {...}` table must match exactly,
  or GearSwap silently equips nothing.
- For multi-instance items (rings, neck), use `bag = 'wardrobe 2'` to
  pin a specific copy.
- The `_master/sets/` files are working baselines, not "ideal BiS" lists.
  Adjust freely.

After editing sets, validate them in-game with:

```
//gs c checksets
```

This reads every `sets.*` table and reports anything missing/in-storage.

---

## 5. Load and verify in-game

```
//lua load gearswap
//console gs load <Yourname>_WAR
```

Expected console output (specifics vary per job):

```
[WAR] System loaded
[WAR] Keybinds loaded successfully
[WAR] Macrobook set: Book 1, Page 1
[Watchdog] Initialized
[Lockstyle] queued (2.0s delay)
```

Quick sanity checks:

```
//gs c              # show keybind UI overlay
//gs c checksets    # validate all sets, list missing items
//gs c info         # framework version + loaded modules
```

---

## 6. Optional: install DressUp for lockstyle

```
//lua load dressup
//gs c lockstyle
```

The framework runs `lockstyle_manager` which throttles dress-up calls and
applies your per-job/per-subjob lockstyle from
`<Yourname>/config/<job>/<JOB>_LOCKSTYLE.lua`. If DressUp isn't loaded
the lockstyle command no-ops silently.

---

## Troubleshooting

### "module 'shared/...' not found"

`shared/` is missing or got corrupted on copy. Re-run the `xcopy` step;
verify `shared/utils/core/COMMON_COMMANDS.lua` exists.

### "attempt to index a nil value (global 'sets')"

Your entry-point can't find the set file. Two common causes:

1. The character name in the file (`<Yourname>` literal) doesn't match the
   character's in-game name. GearSwap is case-sensitive.
2. The set file path doesn't follow the convention
   `<Yourname>/sets/<job>_sets.lua`.

### Lockstyle silently does nothing

`//lua list` to confirm `dressup` is loaded. The framework logs nothing
when DressUp isn't present — this is intentional, since lockstyle is
optional.

### Keybinds not firing

`//lua reload gearswap`. If the issue persists, your job's
`<Yourname>/config/<job>/<JOB>_KEYBINDS.lua` is probably missing or has
a syntax error. Compare against the corresponding `_master/config/<job>/`
file.

---

## Next steps

- [Quick Start](quick-start.md) — first 5 minutes after install
- [Commands](../guides/commands.md) — full `//gs c …` reference
- [Configuration](../guides/configuration.md) — refill, wardrobe, dualbox
- [Keybinds](../guides/keybinds.md) — per-job shortcut reference

---

**14 jobs are fully implemented**: BLM, BRD, BST, COR, DNC, DRK, GEO, PLD,
RDM, RUN, SAM, THF, WAR, WHM. PUP exists as a 12-module scaffold but ships
a 20-line skeleton set file (`_master/sets/pup_sets.lua`) and is not an
actively-maintained job.
