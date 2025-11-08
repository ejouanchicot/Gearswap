# Tetsouo GearSwap Documentation

Professional GearSwap system for Final Fantasy XI with modular architecture and advanced features.

**Version**: 3.1 - Production Ready
**Last Updated**: 2025-11-01
**Supported Jobs**: WAR, PLD, DNC, DRK, SAM, THF, RDM, WHM, BLM, GEO, COR, BRD, BST (13 jobs)

---

## Quick Navigation

### 🚀 Getting Started

New to Tetsouo GearSwap? Start here:

1. **[Installation Guide](user/getting-started/installation.md)** - Install and configure the system
2. **[Quick Start](user/getting-started/quick-start.md)** - Get up and running in 5 minutes

### 📖 User Guides

Learn how to use the system:

- **[Commands Reference](user/guides/commands.md)** - All available commands
- **[Keybinds Guide](user/guides/keybinds.md)** - Keyboard shortcuts for all jobs
- **[Configuration Guide](user/guides/configuration.md)** - Customize your setup
- **[DualBox Guide](user/guides/dualbox.md)** - Multi-character setup
- **[FAQ](user/guides/faq.md)** - Frequently asked questions

### ⚡ Features

Explore advanced features:

- **[Watchdog System](user/features/watchdog.md)** - Automatic stuck midcast protection
- **[UI System](user/features/ui.md)** - Visual keybind overlay
- **[Equipment Validation](user/guides/commands.md#equipment-validation)** - Verify your gear

### 💼 Job Documentation

Complete documentation for all 13 jobs:

- [Job Documentation Index](user/jobs/README.md) - All jobs overview
- Each job has 8 files: README, quick-start, keybinds, commands, states, sets, configuration, troubleshooting

---

## Feature Highlights

### ✅ Universal Features (All Jobs)

- **Automatic Equipment Swapping** - Precast >> Midcast >> Aftercast
- **Hybrid Modes** - PDT/Normal with intelligent gear selection
- **Equipment Validation** - Identify missing/storage items
- **Lockstyle Management** - Auto-apply per job/subjob
- **Macrobook Management** - Auto-set per job/subjob
- **Keybind System** - Customizable keyboard shortcuts
- **UI Overlay** - Visual keybind reference (draggable, saveable)
- **DualBox Support** - Multi-character job synchronization
- **Watchdog Protection** - Auto-recovery from stuck midcast (3.5s timeout)
- **Cooldown Tracking** - Prevents ability spam with cooldown messages
- **Debuff Guard** - Blocks actions when afflicted (Amnesia, Silence, etc.)

### 🎯 Job-Specific Features

**WAR** - Warrior

- 6 weapon options (Ukonvasara, Naegling, Chango, etc.)
- TP Bonus display on WS
- Mighty Strikes detection

**PLD** - Paladin

- AOE BLU magic rotation (auto-select best enmity/sec spell)
- Rune system (Sulpor, Lux - PLD/RUN)
- Auto-Majesty before Cure
- Divine Emblem auto-trigger

**DNC** - Dancer

- Intelligent Waltz (HP-based tier selection I-V)
- Auto-Climactic Flourish toggle
- Auto-Jump system with chaining (Jump >> High Jump if needed)
- Step rotation (Main/Alt)

**RDM** - Red Mage

- 3 Enfeebling modes (Potency/Skill/Duration)
- 3 Nuke modes (FreeNuke/LowTierNuke/Accuracy)
- 5 enhancement spell cycles (Gain/Bar/BarAilment/Spike/Storm)
- Auto-Saboteur system

**WHM** - White Mage

- Cure auto-tier system (downgrades based on missing HP)
- Afflatus management (Solace/Misery)
- Ebers gear auto-equip with Afflatus Solace

**BLM** - Black Mage

- Magic Burst detection
- Weapon swapping (Laevateinn/Akademos/Lathi)

**GEO** - Geomancer

- Bubble modes (Indi/Geo/Both)
- Auto-Entrust system

**BRD** - Bard

- Song rotation with auto-instrument management
- Marsyas Honor March lock system

**COR** - Corsair

- Automatic roll tracking with bust rate calculation
- Party job detection system
- Natural 11 mechanics tracking
- Color-coded warnings (0% safe >> 100% danger)

**BST** - Beastmaster

- 7 ecosystem management
- Species cycling per ecosystem
- Ready Move system with index execution (1-6)
- Intelligent pet engagement (auto Fight >> Move >> Heel sequence)
- Broth inventory display

**SAM** - Samurai

- Auto-Hasso/Seigan management
- Meditate cooldown tracking
- Third Eye auto-refresh

**THF** - Thief

- Smartbuff cycle (THF + subjob)
- Full buff cycle (FBC)

**DRK** - Dark Knight

- Weapon management
- Hybrid mode support

---

## System Requirements

### Required

- **FFXI** with **Windower 4**
- **GearSwap** addon
- **DressUp** addon (for lockstyle)

### Optional but Recommended

- **ConsoleBG** - Better console readability
- **InfoBar** - Status information display

---

## Quick Command Reference

### Essential Commands

```
//gs c reload              # Full system reload
//gs c checksets           # Validate equipment
//gs c lockstyle           # Reapply lockstyle
//gs c ui                  # Toggle UI overlay
//gs c watchdog            # Show watchdog status
```

### Mode Cycling

```
//gs c cycle HybridMode    # Normal ↔ PDT
//gs c cycle MainWeapon    # Cycle weapons
```

### Watchdog

```
//gs c watchdog debug      # Toggle debug mode
//gs c watchdog test       # Test stuck detection
//gs c watchdog timeout 3.5 # Set timeout
```

See **[Commands Reference](user/guides/commands.md)** for complete list.

---

## Quick Keybind Reference

### Universal Keybinds (All Jobs)

| Key | Function |
|-----|----------|
| **Alt+1** | Cycle Main Weapon |
| **Alt+2** | Cycle Hybrid Mode (PDT/Normal) |
| **Alt+F1** | Toggle UI |
| **F9** | Cycle Offense Mode |
| **F10** | Cycle Defense Mode |
| **F12** | Update Gear |

### Job-Specific Examples

**WAR:**

- No additional keybinds (uses universal Alt+1/Alt+2)

**DNC:**

- Alt+3: Main Step
- Alt+4: Alt Step
- Alt+5: Use Alt Step Toggle
- Alt+6: Climactic Auto Toggle
- Alt+7: Jump Auto Toggle

**RDM:**

- Alt+5: Cycle Enfeebling Mode
- Alt+6: Cycle Nuke Mode
- F1-F5: Cycle Enhancement Spells

See **[Keybinds Guide](user/guides/keybinds.md)** for complete job-specific keybinds.

### Job-Specific Documentation

All 13 jobs fully documented with modular structure:

- [Job Documentation Index](user/jobs/README.md) - Complete job list
- Each job: 8 files (README, quick-start, keybinds, commands, states, sets, configuration, troubleshooting)

---

## Documentation Structure

```
docs/
├── README.md                          (This file - Main navigation)
│
├── user/                              (User Documentation)
│   ├── getting-started/
│   │   ├── installation.md            ✅ Installation guide
│   │   └── quick-start.md             ✅ 5-minute quick start
│   │
│   ├── guides/
│   │   ├── commands.md                ✅ Complete command reference
│   │   ├── keybinds.md                ✅ Keybind customization guide
│   │   ├── configuration.md           ✅ Configuration guide
│   │   ├── dualbox.md                 ✅ DualBox multi-character setup
│   │   └── faq.md                     ✅ Frequently asked questions
│   │
│   ├── features/
│   │   ├── auto-tier-system.md        ✅ Auto-tier (WHM Cure, DNC Waltz)
│   │   ├── equipment-validation.md    ✅ Equipment validation system
│   │   ├── job-change-manager.md      ✅ Job change anti-collision
│   │   ├── watchdog.md                ✅ Watchdog auto-recovery
│   │   └── ui.md                      ✅ UI system customization
│   │
│   └── jobs/                          (13 Jobs - Modular Structure)
│       ├── README.md                  ✅ Job index
│       ├── rdm/ (8 files)             ✅ Red Mage
│       ├── whm/ (8 files)             ✅ White Mage
│       ├── blm/ (8 files)             ✅ Black Mage
│       ├── geo/ (8 files)             ✅ Geomancer
│       ├── brd/ (8 files)             ✅ Bard
│       ├── cor/ (8 files)             ✅ Corsair
│       ├── bst/ (8 files)             ✅ Beastmaster
│       ├── pld/ (8 files)             ✅ Paladin
│       ├── dnc/ (8 files)             ✅ Dancer
│       ├── sam/ (8 files)             ✅ Samurai
│       ├── thf/ (8 files)             ✅ Thief
│       ├── war/ (8 files + tp-bonus)  ✅ Warrior
│       └── drk/ (8 files + abilities) ✅ Dark Knight
│
└── templates/                         (Documentation Templates)
    ├── modular/                       (8-file job structure)
    │   ├── README_TEMPLATE.md
    │   ├── quick-start_TEMPLATE.md
    │   ├── keybinds_TEMPLATE.md
    │   ├── commands_TEMPLATE.md
    │   ├── states_TEMPLATE.md
    │   ├── sets_TEMPLATE.md
    │   ├── configuration_TEMPLATE.md
    │   └── troubleshooting_TEMPLATE.md
    ├── JOB_GUIDE_TEMPLATE.md          (Legacy single-file)
    └── JOB_TECHNICAL_GUIDE_TEMPLATE.md (Legacy technical)
```

**Legend**: ✅ = Complete and verified

---

## Support and Troubleshooting

### Common Issues

**Gear not swapping:**

- Network lag detected - Watchdog will auto-recover after 3.5s
- Manual force: `//gs c watchdog clear`

**Lockstyle not applying:**

```
//lua load dressup
//gs c lockstyle
```

**Keybinds not working:**

```
//lua reload gearswap
```

**Equipment validation:**

```
//gs c checksets
```

See **[FAQ](user/guides/faq.md)** for complete troubleshooting guide.

---

## Version History

**Version 3.1** (2025-11-01):

- ✅ Unified ability messages system (100% - all jobs)
- ✅ Removed "activated!" from all JA messages
- ✅ UNIVERSAL_SPELL_DATABASE.lua created (14 databases aggregated)
- ✅ Disabled 15 job-specific message systems (zero duplicates)
- ✅ Cleaned 19 backup files (.bak, .backup)
- ✅ Documentation audit complete

**Version 3.0** (2025-10-26):

- ✅ Documentation complete reorganization (user/technical separation)
- ✅ 13 jobs production-ready (WAR, PLD, DNC, DRK, SAM, THF, RDM, WHM, BLM, GEO, COR, BRD, BST)
- ✅ Watchdog v2.0 (hook-based, test mode, silent coroutine)
- ✅ MidcastManager universal (7-level fallback chain)
- ✅ Equipment validation system
- ✅ DualBox support
- ✅ UI system with drag/save

**Version 2.0** (2025-10-05):

- ✅ WAR, PLD, DNC production-ready
- ✅ Factory patterns (Lockstyle, Macrobook)
- ✅ Centralized systems (8/8)
- ✅ Zero code duplication

**Version 1.0** (2025-09-29):

- ✅ Initial WAR implementation
- ✅ Modular architecture established

---

## Contributing

For developers interested in contributing or customizing:

1. Read **[Standards](../.claude/standards.md)** - Coding standards
2. See **[Development Guide](technical/development/)** - How to add jobs
3. Follow **[Architecture](technical/architecture/)** - System design patterns

---

## Credits

**Author**: Tetsouo
**License**: MIT (or specify your license)
**Repository**: [GitHub URL if public]

---

## Quick Links

- [Installation](user/getting-started/installation.md)
- [Quick Start](user/getting-started/quick-start.md)
- [Commands](user/guides/commands.md)
- [Keybinds](user/guides/keybinds.md)
- [Watchdog](user/features/watchdog.md)
- [FAQ](user/guides/faq.md)
- [Standards](../.claude/standards.md)

---

**Happy adventuring in Vana'diel!** ✨
