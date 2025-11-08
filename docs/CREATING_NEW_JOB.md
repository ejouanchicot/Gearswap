# Guide: Créer un Nouveau Job - GearSwap Tetsouo

Version: 1.1 | Temps estimé: 8-12 heures

## TABLE DES MATIÈRES

1. [Vue d'ensemble](#vue-densemble)
2. [Prérequis](#prérequis)
3. [Phase 1: Structure de base](#phase-1-structure-de-base)
4. [Phase 2: 12 Modules obligatoires](#phase-2-12-modules-obligatoires)
5. [Phase 3: Configuration](#phase-3-configuration)
6. [Phase 4: Equipment Sets](#phase-4-equipment-sets)
7. [Phase 5: Job Abilities Database](#phase-5-job-abilities-database)
8. [Testing](#testing)
9. [Problèmes courants](#problèmes-courants)
10. [⚠️ STACK OVERFLOW - Prévention CRITIQUE](#stack-overflow---prévention-critique)

---

## VUE D'ENSEMBLE

### Architecture Tetsouo

Chaque job suit EXACTEMENT la même structure (12 modules):

```
jobs/[job]/
├── [job]_functions.lua (façade - charge tous les modules)
├── sets/[job]_sets.lua (equipment)
└── functions/
    ├── [JOB]_PRECAST.lua    (precast logic)
    ├── [JOB]_MIDCAST.lua    (midcast logic)
    ├── [JOB]_AFTERCAST.lua  (aftercast)
    ├── [JOB]_IDLE.lua       (idle gear)
    ├── [JOB]_ENGAGED.lua    (combat gear)
    ├── [JOB]_STATUS.lua     (status changes)
    ├── [JOB]_BUFFS.lua      (buff management)
    ├── [JOB]_COMMANDS.lua   (command handling)
    ├── [JOB]_MOVEMENT.lua   (movement)
    ├── [JOB]_LOCKSTYLE.lua  (factory lockstyle)
    └── [JOB]_MACROBOOK.lua  (factory macrobook)
```

### 10 Systèmes Centralisés OBLIGATOIRES

1. CooldownChecker - Validation cooldown universal
2. MessageFormatter - Messages centralisés (JAMAIS add_to_chat direct)
3. MidcastManager - Midcast universal (fallback 7 niveaux)
4. PrecastGuard - Bloque actions si debuffs (Amnesia/Silence)
5. WeaponSkillManager - Validation WS (range/valid)
6. LockstyleManager - Factory lockstyle (JAMAIS coder manuellement)
7. MacrobookManager - Factory macrobook (JAMAIS coder manuellement)
8. AbilityHelper - Auto-trigger abilities (optional)
9. UNIVERSAL_JA_DATABASE - Messages JA (support subjob)
10. Warp System - Auto-lock equipment (81 warp actions)

---

## PRÉREQUIS

### Connaissances requises

- Architecture Tetsouo (lire CLAUDE.md)
- Lua basics (require/include, tables, functions)
- FFXI job mechanics (spells, abilities, gear sets)

### Job à copier (templates)

- **Tank jobs:** Copier PLD
- **DD jobs:** Copier WAR, SAM
- **Support jobs:** Copier WHM, BRD
- **Hybrid jobs:** Copier DNC, PLD

### Fichiers à lire AVANT de commencer

1. `CLAUDE.md` - Architecture overview
2. `.claude/MIDCAST_STANDARD.md` - MidcastManager usage
3. `shared/data/job_abilities/README.md` - JA_DATABASE architecture
4. Template job similaire (ex: PLD pour RUN)

---

## PHASE 1: STRUCTURE DE BASE (30 min)

### Étape 1.1: Créer Main File

```bash
# Copier template (ex: PLD >> RUN)
cp Tetsouo_PLD.lua Tetsouo_RUN.lua
```

Chercher/remplacer dans `Tetsouo_RUN.lua`:

- `PLD` >> `RUN` (uppercase)
- `pld` >> `run` (lowercase)
- Garder TOUTE la structure (JobChangeManager, WarpInit, etc.)

**CRITIQUE:** NE PAS modifier:

- JobChangeManager logic
- WarpInit.init()
- Factory usage (LockstyleManager, MacrobookManager)

### Étape 1.2: Créer Directories

```bash
mkdir -p shared/jobs/run/functions
mkdir -p shared/jobs/run/functions/logic
mkdir -p shared/jobs/run/sets
mkdir -p Tetsouo/config/run
```

### Étape 1.3: Créer Façade

Copier `shared/jobs/pld/functions/pld_functions.lua` >> `shared/jobs/run/functions/run_functions.lua`

Chercher/remplacer:

- `pld` >> `run`
- `PLD` >> `RUN`

**Structure finale:**

```lua
-- Load all modules in dependency order
include('shared/jobs/run/functions/RUN_LOCKSTYLE.lua')
include('shared/jobs/run/functions/RUN_MACROBOOK.lua')
include('shared/jobs/run/functions/RUN_PRECAST.lua')
include('shared/jobs/run/functions/RUN_MIDCAST.lua')
include('shared/jobs/run/functions/RUN_AFTERCAST.lua')
include('shared/jobs/run/functions/RUN_IDLE.lua')
include('shared/jobs/run/functions/RUN_ENGAGED.lua')
include('shared/jobs/run/functions/RUN_STATUS.lua')
include('shared/jobs/run/functions/RUN_BUFFS.lua')
include('shared/jobs/run/functions/RUN_COMMANDS.lua')
include('shared/jobs/run/functions/RUN_MOVEMENT.lua')

print('RUN Functions loaded successfully')
```

---

## PHASE 2: 12 MODULES OBLIGATOIRES (2-3h)

### 2.1 PRECAST (Le plus important - 200-300 lines)

**Template:** Copier `shared/jobs/pld/functions/PLD_PRECAST.lua`

**ORDRE ABSOLU (NE JAMAIS CHANGER):**

```lua
function job_precast(spell, action, spellMap, eventArgs)
    -- 1. DEBUFF BLOCKING (PrecastGuard) - PREMIER
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- 2. COOLDOWN VALIDATION (CooldownChecker) - SECOND
    if spell.action_type == 'Ability' then
        CooldownChecker.check_ability_cooldown(spell, eventArgs)
    elseif spell.action_type == 'Magic' then
        CooldownChecker.check_spell_cooldown(spell, eventArgs)
    end

    if eventArgs.cancel then return end

    -- 3. JOB ABILITIES MESSAGES (UNIVERSAL_JA_DATABASE) - THIRD
    if spell.type == 'JobAbility' and JA_DB[spell.english] then
        MessageFormatter.show_ja_activated(spell.english, JA_DB[spell.english])
    end

    -- 4. WEAPONSKILL VALIDATION (WeaponSkillManager) - FOURTH
    if spell.type == 'WeaponSkill' and WeaponSkillManager then
        if not WeaponSkillManager.check_weaponskill_range(spell) then
            eventArgs.cancel = true
            return
        end
    end

    -- 5. JOB-SPECIFIC LOGIC - DERNIER
    -- Ex: Auto-trigger abilities, custom gear logic
end
```

**Requires obligatoires:**

```lua
local MessageFormatter = require('shared/utils/messages/message_formatter')
local CooldownChecker = require('shared/utils/precast/cooldown_checker')
local AbilityHelper = require('shared/utils/precast/ability_helper')
local precast_guard_success, PrecastGuard = pcall(require, 'shared/utils/debuff/precast_guard')
include('shared/utils/weaponskill/weaponskill_manager.lua')
local JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')
```

**Exports obligatoires:**

```lua
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

local RUN_PRECAST = {}
RUN_PRECAST.job_precast = job_precast
RUN_PRECAST.job_post_precast = job_post_precast
return RUN_PRECAST
```

---

### 2.2 MIDCAST (MidcastManager OBLIGATOIRE - 100-200 lines)

**Template:** Copier `shared/jobs/pld/functions/PLD_MIDCAST.lua`

**RÈGLE ABSOLUE:** TOUS les jobs DOIVENT utiliser MidcastManager.select_set()

**Structure:**

```lua
local MidcastManager = require('shared/utils/midcast/midcast_manager')

function job_midcast(spell, action, spellMap, eventArgs)
    -- Optional: Job-specific PRE-midcast logic
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- SKILL 1: Enhancing Magic
    if spell.skill == 'Enhancing Magic' then
        MidcastManager.select_set({
            skill = 'Enhancing Magic',
            spell = spell,
            mode_state = state.EnhancingMode,  -- Optional
            target_func = MidcastManager.get_enhancing_target  -- self vs others
        })
        return
    end

    -- SKILL 2: Dark Magic (pour RUN)
    if spell.skill == 'Dark Magic' then
        MidcastManager.select_set({
            skill = 'Dark Magic',
            spell = spell
        })
        return
    end

    -- Add more skills as needed
end

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

local RUN_MIDCAST = {}
RUN_MIDCAST.job_midcast = job_midcast
RUN_MIDCAST.job_post_midcast = job_post_midcast
return RUN_MIDCAST
```

**CRITIQUES:**

- JAMAIS coder nested set logic manuellement
- JAMAIS coder fallback chain manuellement
- TOUJOURS utiliser MidcastManager.select_set()
- Overrides job-specific APRÈS MidcastManager (OK)

**Debug:** `//gs c debugmidcast` pour voir fallback chain

**Référence:** `.claude/MIDCAST_STANDARD.md`

---

### 2.3-2.9 Autres Modules (Templates Minimaux)

**AFTERCAST:**

```lua
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Job-specific aftercast logic
end
_G.job_aftercast = job_aftercast
```

**IDLE:**

```lua
function job_customize_idle_set(idleSet)
    -- Customize idle gear based on conditions
    return idleSet
end
_G.job_customize_idle_set = job_customize_idle_set
```

**ENGAGED:**

```lua
function job_customize_melee_set(meleeSet)
    -- Customize combat gear
    return meleeSet
end
_G.job_customize_melee_set = job_customize_melee_set
```

**STATUS:**

```lua
function job_status_change(newStatus, oldStatus, eventArgs)
    -- Handle status changes (Idle, Engaged, Dead)
end
_G.job_status_change = job_status_change
```

**BUFFS:**

```lua
function job_buff_change(buff, gain)
    -- Handle buff gain/loss
end
_G.job_buff_change = job_buff_change
```

**COMMANDS:**

```lua
local CommonCommands = require('shared/utils/core/COMMON_COMMANDS')

function job_self_command(cmdParams, eventArgs)
    if not cmdParams or #cmdParams == 0 then return end
    local command = cmdParams[1]:lower()

    -- Common commands FIRST
    if CommonCommands.is_common_command(command) then
        if CommonCommands.handle_command(command, 'RUN') then
            eventArgs.handled = true
        end
        return
    end

    -- Job-specific commands
    if command == 'ward' then
        -- Handle ward command
        eventArgs.handled = true
    end
end
_G.job_self_command = job_self_command
```

**MOVEMENT:**

```lua
if AutoMove then
    AutoMove.register_job('RUN')
end

function job_handle_equipping_gear(playerStatus, eventArgs)
    -- Movement gear handling
end
_G.job_handle_equipping_gear = job_handle_equipping_gear
```

---

### 2.10 LOCKSTYLE (Factory - OBLIGATOIRE)

**NE PAS CODER MANUELLEMENT - Utiliser Factory:**

```lua
local LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')

return LockstyleManager.create(
    'RUN',                          -- job_code
    'Tetsouo/config/run/RUN_LOCKSTYLE', -- config_path
    1,                              -- default_lockstyle
    'SAM'                           -- default_subjob
)
```

**C'est TOUT.** Pas de code lockstyle manuel.

---

### 2.11 MACROBOOK (Factory - OBLIGATOIRE)

**NE PAS CODER MANUELLEMENT - Utiliser Factory:**

```lua
local MacrobookManager = require('shared/utils/macrobook/macrobook_manager')

return MacrobookManager.create(
    'RUN',                          -- job_code
    'Tetsouo/config/run/RUN_MACROBOOK', -- config_path
    'SAM',                          -- default_subjob
    1,                              -- default_book
    1                               -- default_page
)
```

**C'est TOUT.** Pas de code macrobook manuel.

---

## PHASE 3: CONFIGURATION (1h)

### 3.1 Keybinds Config

**Fichier:** `Tetsouo/config/run/RUN_KEYBINDS.lua`

**Template:** Copier `Tetsouo/config/pld/PLD_KEYBINDS.lua`

```lua
local RUNKeybinds = {}

RUNKeybinds.keybinds = {
    {key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon"},
    {key = "!2", command = "cycle HybridMode", desc = "Hybrid Mode", state = "HybridMode"},
    {key = "!3", command = "cycle SubWeapon", desc = "Sub Weapon", state = "SubWeapon"},
    {key = "!4", command = "cycle TankMode", desc = "Tank Mode", state = "TankMode"},
    {key = "!5", command = "cycle RuneMode", desc = "Rune Mode", state = "RuneMode"},
}

function RUNKeybinds.bind_all()
    for _, bind in pairs(RUNKeybinds.keybinds) do
        local success, error_msg = pcall(send_command, 'bind ' .. bind.key .. ' gs c ' .. bind.command)
        if not success then
            add_to_chat(167, '[RUN] Keybind Error: ' .. tostring(error_msg))
        end
    end
end

function RUNKeybinds.unbind_all()
    for _, bind in pairs(RUNKeybinds.keybinds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end
end

return RUNKeybinds
```

---

### 3.2 Lockstyle Config

**Fichier:** `Tetsouo/config/run/RUN_LOCKSTYLE.lua`

```lua
local RUNLockstyleConfig = {}

RUNLockstyleConfig.default = 1

RUNLockstyleConfig.by_subjob = {
    ['SAM'] = 1,
    ['NIN'] = 2,
    ['DNC'] = 3,
    ['WAR'] = 4,
}

return RUNLockstyleConfig
```

---

### 3.3 Macrobook Config

**Fichier:** `Tetsouo/config/run/RUN_MACROBOOK.lua`

```lua
local RUNMacroConfig = {}

RUNMacroConfig.default = {book = 1, page = 1}

RUNMacroConfig.macrobooks = {
    ['SAM'] = {book = 1, page = 1},
    ['NIN'] = {book = 1, page = 2},
    ['DNC'] = {book = 1, page = 3},
    ['WAR'] = {book = 1, page = 4},
}

return RUNMacroConfig
```

---

### 3.4 States Config (Job-Specific)

**Fichier:** `Tetsouo/config/run/RUN_STATES.lua`

```lua
function define_run_states()
    -- Combat modes
    state.HybridMode = M{['description']='Hybrid Mode', 'PDT', 'MDT', 'Normal'}
    state.HybridMode:set('PDT')

    -- Weapon sets
    state.MainWeapon = M{['description']='Main Weapon', 'Epeolatry', 'Lionheart', 'Aettir'}
    state.MainWeapon:set('Epeolatry')

    state.SubWeapon = M{['description']='Sub Weapon', 'Utu Grip', 'Alber Strap'}
    state.SubWeapon:set('Utu Grip')

    -- Tank mode
    state.TankMode = M{['description']='Tank Mode', 'Tank', 'DD'}
    state.TankMode:set('Tank')

    -- Rune rotation
    state.RuneMode = M{['description']='Rune Mode', 'Ignis', 'Gelus', 'Flabra', 'Tellus', 'Sulpor', 'Unda', 'Lux', 'Tenebrae'}
    state.RuneMode:set('Ignis')

    -- Ward rotation
    state.WardMode = M{['description']='Ward Mode', 'Vallation', 'Valiance', 'Pflug'}
    state.WardMode:set('Vallation')
end

return define_run_states
```

---

## PHASE 4: EQUIPMENT SETS (2-4h)

### Structure Obligatoire

**Fichier:** `shared/jobs/run/sets/run_sets.lua`

```lua
---============================================================================
--- RUN Equipment Sets
---============================================================================

-- PRECAST SETS
sets.precast = {}
sets.precast.JA = {}
sets.precast.WS = {}
sets.precast.FC = {}

-- Job Abilities (enmity focus)
sets.precast.JA['Vallation'] = {}
sets.precast.JA['Valiance'] = {}
sets.precast.JA['Pflug'] = {}
sets.precast.JA['Gambit'] = {}
sets.precast.JA['Rayke'] = {}
sets.precast.JA['Battuta'] = {}

-- Runes (3s cast time - need FC gear)
sets.precast.JA['Ignis'] = {}
sets.precast.JA['Gelus'] = {}
-- ... (all 8 runes)

-- Weaponskills
sets.precast.WS = {}
sets.precast.WS['Resolution'] = {}
sets.precast.WS['Dimidiation'] = {}
sets.precast.WS['Ground Strike'] = {}

-- Fast Cast
sets.precast.FC = {
    -- FC +80%, SIRD -102%
}

-- MIDCAST SETS
sets.midcast = {}
sets.midcast['Enhancing Magic'] = {}
sets.midcast['Dark Magic'] = {}
sets.midcast['Phalanx'] = {}

-- IDLE SETS
sets.idle = {}
sets.idle.Normal = {}
sets.idle.PDT = {}
sets.idle.MDT = {}
sets.idle.Town = {}

-- ENGAGED SETS
sets.engaged = {}
sets.engaged.Normal = {}
sets.engaged.PDT = {}
sets.engaged.MDT = {}

-- Tank vs DD modes
sets.engaged.Tank = {}
sets.engaged.DD = {}

-- BUFF SETS
sets.buff = {}
sets.buff.Doom = {}
```

### Conseils Equipment

1. **Copier structure d'un job similaire**
   - Tank: Copier PLD sets
   - DD: Copier WAR sets

2. **Utiliser Wardrobe slots**

   ```lua
   ChirichRing1 = {name="Chirich Ring +1", bag="wardrobe"},
   ChirichRing2 = {name="Chirich Ring +1", bag="wardrobe2"},
   ```

3. **Augmented gear**

   ```lua
   Rudianos.tank = {name="Rudianos Mantle", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Enmity+10','Phys. dmg. taken-10%'}},
   ```

4. **Inventer gear si pas dispo**
   - Utiliser placeholder gear
   - Commenter items manquants

---

## PHASE 5: JOB ABILITIES DATABASE (1h)

### Structure Modulaire (comme PLD)

**Architecture:**

```
shared/data/job_abilities/run/
├── run_mainjob.lua     (abilities main job only)
├── run_sp.lua          (SP abilities)
└── run_subjob.lua      (abilities disponibles en subjob)
```

### Exemple: RUN Main Job Abilities

**Fichier:** `shared/data/job_abilities/run/run_mainjob.lua`

```lua
---============================================================================
--- RUN Main Job Abilities
---============================================================================

local RUN_MainJob = {
    -- Wards (Lv5-77)
    ['Vallation'] = 'Reduce damage, enhance parry (45s)',
    ['Valiance'] = 'Reduce magical damage (45s)',
    ['Pflug'] = 'Reduce physical damage (45s)',

    -- Runes (Lv1-88)
    ['Ignis'] = 'Fire rune: Ice resist+',
    ['Gelus'] = 'Ice rune: Wind resist+',
    ['Flabra'] = 'Wind rune: Earth resist+',
    ['Tellus'] = 'Earth rune: Thunder resist+',
    ['Sulpor'] = 'Thunder rune: Water resist+',
    ['Unda'] = 'Water rune: Fire resist+',
    ['Lux'] = 'Light rune: Dark resist+',
    ['Tenebrae'] = 'Dark rune: Light resist+',

    -- Gambit/Rayke (Lv40-65)
    ['Gambit'] = 'Consume 2 runes: enhance ward (96s)',
    ['Rayke'] = 'Consume 3 runes: lower enemy resist (30s)',

    -- Other (Lv20-83)
    ['Elemental Sforzo'] = 'Next elemental damage nullified (30s)',
    ['One for All'] = 'Party damage >> self (30s)',
    ['Battuta'] = 'Parry rate+ (45s)',
    ['Liement'] = 'Next spell: no element (60s)',
    ['Swordplay'] = 'Accuracy/evasion+ (60s)',
    ['Embolden'] = 'Enhance runes (60s)',
    ['Vivacious Pulse'] = 'AoE HP recovery (10y)',
}

return RUN_MainJob
```

### Exemple: RUN SP Abilities

**Fichier:** `shared/data/job_abilities/run/run_sp.lua`

```lua
local RUN_SP = {
    ['Elemental Sforzo'] = 'SP1: Next elemental damage nullified',
    ['Odyllic Subterfuge'] = 'SP2: Dispel all buffs >> cure (1h)',
    ['Odyllic Subterfuge II'] = 'SP3: Enhanced dispel cure (1h)',
}

return RUN_SP
```

### Exemple: RUN Subjob Abilities

**Fichier:** `shared/data/job_abilities/run/run_subjob.lua`

```lua
local RUN_Subjob = {
    ['Vallation'] = 'Reduce damage, enhance parry (Lv40)',
    ['Lunge'] = 'Rune elemental magic damage (Lv15)',
    ['Swipe'] = 'Rune elemental AOE damage (Lv30)',
}

return RUN_Subjob
```

### Wrapper Database

**Fichier:** `shared/data/job_abilities/RUN_JA_DATABASE.lua`

```lua
---============================================================================
--- RUN Job Ability Database (Auto-Merged)
---============================================================================

local RUN_MainJob = require('shared/data/job_abilities/run/run_mainjob')
local RUN_SP = require('shared/data/job_abilities/run/run_sp')
local RUN_Subjob = require('shared/data/job_abilities/run/run_subjob')

local RUN_JA_DATABASE = {}

-- Merge all ability types
for ability, desc in pairs(RUN_MainJob) do
    RUN_JA_DATABASE[ability] = desc
end

for ability, desc in pairs(RUN_SP) do
    RUN_JA_DATABASE[ability] = desc
end

for ability, desc in pairs(RUN_Subjob) do
    RUN_JA_DATABASE[ability] = desc
end

return RUN_JA_DATABASE
```

### Ajouter à UNIVERSAL_JA_DATABASE

**Fichier:** `shared/data/job_abilities/UNIVERSAL_JA_DATABASE.lua`

```lua
-- Ajouter après autres jobs:
local RUN_JA = require('shared/data/job_abilities/RUN_JA_DATABASE')

-- Merge RUN abilities
for ability, desc in pairs(RUN_JA) do
    UNIVERSAL_JA_DATABASE[ability] = desc
end
```

---

## TESTING

### Test 1: Load Test

```bash
1. //lua unload gearswap
2. Change to RUN in-game
3. //lua load gearswap
4. Verify: [RUN] SYSTEM LOADED message
5. Verify: Keybinds loaded
6. Verify: Macrobook loaded
7. Verify: Lockstyle applied (8s delay)
```

### Test 2: Equipment Validation

```bash
//gs c checksets
>> Should show validation results
>> Note missing items (OK for new job)
```

### Test 3: Keybinds

```bash
Alt+1 >> Cycle MainWeapon
Alt+2 >> Cycle HybridMode
Alt+3 >> Cycle SubWeapon
>> Verify state changes
```

### Test 4: Job Change

```bash
1. Load RUN
2. Change to WAR (//ja "Warrior" <me>)
3. Verify: Clean unload
4. Change back to RUN
5. Verify: Clean reload
```

### Test 5: Subjob Change

```bash
1. RUN/SAM loaded
2. Change subjob (//ja "Ninja" <me>)
3. Verify: Lockstyle changes
4. Verify: Macrobook changes
```

### Test 6: Cooldown Messages

```bash
1. Use ability (ex: Vallation)
2. Try again immediately
3. Verify: Cooldown message
4. Verify: Action cancelled
```

### Test 7: MidcastManager Debug

```bash
//gs c debugmidcast
>> Cast spell (ex: Phalanx)
>> Verify: Fallback chain displayed in chat
```

---

## PROBLÈMES COURANTS

### Problème 1: "attempt to index nil value (global 'state')"

**Cause:** States non définis dans user_setup()

**Solution:**

```lua
-- Dans Tetsouo_RUN.lua, user_setup():
local define_states = require('Tetsouo/config/run/RUN_STATES')
define_states()
```

---

### Problème 2: "module not found: 'shared/jobs/run/functions/RUN_PRECAST'"

**Cause:** Chemin incorrect ou fichier pas créé

**Solution:**

- Vérifier chemin EXACT (case-sensitive)
- Vérifier fichier existe
- Utiliser `include()` pas `require()` pour modules job

---

### Problème 3: MidcastManager fallback error

**Cause:** Sets midcast manquants

**Solution:**

```lua
-- Minimum required:
sets.midcast = {}
sets.midcast['Enhancing Magic'] = {}  -- Base set (P7 fallback)
```

---

### Problème 4: Factory lockstyle/macrobook error

**Cause:** Config files manquants

**Solution:**

- Créer `Tetsouo/config/run/RUN_LOCKSTYLE.lua`
- Créer `Tetsouo/config/run/RUN_MACROBOOK.lua`
- Minimum: `return {default = 1, by_subjob = {}}`

---

### Problème 5: Keybinds not working

**Cause:** Keybinds.bind_all() pas appelé

**Solution:**

```lua
-- Dans Tetsouo_RUN.lua, user_setup():
if is_initial_setup then
    local success, keybinds = pcall(require, 'Tetsouo/config/run/RUN_KEYBINDS')
    if success and keybinds then
        RUNKeybinds = keybinds
        RUNKeybinds.bind_all()  -- IMPORTANT
    end
end
```

---

### Problème 6: "attempt to call nil value (global 'job_precast')"

**Cause:** Exports _G manquants

**Solution:**

```lua
-- À la fin de CHAQUE module:
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- ET return:
local RUN_PRECAST = {}
RUN_PRECAST.job_precast = job_precast
RUN_PRECAST.job_post_precast = job_post_precast
return RUN_PRECAST
```

---

### Problème 7: Warp system not loading

**Cause:** WarpInit.init() pas appelé

**Solution:**

```lua
-- Dans Tetsouo_RUN.lua, user_setup():
if is_initial_setup then
    local warp_success, WarpInit = pcall(require, 'shared/utils/warp/warp_init')
    if warp_success and WarpInit then
        WarpInit.init()  -- OBLIGATOIRE
    end
end
```

---

### Problème 8: Cooldown messages not showing

**Cause:** CooldownChecker pas appelé

**Solution:**

```lua
-- Dans RUN_PRECAST.lua, job_precast():
local CooldownChecker = require('shared/utils/precast/cooldown_checker')

-- SECOND check (après PrecastGuard):
if spell.action_type == 'Ability' then
    CooldownChecker.check_ability_cooldown(spell, eventArgs)
elseif spell.action_type == 'Magic' then
    CooldownChecker.check_spell_cooldown(spell, eventArgs)
end

if eventArgs.cancel then return end
```

---

### Problème 9: JA messages not showing

**Cause:** UNIVERSAL_JA_DATABASE pas utilisé

**Solution:**

```lua
-- Dans RUN_PRECAST.lua:
local JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')

-- Dans job_precast():
if spell.type == 'JobAbility' and JA_DB[spell.english] then
    MessageFormatter.show_ja_activated(spell.english, JA_DB[spell.english])
end
```

---

### Problème 10: Job change collision (multiple UI instances)

**Cause:** JobChangeManager pas initialisé

**Solution:**

```lua
-- Dans Tetsouo_RUN.lua, user_setup():
local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
if jcm_success and JobChangeManager then
    JobChangeManager.initialize({
        keybinds = RUNKeybinds,
        ui = KeybindUI,
        lockstyle = select_default_lockstyle,
        macrobook = select_default_macro_book
    })
end

-- Dans get_sets():
if jcm_success and JobChangeManager then
    JobChangeManager.cancel_all()  -- Cancel pending ops
end
```

---

## CHECKLIST FINALE

### Structure

- [ ] Tetsouo_RUN.lua créé (chercher/remplacer template)
- [ ] shared/jobs/run/functions/ créé (12 modules)
- [ ] shared/jobs/run/sets/ créé
- [ ] Tetsouo/config/run/ créé (5+ configs)

### 12 Modules

- [ ] run_functions.lua (façade)
- [ ] RUN_PRECAST.lua (ordre: Guard>>Cooldown>>JA>>WS>>job)
- [ ] RUN_MIDCAST.lua (MidcastManager.select_set)
- [ ] RUN_AFTERCAST/IDLE/ENGAGED/STATUS/BUFFS.lua
- [ ] RUN_COMMANDS.lua (CommonCommands integration)
- [ ] RUN_MOVEMENT.lua (AutoMove registration)
- [ ] RUN_LOCKSTYLE.lua (Factory usage)
- [ ] RUN_MACROBOOK.lua (Factory usage)

### Configs

- [ ] RUN_KEYBINDS.lua (bind_all/unbind_all)
- [ ] RUN_LOCKSTYLE.lua (default + by_subjob)
- [ ] RUN_MACROBOOK.lua (default + macrobooks)
- [ ] RUN_STATES.lua (define_run_states)
- [ ] Job-specific configs (ex: RUN_WARD_CONFIG.lua)

### Equipment

- [ ] run_sets.lua (precast/midcast/idle/engaged)
- [ ] Minimum sets: precast.FC, midcast base, idle, engaged

### JA Database

- [ ] shared/data/job_abilities/run/ créé
- [ ] run_mainjob.lua (abilities main job)
- [ ] run_sp.lua (SP abilities)
- [ ] run_subjob.lua (subjob abilities)
- [ ] RUN_JA_DATABASE.lua (wrapper merge)
- [ ] UNIVERSAL_JA_DATABASE.lua updated

### 10 Systèmes Centralisés

- [ ] CooldownChecker (PRECAST)
- [ ] MessageFormatter (tous messages)
- [ ] MidcastManager (MIDCAST - select_set)
- [ ] PrecastGuard (PRECAST premier check)
- [ ] WeaponSkillManager (WS validation)
- [ ] LockstyleManager.create() (Factory)
- [ ] MacrobookManager.create() (Factory)
- [ ] AbilityHelper (optional - auto-abilities)
- [ ] UNIVERSAL_JA_DATABASE (JA messages)
- [ ] WarpInit.init() (user_setup)

### Testing

- [ ] Load test (//lua reload gearswap)
- [ ] //gs c checksets
- [ ] Keybinds fonctionnent (Alt+1/2/3/4/5)
- [ ] Job change clean (RUN>>WAR>>RUN)
- [ ] Subjob change clean (RUN/SAM>>RUN/NIN)
- [ ] Cooldown messages affichés
- [ ] MidcastManager debug (//gs c debugmidcast)

---

## RESSOURCES

### Templates

- PRECAST: `shared/jobs/pld/functions/PLD_PRECAST.lua`
- MIDCAST: `shared/jobs/pld/functions/PLD_MIDCAST.lua`
- COMMANDS: `shared/jobs/war/functions/WAR_COMMANDS.lua`
- LOCKSTYLE: `shared/jobs/pld/functions/PLD_LOCKSTYLE.lua`
- Sets: `shared/jobs/war/sets/war_sets.lua`

### Documentation

- Architecture: `CLAUDE.md`
- MidcastManager: `.claude/MIDCAST_STANDARD.md`
- JA Database: `shared/data/job_abilities/README.md`

### Commands In-Game

- `//gs c checksets` - Validate equipment
- `//gs c debugmidcast` - Debug midcast fallback
- `//lua reload gearswap` - Reload after changes

---

## ⚠️ STACK OVERFLOW - Prévention CRITIQUE

### Problème Fréquent

**Stack overflow** lors du chargement d'un nouveau job. **Cause principale:** States manquants ou UI mal initialisé.

### 🔥 3 RÈGLES CRITIQUES

#### 1. ✅ Définir TOUS les States Référencés par Keybinds

**Problème:**

```lua
// JOB_KEYBINDS.lua référence:
{ state = "MainWeapon" }
{ state = "SubWeapon" }

// Mais JOB_STATES.lua ne les définit PAS
>> UI essaie de les lire >> STACK OVERFLOW
```

**Solution:**

```lua
// JOB_STATES_MINIMAL.lua - Définir TOUS les states
function JOBStates.configure()
    state.HybridMode:options('PDT', 'Normal')
    state.MainWeapon = M{['description']='Main Weapon', 'Weapon1', 'Weapon2'}
    state.SubWeapon = M{['description']='Sub Weapon', 'Shield1', 'Shield2'}
    // ... TOUS les states des keybinds
end
```

**Vérification:**

```bash
# Extraire states des keybinds
grep "state =" config/job/JOB_KEYBINDS.lua

# Vérifier qu'ils existent dans config
grep "state\." config/job/JOB_STATES*.lua
```

#### 2. ✅ Utiliser init() au lieu de smart_init()

**Problème:**

```lua
// ❌ MAUVAIS - cause stack overflow:
KeybindUI.smart_init("JOB", init_delay)
```

**Solution:**

```lua
// ✅ BON - safe:
KeybindUI.init("JOB")
```

**Template user_setup():**

```lua
function user_setup()
    local JOBStates = require('Tetsouo/config/job/JOB_STATES_MINIMAL')
    JOBStates.configure()

    if is_initial_setup then
        -- UI avec init() et delay 2.0s
        coroutine.schedule(function()
            local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
            if ui_success and KeybindUI then
                KeybindUI.init("JOB")  -- ← IMPORTANT: init() pas smart_init()
            end
        end, 2.0)

        is_initial_setup = false
    end
end
```

#### 3. ✅ Ne PAS require() Modules Déjà Chargés

**Problème:**

```lua
// JOB_KEYBINDS.show_intro() fait:
require('shared/jobs/job/functions/JOB_LOCKSTYLE')
>> Déjà chargé par job_functions.lua
  >> Récursion circulaire >> STACK OVERFLOW
```

**Solution:**

```lua
// JOB_KEYBINDS.lua - show_intro() simple
function JOBKeybinds.show_intro()
    local active_binds = JOBKeybinds.get_active_binds()
    MessageFormatter.show_system_intro("JOB SYSTEM LOADED", active_binds)
    // PAS de require('JOB_LOCKSTYLE') ou require('JOB_MACROBOOK')
end
```

### Checklist Anti-Stack Overflow

Avant `//lua reload gearswap`:

- [ ] **Syntaxe:** Pas de double `end`, tous les `if/function` fermés
- [ ] **States:** TOUS les states des keybinds définis dans JOB_STATES
- [ ] **UI:** Utilise `KeybindUI.init()` pas `smart_init()`
- [ ] **Keybinds:** show_intro() ne fait PAS de require() circulaires
- [ ] **Delays:** UI avec delay 2.0s minimum
- [ ] **Path:** Fichier sets existe au bon path

### Debug Stack Overflow

**Méthode progressive:**

1. **Désactiver user_setup() complet:**

   ```lua
   function user_setup()
       print('[JOB] MINIMAL MODE')
   end
   ```

   - Si load >> Problème dans user_setup()

2. **Ajouter juste states:**

   ```lua
   function user_setup()
       local JOBStates = require('config/job/JOB_STATES_MINIMAL')
       JOBStates.configure()
   end
   ```

   - Si stack overflow >> States manquants ou mal définis

3. **Ajouter keybinds (sans UI):**

   ```lua
   coroutine.schedule(function()
       local success, keybinds = pcall(require, 'config/job/JOB_KEYBINDS')
       if success and keybinds then
           JOBKeybinds = keybinds
           JOBKeybinds.bind_all()
       end
   end, 0.5)
   ```

   - Si stack overflow >> Keybinds référencent states inexistants

4. **Ajouter UI:**

   ```lua
   coroutine.schedule(function()
       local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
       if ui_success and KeybindUI then
           KeybindUI.init("JOB")
       end
   end, 2.0)
   ```

   - Si stack overflow >> States manquants

### Documentation Complète

Voir `RUN_STACK_OVERFLOW_RESOLUTION.md` pour:

- Explication complète des 3 causes
- Templates complets safe
- Exemples RUN (résolu)
- Script de vérification states

---

**Version:** 1.1 (Stack Overflow Prevention Added)
**Auteur:** Tetsouo
**Dernière mise à jour:** 2025-11-03
