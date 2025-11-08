# RUN Stack Overflow - Résolution Complète

## PROBLÈME RÉSOLU ✅

**Stack overflow** lors du chargement de RUN job causé par **UI_MANAGER.smart_init()**.

---

## CAUSES IDENTIFIÉES

### 1. Erreur de Syntaxe (Corrigée)

**Fichier:** `Tetsouo_RUN.lua` ligne 163
**Erreur:** Double `end` dans `job_sub_job_change()`

```lua
-- AVANT (CASSÉ):
function job_sub_job_change(newSubjob, oldSubjob)
    -- ... code ...
end
end  ← DOUBLE END CAUSAIT STACK OVERFLOW

-- APRÈS (FIXÉ):
function job_sub_job_change(newSubjob, oldSubjob)
    -- ... code ...
    end  ← Ferme if
end      ← Ferme function
```

### 2. States Manquants (Cause Principale)

**Fichier:** `RUN_STATES_MINIMAL.lua`
**Problème:** Keybinds référençaient des states non définis

**RUN_KEYBINDS.lua** référence ces states:

- `HybridMode` ✅
- `MainWeapon` ❌ (manquant)
- `SubWeapon` ❌ (manquant)
- `Xp` ❌ (manquant)
- `RuneMode` ❌ (manquant)

**Quand UI_MANAGER essayait de lire ces states >> Stack Overflow**

**Solution:**

```lua
-- RUN_STATES_MINIMAL.lua - TOUS les states doivent être définis
function RUNStates.configure()
    state.HybridMode:options('PDT', 'Normal')
    state.HybridMode:set('PDT')

    state.MainWeapon = M{['description']='Main Weapon', 'Sword1', 'Sword2'}
    state.SubWeapon = M{['description']='Sub Weapon', 'Shield1', 'Shield2'}
    state.Xp = M{['description']='Xp', 'Off', 'On'}
    state.RuneMode = M{['description']='Rune Mode', 'Ignis', 'Gelus', 'Flabra', 'Tellus'}
end
```

### 3. UI_MANAGER.smart_init() vs init()

**Fichier:** `Tetsouo_RUN.lua` user_setup()
**Problème:** `smart_init()` cause récursion au chargement initial

```lua
-- AVANT (STACK OVERFLOW):
KeybindUI.smart_init("RUN", init_delay)

-- APRÈS (FONCTIONNE):
KeybindUI.init("RUN")
```

**Pourquoi?**

- `smart_init()` fait des checks/validations qui causent récursion
- `init()` est direct, pas de récursion

---

## SOLUTION FINALE

### Fichier 1: `RUN_STATES_MINIMAL.lua`

```lua
-- Minimal RUN States for testing
local RUNStates = {}

function RUNStates.configure()
    -- TOUS les states référencés par keybinds DOIVENT être définis
    state.HybridMode:options('PDT', 'Normal')
    state.HybridMode:set('PDT')

    -- MainWeapon state (required by keybinds)
    state.MainWeapon = M{['description']='Main Weapon', 'Sword1', 'Sword2'}

    -- SubWeapon state (required by keybinds)
    state.SubWeapon = M{['description']='Sub Weapon', 'Shield1', 'Shield2'}

    -- XP Mode (required by keybinds)
    state.Xp = M{['description']='Xp', 'Off', 'On'}

    -- RuneMode (required by keybinds)
    state.RuneMode = M{['description']='Rune Mode', 'Ignis', 'Gelus', 'Flabra', 'Tellus'}

    print('[RUN] States configured (MINIMAL MODE - all keybind states defined)')
end

return RUNStates
```

### Fichier 2: `Tetsouo_RUN.lua` - user_setup()

```lua
function user_setup()
    -- RUN-specific states (defines all states including HybridMode)
    local RUNStates = require('Tetsouo/config/run/RUN_STATES_MINIMAL')
    RUNStates.configure()

    if is_initial_setup then
        -- Load keybinds with delay
        coroutine.schedule(function()
            local success, keybinds = pcall(require, 'Tetsouo/config/run/RUN_KEYBINDS')
            if success and keybinds then
                RUNKeybinds = keybinds
                RUNKeybinds.bind_all()
            end
        end, 0.5)

        -- Initialize UI with init() instead of smart_init()
        coroutine.schedule(function()
            local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
            if ui_success and KeybindUI then
                KeybindUI.init("RUN")  -- ← init() au lieu de smart_init()
            end
        end, 2.0)

        -- ... reste du code ...
        is_initial_setup = false
    end
end
```

### Fichier 3: `RUN_KEYBINDS.lua` - show_intro()

```lua
--- Display RUN system intro message with keybinds only
--- Avoids circular dependencies by not requiring RUN_MACROBOOK/RUN_LOCKSTYLE.
function RUNKeybinds.show_intro()
    -- Get active binds (filtered by subjob)
    local active_binds = RUNKeybinds.get_active_binds()

    -- Show basic intro (no macro/lockstyle info to avoid circular require)
    MessageFormatter.show_system_intro("RUN SYSTEM LOADED", active_binds)
end
```

**IMPORTANT:** Ne PAS faire `require('RUN_LOCKSTYLE')` ou `require('RUN_MACROBOOK')` dans show_intro() >> Récursion circulaire!

---

## CHECKLIST POUR NOUVEAUX JOBS

### ✅ **Étape 1: Vérifier Syntaxe**

- [ ] Pas de double `end`
- [ ] Tous les `if` ont leur `end`
- [ ] Tous les `function` ont leur `end`
- [ ] Pas de `end` orphelin

### ✅ **Étape 2: States Configuration**

1. **Lister TOUS les states référencés dans keybinds:**

   ```lua
   // Dans JOB_KEYBINDS.lua, chercher:
   state = "HybridMode"
   state = "MainWeapon"
   state = "SubWeapon"
   // etc.
   ```

2. **Définir TOUS ces states dans JOB_STATES.lua:**

   ```lua
   function JOBStates.configure()
       -- TOUS les states doivent être définis ici
       state.HybridMode:options('PDT', 'Normal')
       state.MainWeapon = M{['description']='Main Weapon', 'Option1', 'Option2'}
       -- etc.
   end
   ```

3. **Vérifier correspondance:**

   ```bash
   # Extraire states des keybinds
   grep "state =" config/job/JOB_KEYBINDS.lua

   # Vérifier qu'ils existent dans states config
   grep "state\." config/job/JOB_STATES.lua
   ```

### ✅ **Étape 3: UI Initialization**

**TOUJOURS utiliser `init()` au lieu de `smart_init()` pour nouveaux jobs:**

```lua
-- ❌ MAUVAIS (peut causer stack overflow):
KeybindUI.smart_init("JOB", init_delay)

-- ✅ BON (safe):
KeybindUI.init("JOB")
```

### ✅ **Étape 4: Keybinds show_intro()**

**NE PAS require() les modules déjà chargés:**

```lua
-- ❌ MAUVAIS (récursion circulaire):
function JOBKeybinds.show_intro()
    local success, JOB_LOCKSTYLE = pcall(require, 'shared/jobs/job/functions/JOB_LOCKSTYLE')
    -- ...
end

-- ✅ BON (pas de require):
function JOBKeybinds.show_intro()
    local active_binds = JOBKeybinds.get_active_binds()
    MessageFormatter.show_system_intro("JOB SYSTEM LOADED", active_binds)
end
```

### ✅ **Étape 5: Delays**

**Utiliser delays appropriés pour éviter race conditions:**

```lua
-- Keybinds: 0.5s delay
coroutine.schedule(function()
    -- Load keybinds
end, 0.5)

-- UI: 2.0s delay (plus long pour éviter conflicts)
coroutine.schedule(function()
    KeybindUI.init("JOB")
end, 2.0)
```

### ✅ **Étape 6: Path des Sets**

**Vérifier le path des equipment sets:**

```lua
-- ❌ MAUVAIS:
include('Tetsouo/jobs/job/sets/job_sets.lua')

-- ✅ BON (vérifier où le fichier existe vraiment):
include('Tetsouo/sets/job_sets.lua')
```

---

## DEBUGGING STACK OVERFLOW

### Méthode 1: Désactivation Progressive

1. **Désactiver TOUT dans user_setup():**

   ```lua
   function user_setup()
       print('[JOB] user_setup() - MINIMAL MODE')
   end
   ```

   - Si ça load >> Problème dans user_setup()
   - Si stack overflow >> Problème ailleurs

2. **Réactiver états seulement:**

   ```lua
   function user_setup()
       local JOBStates = require('config/job/JOB_STATES_MINIMAL')
       JOBStates.configure()
   end
   ```

   - Si stack overflow >> Problème dans states

3. **Ajouter keybinds:**

   ```lua
   -- Ajouter keybinds
   coroutine.schedule(function()
       local success, keybinds = pcall(require, 'config/job/JOB_KEYBINDS')
       if success and keybinds then
           JOBKeybinds = keybinds
           JOBKeybinds.bind_all()
       end
   end, 0.5)
   ```

   - Si stack overflow >> Problème dans keybinds ou states manquants

4. **Ajouter UI:**

   ```lua
   coroutine.schedule(function()
       local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
       if ui_success and KeybindUI then
           KeybindUI.init("JOB")
       end
   end, 2.0)
   ```

   - Si stack overflow >> Problème UI avec states

### Méthode 2: Vérifier States vs Keybinds

```lua
-- Script de vérification
local keybind_states = {}
for _, bind in ipairs(JOBKeybinds.binds) do
    if bind.state then
        keybind_states[bind.state] = true
    end
end

-- Vérifier que tous existent
for state_name, _ in pairs(keybind_states) do
    if not state[state_name] then
        print('[ERROR] State missing: ' .. state_name)
    end
end
```

---

## ERREURS COURANTES

### ❌ **Erreur 1: States Manquants**

```
Keybinds référence state.MainWeapon
Mais MainWeapon pas défini dans JOB_STATES.lua
>> UI essaie de lire >> Stack Overflow
```

**Solution:** Définir TOUS les states référencés

### ❌ **Erreur 2: smart_init() au Chargement**

```
KeybindUI.smart_init() fait des validations complexes
>> Récursion au chargement initial
```

**Solution:** Utiliser `init()` à la place

### ❌ **Erreur 3: Circular Require**

```
JOB_KEYBINDS.show_intro()
  >> require('JOB_LOCKSTYLE')
    >> Déjà chargé par job_functions.lua
      >> Récursion
```

**Solution:** Ne PAS require() modules déjà chargés

### ❌ **Erreur 4: Double Définition States**

```
user_setup(): state.HybridMode:options('PDT', 'Normal')
JOB_STATES.configure(): state.HybridMode:options('PDT', 'MDT')
>> Conflit/récursion possible
```

**Solution:** Définir states UNE SEULE FOIS dans JOB_STATES

---

## TEMPLATE SAFE POUR NOUVEAUX JOBS

### user_setup() Template

```lua
function user_setup()
    -- Load states (defines ALL states including HybridMode)
    local JOBStates = require('Tetsouo/config/job/JOB_STATES_MINIMAL')
    JOBStates.configure()

    if is_initial_setup then
        -- Keybinds (0.5s delay)
        coroutine.schedule(function()
            local success, keybinds = pcall(require, 'Tetsouo/config/job/JOB_KEYBINDS')
            if success and keybinds then
                JOBKeybinds = keybinds
                JOBKeybinds.bind_all()
            end
        end, 0.5)

        -- UI (2.0s delay, use init() not smart_init())
        coroutine.schedule(function()
            local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
            if ui_success and KeybindUI then
                KeybindUI.init("JOB")  -- ← IMPORTANT: init() pas smart_init()
            end
        end, 2.0)

        -- JobChangeManager
        local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
        if jcm_success and JobChangeManager then
            if select_default_lockstyle and select_default_macro_book then
                JobChangeManager.initialize({
                    keybinds = JOBKeybinds,
                    ui = KeybindUI,
                    lockstyle = select_default_lockstyle,
                    macrobook = select_default_macro_book
                })

                if player then
                    select_default_macro_book()
                    coroutine.schedule(select_default_lockstyle, LockstyleConfig.initial_load_delay)
                end
            end
        end

        -- Warp System
        local warp_success, WarpInit = pcall(require, 'shared/utils/warp/warp_init')
        if warp_success and WarpInit then
            WarpInit.init()
        end

        is_initial_setup = false
    end
end
```

### JOB_STATES_MINIMAL.lua Template

```lua
local JOBStates = {}

function JOBStates.configure()
    -- Define ALL states referenced in JOB_KEYBINDS.lua

    state.HybridMode:options('PDT', 'Normal')
    state.HybridMode:set('PDT')

    state.MainWeapon = M{['description']='Main Weapon', 'Weapon1', 'Weapon2'}
    state.SubWeapon = M{['description']='Sub Weapon', 'Shield1', 'Shield2'}

    -- Add other states as needed based on keybinds

    print('[JOB] States configured')
end

return JOBStates
```

---

## RÉSUMÉ

**3 Fixes Critiques pour Éviter Stack Overflow:**

1. ✅ **Définir TOUS les states** référencés par keybinds
2. ✅ **Utiliser `init()` au lieu de `smart_init()`** pour UI
3. ✅ **Ne PAS require() modules déjà chargés** dans show_intro()

**Bonus:**

- Vérifier syntaxe (pas de double `end`)
- Utiliser delays appropriés (0.5s keybinds, 2.0s UI)
- Vérifier paths des fichiers

---

**Date:** 2025-11-03
**Job Testé:** RUN (Rune Fencer)
**Status:** ✅ RÉSOLU - Pas de stack overflow
