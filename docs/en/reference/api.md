# API Reference

## 🔧 Main Functions

### Configuration

```lua
local config = require('config/config')

-- Get values
local player_name = config.get('players.main')
local debug_mode = config.get('debug.enabled', false)

-- Set values
config.set('debug.enabled', true)
```

### Equipment

```lua
local factory = require('utils/EQUIPMENT_FACTORY')

-- Create equipment
local helm = factory.create('Adhemar Bonnet +1', 10)
local weapon = factory.create('Twashtar', 15, 'inventory')

-- Equipment validation
local results = EquipmentValidator.validate_all_sets()
-- Returns: { success_rate = 0.97, found_count = 239, total_items = 247 }
```

### Dual-Boxing

```lua
local dualbox = require('features/DUALBOX')

-- Alt checks
local alt_job = dualbox.get_alt_job()           -- 'GEO', 'RDM', nil
local available = dualbox.is_alt_available()    -- true/false

-- Alt commands
dualbox.send_command('input /ma "Geo-Haste" <stpc>')
dualbox.send_command('input /ja "Full Circle" <me>', 2)  -- with delay
```

### Messages

```lua
local msg = require('utils/MESSAGES')

msg.success('Equipment validated: 97% found')
msg.error('Job file not found')
msg.warning('Missing equipment: Regal Ring')
msg.info('Alt job changed: GEO')
```

## 🎮 States and Jobs

### State Management

```lua
-- Create states
state.MainWeapon = M('Twashtar', 'Naegling', 'Tauret')
state.TreasureMode = M('None', 'Tag', 'Fulltime')

-- Change handler
function job_state_change(field, new_value, old_value)
    if field == 'MainWeapon' then
        equip_weapon_set(new_value)
    end
end
```

### Job Structure

```lua
function get_sets()
    -- Initialization
    include('Mote-Include.lua')
    include('core/GLOBALS.lua')
    
    -- Equipment sets
    sets.engaged.Normal = {
        head = factory.create('Adhemar Bonnet +1', 10),
        body = factory.create('Abnoba Kaftan', 8)
    }
end

function job_setup()
    -- Job-specific configuration
    state.TreasureMode.value = 'Tag'
end
```

## 🖥️ Interface UI

### Keybind UI

```lua
-- Automatic UI update
function update_keybind_display()
    if KeybindUI then
        KeybindUI.update()
    end
end

-- Custom colors
function get_job_specific_color(value, description)
    if description:find('Geo') then
        return "\\cs(255,255,150)"  -- Yellow
    end
    return nil  -- Default color
end
```

### UI Settings

```lua
local settings = require('ui/KEYBIND_SETTINGS')

-- Save position
settings.save({ pos = { x = 100, y = 200 } })

-- Load settings
local ui_settings = settings.load() or {}
```

## ⚙️ Commandes

### Command Registration

```lua
-- Universal commands
function handle_universal_command(params)
    local cmd = params[1]:lower()
    
    if cmd == 'checksets' then
        validate_equipment()
        return true
    end
    
    return false
end

-- Job-specific commands
function handle_job_command(params)
    local cmd = params[1]:lower()
    
    if cmd == 'thfbuff' and player.main_job == 'THF' then
        execute_thf_buffs()
        return true
    end
    
    return false
end
```

## 📊 Monitoring

### Performance

```lua
local monitor = require('performance/PERFORMANCE_MONITOR')

-- Record metric
local start_time = os.clock()
expensive_operation()
monitor.record('operation_name', os.clock() - start_time)

-- Statistics
local stats = monitor.get_statistics()
```

### Error Handling

```lua
local errors = require('utils/ERROR_HANDLER_LIGHTWEIGHT')

-- Report error
errors.report_error('Error message', 'WARNING')

-- With recovery
local success, result = pcall(risky_function)
if not success then
    errors.report_error(result, 'ERROR')
    result = fallback_value()
end
```

## 🔗 Integration

### Windower Events

```lua
-- Job change
windower.register_event('job change', function(new_job)
    reload_job_config(new_job)
end)

-- Zone change
windower.register_event('zone change', function(new_zone)
    update_zone_settings(new_zone)
end)
```

### Custom Modules

```lua
-- Load optional module
if SafeLoader.is_available('custom/my_module') then
    local MyModule = SafeLoader.require('custom/my_module')
    MyModule.initialize()
end
```

This reference covers the main APIs for customizing and extending the GearSwap system.
