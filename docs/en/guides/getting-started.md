# GearSwap Quick Start

## ⚡ 5 Minutes to Get Started

### Step 1: Minimal Configuration

Edit **Tetsouo/config/settings.lua**:

```lua
settings.players = {
    main = 'YourCharacterName',     -- ⚠️ CHANGE THIS
    alt_enabled = false             -- true if dual-boxing
}
```

### Step 2: Copy Your Job

Copy the appropriate job file:

- **THF**: `TETSOUO_THF.lua` → `YourName_THF.lua`
- **BLM**: `TETSOUO_BLM.lua` → `YourName_BLM.lua`
- **WAR**: `TETSOUO_WAR.lua` → `YourName_WAR.lua`

### Step 3: Load

```bash
//gs load YourName_THF
```

## ✅ Quick Verification

Success messages to look for:

```text
[GearSwap] YourName_THF.lua loaded successfully
[KeybindUI] UI initialized successfully
```

## 🎮 Immediate Usage

### Essential Keybinds

- **F1-F6**: Cycle states (weapons, modes)
- **//gs c ui**: Toggle interface
- **//gs c help**: Complete help

### Main Commands

```bash
//gs c help          # Help menu
//gs c checksets     # Validate equipment
//gs c ui            # Toggle UI
```

## 🔧 If It Doesn't Work

1. **Job won't load** → Check exact filename
2. **Missing equipment** → `//gs c checksets`
3. **UI invisible** → `//gs c ui`

## 📖 Complete Documentation

- **Configuration**: `docs/en/features/configuration-system.md`
- **Equipment**: `docs/en/features/equipment-system.md`
- **Dual-Boxing**: `docs/en/features/dual-boxing.md`
- **UI Interface**: `docs/en/features/ui-system.md`
- **Commands**: `docs/en/features/command-system.md`

The system is designed to work immediately with minimal configuration.
