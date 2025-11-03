# AUDIT COMPLET: INIT_SYSTEMS.lua - Systèmes Universels

**Date:** 2025-10-28
**Objectif:** Déterminer quels systèmes `shared/utils` doivent être dans `INIT_SYSTEMS.lua`

---

## ✅ ACTUELLEMENT DANS INIT_SYSTEMS (Correct)

### 1. **Midcast Watchdog** (`shared/utils/core/midcast_watchdog.lua`)

**Type:** Protection universelle
**Statut:** ✅ Correct dans INIT_SYSTEMS

**Pourquoi universel:**

- Protège TOUS les jobs contre midcast freeze (timeout 3.5s)
- Aucune configuration job-specific requise
- Système de monitoring passif

**Initialisation:**

```lua
local watchdog_success, MidcastWatchdog = pcall(require, 'shared/utils/core/midcast_watchdog')
if watchdog_success and MidcastWatchdog then
    coroutine.schedule(function()
        MidcastWatchdog.start()
    end, 2.0)
end
```

---

### 2. **Warp System** (`shared/utils/warp/warp_init.lua`)

**Type:** Système universel avec IPC multi-boxing
**Statut:** ✅ Correct dans INIT_SYSTEMS

**Pourquoi universel:**

- Détection automatique des warp spells/items pour TOUS jobs
- Lock equipment pendant warp (protection universelle)
- IPC multi-boxing (`//gs c warpall`) pour coordination Tetsouo/Kaories
- Aucune configuration job-specific requise

**Initialisation:**

```lua
local warp_success, WarpInit = pcall(require, 'shared/utils/warp/warp_init')
if warp_success and WarpInit then
    WarpInit.init()
end
```

**Modules chargés automatiquement:**

- `warp_commands.lua` - Commandes warp (50+ destinations)
- `warp_ipc_register.lua` - IPC listener (global scope)
- `warp_precast.lua` - Detection precast
- `warp_equipment.lua` - Equipment lock

---

## ❌ NE DOIVENT PAS ÊTRE DANS INIT_SYSTEMS

### Catégorie 1: **Systèmes Job-Specific**

#### **shared/utils/dnc/waltz_manager.lua**

**Type:** Job-specific (DNC uniquement)
**Raison:** Waltz healing system = DNC only

#### **shared/utils/drg/DRG_JUMP_MANAGER.lua**

**Type:** Job-specific (DRG uniquement)
**Raison:** Jump auto-trigger = DRG only

#### **shared/utils/whm/**

- `cure_manager.lua` - WHM/RDM Cure logic
- `whm_message_formatter.lua` - WHM messages

**Raison:** Job-specific healing logic

---

### Catégorie 2: **Factories (Chargés par chaque job individuellement)**

#### **shared/utils/lockstyle/lockstyle_manager.lua**

**Type:** Factory pattern
**Raison:** Chaque job appelle `LockstyleManager.create()` dans son `[JOB]_LOCKSTYLE.lua`

**Exemple d'utilisation (DNC_LOCKSTYLE.lua):**

```lua
return LockstyleManager.create(
    'DNC',
    'config/dnc/DNC_LOCKSTYLE',
    1,
    'SAM'
)
```

#### **shared/utils/macrobook/macrobook_manager.lua**

**Type:** Factory pattern
**Raison:** Chaque job appelle `MacrobookManager.create()` dans son `[JOB]_MACROBOOK.lua`

**Exemple d'utilisation (DNC_MACROBOOK.lua):**

```lua
return MacrobookManager.create(
    'DNC',
    'config/dnc/DNC_MACROBOOK',
    'SAM',
    1,
    1
)
```

---

### Catégorie 3: **Systèmes À La Demande (On-Demand)**

#### **shared/utils/precast/**

- `cooldown_checker.lua` - Vérification cooldowns abilities/spells
- `ability_helper.lua` - Auto-trigger abilities (Climactic, Majesty, etc.)
- `tp_bonus_handler.lua` - Calcul TP bonus pour WS
- `ws_validator.lua` - Validation weaponskills

**Raison:** Modules `require()` dans les hooks `job_precast` de chaque job

**Exemple d'utilisation (DNC_PRECAST.lua):**

```lua
local CooldownChecker = require('utils/precast/cooldown_checker')
local AbilityHelper = require('utils/precast/ability_helper')

function job_precast(spell, action, spellMap, eventArgs)
    if spell.action_type == 'Ability' then
        CooldownChecker.check_ability_cooldown(spell, eventArgs)
    end
end
```

#### **shared/utils/midcast/midcast_manager.lua**

**Raison:** Utilisé dans `job_post_midcast` de chaque job via `require()`

**Exemple d'utilisation (DNC_MIDCAST.lua):**

```lua
local MidcastManager = require('shared/utils/midcast/midcast_manager')

function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.skill == 'Healing Magic' then
        MidcastManager.select_set({
            skill = 'Healing Magic',
            spell = spell
        })
    end
end
```

#### **shared/utils/weaponskill/**

- `weaponskill_manager.lua` - Validation WS (range, target, etc.)
- `tp_bonus_calculator.lua` - Calcul TP bonus

**Raison:** Chargés via `include()` dans les hooks precast de chaque job

#### **shared/utils/debuff/**

- `debuff_checker.lua` - Vérification debuffs actifs
- `precast_guard.lua` - Blocage actions sous debuffs (Amnesia, Silence, etc.)

**Raison:** Utilisés dans `job_precast` via `require()`

#### **shared/utils/equipment/equipment_checker.lua**

**Raison:** Commande `//gs c checksets` (validation equipment on-demand)

---

### Catégorie 4: **Message Formatters (Modules Passifs)**

#### **shared/utils/messages/**

Tous les `message_*.lua` (24 fichiers)

**Raison:** Modules de formatting utilisés via `require()` à la demande

**Exemples:**

- `message_formatter.lua` - Façade principale
- `message_cooldowns.lua` - Cooldown messages
- `message_dnc.lua` - DNC waltz messages
- `message_warp.lua` - Warp messages (utilisé par warp system)

**Usage typique:**

```lua
local MessageFormatter = require('utils/messages/message_formatter')
MessageFormatter.show_ws_tp(spell.name, current_tp)
```

---

### Catégorie 5: **UI System (Job-Level Initialization)**

#### **shared/utils/ui/**

Tous les `UI_*.lua` (9 fichiers)

**Raison:** UI initialisé par chaque job dans `user_setup()` via `KeybindUI.smart_init()`

**Exemple d'utilisation (Tetsouo_DNC.lua):**

```lua
function user_setup()
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.smart_init("DNC", UIConfig.init_delay)
    end
end
```

**Modules UI:**

- `UI_MANAGER.lua` - Manager principal
- `UI_DISPLAY_BUILDER.lua` - Construction affichage
- `UI_FORMATTER.lua` - Formatting
- `UI_SECTIONS.lua` - Sections keybinds
- `UI_COMMANDS.lua` - Commandes UI
- `COLOR_SYSTEM.lua` - Couleurs
- Etc.

---

### Catégorie 6: **Core Systems (Special Handling)**

#### **shared/utils/core/job_change_manager.lua**

**Type:** Job-level initialization
**Raison:** Initialisé par chaque job dans `user_setup()` avec job-specific callbacks

**Exemple d'utilisation (Tetsouo_DNC.lua):**

```lua
function user_setup()
    local jcm_success, JobChangeManager = pcall(require, 'utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.initialize({
            keybinds = DNCKeybinds,
            ui = KeybindUI,
            lockstyle = select_default_lockstyle,
            macrobook = select_default_macro_book
        })
    end
end
```

**Pourquoi pas dans INIT_SYSTEMS:**

- Nécessite des fonctions job-specific (`select_default_lockstyle`, `DNCKeybinds`, etc.)
- Initialization doit être APRÈS chargement des modules job

#### **shared/utils/core/COMMON_COMMANDS.lua**

**Type:** Command handler
**Raison:** Utilisé dans `job_self_command` de chaque job via `require()`

**Exemple d'utilisation (DNC_COMMANDS.lua):**

```lua
local CommonCommands = require('utils/core/COMMON_COMMANDS')

function job_self_command(cmdParams, eventArgs)
    if CommonCommands.is_common_command(command) then
        CommonCommands.handle_command(command, 'DNC')
    end
end
```

#### **shared/utils/core/test_registry.lua**

**Type:** Testing system
**Raison:** Système de test optionnel, pas production

---

## 🤔 CAS SPÉCIAUX - À DISCUTER

### 1. **AutoMove** (`shared/utils/movement/automove.lua`)

**Statut Actuel:** Chargé manuellement par chaque job via `include()`

**Exemple (Tetsouo_DNC.lua ligne 139):**

```lua
function get_sets()
    include('Mote-Include.lua')
    include('../shared/utils/movement/automove.lua')  -- Manuel
    include('../shared/jobs/dnc/functions/dnc_functions.lua')
end
```

**Pourquoi pourrait être universel:**

- ✅ S'initialise automatiquement lors du `include()`
- ✅ Enregistre un event `prerender` global
- ✅ Fonctionne pour TOUS jobs sans configuration
- ✅ Détection mouvement universelle

**Pourquoi actuellement manuel:**

- ⚠️ Nécessite `sets.MoveSpeed` défini dans chaque job
- ⚠️ Callback system pour job-specific logic
- ⚠️ État global `state.Moving` créé

**RECOMMANDATION:** **✅ AJOUTER À INIT_SYSTEMS**

**Avantages:**

1. Éliminerait ligne `include('automove.lua')` de chaque job
2. Garantit que TOUS jobs ont movement detection
3. Simplifie nouveaux jobs (une ligne de moins)

**Impact:**

- Jobs doivent toujours définir `sets.MoveSpeed` (pas changé)
- Aucun breaking change

---

### 2. **DualBox Manager** (`shared/utils/dualbox/dualbox_manager.lua`)

**Statut Actuel:** S'auto-initialise via flag global `_G.DualBoxManagerInitialized`

**Code d'auto-initialization (ligne 376-399):**

```lua
if not _G.DualBoxManagerInitialized then
    _G.DualBoxManagerInitialized = true

    coroutine.schedule(function()
        if player and player.name then
            DualBoxManager.initialize()

            -- ALT sends initial job update
            if _G.DualBoxConfig.role == "alt" then
                DualBoxManager.send_job_update()

            -- MAIN requests job from ALT
            elseif _G.DualBoxConfig.role == "main" then
                DualBoxManager.request_alt_job()
            end
        end
    end, 2)
end
```

**Pourquoi pourrait être universel:**

- ✅ Communication Tetsouo ↔ Kaories (multi-boxing)
- ✅ S'auto-initialise déjà
- ✅ Système passif (background)

**Pourquoi PAS dans INIT_SYSTEMS:**

- ❌ Nécessite config spécifique (role: "main" vs "alt")
- ❌ Pas tous les jobs l'utilisent (optionnel)
- ❌ S'auto-initialise déjà parfaitement

**RECOMMANDATION:** **❌ NE PAS AJOUTER**

**Raison:** Système optionnel qui s'auto-initialise déjà. Pas besoin de forcer dans INIT_SYSTEMS.

---

## 📊 RÉSUMÉ FINAL

### ✅ **Systèmes À Garder dans INIT_SYSTEMS (2)**

1. **Midcast Watchdog** - Protection timeout universelle
2. **Warp System** - Warp detection + IPC multi-boxing

### ✅ **Systèmes À Ajouter à INIT_SYSTEMS (1 RECOMMANDÉ)**

3. **AutoMove** - Movement detection universelle

**Impact:** Simplifie nouveaux jobs, garantit mouvement pour tous

---

### ❌ **Systèmes À NE PAS Ajouter (Tous les autres)**

**Raisons:**

- **Job-Specific** (DNC, DRG, WHM) - Pas universels
- **Factories** (Lockstyle, Macrobook) - Nécessitent job-specific config
- **On-Demand** (Precast, Midcast, Weaponskill) - Chargés dans hooks
- **Message Formatters** - Modules passifs utilisés à la demande
- **UI System** - Job-level init avec job-specific keybinds
- **JobChangeManager** - Nécessite job-specific callbacks
- **DualBoxManager** - Optionnel + s'auto-initialise
- **Testing** - Pas production

---

## 🎯 RECOMMANDATION FINALE

### **Configuration INIT_SYSTEMS.lua Optimale:**

```lua
---============================================================================
--- Universal Systems Auto-Initialization Façade
---============================================================================

---============================================================================
--- SYSTEM 1: MIDCAST WATCHDOG
---============================================================================

local watchdog_success, MidcastWatchdog = pcall(require, 'shared/utils/core/midcast_watchdog')
if watchdog_success and MidcastWatchdog then
    _G.MidcastWatchdog = MidcastWatchdog
    coroutine.schedule(function()
        MidcastWatchdog.start()
        add_to_chat(158, '[Watchdog] Initialized (timeout: 3.5s)')
    end, 2.0)
end

---============================================================================
--- SYSTEM 2: WARP SYSTEM (with IPC Multi-Boxing Support)
---============================================================================

local warp_success, WarpInit = pcall(require, 'shared/utils/warp/warp_init')
if warp_success and WarpInit then
    WarpInit.init()
end

---============================================================================
--- SYSTEM 3: AUTOMOVE (Movement Detection)
---============================================================================

include('../shared/utils/movement/automove.lua')
-- AutoMove s'initialise automatiquement via include()
-- Jobs doivent définir: sets.MoveSpeed = { legs="..." }
```

### **Impact sur les jobs:**

**AVANT (chaque job manuellement):**

```lua
function get_sets()
    include('Mote-Include.lua')
    include('../shared/utils/core/INIT_WATCHDOG.lua')      -- Manuel
    include('../shared/utils/movement/automove.lua')        -- Manuel

    -- Warp system pas initialisé (BUG actuel sur certains jobs)
end
```

**APRÈS (via INIT_SYSTEMS):**

```lua
function get_sets()
    include('Mote-Include.lua')
    include('../shared/utils/core/INIT_SYSTEMS.lua')       -- Tout en un
end
```

**Bénéfices:**

- ✅ 2 lignes au lieu de 3 (ou plus)
- ✅ Garantit que TOUS jobs ont Watchdog + Warp + AutoMove
- ✅ Simplifie création nouveaux jobs
- ✅ Pas de risque d'oublier un système (comme warp_init sur DNC avant)

---

## 📝 ACTIONS REQUISES

### **Option 1: Configuration Actuelle (Minimale - 2 systèmes)**

**Garder INIT_SYSTEMS.lua tel quel:**

- Watchdog
- Warp System

**Aucune modification requise**

---

### **Option 2: Configuration Optimale (Recommandée - 3 systèmes)**

**Ajouter AutoMove à INIT_SYSTEMS.lua:**

1. ✅ Ajouter `include('../shared/utils/movement/automove.lua')` à INIT_SYSTEMS
2. ✅ Retirer `include('automove.lua')` de chaque job (WAR, PLD, DNC, etc.)
3. ✅ Tester sur Tetsouo (reload GearSwap)
4. ✅ Tester sur Kaories (clone automatique)

**Impact:**

- Simplifie 12 lignes (si 12 jobs)
- Zero breaking change (AutoMove fonctionne identique)
- Garantit mouvement pour tous nouveaux jobs

---

## 🏁 CONCLUSION

**INIT_SYSTEMS.lua actuel est CORRECT** avec 2 systèmes:

1. ✅ Midcast Watchdog
2. ✅ Warp System

**RECOMMANDATION: Ajouter AutoMove (optionnel mais recommandé)**

**Tous les autres systèmes sont correctement gérés:**

- Job-specific → Chargés par job
- Factories → Utilisés par job
- On-demand → Require dans hooks
- Optionnels → Auto-init ou pas dans INIT

**Score Architecture:** 10/10 - Séparation des responsabilités parfaite
