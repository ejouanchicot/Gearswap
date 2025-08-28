# System Architecture

## 🏗️ General Structure

### Module Organization

```text
├── core/                    # Système principal
│   ├── GLOBALS.lua         # Fonctions globales
│   └── UNIVERSAL_COMMANDS.lua  # Commandes communes
├── config/                  # Configuration
│   ├── settings.lua        # Paramètres utilisateur
│   └── config.lua          # Accès configuration
├── utils/                   # Utilitaires
│   ├── SAFE_LOADER.lua     # Chargement sécurisé
│   ├── EQUIPMENT_FACTORY.lua   # Création équipement
│   └── MESSAGES.lua        # Messages système
├── jobs/                    # Jobs spécifiques
│   ├── thf/THF_SET.lua     # Sets équipement THF
│   ├── thf/THF_FUNCTION.lua    # Fonctions THF
│   └── blm/BLM_SET.lua     # Sets équipement BLM
├── features/               # Fonctionnalités
│   └── DUALBOX.lua        # Dual-boxing
└── ui/                     # Interface
    ├── KEYBIND_UI.lua     # Affichage UI
    └── KEYBIND_SETTINGS.lua   # Sauvegarde UI
```

## ⚙️ Main Components

### SafeLoader

Safe module loading:

```lua
local SafeLoader = require('utils/SAFE_LOADER')
local module = SafeLoader.require('path/module')  -- Does not crash if missing
```

### Equipment Factory

Standardized equipment creation:

```lua
local factory = require('utils/EQUIPMENT_FACTORY')
local weapon = factory.create('Twashtar', 15, 'inventory')
```

### State Management

Gestion des états via framework Mote :

```lua
state.MainWeapon = M('Twashtar', 'Naegling', 'Tauret')

function job_state_change(field, new_value, old_value)
    -- Auto-triggered quand état change
    update_equipment_for_state(field, new_value)
end
```

## 📊 Flux de Données

### Changement d'État

```text
Keybind Utilisateur (F1)
    ↓
Changement État (state.MainWeapon)
    ↓
job_state_change() déclenché
    ├── Mise à jour UI
    ├── Changement équipement
    └── Fonctions job spécifiques
```

### Dual-Boxing

```text
Commande Principal (//gs c altgeo)
    ↓
Détection Alt Job (lecture fichier job)
    ↓
Génération Commande
    ├── Sélection cible (buff vs debuff)
    ├── Commande spell appropriée
    └── send command vers alt
```

### Validation Équipement

```text
Demande équipement
    ↓
Factory validation
    ├── Nom correct
    ├── Priorité valide
    └── Bag accessible
    ↓
Intégration dans set
    ├── Vérification disponibilité
    └── Application équipement
```

## 🔄 Intégrations

### Windower

```lua
windower.register_event('addon command', handle_commands)
windower.register_event('job change', reload_job)
windower.send_command('send Alt input /ma "Geo-Haste" <stpc>')
```

### GearSwap

```lua
function get_sets()          -- Initialisation
function job_setup()         -- Configuration job
function job_precast()       -- Avant action
function job_aftercast()     -- Après action
```

### Mote Framework

```lua
state.OffenseMode = M('Normal', 'Acc')
state.HybridMode = M('Normal', 'PDT', 'MDT')
```

## 🛡️ Gestion Erreurs

### Chargement Sécurisé

```lua
local success, result = pcall(risky_function)
if not success then
    ErrorHandler.report_error(result, 'WARNING')
    result = safe_default()
end
```

### Fallbacks Progressifs

1. Fonction principale
2. Fonction fallback
3. Valeur par défaut sécurisée

## 🚀 Performance

### Chargement Paresseux

```lua
-- Modules chargés seulement quand nécessaires
local function get_module()
    if not cached_module then
        cached_module = SafeLoader.require('expensive/MODULE')
    end
    return cached_module
end
```

### Limitation Événements

```lua
-- UI mise à jour toutes les 2 secondes max
local throttle = 0
windower.register_event('time change', function()
    throttle = throttle + 1
    if throttle >= 4 then
        throttle = 0
        update_ui()
    end
end)
```

## 📈 Extensibilité

### Ajout Nouveau Job

1. Créer `jobs/newjob/NEWJOB_SET.lua`
2. Créer `jobs/newjob/NEWJOB_FUNCTION.lua`
3. Copier `TETSOUO_NEWJOB.lua`
4. Système détecte automatiquement

### Module Personnalisé

```lua
if SafeLoader.is_available('custom/my_module') then
    local MyModule = SafeLoader.require('custom/my_module')
    MyModule.initialize()
end
```

This modular architecture allows easy extension while maintaining the stability of the main system.
