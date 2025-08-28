# Référence API

## 🔧 Fonctions Principales

### Configuration

```lua
local config = require('config/config')

-- Obtenir valeurs
local player_name = config.get('players.main')
local debug_mode = config.get('debug.enabled', false)

-- Définir valeurs
config.set('debug.enabled', true)
```

### Équipement

```lua
local factory = require('utils/EQUIPMENT_FACTORY')

-- Créer équipement
local helm = factory.create('Adhemar Bonnet +1', 10)
local weapon = factory.create('Twashtar', 15, 'inventory')

-- Validation équipement
local results = EquipmentValidator.validate_all_sets()
-- Retourne: { success_rate = 0.97, found_count = 239, total_items = 247 }
```

### Dual-Boxing

```lua
local dualbox = require('features/DUALBOX')

-- Vérifications alt
local alt_job = dualbox.get_alt_job()           -- 'GEO', 'RDM', nil
local available = dualbox.is_alt_available()    -- true/false

-- Commandes alt
dualbox.send_command('input /ma "Geo-Haste" <stpc>')
dualbox.send_command('input /ja "Full Circle" <me>', 2)  -- avec délai
```

### Messages

```lua
local msg = require('utils/MESSAGES')

msg.success('Équipement validé: 97% trouvé')
msg.error('Job file non trouvé')
msg.warning('Équipement manquant: Regal Ring')
msg.info('Alt job changé: GEO')
```

## 🎮 États et Jobs

### Gestion États

```lua
-- Créer états
state.MainWeapon = M('Twashtar', 'Naegling', 'Tauret')
state.TreasureMode = M('None', 'Tag', 'Fulltime')

-- Gestionnaire changements
function job_state_change(field, new_value, old_value)
    if field == 'MainWeapon' then
        equip_weapon_set(new_value)
    end
end
```

### Structure Job

```lua
function get_sets()
    -- Initialisation
    include('Mote-Include.lua')
    include('core/GLOBALS.lua')
    
    -- Sets équipement
    sets.engaged.Normal = {
        head = factory.create('Adhemar Bonnet +1', 10),
        body = factory.create('Abnoba Kaftan', 8)
    }
end

function job_setup()
    -- Configuration job spécifique
    state.TreasureMode.value = 'Tag'
end
```

## 🖥️ Interface UI

### Keybind UI

```lua
-- Mise à jour automatique UI
function update_keybind_display()
    if KeybindUI then
        KeybindUI.update()
    end
end

-- Couleurs personnalisées
function get_job_specific_color(value, description)
    if description:find('Geo') then
        return "\\cs(255,255,150)"  -- Jaune
    end
    return nil  -- Couleur par défaut
end
```

### Paramètres UI

```lua
local settings = require('ui/KEYBIND_SETTINGS')

-- Sauvegarder position
settings.save({ pos = { x = 100, y = 200 } })

-- Charger paramètres
local ui_settings = settings.load() or {}
```

## ⚙️ Commandes

### Enregistrement Commandes

```lua
-- Commandes universelles
function handle_universal_command(params)
    local cmd = params[1]:lower()
    
    if cmd == 'checksets' then
        validate_equipment()
        return true
    end
    
    return false
end

-- Commandes job spécifiques
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

-- Enregistrer métrique
local start_time = os.clock()
expensive_operation()
monitor.record('operation_name', os.clock() - start_time)

-- Statistiques
local stats = monitor.get_statistics()
```

### Gestion Erreurs

```lua
local errors = require('utils/ERROR_HANDLER_LIGHTWEIGHT')

-- Signaler erreur
errors.report_error('Message erreur', 'WARNING')

-- Avec récupération
local success, result = pcall(risky_function)
if not success then
    errors.report_error(result, 'ERROR')
    result = fallback_value()
end
```

## 🔗 Intégration

### Événements Windower

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

### Modules Personnalisés

```lua
-- Charger module optionnel
if SafeLoader.is_available('custom/my_module') then
    local MyModule = SafeLoader.require('custom/my_module')
    MyModule.initialize()
end
```

Cette référence couvre les APIs principales pour personnaliser et étendre le système GearSwap.
