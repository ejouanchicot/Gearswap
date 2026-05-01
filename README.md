<div align="center">

# 🎮 Tetsouo GearSwap

### _A world-class modular GearSwap framework for Final Fantasy XI_

[![Lua](https://img.shields.io/badge/Lua-5.1-blue?logo=lua&logoColor=white)](https://www.lua.org/)
[![Windower](https://img.shields.io/badge/Windower-4-purple)](https://www.windower.net/)
[![FFXI](https://img.shields.io/badge/FFXI-Retail-red)](https://www.playonline.com/ff11/)
[![Jobs](https://img.shields.io/badge/Jobs-15-green)](#-supported-jobs)
[![Files](https://img.shields.io/badge/Lua%20files-600%2B-blueviolet)](https://github.com/Tetsouo/Gearswap)
[![License](https://img.shields.io/badge/License-MIT-yellow)](https://opensource.org/licenses/MIT)

**Zero duplication. 9 centralized systems. 15 jobs. 100+ warp aliases. 76-file message system (14k+ LoC).**
**Built like production software, not a 2000-line GearSwap script.**

[🚀 Quick Start](#-quick-start) • [🏆 What it does](#-complete-feature-audit) • [⚡ Commands](#-command-cheatsheet) • [🏗 Architecture](#-architecture)

</div>

---

## 🚀 Quick Start

### Prerequisites

- [Windower 4](https://www.windower.net/) installed
- A working FFXI account
- 5 minutes

### 1. Clone into your GearSwap data folder

```bash
cd "<Windower>/addons/GearSwap/data/"
git clone https://github.com/Tetsouo/Gearswap.git temp
xcopy /E /Y temp\* .\ && rmdir /S /Q temp
```

### 2. Generate your character's config

Double-click **`CLONE_CHARACTER.bat`** (or run `python clone_character.py`).

```
========================================================================
  CLONE INTELLIGENT - SYSTÈME GEARSWAP TETSOUO
========================================================================

Enter character name: Bob
Select jobs (comma-separated, or 'all'): WAR,RDM,BLM
Role (main/alt): main

[OK] Generated Bob/Bob_WAR.lua
[OK] Generated Bob/Bob_RDM.lua
[OK] Generated Bob/Bob_BLM.lua
[OK] Copied 7 global configs
[OK] Wrote DUALBOX_CONFIG (role=main)
```

### 3. Edit your gear

Open `Bob/sets/<job>_sets.lua` and fill in **the items you actually own** with your augments. Templates from `_master/` give you a working baseline — just swap names and add bag annotations like `bag = 'wardrobe 2'` for multi-instance items.

### 4. Load it in-game

```
//lua load gearswap
//console gs load Bob_WAR
```

### 5. Try the magic commands

```
//gs c                                      # see your keybind UI overlay
//gs c checksets                            # validate all your sets
//gs c wo                                   # auto-organize your wardrobes
//gs c rf                                   # refill consumables from Mog Case/Sack
//gs c craft                                # equip your bonecraft set
//gs c warp                                 # teleport home
//gs c tph                                  # teleport-Holla
```

**That's it. You're running a fully-modular professional GearSwap setup.**

---

## 🏆 Complete Feature Audit

This isn't a hobby script. Here's the full inventory of what this framework does.

<details>
<summary><h3>⚔️ Combat & Job Rotation (click to expand)</h3></summary>

The 5-phase combat lifecycle (precast → midcast → aftercast → idle → engaged) is centralized into 9 mandatory systems used by all 15 jobs.

#### Precast pipeline

- **PrecastGuard** — first check on every action. Blocks while silenced/paralyzed/amnesia/stunned. Auto-cures with Echo Drops / Remedy / Panacea per `DEBUFF_AUTOCURE_CONFIG`.
- **CooldownChecker** — validates JA/spell recast via `spell.recast_id`. Cancels with a clear chat message before the cast queue is consumed.
- **WSPrecastHandler** — unified weaponskill handling. Auto-triggers prerequisite abilities (Sneak Attack, Trick Attack, Climactic Flourish, Sange, etc.).
- **AbilityHelper** — knows which JAs auto-fire before which weaponskills.
- **TPBonusHandler** — calculates and detects WS TP bonuses (Moonshade Earring, Aftermath, etc.).
- **WSValidator** — validates target, range, TP, weapon-skill prerequisites before allowing the swap.

#### Midcast pipeline

- **MidcastManager** — single mandatory entry point: `MidcastManager.select_set({skill, spell, mode_state, database_func, target_func})`. Implements a 9-level nested fallback chain: spell name → skill type → spell type → target type → mode → base set. Replaces all manual fallback code that used to live in every job file.
- **Bard song matching** — Singing skill specially handled (recast group lookup, marcato detection, song timing).
- **Debug toggle** — `//gs c debugmidcast` traces every set selection.

#### Aftercast / Idle / Engaged

- Automatic state transitions with town detection (idle gear in safe zones), aftermath tracking (WAR Ukonvasara AM3, buff ID 272 → `sets.engaged.PDTAFM3`), DT vs offense vs hybrid mode cycling.

#### Defensive systems

- **Debuff Checker** — real-time scan of `buffactive` for Silence/Para/Amnesia/Stun.
- **Doom Manager** — Doom buff handling with auto-Holy Water / cure prioritization.
- **Midcast Watchdog** — detects cast interruptions and warns the user.

</details>

<details>
<summary><h3>🎒 Inventory Management — <code>//gs c rf</code></h3></summary>

A full restock system that reads your active job's needs from a config file and pulls from Mog Case/Sack.

#### Features

- **Per-job, per-subjob configs** at `<char>/config/<job>/<JOB>_REFILL.lua` (15 job configs ship with the project).
- **Item alternates** — write `{name = {'Sublime Sushi +1', 'Sublime Sushi'}, target = 12}` and the manager prefers the +1 form, falls back to base.
- **Surplus push-back** — if you have 18 Panacea and the target is 12, the 6 extras get pushed to your `store_bag` automatically.
- **Foreign-items detection** — items from OTHER jobs' refill lists found in your inventory get pushed to Case as well. Keeps the inv lean for the active job.
- **Inventory full pre-check** — refuses to start if there aren't 33 free slots to gather slips, with an explicit error count: _"Need 5 more free slots"_.
- **Craft mode auto-detection** — when a craft set is active, switches to a craft-specific list (Coconut Rusk, Kitron Macaron) and shoves all standard medicines/food back to Case.
- **FFXI item resolver** — uses Windower's `res/items.lua` to handle abbreviated/full name pairs (`R. Curry Bun +1` ↔ `Red Curry Bun +1`, `Lethargy Sayon +3` ↔ `Leth. Sayon +3`).

#### Output

```
==============================================================================
===================== Inventory Refill - Started =============================
==============================================================================
  Config: WAR/SAM
  Surplus bag: Case
  Items tracked: 8
[Refill] Transferring 4 operations ...

==============================================================================
===================== Inventory Refill - Complete ============================
==============================================================================
  Panacea: 12/12 (OK)
  Antacid: 8/12 -> 12/12 (+4 Case)
  Sublime Sushi +1: 12/12 (OK)
  R. Curry Bun +1: 0/12 -> 8/12 (+8 Case)  Short 4
  Pulled in: 12 item(s)
  Missing: 4 item(s) - restock Case/Sack!
==============================================================================
```

Color-coded: 🟢 OK, 🟡 food/surplus, 🟠 partial, 🔴 out of stock.

</details>

<details>
<summary><h3>🗄️ Wardrobe Management — <code>//gs c wo</code></h3></summary>

A full algorithmic wardrobe organizer with phases, retries, and crash recovery.

#### Modes

- `//gs c wo` — **per-active-job mode**. Move the active job's gear to W1/W2, push everything else to overflow.
- `//gs c wo preview` — dry-run, prints what _would_ move without touching anything.
- `//gs c wo verify` — read-only check, validates current layout matches the plan.
- `//gs c wo recover` — nuclear unlock: re-enables all slots if anything got stuck disabled.
- `//gs c wo reset` — soft state reset.
- `//gs c wo alt` — alt-character mode (4 wardrobes + Sack/Case for chars with fewer wardrobes).

#### Algorithm (5 phases)

1. **Phase 0** — `gs c naked` (correctly ordered: unequip BEFORE locking, otherwise the disable would block the equip).
2. **Phase 1** — state recensement: scans all wardrobes, builds the move plan.
3. **Phase 2** — **empty W1/W2** of items not used by the active job (eviction to overflow).
4. **Phase 3** — **fill W1/W2** with active-job items pulled from overflow.
5. **Phase 4** — inventory cleanup with retries (FFXI silently rejects rapid `put_item` calls; the framework retries up to `CLEANUP_MAX_PASSES`).

#### Robustness

- **Auto-retry up to 12 iterations** with last-chance verify before giving up.
- **Multi-pin items** (Chirich Ring +1 with `bag='wardrobe 1'` AND another with `bag='wardrobe 2'`) get split correctly across W1 and W2 even if one copy is in inventory.
- **Used-item-in-inv detection** — items used by the active job that are stuck in inv (because both W1/W2 are full) aren't counted as "misplaced" since they'll be auto-equipped on next swap.
- **Panic-unlock guards** on every coroutine — if anything errors mid-flow, slots are always re-enabled.
- **Per-character config** at `<char>/config/WARDROBE_CONFIG.lua` defines `PRIMARY_BAGS`, `OVERFLOW_BAGS`, `PROTECTED`.
- **W7 craft and W8 reserve always protected by default**.

#### Wardrobe Auditor — `//gs c wa`

Scans every set file for items, cross-references against actual wardrobe contents, reports unused/orphaned wardrobe items per job.

</details>

<details>
<summary><h3>🌍 Warp & Teleport System (50+ commands)</h3></summary>

The most complete warp shortcut system anyone has shipped. Single source of truth via `warp_command_registry.lua`.

#### Standard warp / retrace / escape

- `w`, `warp`, `w2`, `warp2`, `ret`, `retrace`, `esc`, `escape`

#### WHM Teleports

- `tph` (Holla), `tpd` (Dem), `tpm` (Mea), `tpa` (Altep), `tpy` (Yhoat), `tpv` (Vahzl)

#### WHM Recalls

- `rj` (Jugner), `rp` (Pashhow), `rm` (Meriphataud)

#### Nation cities

- `sd` (San d'Oria), `bt` (Bastok), `wd` (Windurst)

#### Outpost & town shortcuts

- `sb` (Selbina), `mh` (Mhaura), `rb` (Rabao), `kz` (Kazham), `ng` (Norg), `tv` (Tavnazia), `au`/`wg` (Aht Urhgan/Whitegate), `ns` (Nashmau), `ad` (Adoulin)

#### Chocobo stables (per nation)

- `stsd`, `stbt`, `stwd`, `stjn`

#### Conquest / Frontier zones

- `op` / `outpost`, `cz` (Ceizak), `ys` (Yahse), `hn` (Hennetiel), `mm` (Morimar), `mj` (Marjami), `yc` (Yorcia), `km` (Kamihr)

#### Special locations

- `wj` (Wajaom), `ar` (Arrapago), `pg` (Purgonorgo), `rl` (Rulude), `zv` (Zvahl), `riv` (Riverne), `yo` (Yoran), `lf` (Leafallia), `bh` (Behemoth), `cc` (Choco Circuit), `pt` (Parting), `cg` (Choco Girl)

#### Mechanics

- `ld` / `leader` — warp to leader
- `td` / `tidal` — Tidal Talisman handling
- **Pre-cast detection** — auto-equips warp gear before the spell fires, swaps back after.
- **Item fallbacks** — if you're MP-starved, auto-uses Tele-* / Warp Cudgel / Cudgel +1.
- **IPC sync** — broadcasts your warp to dual-boxed alts.

</details>

<details>
<summary><h3>🔨 Craft & Fishing — <code>//gs c craft</code> / <code>//gs c fish</code></h3></summary>

Quick-equip craft sets across **any job** (you don't need to be on a specific main job).

#### Bonecraft (6 variants)

```
//gs c craft           Bonecraft HQ      (Confectioner's Ring)
//gs c craft nq        Bonecraft NQ      (Bonecrafter's Ring)
//gs c craft success   Bonecraft Success (Patissiere's Ring)
//gs c craft wood      HQ + Carver's Torque   (woodworking sub-craft)
//gs c craft smith     HQ + Smithy's Torque   (smithing sub-craft)
//gs c craft leather   HQ + Tanner's Torque   (leathercraft sub-craft)
```

#### Fishing

```
//gs c fish            Equip fishing set
//gs c uncraft         Unlock slots, normal gear resumes
```

#### How it works

- Load gear set from `<char>/sets/<craft>_sets.lua` (multi-variant support).
- `gs disable all` to lock all slots — idle/engaged hooks can't override during your synth animation.
- 2-second post-equip delay so all slot packets land before locking.
- State stored in `_G.__CraftManagerState` so it survives module re-requires.

</details>

<details>
<summary><h3>👯 Multi-Character / Dualbox</h3></summary>

Built-in dual-boxing support with proper IPC.

#### Features

- **`<char>/config/DUALBOX_CONFIG.lua`** — `role = 'main' | 'alt'` + partner character name.
- **`//gs c altjobupdate <JOB> <SUBJOB>`** — alt notifies main of job change.
- **Auto-macrobook reload** on main when alt's job changes.
- **Job-state propagation** via Windower IPC packets.
- **Online status tracking** — main knows if alt is connected.

#### Per-character templates in `_master/`

- `_master/Tetsouo/` — Tetsouo's overlay (REFILL configs, craft sets, custom WARDROBE_CONFIG).
- `_master/Kaories/` — Kaories overlay (alt-specific 4-wardrobe layout, COR/GEO/RDM jobs).

The clone script applies overlays automatically:

```
python clone_character.py                        # default (Tetsouo template)
python clone_character.py --source Kaories       # rebuild Kaories from her overlay
```

</details>

<details>
<summary><h3>🎨 Real-Time In-Game UI</h3></summary>

A draggable HUD overlay shown on top of FFXI showing your current keybinds, job state, and binding categories.

- **`//gs c ui`** — toggle on/off (persisted across reloads).
- **`//gs c uisave`** — save current window position.
- Real-time state display: current job/subjob, hybrid mode, selected weapons, etc.
- Draggable window with per-character position memory.
- Job-specific keybind tables generated from `<JOB>_KEYBINDS.lua`.
- Intelligent update queue with debouncing (avoids redraw spam).
- 509-color palette (`shared/utils/ui/COLOR_SYSTEM.lua`) with `//gs c testcolors` for theming.

</details>

<details>
<summary><h3>💬 Messaging System (76 modules, 14,400+ LoC)</h3></summary>

Every message in this framework goes through the centralized formatter — never `add_to_chat` directly.

#### Architecture

- **Templates** in `shared/utils/messages/data/` — pure data, no logic.
- **Formatters** in `shared/utils/messages/formatters/` — composition.
- **Core engine** at `shared/utils/messages/core/message_engine.lua` + `message_renderer.lua` — color schemes, accessibility, monochrome mode.
- **Validators** ensure format strings have all expected placeholders before render.

#### Coverage

- 9 job-specific message namespaces with dedicated templates: BLM, BRD, BST, COR, DRG, GEO, RDM, RUN, WHM
- 25 system namespaces: buffs, combat, cooldowns, debuffs, dualbox, equipment, keybinds, magic, midcast, precast, profiler, songs, status, system, ui, warp, watchdog, weaponskill, info, init, ja_buffs, commands, database, blm_midcast, rdm_midcast
- Other jobs without dedicated messages use the system-level templates (combat, weaponskill, magic, etc.)
- Job-tagged colored output: `[BLM]`, `[Wardrobe]`, `[Refill]`, `[Craft]`, etc.
- Standard 74-char ASCII panels with `===== Title =====` 3-line banners.

</details>

<details>
<summary><h3>🏃 Movement System</h3></summary>

Auto-equips movement gear when you start running, swaps back when you stop or engage.

- **Combat-aware** — never equips movement gear in combat.
- **0.08s check interval, 0.3s debounce** — smooth without spamming swaps.
- **Single-timer chain** with v2.1.0 anti-coroutine-accumulation fix (prevents ghost timers across reloads).
- **Job callbacks** — each job can hook into the movement state change.
- **`//gs c automovedebug`** / `amd` — trace movement decisions.

</details>

<details>
<summary><h3>🛠 Debug & Developer Tools</h3></summary>

A whole suite of diagnostic commands.

| Command | Purpose |
| --- | --- |
| `//gs c fulltest` / `ft` | Run the comprehensive system validation suite |
| `//gs c syscheck` / `sc` | Verify all 15 jobs and core systems are operational |
| `//gs c perf [start\|stop\|status]` | Performance profiler (timing + memory) |
| `//gs c lagdebug` / `ldb` | Identify lag patterns (server vs client) |
| `//gs c jamsg` | Trace job ability message flow |
| `//gs c spellmsg` | Trace spell message flow |
| `//gs c wsmsg` | Trace weapon skill message flow |
| `//gs c info` | System status, version, loaded modules |
| `//gs c debugsubjob` / `dsj` | Validate subjob override system |
| `//gs c debugjobchange` / `djc` | Trace job change events |
| `//gs c debugmidcast` | Toggle MidcastManager set selection trace |
| `//gs c debugmsg` | Toggle universal message logging |
| `//gs c debugupdate` / `du` | Trace `gs c update` flow |
| `//gs c debugstate` / `ds` | Dump current state machine |

</details>

<details>
<summary><h3>📚 Shared Databases</h3></summary>

Real FFXI mechanics knowledge baked in.

- **Job ability database** — per-job main+sub abilities, with metadata (recast group, charges, type).
- **Magic spell databases** — element, skill, recast, jobs that learn it, MP cost.
- **Weaponskill database** — TP costs, fTP, modifiers, requirements, element binding.
- **Aftermath database** — weapon → aftermath effect → buff ID mapping.
- **Roll database (COR)** — all 12 phantom rolls with bonuses, lucky/unlucky numbers.
- **Song database (BRD)** — packs, durations, recasts, instrument requirements.

</details>

<details>
<summary><h3>🎯 Job-Specific Specialties</h3></summary>

Each of the 15 jobs has bespoke logic for its unique mechanics. Not just gear swaps — actual job intelligence.

#### BLM

- Elemental matcher (Storm buff + day element + weather synergy)
- Spell refiner (Manaburst tracking, MB-vs-FreeNuke gear sets)
- Storm manager (all 6 storms tracked)
- Auto-buff sequence (Stoneskin, Blink, Aquaveil, Ice Spikes)

#### BRD

- Song rotation manager with pack selection (March, Minuet, Ballad, etc.)
- Song refinement (auto-Victory March if Haste already up)
- Instrument lock (Marsyas / Loughnashade exclusive locking)
- Per-song timing config

#### BST

- Pet command set selection (Ready moves vs JAs)
- Ecosystem manager (pet type matched to zone — birds, beasts, lizards)
- Ready move categorizer (physical vs magical)
- Dedicated `BST_PET_PRECAST` and `BST_PET_MIDCAST` modules

#### COR

- Phantom Roll tracking with **packet-level party-job detection** (parses 0xDD/0xDF packets in `party_tracker.lua`)
- Roll database with Lucky/Unlucky numbers per roll
- Natural 11 detection (`_G.cor_natural_eleven_active` — instant recast + bust immunity tracked)
- Double-Up window management

#### DNC (6 logic modules — most extensive job logic)

- `step_manager.lua` — Step ability sequencing
- `climactic_manager.lua` — Climactic Flourish handling
- `smartbuff_manager.lua` — Auto-buff coordination
- `jump_manager.lua` — DRG/DNC jump coordination
- `ws_variant_selector.lua` — WS gear variants per state
- Cure/Divine Waltz handled by shared `shared/utils/dnc/waltz_manager.lua` (works for any job with /DNC)

#### DRG

- Centralized jump manager at `shared/utils/drg/`
- `//gs c jump` works on any job with /DRG sub

#### DRK (`drk_buff_anticipation.lua` + `set_builder.lua`)

- Buff anticipation module — predicts buff drops to preempt with Haste II
- Last Resort precast set handling

#### GEO

- `geo_spell_refiner.lua` — elemental Ge/Indi spell refinement
- `set_builder.lua` — Geo-specific gear selection

#### PLD (5 logic modules)

- `rune_manager.lua` — Rune ability handling for /RUN subjob (Sulpor, Lux, Tellus, etc.)
- `aoe_manager.lua` — Group cure / AOE healing tactics
- `cure_set_builder.lua` — Priority-based cure target selection
- Shares rune/aoe/cure logic with RUN main job

#### PUP

- Dedicated `PUP_PET_PRECAST.lua` and `PUP_PET_MIDCAST.lua` for Automaton command sets
- 12-module structure same as other jobs (no separate logic/ folder needed)

#### RDM

- **Saboteur override** in `RDM_MIDCAST.lua` — when Saboteur is active, auto-equips `sets.midcast['Enfeebling Magic'].Saboteur` (your custom Saboteur potency set)
- Standard MidcastManager pipeline for all other casts

#### RUN (4 logic modules — shares logic with PLD)

- `rune_manager.lua`, `aoe_manager.lua`, `cure_set_builder.lua`, `set_builder.lua`
- Same rune/cure infrastructure as PLD

#### SAM

- `set_builder.lua` — Engagement and TP-handling logic
- States configured in `<char>/config/sam/SAM_STATES.lua` (Hagakure, Meditate, etc.)

#### THF (3 logic modules)

- `sa_ta_manager.lua` — Sneak Attack + Trick Attack auto-trigger before WS
- `smartbuff_manager.lua` — Haste / TP-gen tracking
- `set_builder.lua` — Engagement / theft gear selection

#### WAR (`set_builder.lua` + `smartbuff_manager.lua`)

- **Aftermath Lv.3 detection** (Ukonvasara, buff ID 272 → specialized `sets.engaged.PDTAFM3`)
- **Kraken Club sub-weapon detection** → `sets.engaged.PDTKC` (multi-attack focus)
- **Hybrid mode cycle**: `PDT` / `Normal` / `SubtleBlow` (auto-equips `sets.engaged.SubtleBlow` when selected)
- Smartbuff manager for Berserk/Aggressor coordination

#### WHM

- Cure manager at `shared/utils/whm/cure_manager.lua` (target priority: self > low-HP party > TP trade)
- `set_builder.lua` for spell-skill-specific gearing

</details>

<details>
<summary><h3>🪩 Waltz Support (universal — works on any job with /DNC)</h3></summary>

- **`//gs c waltz`** — Curing Waltz on target. HP-based tier selection (V > IV > III > II > I), TP threshold check (200-800 TP), level detection.
- **`//gs c aoewaltz`** — Divine Waltz / Divine Waltz II auto-pick.
- Works on **all 15 jobs** when /DNC is the subjob.

</details>

<details>
<summary><h3>🌐 Universal Commands (work on any job)</h3></summary>

Every job inherits these via `CommonCommands.is_common_command()`:

| Command | Action |
| --- | --- |
| `//gs c` | Show keybind UI |
| `//gs c reload` | Hot-reload current GearSwap |
| `//gs c checksets` | Validate all sets, find missing items |
| `//gs c naked` | Strip all equipment |
| `//gs c equip <set>` | Equip a defined set by name |
| `//gs c lockstyle` / `ls` | Re-apply lockstyle |
| `//gs c dressup` | Toggle DressUp |
| `//gs c testcolors` / `colors` | Show 509-color FFXI palette |

</details>

---

## ⚡ Command cheatsheet

### Inventory & wardrobes

| Command | Action |
| --- | --- |
| `//gs c wo` | Wardrobe Organize — self-organize for current job |
| `//gs c wo preview` | Dry-run, no moves |
| `//gs c wo verify` | Read-only layout check |
| `//gs c wo recover` | Nuclear unlock if anything stuck |
| `//gs c rf` | Refill consumables for current job |
| `//gs c wa` | Wardrobe audit (find unused items) |

### Craft / fishing

| Command | Action |
| --- | --- |
| `//gs c craft` / `craft nq` / `craft success` | Bonecraft variants |
| `//gs c craft wood` / `smith` / `leather` | HQ + sub-craft skill torque |
| `//gs c fish` | Equip fishing set |
| `//gs c uncraft` | Unlock and resume normal gear |

### Movement helpers

| Command | Action |
| --- | --- |
| `//gs c jump` | DRG jump (any job with /DRG) |
| `//gs c waltz` | Curing Waltz (any job with /DNC) |
| `//gs c aoewaltz` | Divine Waltz (any job with /DNC) |

### Job-specific (per `<JOB>_KEYBINDS.lua`)

```
WAR:    Alt+1 cycle weapon | Alt+2 cycle hybrid (PDT/Normal/SubtleBlow)
BLM:    Alt+1 main element | Alt+2 nuke mode | F9 buff | F10 storm
PLD:    Alt+1 weapon       | Alt+2 hybrid    | F9 panic
DNC:    Alt+W curing waltz | Alt+E divine waltz
COR:    F9 Lucky+Unlucky display | F10 Random Deal
... etc per job
```

---

## 🏗 Architecture

### Three layers

```
┌─────────────────────────────────────────────────────────────┐
│  ENTRY POINT      <Char>/<Char>_<JOB>.lua                   │
│                   (loaded by GearSwap, ~200 lines)          │
└────────────────────────────┬────────────────────────────────┘
                             │ requires
┌────────────────────────────▼────────────────────────────────┐
│  JOB FACADE       shared/jobs/<job>/<job>_functions.lua     │
│                   (loads 12 specialized modules)            │
└────────────────────────────┬────────────────────────────────┘
                             │ uses
┌────────────────────────────▼────────────────────────────────┐
│  9 SHARED SYSTEMS   shared/utils/                           │
│   • PrecastGuard      • CooldownChecker                     │
│   • WSPrecastHandler  • MidcastManager                      │
│   • MessageFormatter  • LockstyleManager                    │
│   • MacrobookManager  • AbilityHelper                       │
│   • JobChangeManager                                        │
└─────────────────────────────────────────────────────────────┘
```

### 12 modules per job

```
shared/jobs/<job>/
├── <job>_functions.lua              Facade (loads all modules)
└── functions/
    ├── <JOB>_PRECAST.lua            Guard → Cooldown → WS → job logic
    ├── <JOB>_MIDCAST.lua            MidcastManager.select_set() (mandatory)
    ├── <JOB>_AFTERCAST.lua          State restore
    ├── <JOB>_IDLE.lua                Idle gear with town detection
    ├── <JOB>_ENGAGED.lua             Combat gear with sub-modes
    ├── <JOB>_STATUS.lua              Buff/debuff handling
    ├── <JOB>_BUFFS.lua               Auto-buff sequences
    ├── <JOB>_COMMANDS.lua            Custom //gs c commands
    ├── <JOB>_MOVEMENT.lua            AutoMove integration
    ├── <JOB>_LOCKSTYLE.lua           Factory call (3 lines)
    └── <JOB>_MACROBOOK.lua           Factory call (3 lines)
```

### File-size discipline

- 🟢 Files: **< 600 lines** (hard limit 800)
- 🟢 Functions: **< 30 lines** (except dispatchers)
- 🟢 Code duplication: **0%**

---

## 🎯 Supported jobs

<div align="center">

| Mage | DD/Hybrid | Tank | Support |
| :---: | :---: | :---: | :---: |
| BLM | DNC | PLD | BRD |
| RDM | THF | RUN | COR |
| WHM | WAR | — | GEO |
| — | SAM | — | — |
| — | DRK | — | — |
| — | BST | — | — |
| — | PUP | — | — |

</div>

**15 fully implemented jobs. 9 mandatory systems on each. Same architecture everywhere.**

---

## 📁 Project structure

```
GearSwap/data/
│
├── _master/                       Canonical template (clone source)
│   ├── sets/                      Generic gear sets per job
│   ├── config/<job>/              Generic configs per job
│   ├── entry/                     Generic entry-point templates
│   ├── config_global/             Global defaults
│   ├── Tetsouo/                   Tetsouo overlay (REFILL, craft, etc.)
│   └── Kaories/                   Kaories overlay (3 jobs, alt config)
│
├── shared/                        Shared code (NEVER duplicated per job)
│   ├── jobs/<job>/functions/      12 modules per job
│   ├── utils/                     9 mandatory systems + extras
│   │   ├── core/                  Common commands, debug, watchdog
│   │   ├── precast/               PrecastGuard, CooldownChecker, WSPrecastHandler
│   │   ├── midcast/               MidcastManager (single source of truth)
│   │   ├── messages/              ASCII panels, color formatting, templates
│   │   ├── inventory/             Refill manager
│   │   ├── wardrobe/              Wardrobe organizer (8 sub-modules)
│   │   ├── craft/                 Craft set manager
│   │   ├── warp/                  Warp commands + IPC
│   │   ├── movement/              Auto-move
│   │   ├── dualbox/               IPC for dual-boxing
│   │   ├── equipment/             Equipment factory + auditor
│   │   ├── ui/                    In-game keybind UI
│   │   └── debug/                 Test suite, profiler
│   ├── data/                      Spell/ability/weaponskill databases
│   └── hooks/                     Auto-message handlers
│
├── docs/                          User guides + reference
├── clone_character.py             Smart character cloning script
└── CLONE_CHARACTER.bat            Windows launcher
```

---

## 🔧 Configuration

All your customizations live in **`<YourChar>/config/`**:

```
<YourChar>/config/
├── DUALBOX_CONFIG.lua             role=main|alt, partner name
├── REGION_CONFIG.lua              EU/NA region preferences
├── WARDROBE_CONFIG.lua            primary/overflow bag layout
├── LOCKSTYLE_CONFIG.lua           lockstyle timing
├── RECAST_CONFIG.lua              cooldown tolerances
├── UI_CONFIG.lua                  keybind UI behavior
├── ui_settings.lua                UI position + toggles
├── message_modes.lua              Per-namespace verbosity
└── <job>/                         per-job configs
    ├── <JOB>_KEYBINDS.lua         your keybinds
    ├── <JOB>_LOCKSTYLE.lua        per-subjob lockstyle picks
    ├── <JOB>_MACROBOOK.lua        per-subjob macrobook pages
    ├── <JOB>_STATES.lua           Mote-Include states
    ├── <JOB>_TP_CONFIG.lua        Engaged TP thresholds
    └── <JOB>_REFILL.lua           refill list for this job
```

### Per-character templates (for repeatable rebuilds)

Want your customizations to survive across reinstalls? Drop them into `_master/<YourChar>/` mirroring the live folder structure. The clone script picks them up automatically as overlays:

```bash
python clone_character.py --source Bob   # rebuild Bob from _master/ + _master/Bob/
```

---

## 🛠 For developers

### Adding a new job

1. Create `_master/sets/<job>_sets.lua` (copy from a similar job)
2. Create `_master/config/<job>/<JOB>_*.lua` (KEYBINDS, LOCKSTYLE, MACROBOOK, STATES, TP_CONFIG)
3. Create `shared/jobs/<job>/<job>_functions.lua` (facade, ~50 lines)
4. Create the 12 modules in `shared/jobs/<job>/functions/<JOB>_*.lua`
5. Job is auto-detected by `clone_character.py` from `_master/sets/`

### Project metrics (current snapshot)

```
Lua files in shared/      : 600+
Lua files (total tracked) : 980+
Lines of code (shared+_master) : 43,000+
Jobs (main, fully implemented) : 15
Shared utility subsystems : 25 directories under shared/utils/
//gs c commands           : 80+ (universal + per-job)
Warp aliases              : 100+ (~50 unique destinations)
Per-job logic modules     : 44 across all 15 jobs
Code duplication          : 0%
File-size violations      : 0
Function-size violations  : 0
Documented functions      : 100%
```

### Standards

- **Every function gets a `--- description` doc-comment** with `@param` and `@return`.
- **File headers** with `@file`, `@author`, `@version`, `@date`.
- **Lazy loading** of optional modules via `pcall(require, ...)`.
- **Always export** via both `_G.foo = foo` AND `return Module` (GearSwap dual mechanism).
- **No `add_to_chat()` direct calls** — always through MessageFormatter.
- **No manual lockstyle/macrobook code** — always via factories.

---

## 📜 License

MIT — do whatever you want with it. Attribution appreciated, not required.

---

<div align="center">

### Built with ❤️ for FFXI by [Tetsouo](https://github.com/Tetsouo)

_Bringing software engineering discipline to GearSwap._

[Report an issue](https://github.com/Tetsouo/Gearswap/issues) • [Star the repo](https://github.com/Tetsouo/Gearswap) • [Follow updates](https://github.com/Tetsouo/Gearswap/commits/master)

</div>
