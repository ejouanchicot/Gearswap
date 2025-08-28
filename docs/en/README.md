# GearSwap Documentation

## ⚡ Quick Start

### 5 Minutes to Get Started

1. **[Getting Started Guide](guides/getting-started.md)** - Immediate setup
2. Edit `Tetsouo/config/settings.lua` with your character name  
3. Copy the appropriate job file
4. Load with `//gs load YourName_JOB`

## 📚 Documentation

### Essential Guides

- **[Getting Started](guides/getting-started.md)** - 5-minute setup
- **[Command System](features/command-system.md)** - All commands
- **[Equipment System](features/equipment-system.md)** - Equipment management
- **[Dual-Boxing System](features/dual-boxing.md)** - Multi-character

### Technical References

- **[API Reference](reference/api.md)** - Development APIs
- **[Architecture](reference/architecture.md)** - System structure
- **[Performance](reference/performance.md)** - Optimization

## 🎮 Supported Jobs

### Main Character (10 jobs)

**THF** - **WAR** - **BLM** - **PLD** - **BST**  
**DNC** - **DRG** - **RUN** - **BRD** - **RDM**

### Alt Character (4 jobs)

**GEO** - **RDM** - **COR** - **PLD**

## ⚡ Essential Commands

```bash
//gs c help           # Complete help
//gs c checksets      # Validate equipment
//gs c ui             # Toggle interface
//gs c altgeo         # Alt GEO spells (if dual-boxing)
```

## 🔧 Minimal Configuration

```lua
-- Tetsouo/config/settings.lua
settings.players = {
    main = 'YourName',              -- ⚠️ CHANGE THIS
    alt_enabled = false             -- true if dual-boxing
}
```

## 🆘 Common Issues

- **Job won't load** → Check exact filename
- **Missing equipment** → `//gs c checksets`  
- **UI invisible** → `//gs c ui`
- **Alt not detected** → `//gs c status`

The system is designed to work immediately with minimal configuration.
