# Architecture du Système Job

## 🎯 Jobs Supportés

### Personnage Principal (Tetsouo)

- **THF** - Treasure Hunter + SA/TA automation
- **WAR** - DPS mêlée avec gestion stance
- **BLM** - Sorts élémentaires + Magic Burst
- **PLD** - Tank avec enmity et défense
- **BST** - Coordination pet + écosystème
- **DNC** - DPS support + steps
- **DRG** - Coordination wyvern
- **RUN** - Tank magique + runes
- **BRD** - Gestion songs avancée
- **RDM** - Lanceur hybride

### Personnage Alt (Kaories)

- **GEO** - Sorts Geo/Indi complets
- **RDM** - Support dual-boxing
- **COR** - Support roll et ranged
- **PLD** - Configuration alt tank

## 🏗️ Architecture Standard

### Structure Fichiers

```text
jobs/[job]/
├── [JOB]_SET.lua      # Sets équipement
└── [JOB]_FUNCTION.lua # Mécaniques spécifiques
```

### Fichiers Personnages

```text
TETSOUO_[JOB].lua     # Configuration principale
KAORIES_[JOB].lua     # Configuration alt (4 jobs)
```

## 🛠️ Création Sets d'Équipement

### Exemple THF

```lua
local factory = require('utils/EQUIPMENT_FACTORY')

-- Sets engaged
sets.engaged.Normal = {
    head = factory.create('Adhemar Bonnet +1', 10),
    body = factory.create('Abnoba Kaftan', 8),
    hands = factory.create('Adhemar Wrist. +1', 10)
}

-- Sets Treasure Hunter
sets.TreasureHunter = {
    head = factory.create('White Rarab Cap +1', 15),
    hands = factory.create('Plun. Armlets +3', 15),
    feet = factory.create('Skulk. Poulaines +1', 15)
}
```

## 🎮 Fonctionnalités Principales

### BLM - Système Sort

```lua
state.MainLightSpell = M('Fire', 'Thunder', 'Blizzard', 'Aero', 'Stone', 'Water')
state.TierSpell = M('III', 'II', '')  -- Chaîne vide = Tier I
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

### GEO - Sorts Colure (Alt)

```lua
state.GeoSpell = M(
    'Geo-Haste', 'Geo-Refresh', 'Geo-Focus', 'Geo-Fury',
    'Geo-Malaise', 'Geo-Frailty', 'Geo-Languor'
    -- 30+ sorts disponibles
)
```

### BST - Gestion Pet

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

## 🔧 Gestion d'État

### Framework Mote

```lua
-- États standard
state.WeaponSet = M('MainWeapon', 'AltWeapon', 'ProcWeapon')
state.HybridMode = M('Normal', 'PDT', 'MDT') 
state.OffenseMode = M('Normal', 'Acc', 'SomeAcc')

-- Gestionnaire changements
function job_state_change(stateField, newValue, oldValue)
    if stateField == 'WeaponSet' then
        equip_weapon_set(newValue)
    end
end
```

## 🚀 Initialisation Job

### Processus de Chargement

1. **Framework Mote** : Base GearSwap
2. **Modules Core** : SafeLoader, globals, config
3. **Modules Job** : SET.lua + FUNCTION.lua spécifiques
4. **Dual-Boxing** : Coordination alt
5. **Macros** : Application livre macro automatique
6. **UI** : Configuration keybinds

### Template Standard

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

## 🛠️ Dépannage

### Problèmes Courants

- **Job ne charge pas** → Vérifiez nommage fichier `TETSOUO_[JOB].lua`
- **Équipement ne change pas** → `//gs c checksets` pour validation
- **États ne se mettent pas à jour** → Vérifiez configuration keybinds
- **Erreurs modules** → Vérifiez messages SafeLoader

### Debug

```lua
function job_debug_info()
    add_to_chat(122, 'Job : ' .. player.main_job .. '/' .. player.sub_job)
    add_to_chat(122, 'Sets chargés : ' .. #sets_loaded)
    add_to_chat(122, 'Modules chargés : ' .. #modules_loaded)
end
```

## 💡 Bonnes Pratiques

### Architecture

1. **Split SET/FUNCTION** : Séparez équipement et logique
2. **SafeLoader** : Toutes dépendances via SafeLoader
3. **Equipment Factory** : Utilisez `factory.create()` pour équipement
4. **États Mote** : Framework pour gestion état
5. **Gestion Erreur** : Validation et fallbacks

### Performance

1. **Chargement Paresseux** : Modules à la demande
2. **Cache** : Données fréquentes en cache
3. **Efficacité Événements** : Opérations légères
4. **Nettoyage Ressources** : Libération mémoire

Le système job fournit une automation FFXI complète avec 10 jobs principaux et 4 jobs alt, architecture modulaire et performance optimisée.