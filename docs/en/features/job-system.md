# Job System Architecture

## 🎯 Supported Jobs

### Main Character (Tetsouo)

- **THF** - Treasure Hunter + SA/TA automation
- **WAR** - Melee DPS with stance management
- **BLM** - Elemental spells + Magic Burst
- **PLD** - Tank with enmity and defense
- **BST** - Pet coordination + ecosystem
- **DNC** - DPS support + steps
- **DRG** - Wyvern coordination
- **RUN** - Magic tank + runes
- **BRD** - Advanced song management
- **RDM** - Hybrid caster

### Alt Character (Kaories)

- **GEO** - Complete Geo/Indi spells
- **RDM** - Dual-boxing support
- **COR** - Roll and ranged support
- **PLD** - Alt tank configuration

## 🏗️ Standard Architecture

### File Structure

```text
jobs/[job]/
├── [JOB]_SET.lua      # Equipment sets
└── [JOB]_FUNCTION.lua # Specific mechanics
```

### Character Files

```text
TETSOUO_[JOB].lua     # Main configuration
KAORIES_[JOB].lua     # Alt configuration (4 jobs)
```

## 🛠️ Equipment Set Creation

### THF Example

```lua
local factory = require('utils/EQUIPMENT_FACTORY')

-- Engaged sets
sets.engaged.Normal = {
    head = factory.create('Adhemar Bonnet +1', 10),
    body = factory.create('Abnoba Kaftan', 8),
    hands = factory.create('Adhemar Wrist. +1', 10)
}

-- Treasure Hunter sets
sets.TreasureHunter = {
    head = factory.create('White Rarab Cap +1', 15),
    hands = factory.create('Plun. Armlets +3', 15),
    feet = factory.create('Skulk. Poulaines +1', 15)
}
```

## 🎮 Main Features

### BLM - Spell System

```lua
state.MainLightSpell = M('Fire', 'Thunder', 'Blizzard', 'Aero', 'Stone', 'Water')
state.TierSpell = M('III', 'II', '')  -- Empty string = Tier I
state.Aja = M('Firaja', 'Thundaja', 'Blizzaja', 'Aeroja', 'Stonja', 'Waterja')
```

### THF - Treasure Hunter

```lua
state.TreasureMode = M('None', 'Tag', 'SATA', 'Fulltime')

function apply_TH_on_action(action)
    if state.TreasureMode.value == 'Tag' then
        equip(sets.TreasureHunter)
    end
end
```

### GEO - Colure Spells (Alt)

```lua
state.GeoSpell = M(
    'Geo-Haste', 'Geo-Refresh', 'Geo-Focus', 'Geo-Fury',
    'Geo-Malaise', 'Geo-Frailty', 'Geo-Languor'
    -- 30+ spells available
)
```

### BST - Pet Management

```lua
local ecosystem_pets = {
    ['Demon'] = 'Dire Broth',
    ['Beast'] = 'Livid Broth', 
    ['Lizard'] = 'Honey Broth'
}

function select_optimal_pet(target_ecosystem)
    local broth = ecosystem_pets[target_ecosystem]
    if broth then
        state.JugPet.value = broth
    end
end
```

## 🔧 State Management

### Framework Mote

```lua
-- Standard states
state.WeaponSet = M('MainWeapon', 'AltWeapon', 'ProcWeapon')
state.HybridMode = M('Normal', 'PDT', 'MDT') 
state.OffenseMode = M('Normal', 'Acc', 'SomeAcc')

-- Change handler
function job_state_change(stateField, newValue, oldValue)
    if stateField == 'WeaponSet' then
        equip_weapon_set(newValue)
    end
end
```

## 🚀 Job Initialization

### Loading Process

1. **Mote Framework** : GearSwap base
2. **Core Modules** : SafeLoader, globals, config
3. **Job Modules** : Specific SET.lua + FUNCTION.lua
4. **Dual-Boxing** : Alt coordination
5. **Macros** : Automatic macro book application
6. **UI** : Keybind configuration

### Standard Template

```lua
function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
    include('core/GLOBALS.lua')
    include('monitoring/SIMPLE_JOB_MONITOR.lua') 
    include('features/DUALBOX.lua')
    include('macros/MACRO_MANAGER.lua')
    include('jobs/' .. job:lower() .. '/' .. job .. '_SET.lua')
    include('jobs/' .. job:lower() .. '/' .. job .. '_FUNCTION.lua')
end
```

## 🛠️ Troubleshooting

### Common Issues

- **Job doesn't load** → Check file naming `TETSOUO_[JOB].lua`
- **Equipment doesn't change** → `//gs c checksets` for validation
- **States don't update** → Check keybind configuration
- **Module errors** → Check SafeLoader messages

### Debug

```lua
function job_debug_info()
    add_to_chat(122, 'Job: ' .. player.main_job .. '/' .. player.sub_job)
    add_to_chat(122, 'Sets loaded: ' .. #sets_loaded)
    add_to_chat(122, 'Modules loaded: ' .. #modules_loaded)
end
```

## 💡 Best Practices

### Architecture

1. **Split SET/FUNCTION** : Separate equipment and logic
2. **SafeLoader** : All dependencies via SafeLoader
3. **Equipment Factory** : Use `factory.create()` for equipment
4. **Mote States** : Framework for state management
5. **Error Handling** : Validation and fallbacks

### Performance

1. **Lazy Loading** : On-demand modules
2. **Cache** : Frequent data in cache
3. **Event Efficiency** : Lightweight operations
4. **Resource Cleanup** : Memory release

The job system provides complete FFXI automation with 10 main jobs and 4 alt jobs, modular architecture and optimized performance.