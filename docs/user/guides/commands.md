# Commands reference

All commands use the format `//gs c <command> [args...]`.

This is the **complete, verified** command list as of v3.2.0. Every entry
below is wired in either:

- `shared/utils/core/COMMON_COMMANDS.lua` (universal)
- `shared/utils/ui/UI_COMMANDS.lua` (`ui` family)
- `shared/utils/warp/warp_commands.lua` (warp family)
- `shared/jobs/<job>/functions/<JOB>_COMMANDS.lua` (per-job)

If you add a command to one of those files, document it here.

---

## Quick reference

```
//gs c                    Toggle the keybind UI overlay
//gs c reload             Hot-reload current GearSwap
//gs c checksets          Validate every set, report MISSING / STORAGE
//gs c naked              Strip all equipment
//gs c info               Framework version, loaded modules, watchdog state
//gs c help / ?           Built-in help
//gs c commands / cmds    Print all commands in-game
```

---

## System

| Command | Alias | Description |
| --- | --- | --- |
| `reload` | — | Full system reload |
| `checksets` | — | Validate equipment sets — reports OK / STORAGE / MISSING per item |
| `equip naked` / `naked` | — | Strip all equipment |
| `equip <set>` | — | Equip a defined set by name |
| `lockstyle` | `ls` | Re-apply lockstyle (DressUp must be loaded) |
| `dressup` | — | Toggle DressUp addon management |
| `info` | — | System status, version, loaded modules |

## Inventory & wardrobe

| Command | Alias | Description |
| --- | --- | --- |
| `refill` | `rf` | Pull consumables for the current job/subjob from `<JOB>_REFILL.lua` |
| `worganize` | `wo` | Wardrobe organize for the current job |
| `worganize preview` | `wo preview` | Dry-run wardrobe organize |
| `worganize verify` | `wo verify` | Read-only layout check |
| `worganize recover` | `wo recover` | Re-enable every slot if anything got stuck disabled |
| `worganize reset` | `wo reset` | Soft state reset |
| `worganize alt` | `wo alt` | Alt-character mode (4 wardrobes + Sack/Case) |
| `wardrobeaudit` | `wa` | Find unused wardrobe items per job — exports report to `wardrobe_audit.txt` |

## Craft & fishing

| Command | Description |
| --- | --- |
| `craft` | Bonecraft HQ (default variant from `<char>/sets/bonecraft_sets.lua`) |
| `craft nq` | Bonecraft NQ guarantee |
| `craft success` | Bonecraft success rate |
| `craft wood` | HQ + Carver's Torque (woodworking sub-craft) |
| `craft smith` | HQ + Smithy's Torque (smithing sub-craft) |
| `craft leather` | HQ + Tanner's Torque (leathercraft sub-craft) |
| `fish` / `fishing` | Equip the fishing set |
| `uncraft` | Unlock slots, normal gear resumes |

## Cross-job utility

| Command | Subjob | Description |
| --- | --- | --- |
| `waltz` | /DNC | Curing Waltz on target — auto-selects tier V→I from missing HP and TP |
| `aoewaltz` | /DNC | Divine Waltz / Divine Waltz II auto-pick |
| `jump` | /DRG | DRG jump |

## State cycling

Mote-Include states. Each job exposes only the cycles defined in its
`<JOB>_STATES.lua`.

| Command | Description |
| --- | --- |
| `cycle <StateName>` | Cycle a multi-value state forward |
| `cycleback <StateName>` | Cycle backward |
| `set <StateName> <Value>` | Force a specific value |
| `reset <StateName>` | Reset to default |
| `toggle <StateName>` | Toggle a boolean state |
| `update` | Force a gear refresh |

Common state names: `MainWeapon`, `SubWeaponOverride`, `HybridMode`,
`OffenseMode`, `CastingMode`, `IdleMode`, `EnfeebleMode`, `EnhancingMode`,
`NukeMode`, `CureMode`, `MainStep`, `AltStep`, `RuneMode`, `BubbleMode`.

---

## UI overlay

| Command | Alias | Description |
| --- | --- | --- |
| `ui` | — | Toggle visibility |
| `ui on` / `ui off` | `ui enable` / `ui disable` | Show / hide (persists across reload) |
| `ui header` | `ui h` | Toggle header section |
| `ui legend` | `ui l` | Toggle legend section |
| `ui columns` | `ui c` | Toggle column headers |
| `ui footer` | `ui f` | Toggle footer section |
| `ui font <name>` | — | `Consolas` or `Courier New` |
| `ui bg <preset>` | `ui background`, `ui theme` | Apply a background preset |
| `ui bg toggle` | — | Toggle background visibility |
| `ui bg list` | — | List available presets |
| `ui bg <r> <g> <b> <a>` | — | Custom RGBA (0-255 each) |
| `ui save` | `ui s` | Save current position + settings |

---

## Warp & teleport

`//gs c warp [destination]` and 100+ aliases. Equips the right
spell/item, casts/uses it, restores your gear after.

| Family | Examples |
| --- | --- |
| Warp / Retrace / Escape | `w`, `warp`, `w2`, `warp2`, `ret`, `retrace`, `esc`, `escape` |
| WHM Teleports | `tph` (Holla), `tpd` (Dem), `tpm` (Mea), `tpa` (Altep), `tpy` (Yhoat), `tpv` (Vahzl) |
| WHM Recalls | `rj` (Jugner), `rp` (Pashhow), `rm` (Meriphataud) |
| Nation cities | `sd` (San d'Oria), `bt` (Bastok), `wd` (Windurst) |
| Outpost / town | `sb` (Selbina), `mh` (Mhaura), `rb` (Rabao), `kz` (Kazham), `ng` (Norg), `tv` (Tavnazia), `au`/`wg` (Aht Urhgan/Whitegate), `ns` (Nashmau), `ad` (Adoulin) |
| Chocobo stables | `stsd`, `stbt`, `stwd`, `stjn` |
| Frontier zones | `op`/`outpost`, `cz` (Ceizak), `ys` (Yahse), `hn` (Hennetiel), `mm` (Morimar), `mj` (Marjami), `yc` (Yorcia), `km` (Kamihr) |
| Special | `wj` (Wajaom), `ar` (Arrapago), `pg` (Purgonorgo), `rl` (Rulude), `zv` (Zvahl), `riv` (Riverne), `yo` (Yoran), `lf` (Leafallia), `bh` (Behemoth), `cc` (Choco Circuit), `pt` (Parting), `cg` (Choco Girl) |
| Mechanics | `ld`/`leader`, `td`/`tidal` |

### Subcommands

| Command | Description |
| --- | --- |
| `warp status` | Show warp system status |
| `warp lock` / `unlock` | Lock / unlock warp item |
| `warp fix` | Force-clear stuck warp state |

### Multi-character

Append `all` to broadcast over IPC: `warpall`, `tphall`, etc.

---

## Message verbosity

| Command | Values | Affects |
| --- | --- | --- |
| `jamsg` | `full` / `on` / `off` | Job Ability messages |
| `spellmsg` | `full` / `on` / `off` | Spell messages |
| `wsmsg` | `full` / `on` / `off` / `tp` | Weapon skill messages |
| `debugmsg` | toggle | Universal message logging |
| `testmsg [job]` / `msgtest` | — | Smoke-test the message API for a job |
| `msgtests` | — | Run the full message-system test suite |

---

## Diagnostics & profiler

| Command | Alias | Description |
| --- | --- | --- |
| `fulltest` | `ft` | Run the full system validation suite |
| `syscheck` | `sc` | Verify all jobs and core systems are operational |
| `lagdebug` | `ldb` | Identify lag patterns (server vs client) |
| `perf` | — | Performance profiler status |
| `perf start` / `perf stop` | `perf on` / `perf off` | Enable / disable profiling |
| `testcolors` | `colors` | Show 509-color FFXI palette |

## Debug

Most are toggles. Output is verbose; turn off when not needed.

| Command | Alias | Description |
| --- | --- | --- |
| `debugmidcast` | — | Trace `MidcastManager.select_set()` decisions |
| `debugprecast` | — | Trace precast pipeline |
| `debugsubjob` | `dsj` | Show job/subjob/zone validation |
| `debugwarp` | — | Trace warp system flow |
| `debugjobchange` | `djc` | Trace `JobChangeManager` 3.0s debounce |
| `debugstate` | `ds` | Dump AutoMove / JCM / UI state |
| `debugupdate` | `du` | Trace `gs c update` flow |
| `automovedebug` | `amd` | Trace movement-speed gear decisions |

---

## Per-job commands

These are wired in `shared/jobs/<job>/functions/<JOB>_COMMANDS.lua`.

### WAR

| Command | Notes |
| --- | --- |
| `cyclestate MainWeapon` | Bound to Alt+1 (Ukonvasara, Naegling, Chango, etc.) |
| `cyclestate HybridMode` | Bound to Alt+2 (PDT / Normal / SubtleBlow) |
| `debugretaliation` / `debugretal` | Trace Retaliation set selection |
| `retalstatus` | Show Retaliation state |

### PLD

| Command | Notes |
| --- | --- |
| `aoe` | AoE BLU enmity rotation (requires /BLU) |
| `rune` | Cast the currently-selected rune (requires /RUN) |
| `cyclestate MainWeapon`, `cyclestate HybridMode`, `cyclestate RuneMode` | Standard cycles |

### RUN

| Command | Notes |
| --- | --- |
| `aoe` | AoE BLU enmity rotation (requires /BLU sub) |
| `rune` | Cast the currently-selected rune |

### DNC

| Command | Notes |
| --- | --- |
| `smartbuff` | Auto-buff cycle (DNC + subjob) |
| `step` | Execute step in the configured Main/Alt rotation |
| `fandance` / `dance` | Activate the selected dance |
| `cyclestate MainStep` / `AltStep` / `UseAltStep` / `ClimacticAuto` / `JumpAuto` / `Dance` | Step + auto-toggle cycles |

### THF

| Command | Notes |
| --- | --- |
| `smartbuff` | Auto-buff cycle (THF + subjob) |
| `fbc` | Full Buff Cycle |
| `range` | Toggle range / melee mode |

### BLM

| Command | Notes |
| --- | --- |
| `cyclemainlight` | Cycle main weapon for light spells |
| `cyclemaindark` | Cycle main weapon for dark spells |
| `cyclesublight` / `cyclesubdark` | Cycle sub-weapon per element |
| `cyclestate MainWeapon` / `SubWeapon` / `HybridMode` | Standard cycles |

### RDM

| Command | Notes |
| --- | --- |
| `enspell` | Cycle Enspell selection |
| `cyclestorm` | Cycle Storm spell |
| `cyclestate EnfeeblingMode` / `EnhancingMode` / `NukeMode` | Standard cycles |

### WHM

| Command | Notes |
| --- | --- |
| `afflatus` | Cast the selected Afflatus stance |
| `cyclestate AfflatusMode` / `CureMode` / `CureAutoTier` | Standard cycles |

### BRD

| Command | Notes |
| --- | --- |
| `soul_voice` / `sv` | Cast Soul Voice |
| `nightingale` / `ni` | Cast Nightingale |
| `troubadour` / `tr` | Cast Troubadour |
| `forceidle` | Force idle gear (overrides engaged) |
| `cyclestate SongMode` and other state cycles | Defined per `BRD_STATES.lua` |

### COR

| Command | Notes |
| --- | --- |
| `rolls` | Display all active rolls + Lucky/Unlucky numbers |
| `doubleup` / `du` | Double-Up window status |
| `clearrolls` | Clear roll tracking state |
| `track_roll` / `trackroll` | Manually mark a roll as tracked |

### BST

| Command | Notes |
| --- | --- |
| `ecosystem` | Cycle the 7 ecosystems |
| `species` | Cycle species inside the active ecosystem |
| `broth` / `broths` | Show broth inventory counts |

### GEO

| Command | Notes |
| --- | --- |
| `indi <element>` | Cast the matching Indi spell |
| `geo <element>` | Cast the matching Geo spell |
| `entrust <spell>` | Entrust a spell on the target |
| `lightspell` | Cycle light spell |

### SAM / DRK

Standard `cyclestate` only — `MainWeapon` and `HybridMode`.

---

## DualBox

| Command | Description |
| --- | --- |
| `altjob` | Request alt character's current job |
| `altjobupdate <JOB> <SUBJOB>` | Send job update over IPC (called automatically) |
| `requestjob` | IPC handshake (called automatically) |

Append `all` to most warp commands to broadcast (`warpall`, `tphall`).

---

## Where these come from

| File | Wires |
| --- | --- |
| `shared/utils/core/COMMON_COMMANDS.lua` | All universal commands above |
| `shared/utils/ui/UI_COMMANDS.lua` | `ui` family |
| `shared/utils/warp/warp_commands.lua` | `warp` + 100+ aliases |
| `shared/utils/inventory/refill_manager.lua` | `refill` / `rf` |
| `shared/utils/wardrobe/` | `worganize` / `wo` family |
| `shared/utils/craft/craft_manager.lua` | `craft`, `fish`, `uncraft` |
| `shared/jobs/<job>/functions/<JOB>_COMMANDS.lua` | Per-job commands |

`grep -E "if cmd ==|if command ==" shared/utils/core/COMMON_COMMANDS.lua`
will print the canonical universal command list.
