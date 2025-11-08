# DataLoader - Système d'Accès Universel aux Données FFXI

## 🎯 Objectif

Permettre à **N'IMPORTE QUEL JOB** d'accéder à **N'IMPORTE QUELLE DONNÉE** (spells, abilities, weaponskills), même si le job ne peut normalement pas les utiliser.

### Cas d'usage

- **WAR/BLU** peut afficher les descriptions des spells BLU
- **DNC/WHM** peut accéder aux data de Cure pour calculer les potencies
- **UI/HUD** peut afficher toutes les données sans restriction de job
- **Debugging** peut inspecter n'importe quelle donnée

---

## 📊 Architecture

```
MODULAR FILES (858 spells)
├── dark/dark_absorb.lua (10 spells)
├── elemental/helix.lua (16 spells)
├── blu/physical/blu_physical_slashing.lua (21 spells)
└── etc...
         ↓
AGGREGATORS (14 databases)
├── DARK_MAGIC_DATABASE.lua (loads dark/*.lua, exports 26 spells)
├── ELEMENTAL_MAGIC_DATABASE.lua (loads elemental/*.lua, exports 115 spells)
├── BLU_SPELL_DATABASE.lua (loads blu/*/*.lua, exports 196 spells)
└── etc...
         ↓
DATA_LOADER.lua (loads ALL aggregators)
├── Merges ALL spell databases >> _G.FFXI_DATA.spells
├── Merges ALL job abilities >> _G.FFXI_DATA.abilities
└── Merges ALL weaponskills >> _G.FFXI_DATA.weaponskills
         ↓
GLOBAL ACCESS (anywhere in code)
_G.FFXI_DATA.spells['Cure III']
_G.FFXI_DATA.abilities['Provoke']
_G.FFXI_DATA.weaponskills['Savage Blade']
```

---

## 🚀 Usage

### 1. Charger le DataLoader (une seule fois)

Dans n'importe quel fichier principal (ex: `TETSOUO_WAR.lua`):

```lua
-- Charge automatiquement TOUS les spells au démarrage
require('shared/utils/data/data_loader')
```

**Note:** Les spells sont chargés automatiquement, les abilities/weaponskills se chargent on-demand.

### 2. Accéder aux données

#### Méthode 1: Via DataLoader (recommandé)

```lua
local DataLoader = require('shared/utils/data/data_loader')

-- Query spell
local cure3 = DataLoader.get_spell('Cure III')
if cure3 then
    print(cure3.description)  -- "Restores HP (tier 3)."
    print(cure3.mp_cost)      -- 46
end

-- Query ability
local provoke = DataLoader.get_ability('Provoke')
if provoke then
    print(provoke.description)  -- "Provokes enemy."
    print(provoke.recast)       -- 30
end

-- Query weaponskill
local savage_blade = DataLoader.get_weaponskill('Savage Blade')
if savage_blade then
    print(savage_blade.type)         -- "Physical"
    print(savage_blade.skillchain)   -- {"Scission", "Detonation"}
end
```

#### Méthode 2: Via table globale (direct)

```lua
-- Après require('shared/utils/data/data_loader'), accessible partout:

-- Spells
local spell = _G.FFXI_DATA.spells['Foot Kick']
print(spell.description)  -- "Deals slashing dmg."
print(spell.category)     -- "Physical"
print(spell.damage_type)  -- "Slashing"

-- Abilities
local ability = _G.FFXI_DATA.abilities['Blood Rage']
print(ability.description)  -- "Party critical hit boost"

-- Weaponskills
local ws = _G.FFXI_DATA.weaponskills['Upheaval']
print(ws.element)  -- "Earth"
```

---

## 🎓 Exemples Pratiques

### Example 1: WAR/BLU affiche spell BLU

```lua
-- Dans WAR_COMMANDS.lua
function job_self_command(cmdParams, eventArgs)
    if cmdParams[1] == 'checkspell' then
        local spell_name = cmdParams[2] or 'Foot Kick'

        local DataLoader = require('shared/utils/data/data_loader')
        local spell = DataLoader.get_spell(spell_name)

        if spell then
            add_to_chat(001, string.format('[%s] %s', spell_name, spell.description))
            if spell.notes then
                add_to_chat(002, spell.notes)
            end
        else
            add_to_chat(167, string.format('Spell "%s" not found', spell_name))
        end

        eventArgs.handled = true
    end
end
```

**Usage in-game:**

```
//gs c checkspell Cure III
[Cure III] Restores HP (tier 3).
MP: 46. Level: 17. Trait: None. Potency: ~150 HP. WHM-only.

//gs c checkspell Foot Kick
[Foot Kick] Deals slashing dmg.
Physical slashing damage. Level: 1. Trait: Lizard Killer (4 pts). Skillchain: Detonation. Uses TP. BLU only.
```

### Example 2: UI affiche toutes les Cure spells

```lua
-- Dans UI module
local DataLoader = require('shared/utils/data/data_loader')

function show_all_cures()
    local cures = {}

    -- Iterate toutes les spells
    for spell_name, spell_data in pairs(_G.FFXI_DATA.spells) do
        if spell_name:match('^Cure') then
            table.insert(cures, {
                name = spell_name,
                mp = spell_data.mp_cost or 0,
                description = spell_data.description
            })
        end
    end

    -- Sort by MP cost
    table.sort(cures, function(a, b) return a.mp < b.mp end)

    -- Display
    for _, cure in ipairs(cures) do
        print(string.format('%s (MP: %d) - %s', cure.name, cure.mp, cure.description))
    end
end
```

**Output:**

```
Cure (MP: 8) - Restores HP (tier 1).
Cure II (MP: 24) - Restores HP (tier 2).
Cure III (MP: 46) - Restores HP (tier 3).
Cure IV (MP: 88) - Restores HP (tier 4).
Cure V (MP: 135) - Restores HP (tier 5).
Cure VI (MP: 252) - Restores HP (tier 6).
```

### Example 3: Weaponskill property lookup

```lua
-- Check if WS has specific skillchain
function has_skillchain(ws_name, sc_property)
    local DataLoader = require('shared/utils/data/data_loader')
    local ws = DataLoader.get_weaponskill(ws_name)

    if ws and ws.skillchain then
        for _, sc in ipairs(ws.skillchain) do
            if sc == sc_property then
                return true
            end
        end
    end

    return false
end

-- Usage
if has_skillchain('Savage Blade', 'Scission') then
    print('Savage Blade can Scission!')
end
```

---

## 📦 Données Disponibles

### Spells (~858 spells)

**Champs communs:**

- `description` - Ultra-concise (3-5 mots)
- `notes` - Comprehensive details
- `category` - Type de spell
- `element` - Elemental affinity
- `magic_type` - Black/White/Blue/Song/etc.
- `mp_cost` - MP cost (si applicable)

**Categories:**

- Dark Magic (26)
- Divine Magic (12)
- Elemental Magic (115)
- Enfeebling Magic (35)
- Enhancing Magic (139)
- Healing Magic (32)
- Geomancy (60)
- Song (107)
- Summoning (136)
- Blue Magic (196)

### Abilities (~400 abilities)

**Champs communs:**

- `description` - Effect description
- `level` - Unlock level
- `recast` - Recast time (seconds)
- `main_job_only` - true/false
- `cumulative_enmity` - CE value
- `volatile_enmity` - VE value

**Jobs:**

- Tous les 21 jobs (WAR, PLD, DNC, etc.)
- Mainjob + Subjob abilities
- SP abilities
- Pet commands (BST/DRG/PUP/SMN)

### Weaponskills (~200 weaponskills)

**Champs communs:**

- `description` - Effect description
- `type` - Physical/Magical/Hybrid
- `mods` - Stat modifiers (STR%, DEX%, etc.)
- `hits` - Number of hits
- `element` - Elemental affinity
- `skillchain` - Skillchain properties
- `ftp` - TP modifier values
- `jobs` - Job availability

**Weapon types:**

- Sword, Greatsword, Katana, Great Katana
- Axe, Great Axe, Scythe, Polearm
- Club, Staff, Dagger, H2H
- Archery, Universal

---

## ⚡ Performance

**Memory:**

- Spells: Auto-loaded (~858 entries)
- Abilities: Lazy-loaded (~400 entries)
- Weaponskills: Lazy-loaded (~200 entries)

**Loading time:**

- Initial load: ~0.5s (spells only)
- First ability query: ~0.2s (loads all abilities)
- First weaponskill query: ~0.1s (loads all weaponskills)
- Subsequent queries: Instant (table lookup)

**Optimization:**

- Safe pcall: Never crashes on missing files
- Deduplication: Priorité aux skill-based databases
- Global cache: Une seule copie en mémoire

---

## 🔧 Integration dans Existing Jobs

### Option 1: Global load (recommandé)

Dans `TETSOUO_[JOB].lua`:

```lua
function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')

    -- Load universal data access
    require('shared/utils/data/data_loader')

    include('jobs/[job]/functions/[job]_functions.lua')
end
```

### Option 2: On-demand load

Dans un module spécifique (ex: `WAR_COMMANDS.lua`):

```lua
function job_self_command(cmdParams, eventArgs)
    if cmdParams[1] == 'spellinfo' then
        -- Load data only when needed
        local DataLoader = require('shared/utils/data/data_loader')
        local spell = DataLoader.get_spell(cmdParams[2])
        -- ...
    end
end
```

---

## ✅ Testing

### Test 1: Vérifier chargement

```lua
//lua i
> require('shared/utils/data/data_loader')
[DataLoader] Loaded 858 spells

> #_G.FFXI_DATA.spells
858

> _G.FFXI_DATA.spells['Cure III']
{description = "Restores HP (tier 3).", mp_cost = 46, ...}
```

### Test 2: Query cross-job

```lua
-- WAR job peut query BLU spells
> local spell = _G.FFXI_DATA.spells['Foot Kick']
> print(spell.description)
Deals slashing dmg.

> print(spell.damage_type)
Slashing
```

### Test 3: Abilities

```lua
> local DataLoader = require('shared/utils/data/data_loader')
> DataLoader.load_abilities()
[DataLoader] Loaded 400 job abilities

> local provoke = _G.FFXI_DATA.abilities['Provoke']
> print(provoke.description)
Provokes enemy.
```

---

## 📚 Related Files

- **Source:** `shared/utils/data/data_loader.lua`
- **Spell Aggregators:** `shared/data/magic/*_DATABASE.lua`
- **Modular Spells:** `shared/data/magic/*/`
- **Job Abilities:** `shared/data/job_abilities/*/`
- **Weaponskills:** `shared/data/weaponskills/`

---

## 🎉 Benefits

✅ **Accès universel** - N'importe quel job accède à n'importe quelle donnée
✅ **Zero duplication** - Une seule source de vérité
✅ **Type-safe** - Tables structurées avec champs consistents
✅ **Extensible** - Facile d'ajouter de nouvelles queries
✅ **Performance** - Cache global, lazy loading
✅ **Safe** - Never crashes (pcall protection)

---

**Version:** 1.0
**Author:** Tetsouo
**Date:** 2025-11-01
