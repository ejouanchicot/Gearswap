# User Interface System

## 🎯 Concept

Real-time visual interface displaying GearSwap states with keybinds organized by job, dynamic colors and saved positioning.

## 🎮 Main Commands

```bash
//gs c ui                 # Toggle UI visibility
//gs c uisave             # Save position manually
```

## 🎨 Color System

### Elemental Colors

- **Fire** → Bright red
- **Ice** → Light blue
- **Wind** → Light green
- **Earth** → Brown
- **Lightning** → Purple-pink
- **Water** → Blue
- **Light** → White
- **Dark** → Dark purple

### Stat Colors

- **STR** → Red
- **DEX** → Purple-pink
- **VIT** → Brown
- **AGI** → Green
- **INT** → Purple
- **MND** → Light blue
- **CHR** → White

### Status Indicators

- **Active** → Bright green
- **Inactive** → Bright red
- **Unknown** → Yellow

## 🗂️ Supported Jobs

### Example Layouts

#### BRD (Bard)

```text
Key    Function         Current
1      BRD Rotation     Honor March
2      Victory March    Victory March
3      Type Etude       STR
4      Carol Element    Fire
5      Threnody Element Ice
       Slot 1           Honor March
       Slot 2           Victory March
       Slot 3           Minuet V
```

#### BLM (Black Mage)

```text
── Spells ──
Key    Function         Current
F1     Main Light       Fire
F2     Main Dark        Drain
F3     Sub Light        Thunder
F5     Aja Spell        Firaja
F6     Spell Tier       III

── Modes ──
F9     Casting Mode     MagicBurst
```

#### THF (Thief)

```text
Key    Function         Current
F1     Main Weapon      Twashtar
F2     Sub Weapon       Taming Sari
F3     Abyssea Proc     false
F5     Hybrid Mode      Normal
F6     Treasure Mode    Tag
```

## 🔧 Features

### Auto-Positioning

- **Draggable Interface** : Click-drag to reposition
- **Auto-Save** : Position saved automatically
- **Restoration** : Position restored on reload/zone change

### Smart Organization

#### Magic Jobs (BLM, GEO, RDM)

- **Spells Section** : Elemental magic, tiers, specials
- **Colure Section** : (GEO) Geo/Indi spells
- **Weapons Section** : Main/Sub
- **Modes Section** : Combat, casting

#### Melee Jobs (THF, WAR, DNC)

- **Weapons Section** : Multiple weapon sets
- **Abilities Section** : (DNC) Specialized steps
- **Modes Section** : Hybrid, treasure, combat

#### Support Jobs (BRD, BST)

- **Songs/Pet** : Main mechanics
- **Real-Time Slots** : (BRD) Active song tracking
- **Weapons Section** : Standard
- **Modes Section** : Support-specific

### Dynamic Display

```lua
-- Elemental color example
local element_colors = {
    Fire = "\\cs(255,100,100)",      -- Bright red
    Ice = "\\cs(150,200,255)",       -- Light blue
    Wind = "\\cs(150,255,150)",      -- Light green
}

-- Special tier handling
if state_name == "TierSpell" and result == "" then
    result = "I"  -- Display Tier I instead of empty
end
```

## 🚀 Configuration

### Settings Structure

```lua
local ui_settings = {
    pos = { 
        x = saved_settings.pos.x,
        y = saved_settings.pos.y 
    },
    text = { 
        size = 12,
        font = 'Consolas',
        stroke = { width = 2, alpha = 255, red = 0, green = 0, blue = 0 }
    },
    bg = { 
        alpha = 200,
        red = 10, green = 10, blue = 25,
        visible = true 
    },
    flags = { 
        draggable = true,
        bold = true
    }
}
```

### Auto-Save

```lua
-- Position saved when UI moved
function save_position(x, y)
    saved_settings.pos.x = x
    saved_settings.pos.y = y
    KeybindSettings.save(saved_settings)
end
```

## 🔄 System Integration

### State Management

```lua
-- UI updates automatically
function update_display()
    for _, keybind in ipairs(current_job_keybinds) do
        local current_value = get_state_value(keybind.state, keybind.key)
        local color = get_value_color(current_value, keybind.description)
    end
end
```

### Job Detection

```lua
function get_current_job_keybinds()
    local job = player and player.main_job or "UNK"
    
    if job == "BLM" then
        return blm_keybind_layout
    elseif job == "GEO" then  
        return geo_keybind_layout
    end
end
```

## 🛠️ Troubleshooting

### Common Issues

- **UI invisible** → `//gs c ui` to toggle visibility
- **Missing colors** → Check Windower color support
- **Position not saved** → `//gs c uisave` to force save
- **Slow performance** → Check memory leaks, restart GearSwap

### Debug

```lua
settings.ui = {
    debug_updates = true,
    debug_colors = true,
    debug_positioning = true,
    show_performance_metrics = true
}
```

## 💡 Optimization

### Performance

- **Lazy Rendering** : Elements rendered only if visible
- **Color Cache** : Color lookups cached
- **Update Throttling** : Position checks optimized
- **Memory Cleanup** : Resources freed on job change

The UI system provides an intuitive interface with real-time visual feedback for all jobs, customizable positioning and complete integration with GearSwap systems.
