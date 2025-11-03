# Commands Reference

Complete command reference for the Tetsouo GearSwap system.

## Table of Contents

- [Command Format](#command-format)
- [Universal Commands](#universal-commands)
- [Watchdog Commands](#watchdog-commands)
- [Job-Specific Commands](#job-specific-commands)
- [Quick Reference Table](#quick-reference-table)

---

## Command Format

All GearSwap commands are typed in FFXI chat:

```
//gs c [command] [parameters]
```

**Examples:**

```
//gs c reload                    # System reload
//gs c cycle HybridMode          # Cycle hybrid modes
//gs c watchdog                  # Show watchdog status
//gs c checksets                 # Validate equipment
```

---

## Universal Commands

These commands work for **ALL jobs**.

### System Commands

| Command | Description |
|---------|-------------|
| `//gs c reload` | Force complete system reload (lockstyle, macros, keybinds, UI) |
| `//gs c checksets` | Validate all equipment sets (identify missing/storage items) |
| `//gs c lockstyle` or `//gs c ls` | Reapply lockstyle |
| `//gs reload` | Standard Windower GearSwap reload |

**Example - Equipment Validation:**

```
//gs c checksets
→ [WAR/SAM] Validating equipment sets...
→ [WAR/SAM] ✓ 42/44 items validated (95.5%)
→ [STORAGE] sets.precast.WS['Upheaval'].neck: "Fotia Gorget"
→ [MISSING] sets.idle.PDT.body: "Sakpata's Plate"
```

**Output Legend:**

- **[OK]** - Item available in inventory
- **[STORAGE]** - Item exists but in Mog House/Storage
- **[MISSING]** - Item doesn't exist

### UI Commands

| Command | Description |
|---------|-------------|
| `//gs c ui` | Toggle UI visibility (show/hide) |
| `//gs c ui save` | Save current UI position |
| `//gs c ui hide` | Hide UI |
| `//gs c ui show` | Show UI |

**Workflow - Reposition UI:**

```
1. //gs c ui show         # Show UI
2. Drag UI to desired position with mouse
3. //gs c ui save         # Save position to config
```

### Mode Cycling

| Command | Description |
|---------|-------------|
| `//gs c cycle HybridMode` | Cycle: Normal ↔ PDT |
| `//gs c cycle OffenseMode` | Cycle: Normal → Acc → ... |
| `//gs c cycle DefenseMode` | Cycle defense modes |

### DualBox Commands

| Command | Description |
|---------|-------------|
| `//gs c altjob` | Request alt character's job info |

**Setup:**

1. Configure `config/DUALBOX_CONFIG.lua` on both characters
2. Main: `//gs c altjob`
3. Alt auto-responds with job info
4. Main UI displays alt job (if enabled)

---

## Watchdog Commands

Protects against stuck midcast in laggy zones (Odyssey, Dynamis).

### Basic Commands

| Command | Description |
|---------|-------------|
| `//gs c watchdog` | Show watchdog status |
| `//gs c watchdog on` | Enable watchdog |
| `//gs c watchdog off` | Disable watchdog |
| `//gs c watchdog toggle` | Toggle on/off |

### Debug Commands

| Command | Description |
|---------|-------------|
| `//gs c watchdog debug` | Toggle debug mode (shows scan details every 0.5s) |
| `//gs c watchdog test` | Test detection (simulates stuck midcast) |
| `//gs c watchdog stats` | Show detailed statistics |

### Configuration Commands

| Command | Description |
|---------|-------------|
| `//gs c watchdog timeout 3.5` | Set timeout (seconds) |
| `//gs c watchdog clear` | Force cleanup of stuck midcast |

**Example - Test Detection:**

```
//gs c watchdog test
→ [Watchdog TEST] Simulating stuck midcast: Test Spell
→ [Watchdog TEST] Aftercast will be BLOCKED - watchdog should cleanup after 3.5s
... (after 3.5s) ...
→ [Watchdog] Midcast stuck detected - recovering from: Test Spell (stuck for 3.5s)
→ [Watchdog TEST] Test mode deactivated after cleanup
```

**Timeout Recommendations:**

- **3.5s** (default) - Balanced for most situations
- **3.0s** - Aggressive (extreme lag)
- **4.0s** - Conservative (fewer false positives)

See `../features/watchdog.md` for complete documentation.

---

## Job-Specific Commands

### WAR - Warrior

| Command | Description | Keybind |
|---------|-------------|---------|
| `//gs c cycle MainWeapon` | Cycle weapons (Ukonvasara, Naegling, etc.) | Alt+1 |
| `//gs c cycle HybridMode` | Cycle: PDT ↔ Normal | Alt+2 |

**Weapons:** Ukonvasara, Naegling, Shining One, Chango, Ikenga's Axe, Loxotic Mace

### PLD - Paladin

| Command | Description | Keybind | Requires |
|---------|-------------|---------|----------|
| `//gs c aoe` | AOE BLU magic rotation (auto-select best spell) | Alt+4 | PLD/BLU |
| `//gs c rune` | Use selected rune | Alt+5 | PLD/RUN |
| `//gs c cycle RuneMode` | Cycle: Sulpor ↔ Lux | Alt+6 | PLD/RUN |

**AOE BLU Rotation:** Automatically selects spell with best enmity/sec ratio from available spells (Geist Wall, Stinking Gas, Sound Blast, Sheep Song, Soporific).

### DNC - Dancer

| Command | Description | Keybind |
|---------|-------------|---------|
| `//gs c waltz` | Curing Waltz (HP-based tier selection) | Alt+3 |
| `//gs c aoewaltz` | Divine Waltz (AoE healing) | Alt+4 |
| `//gs c step` | Execute Step (Main/Alt rotation) | Alt+5 |
| `//gs c cycle ClimacticAuto` | Toggle auto Climactic Flourish | Alt+6 |
| `//gs c cycle JumpAuto` | Toggle auto Jump before WS | Alt+7 |

**Waltz System:** Automatically selects tier I-V based on target's missing HP.

### RDM - Red Mage

| Command | Description | Keybind |
|---------|-------------|---------|
| `//gs c cycle EnfeeblingMode` | Cycle: Potency/Skill/Duration | Alt+5 |
| `//gs c cycle NukeMode` | Cycle: FreeNuke/LowTierNuke/Accuracy | Alt+6 |
| `//gs c cycle GainSpell` | Cycle Gain spells (7 stats) | F1 |
| `//gs c cycle Barspell` | Cycle Bar Element spells (6 elements) | F2 |
| `//gs c cycle BarAilment` | Cycle Bar Ailment spells (8 ailments) | F3 |
| `//gs c cycle Spike` | Cycle Spike spells (3 types) | F4 |
| `//gs c cycle Storm` | Cycle Storm spells (8 storms - RDM/SCH only) | F5 |

**Enhancement Cycling:** Press F1-F5 to cycle through spell selections. Current selection displays in UI.

### WHM - White Mage

| Command | Description | Keybind |
|---------|-------------|---------|
| `//gs c afflatus` | Auto-cast current Afflatus stance | Alt+3 |
| `//gs c cycle AfflatusMode` | Cycle: Solace ↔ Misery | Alt+4 |
| `//gs c cycle CureAutoTier` | Toggle Cure auto-tier (On ↔ Off) | Alt+5 |

**Cure Auto-Tier:** When enabled, automatically downgrades Cure tier based on target's missing HP (prevents overkill).

### BLM - Black Mage

| Command | Description | Keybind |
|---------|-------------|---------|
| `//gs c cycle MainWeapon` | Cycle: Laevateinn/Akademos/Lathi | Alt+1 |
| `//gs c cycle SubWeapon` | Cycle shields | Alt+2 |
| `//gs c cycle HybridMode` | Cycle: PDT ↔ Normal | Alt+3 |

**Magic Burst:** Auto-detects MB windows and swaps to optimal MB gear.

### GEO - Geomancer

| Command | Description | Keybind |
|---------|-------------|---------|
| `//gs c cycle BubbleMode` | Cycle: Indi/Geo/Both | Alt+3 |

**Bubble Modes:**

- **Indi** - Personal bubbles only
- **Geo** - Party bubbles only
- **Both** - Dual bubble setup

### BRD - Bard

| Command | Description | Keybind |
|---------|-------------|---------|
| `//gs c song` | Execute song from rotation (auto-instrument) | Alt+3 |
| `//gs c cycle SongMode` | Cycle: HonorMarch/Paeon/Minne/etc. | Alt+4 |

**Auto-Instrument:** Automatically selects optimal instrument per song (Marsyas for Honor March, Gjallarhorn for ballads, etc.).

### COR - Corsair

| Command | Alias | Description |
|---------|-------|-------------|
| `//gs c rolls` | N/A | Display all active rolls |
| `//gs c doubleup` | `//gs c du` | Show Double-Up window status |
| `//gs c clearrolls` | N/A | Clear all roll tracking |
| `//gs c party` | N/A | Display detected party members |
| `//gs c track_roll [name] [value]` | N/A | Manual roll tracking |

**Roll Tracking:** Automatic roll tracking with bust rate calculation and color-coded warnings.

### BST - Beastmaster

| Command | Description | Keybind |
|---------|-------------|---------|
| `//gs c ecosystem` | Cycle through 7 ecosystems | Alt+3 |
| `//gs c species` | Cycle species for current ecosystem | Alt+4 |
| `//gs c broth` | Display broth counts in inventory | Alt+5 |
| `//gs c rdylist` | List all available Ready Moves | N/A |
| `//gs c rdymove [1-6]` | Execute Ready Move by index | N/A |
| `//gs c pet engage` | Manually engage pet | N/A |
| `//gs c pet disengage` | Manually disengage pet | N/A |

**Ready Move System:**

- If pet engaged: Uses move immediately
- If pet idle + player engaged: Fight → Move (stays engaged)
- If pet idle + player idle: Fight → Move → Heel

### SAM - Samurai

| Command | Description | Keybind |
|---------|-------------|---------|
| `//gs c cycle MainWeapon` | Cycle: Masamune/Dojikiri/Nagi | Alt+1 |
| `//gs c cycle HybridMode` | Cycle: PDT ↔ Normal | Alt+2 |

**Features:** Auto-Hasso/Seigan management, Meditate cooldown tracking, Third Eye auto-refresh.

### DRK - Dark Knight

| Command | Description | Keybind |
|---------|-------------|---------|
| `//gs c cycle MainWeapon` | Cycle weapons | Alt+1 |
| `//gs c cycle HybridMode` | Cycle: PDT ↔ Normal | Alt+2 |

### THF - Thief

| Command | Description | Keybind |
|---------|-------------|---------|
| `//gs c smartbuff` | Auto-buff cycle (THF + subjob) | Alt+3 |
| `//gs c fbc` | Full Buff Cycle (all buffs) | Alt+4 |

---

## Quick Reference Table

### Universal Commands

| Command | Action |
|---------|--------|
| `//gs c reload` | Full system reload |
| `//gs c checksets` | Validate equipment |
| `//gs c lockstyle` | Reapply lockstyle |
| `//gs c ui` | Toggle UI |
| `//gs c ui save` | Save UI position |
| `//gs c cycle HybridMode` | Normal ↔ PDT |

### Watchdog Commands

| Command | Action |
|---------|--------|
| `//gs c watchdog` | Show status |
| `//gs c watchdog debug` | Toggle debug mode |
| `//gs c watchdog test` | Test stuck detection |
| `//gs c watchdog timeout [seconds]` | Set timeout |

### DualBox Commands

| Command | Action |
|---------|--------|
| `//gs c altjob` | Request alt job info |

---

## Common Workflows

### Initial Setup

```
//gs c reload        # Full system reload
//gs c checksets     # Validate equipment
//gs c ui show       # Show UI
```

### Quick Weapon Change

```
//gs c cycle MainWeapon              # Cycle through options
//gs c set MainWeapon Naegling       # Force specific weapon
```

### Switch to Defensive Mode

```
//gs c cycle HybridMode              # Cycle mode
//gs c set HybridMode PDT             # Force PDT
```

### Test Watchdog Protection

```
//gs c watchdog test                 # Simulate stuck midcast
... (wait 3.5s for auto-recovery) ...
```

---

## Next Steps

- **[Keybinds Reference](keybinds.md)** - Keyboard shortcuts for these commands
- **[Configuration Guide](configuration.md)** - Customize system settings
- **[Features](../features/)** - Detailed feature documentation
- **[FAQ](faq.md)** - Solutions to common problems

---

**Version**: 1.0 (User Docs)
**Last Updated**: 2025-10-26
**Supported Jobs**: WAR, PLD, DNC, DRK, SAM, THF, RDM, WHM, BLM, GEO, COR, BRD, BST
