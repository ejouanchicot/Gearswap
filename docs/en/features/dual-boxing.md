# Dual-Boxing System

## 🎯 Concept

Automatic coordination between your main character and your alt with intelligent job detection and adapted commands.

## ⚙️ Configuration

### Character Configuration

```lua
settings.players = {
    main = 'Tetsouo',     -- Your main character
    alt_enabled = true,   -- Enable dual-boxing
    alt = 'Kaories',      -- Your alt character
}
```

### Alt Job Detection

The system automatically reads your alt's job via `{alt_name}_job.txt` and adapts available commands.

## 🎮 Main Commands

The system automatically detects your alt's job. If needed, use `//gs c setjob <JOB>` to set manually.

### Alt GEO

```bash
//gs c altgeo             # Geo spell on appropriate target
//gs c altindi            # Indi spell on you
//gs c altentrust         # Entrust Indi to main character
```

### Alt RDM

```bash
//gs c bufftank           # Haste2 + Refresh3 + Phalanx2 + Regen2
//gs c buffmelee          # Haste2 + Phalanx2 + Regen2
//gs c buffrng            # Flurry2 + Phalanx2 + Regen2
//gs c debuff             # Distract3 + Dia3 + Slow2 + Blind2 + Paralyze2
```

### Alt BRD

```bash
//gs c song1              # Song slot 1
//gs c song2              # Song slot 2
//gs c honor              # Honor March
//gs c victory            # Victory March
```

## 🔧 How It Works

1. **Auto Detection**: The system detects your alt's job automatically
2. **Dynamic Macros**: Changes macro books according to main+alt combination
3. **Intelligent Targeting**: Buffs on you, debuffs on enemy
4. **Adapted Commands**: Only commands for the current alt job appear

## 🛠️ Troubleshooting

- **Alt not detected** → Check `alt_enabled = true` and exact spelling of names
- **Missing commands** → `//gs c setjob <JOB>` to force alt job  
- **Spells badly targeted** → Check character name configuration
