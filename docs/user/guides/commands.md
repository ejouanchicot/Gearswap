# Commands reference

All commands use the format `//gs c [command] [parameters]`.

---

## System

| Command | Alias | Description |
|---------|-------|-------------|
| `reload` | | Full system reload (lockstyle, macros, keybinds, UI) |
| `checksets` | | Validate equipment sets -- reports OK / STORAGE / MISSING per item |
| `lockstyle` | `ls` | Reapply lockstyle |
| `dressup` | | Toggle DressUp addon management (persistent across sessions) |

## Equipment and inventory

| Command | Alias | Description |
|---------|-------|-------------|
| `checksets` | | Scan all gear sets, report missing or stored items |
| `wardrobeaudit` | `wa` | Find items in your wardrobes that no job uses. Exports report to `wardrobe_audit.txt` |
| `refill` | `rf` | Pull consumables from Mog Case/Sack into inventory (Panacea, Remedy, Holy Water, etc.) |

## Mode cycling

| Command | Description |
|---------|-------------|
| `cycle HybridMode` | Normal / PDT |
| `cycle MainWeapon` | Cycle through weapon options |
| `cycle OffenseMode` | Normal / Acc / ... |
| `cycle DefenseMode` | Cycle defense modes |
| `set [State] [Value]` | Force a specific state value |
| `toggle [State]` | Toggle a boolean state |
| `reset [State]` | Reset state to default |

## UI

| Command | Alias | Description |
|---------|-------|-------------|
| `ui` | | Toggle UI visibility |
| `ui on` | `ui enable` | Enable UI (create and show) |
| `ui off` | `ui disable` | Disable UI (hide and persist across reloads) |
| `ui header` | `ui h` | Toggle header section |
| `ui legend` | `ui l` | Toggle legend section |
| `ui columns` | `ui c` | Toggle column headers |
| `ui footer` | `ui f` | Toggle footer section |
| `ui font <name>` | | Change font (`Consolas` or `Courier New`) |
| `ui bg <preset>` | `ui background`, `ui theme` | Apply a background preset (e.g., `dark_blue`, `neon_green`) |
| `ui bg toggle` | `ui theme toggle` | Toggle background visibility |
| `ui bg list` | `ui theme list` | List available background presets |
| `ui bg <r> <g> <b> <a>` | | Set custom background RGBA (0-255 each) |
| `ui save` | `ui s` | Save current UI position and settings |
| `ui help` | `ui ?` | Show UI command help |

## Warp system

Handles teleport spells, recall spells, and item-based warps. Equips the right item, uses it, then restores your gear.

### Spells and system warps

| Command | Alias | Destination |
|---------|-------|-------------|
| `warp` | `w` | Warp (return to home point) |
| `warp2` | `w2` | Warp II |
| `retrace` | `ret` | Retrace |
| `escape` | `esc` | Escape |

### Teleport (WHM)

| Command | Alias | Destination |
|---------|-------|-------------|
| `tpholla` | `tph` | Teleport-Holla |
| `tpdem` | `tpd` | Teleport-Dem |
| `tpmea` | `tpm` | Teleport-Mea |
| `tpaltep` | `tpa` | Teleport-Altep |
| `tpyhoat` | `tpy` | Teleport-Yhoat |
| `tpvahzl` | `tpv` | Teleport-Vahzl |

### Recall (WHM)

| Command | Alias | Destination |
|---------|-------|-------------|
| `recjugner` | `rj` | Recall-Jugner |
| `recpashh` | `rp` | Recall-Pashh |
| `recmeriph` | `rm` | Recall-Meriph |

### Nations and cities

| Command | Alias | Destination |
|---------|-------|-------------|
| `sandoria` | `sd` | San d'Oria |
| `bastok` | `bt` | Bastok |
| `windurst` | `wd` | Windurst |
| `jeuno` | `jn` | Jeuno |
| `selbina` | `sb` | Selbina |
| `mhaura` | `mh` | Mhaura |
| `rabao` | `rb` | Rabao |
| `kazham` | `kz` | Kazham |
| `norg` | `ng` | Norg |
| `tavnazia` | `tv` | Tavnazia |
| `whitegate` | `wg` | Al Zahbi / Whitegate |
| `nashmau` | `ns` | Nashmau |
| `adoulin` | `ad` | Adoulin |

### Chocobo stables

| Command | Alias |
|---------|-------|
| `stable-sd` | `stsd` |
| `stable-bt` | `stbt` |
| `stable-wd` | `stwd` |
| `stable-jn` | `stjn` |

### Conquest outpost

| Command | Alias |
|---------|-------|
| `outpost` | `op` |

### Adoulin frontier stations

| Command | Alias | Zone |
|---------|-------|------|
| `ceizak` | `cz` | Ceizak Battlegrounds |
| `yahse` | `ys` | Yahse Hunting Grounds |
| `hennetiel` | `hn` | Foret de Hennetiel |
| `morimar` | `mm` | Morimar Basalt Fields |
| `marjami` | `mj` | Marjami Ravine |
| `yorcia` | `yc` | Yorcia Weald |
| `kamihr` | `km` | Kamihr Supplicarium |

### Special locations

| Command | Alias | Destination |
|---------|-------|-------------|
| `wajaom` | `wj` | Wajaom Woodlands |
| `arrapago` | `ar` | Arrapago Reef |
| `purgonorgo` | `pg` | Purgonorgo Isle |
| `rulude` | `rl` | Ru'Lude Gardens |
| `zvahl` | `zv` | Zvahl |
| `riverne` | `riv` | Riverne |
| `yoran` | `yo` | Yoran Oran |
| `leafallia` | `lf` | Leafallia |
| `behemoth` | `bh` | Behemoth's Dominion |
| `chocircuit` | `cc` | Chocobo Circuit |
| `parting` | `pt` | Parting Glass |
| `chocogirl` | `cg` | Chocobo Girl |
| `leader` | `ld` | Unity Leader warp |
| `tidal` | `td` | Tidal Talisman |

### Warp subcommands

| Command | Description |
|---------|-------------|
| `warp status` | Show warp system status |
| `warp lock` | Lock warp item |
| `warp unlock` | Unlock warp item |
| `warp fix` | Fix stuck warp state |

### Multi-character warp (DualBox)

Add `all` suffix to warp both characters: `warpall`, `tphall`, etc.

## Message toggles

Control chat message verbosity for abilities, spells, and weapon skills.

| Command | Values | Description |
|---------|--------|-------------|
| `jamsg` | `full` / `on` / `off` | Job Ability messages. Full = name + description, On = name only, Off = silent |
| `spellmsg` | `full` / `on` / `off` | Spell messages (non-enfeebling) |
| `wsmsg` | `full` / `on` / `off` / `tp` | Weapon skill messages. TP = name + TP only |

## Watchdog

Protects against stuck midcast in laggy zones (Odyssey, Dynamis). Auto-recovers gear after timeout.

| Command | Description |
|---------|-------------|
| `watchdog` | Show status |
| `watchdog on` | Enable |
| `watchdog off` | Disable |
| `watchdog toggle` | Toggle |
| `watchdog debug` | Toggle debug mode (shows scan details) |
| `watchdog test` | Simulate stuck midcast |
| `watchdog stats` | Show statistics |
| `watchdog timeout [seconds]` | Set timeout (default: dynamic based on cast time + 1.5s buffer) |
| `watchdog clear` | Force cleanup stuck state |

## Subjob abilities

These work regardless of main job, as long as the subjob matches.

| Command | Subjob | Description |
|---------|--------|-------------|
| `waltz` | /DNC | Curing Waltz -- auto-selects tier I-V based on target's missing HP |
| `aoewaltz` | /DNC | Divine Waltz (AoE healing) |
| `jump` | /DRG | Jump ability |

## DualBox

| Command | Description |
|---------|-------------|
| `altjob` | Request alt character's job info |

## Utility

| Command | Alias | Description |
|---------|-------|-------------|
| `info [name]` | | Show detailed JA / spell / WS data from databases |
| `testcolors` | `colors` | Display all 509 FFXI chat color codes |
| `perf` | | Performance profiler status |
| `perf start` | `perf on` | Enable profiling |
| `perf stop` | `perf off` | Disable profiling |
| `commands` | `cmds` | List all available commands in-game |
| `help` | `?` | Show help |

## Debug

These are for troubleshooting. Most toggle verbose output on/off.

| Command | Alias | Description |
|---------|-------|-------------|
| `debugmidcast` | | Debug midcast set selection |
| `debugprecast` | | Debug precast logic |
| `debugsubjob` | `dsj` | Show job/zone info |
| `debugwarp` | | Debug warp system |
| `debugjobchange` | `djc` | Debug job change manager |
| `debugstate` | `ds` | Show internal state (AutoMove, JCM, UI) |
| `debugupdate` | `du` | Debug gear updates |
| `debugmsg` | | Debug message system |
| `automovedebug` | `amd` | Debug AutoMove (movement speed gear) |
| `testmsg [job]` | | Test message API for a specific job |

---

## Job-specific commands

### WAR

| Command | Keybind |
|---------|---------|
| `cycle MainWeapon` (Ukonvasara, Naegling, Shining One, Chango, Ikenga's Axe, Loxotic Mace) | Alt+1 |
| `cycle HybridMode` | Alt+2 |

### PLD

| Command | Keybind | Notes |
|---------|---------|-------|
| `aoe` -- AoE BLU enmity rotation | Alt+4 | Requires /BLU. Auto-selects best enmity/sec spell |
| `rune` -- Use selected rune | Alt+5 | Requires /RUN |
| `cycle RuneMode` (Sulpor / Lux) | Alt+6 | |

### DNC

| Command | Keybind |
|---------|---------|
| `waltz` -- Curing Waltz (auto-tier I-V) | Alt+3 |
| `aoewaltz` -- Divine Waltz | Alt+4 |
| `step` -- Execute step (Main/Alt rotation) | Alt+5 |
| `cycle ClimacticAuto` -- Auto Climactic Flourish | Alt+6 |
| `cycle JumpAuto` -- Auto Jump before WS | Alt+7 |

### BLM

| Command | Keybind |
|---------|---------|
| `cycle MainWeapon` (Laevateinn / Akademos / Lathi) | Alt+1 |
| `cycle SubWeapon` | Alt+2 |
| `cycle HybridMode` | Alt+3 |

### RDM

| Command | Keybind |
|---------|---------|
| `cycle EnfeeblingMode` (Potency / Skill / Duration) | Alt+5 |
| `cycle NukeMode` (FreeNuke / LowTierNuke / Accuracy) | Alt+6 |
| `cycle GainSpell` (7 stats) | F1 |
| `cycle Barspell` (6 elements) | F2 |
| `cycle BarAilment` (8 ailments) | F3 |
| `cycle Spike` (3 types) | F4 |
| `cycle Storm` (8 storms) | F5 |

### WHM

| Command | Keybind |
|---------|---------|
| `afflatus` -- Cast current Afflatus stance | Alt+3 |
| `cycle AfflatusMode` (Solace / Misery) | Alt+4 |
| `cycle CureAutoTier` -- Auto-downgrade cure tier based on missing HP | Alt+5 |

### BRD

| Command | Keybind |
|---------|---------|
| `song` -- Execute next song in rotation (auto-instrument) | Alt+3 |
| `cycle SongMode` | Alt+4 |

### COR

| Command | Description |
|---------|-------------|
| `rolls` | Display all active rolls |
| `doubleup` / `du` | Double-Up window status |
| `clearrolls` | Clear roll tracking |
| `party` | Show detected party jobs |

### BST

| Command | Keybind |
|---------|---------|
| `ecosystem` -- Cycle 7 ecosystems | Alt+3 |
| `species` -- Cycle species in current ecosystem | Alt+4 |
| `broth` -- Show broth inventory counts | Alt+5 |
| `rdylist` -- List Ready Moves | |
| `rdymove [1-6]` -- Execute Ready Move by index | |
| `pet engage` / `pet disengage` | |

### GEO

| Command | Keybind |
|---------|---------|
| `cycle BubbleMode` (Indi / Geo / Both) | Alt+3 |

### SAM

| Command | Keybind |
|---------|---------|
| `cycle MainWeapon` (Masamune / Dojikiri / Nagi) | Alt+1 |
| `cycle HybridMode` | Alt+2 |

### THF

| Command | Keybind |
|---------|---------|
| `smartbuff` -- Auto-buff cycle (THF + subjob) | Alt+3 |
| `fbc` -- Full Buff Cycle | Alt+4 |

### DRK

| Command | Keybind |
|---------|---------|
| `cycle MainWeapon` | Alt+1 |
| `cycle HybridMode` | Alt+2 |
