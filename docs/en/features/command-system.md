# GearSwap Command Guide

An intelligent command system that automatically adapts to your job and dual-boxing configuration.

## 🎯 Basic Commands

### Help Menu and Information

```bash
//gs c help              # Main help menu with all sections
//gs c info               # Detailed system and cache information
//gs c binds              # Active keybinds for your job (auto-detection)
//gs c commands           # Complete list of available commands  
//gs c dual               # Dual-boxing guide with alt commands
```

### Equipment Management

```bash
//gs c checksets          # Validates all your sets and shows missing items
//gs c ui                 # Enable/disable keybind display
//gs c clear_cache        # Clears system cache (resolves item bugs)
```

### Performance Monitoring  

```bash
//gs c perf start         # Start performance monitoring
//gs c perf stop          # Stop monitoring
//gs c perf report        # Display detailed performance report
//gs c perf clear         # Reset performance metrics
```

## 🎮 Advanced Dual-Boxing

The system automatically detects your alt character and adapts available commands.

### Initial Configuration

```bash
//gs c setjob <JOB>       # Set your alt character's job
```

**Examples:**

```bash
//gs c setjob GEO         # Configure Kaories as GEO
//gs c setjob RDM         # Configure Kaories as RDM
//gs c setjob BRD         # Configure Kaories as BRD
```

### Commands with Alt GEO

```bash
//gs c altgeo             # Cast selected Geo spell on proper target
//gs c altindi            # Cast selected Indi spell on you
//gs c altentrust         # Entrust current Indi to main character
//gs c altnuke            # Nuke with selected elemental spell + tier

# Dynamic spell management  
//gs c cycle altPlayerGeo   # Change Geo spell (Haste, Malaise, etc.)
//gs c cycle altPlayerIndi  # Change Indi spell (Fury, Haste, etc.)
```

### Commands with Alt RDM

```bash
# Targeted buff sequences
//gs c bufftank           # Haste2 + Refresh3 + Phalanx2 + Regen2 (tank)
//gs c buffmelee          # Haste2 + Phalanx2 + Regen2 (melee)
//gs c buffrng            # Flurry2 + Phalanx2 + Regen2 (ranged)

# Healing and debuffs
//gs c curaga             # Emergency Curaga3 on party
//gs c debuff             # Distract3 + Dia3 + Slow2 + Blind2 + Paralyze2
```

### Commands with Alt BRD

```bash
//gs c song1              # Cast song slot 1
//gs c song2              # Cast song slot 2  
//gs c honor              # Honor March on party
//gs c victory            # Victory March on party
//gs c rotation           # Execute complete BRD sequence
```

## ⚔️ Job-Specific Commands

The system detects your current job and automatically activates appropriate commands.

### THF

```bash
//gs c thfbuff            # Auto-buffs: Feint + Bully + Conspirator
```

### WAR

```bash
//gs c berserk            # Activate Berserk (cancels Defender)
//gs c defender           # Activate Defender (cancels Berserk + PDT mode)
//gs c thirdeye           # Activate Third Eye
//gs c jump               # Cast Jump on target
```

### BLM

```bash
//gs c buffself           # Stoneskin + Blink + other defensive buffs
//gs c mainlight          # Cast main light spell + current tier
//gs c maindark           # Cast main dark spell + current tier
//gs c sublight           # Cast secondary light spell + current tier
//gs c subdark            # Cast secondary dark spell + current tier
//gs c aja                # Cast selected Aja spell
//gs c altlight           # Alt cast light spell (tier V limit for RDM)
//gs c altdark            # Alt cast dark spell (tier V limit for RDM)
```

### BST

```bash
//gs c ecosystem          # Cycle ecosystem (Beast, Lizard, Vermin, etc.)
//gs c species            # Cycle species in current ecosystem
//gs c call               # Call Beast according to ecosystem/species
//gs c reward             # Reward on your pet
//gs c ready              # Ready move on target
//gs c charm              # Charm on target
//gs c sic                # Sic on target
//gs c stay               # Stay for pet control
//gs c heel               # Heel for pet recall
```

### BRD

```bash
//gs c song1              # Cast configured song slot 1
//gs c song2              # Cast configured song slot 2  
//gs c song3              # Cast configured song slot 3
//gs c song4              # Cast configured song slot 4
//gs c song5              # Cast configured song slot 5
//gs c rotation           # Complete rotation sequence

# Specialized songs
//gs c lullaby2           # Foe Lullaby II on target
//gs c elegy              # Carnage Elegy on target
//gs c requiem            # Foe Requiem VII on target  
//gs c threnody           # Threnody of selected element
//gs c carol              # Carol of selected element
//gs c etude              # Etude according to selected type

# Role-based sequences
//gs c meleesong          # Party songs for melee
//gs c tanksong           # Pianissimo songs for tank
//gs c healersong         # Pianissimo songs for healer
//gs c dummy              # Dummy songs for preparation
//gs c nt                 # Nightingale + Troubadour combo

# Tracking and status
//gs c setsongs <name> <nb> # Manually set nb songs on member
//gs c checksongs <name>    # Check active songs on member
//gs c songstatus         # Display general song status
```

### DNC

```bash
//gs c steps              # Box Step + Quickstep combo
//gs c boxstep            # Box Step on target
//gs c quickstep          # Quickstep on target
//gs c featherstep        # Feather Step on target
//gs c stutter            # Stutter Step on target

# Flourishes
//gs c violent            # Violent Flourish on target
//gs c desperate          # Desperate Flourish on target  
//gs c reverse            # Reverse Flourish for TP

# Waltz and healing
//gs c waltz              # Curing Waltz III on self
//gs c waltz party        # Divine Waltz on party
//gs c divine             # Divine Waltz on party
//gs c samba              # Haste Samba
```

## 🔧 Technical Commands

### Diagnosis and Maintenance

```bash
//gs c status             # Complete system status
//gs c debug              # Toggle debug mode (verbose)
//gs c version            # Detailed version information
//gs c dependencies       # Check module status
```

### Cache and Optimization

```bash
//gs c clear_cache        # Clear all system caches
//gs c cache_stats        # Display cache statistics
//gs c modules            # Module status and management
//gs c modules stats      # Detailed module statistics
//gs c modules cleanup    # Cleanup unused modules
```

### Interface and Position

```bash
//gs c ui                 # Toggle UI keybind visibility
//gs c uisave             # Save current UI position
//gs c ui_update_silent   # Silent UI update
```

### Advanced Alt Commands

```bash
//gs c altentrust         # Entrust current Indi to main character
//gs c altnuke            # Elemental nuke with alt character
//gs c cycle altPlayerTier # Cycle alt spell tiers (IV, V, VI)
//gs c cycle altPlayerLight # Cycle alt light elements
//gs c cycle altPlayerDark  # Cycle alt dark elements
```

## 💡 Tips for Beginners

### First Start

1. **Start with** `//gs c help` to see the main menu
2. **Check your equipment** with `//gs c checksets`
3. **Configure your alt** with `//gs c setjob <JOB>`
4. **Explore keybinds** with `//gs c binds`

### Easy Dual-Boxing

1. **Once alt is configured**, use `//gs c dual` to see all commands
2. **Commands adapt**: no need to memorize, the system guides you
3. **Automatic feedback**: each command informs you of the result

### Troubleshooting

- **Items not detected?** → `//gs c clear_cache`
- **Commands not working?** → `//gs c status`  
- **Slow performance?** → `//gs c perf start` then `//gs c perf report`

## 🎲 Practical Examples

### Typical Dual-Box Configuration

```bash
# Configure alt GEO
//gs c setjob GEO

# Check configuration  
//gs c dual

# Cast buffs
//gs c altindi            # Indi-Haste on you
//gs c altgeo             # Geo-Malaise on target
```

### Optimized Farming Session

```bash
# Performance monitoring
//gs c perf start

# Main job auto-buffs
//gs c thfbuff

# Alt buffs if RDM configured
//gs c bufftank

# At the end, check performance
//gs c perf report
```

The system is designed to be **intuitive**: commands appear and disappear according to your configuration, naturally guiding you toward what's possible.
