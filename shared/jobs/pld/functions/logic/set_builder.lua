---  ═══════════════════════════════════════════════════════════════════════════
---   Set Builder - Shared Set Construction Logic (PLD)
---  ═══════════════════════════════════════════════════════════════════════════
---   Provides centralized set building for both engaged and idle states.
---   Handles complex PLD-specific gear logic:
---   • Main weapon selection (Burtgang, Naegling, Shining, Malevo)
---   • Shield selection (Duban, Aegis, Blurred Shield +1; weapon-driven in
---     Sortie, stance-driven under /SCH)
---   • Shining exception (Alber Strap grip requirement requirement)
---   • HybridMode application (PDT/MDT/Sortie, or Engaged/Tanking/Hoxne
---     under /SCH, with shield awareness)
---   • XP mode support (idleXp/meleeXp sets)
---   • Movement speed gear
---   • Town detection and town gear
---
---   Features:
---   • Shared logic for both idle and engaged
---   • Safe pcall for set_combine operations
---   • Modular functions for easy maintenance
---
---   @file    jobs/pld/functions/logic/set_builder.lua
---   @author  Tetsouo
---   @version 1.0.0
---   @date    Created: 2025-10-06
---  ═══════════════════════════════════════════════════════════════════════════
local SetBuilder = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES
---  ═══════════════════════════════════════════════════════════════════════════

-- Load base set builder (universal functions)
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

-- Load message formatter for error display
local MessageFormatter = require('shared/utils/messages/message_formatter')

---  ═══════════════════════════════════════════════════════════════════════════
---   HYBRIDMODE → SET MAPPING
---  ═══════════════════════════════════════════════════════════════════════════

--- Which set each HybridMode wears. Most modes name their own set, but some
--- borrow: Sortie wants the mitigation/TP mix while engaged and the magic
--- mitigation set while idle, and /SCH's Tanking stance is that same magic
--- mitigation set - all of which already exist. Hoxne is Engaged plus a lock
--- on the ammo slot, so it wears the Engaged sets unchanged.
local ENGAGED_SET_BY_MODE = {
    PDT     = 'PDT',
    MDT     = 'MDT',
    Sortie  = 'TP',
    Engaged = 'Engaged',
    Tanking = 'MDT',
    Hoxne   = 'Engaged'
}

local IDLE_SET_BY_MODE = {
    PDT     = 'PDT',
    MDT     = 'MDT',
    Sortie  = 'MDT',
    Engaged = 'MDT',
    Tanking = 'MDT',
    Hoxne   = 'MDT'
}

--- In Sortie the shield follows the weapon instead of the mode's set: the
--- mitigation sets are shared with the other modes and carry their own sub,
--- so the sub is decided here rather than duplicated into every Sortie set.
local SORTIE_SHIELD_BY_WEAPON = {
    Burtgang = 'Aegis',
    Naegling = 'Blurred Shield +1'
}

--- Under /SCH the same job is done by the stance rather than the weapon:
--- each stance owns a weapon (PLD_STATES) and the shield that goes with it.
--- Every stance idles in sets.idle.MDT, which carries Aegis, so the two that
--- hold Excalibur have to be corrected back to Duban here.
local SCH_SHIELD_BY_MODE = {
    Engaged = 'Duban',
    Tanking = 'Aegis',
    Hoxne   = 'Duban'
}

---   Resolve the set a HybridMode maps to, or nil when the mode names no set
---   @param source table Set container (sets.engaged or sets.idle)
---   @param mode_map table ENGAGED_SET_BY_MODE or IDLE_SET_BY_MODE
---   @return table|nil Set for the active HybridMode
local function hybrid_set(source, mode_map)
    local mode = state.HybridMode and state.HybridMode.value
    local set_name = mode and mode_map[mode]
    return set_name and source[set_name] or nil
end

---  ═══════════════════════════════════════════════════════════════════════════
---   WEAPON/SHIELD APPLICATION
---  ═══════════════════════════════════════════════════════════════════════════

---   Apply main weapon to set
---   Uses weapon sets defined in pld_sets.lua (sets.Burtgang, sets.Naegling, etc.)
---   @param result table Current equipment set
---   @return table Set with main weapon applied
function SetBuilder.apply_weapon(result)
    if not state.MainWeapon or not state.MainWeapon.current then
        return result
    end

    -- Use sets.* directly (defined in pld_sets.lua)
    local weapon_set = sets[state.MainWeapon.current]
    if weapon_set then
        result = set_combine(result, weapon_set)
    end

    return result
end

---   Apply sub weapon (shield) to set
---   Uses shield sets defined in pld_sets.lua (sets.Duban, sets.Aegis, etc.)
---   Handles Shining exception (Alber Strap).
---   @param result table Current equipment set
---   @param in_town boolean Whether player is in town
---   @return table Set with shield applied
function SetBuilder.apply_shield(result, in_town)
    -- Exception 1: Shining always uses Alber Strap (Polearm needs grip)
    if state.MainWeapon and state.MainWeapon.current == 'Shining' then
        result = set_combine(result, sets.Alber)
        return result
    end

    -- Exception 2: In town, use HybridMode shield
    if in_town then
        local idle_set = hybrid_set(sets.idle, IDLE_SET_BY_MODE)
        if idle_set and idle_set.sub then
            result = set_combine(result, {
                sub = idle_set.sub
            })
        end
        return result
    end


    return result
end

---   Force the shield the current mode calls for, where the mode owns it
---   Sortie reads it off the weapon, the /SCH stances name it outright, and
---   every other mode leaves the sub to its own set. Runs last so it wins over
---   the sub carried by that set.
---   @param result table Current equipment set
---   @return table Set with the mode's shield applied
function SetBuilder.apply_mode_shield(result)
    local mode = state.HybridMode and state.HybridMode.value
    if not mode then
        return result
    end

    local shield = SCH_SHIELD_BY_MODE[mode]
    if not shield and mode == 'Sortie' then
        local weapon = state.MainWeapon and state.MainWeapon.value
        shield = weapon and SORTIE_SHIELD_BY_WEAPON[weapon]
    end

    if shield then
        result = set_combine(result, {sub = shield})
    end

    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MOVEMENT SPEED (INHERITED FROM BASE)
---  ═══════════════════════════════════════════════════════════════════════════

-- Inherit universal movement function from BaseSetBuilder
SetBuilder.apply_movement = BaseSetBuilder.apply_movement


---  ═══════════════════════════════════════════════════════════════════════════
---   TOWN DETECTION (INHERITED FROM BASE)
---  ═══════════════════════════════════════════════════════════════════════════

-- Inherit universal town detection function from BaseSetBuilder
SetBuilder.select_idle_base = BaseSetBuilder.select_idle_base_town

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED BASE SELECTION
---  ═══════════════════════════════════════════════════════════════════════════

---   Select engaged base set with BurtgangKC detection
---   BurtgangKC (Kraken Club) detection takes priority for specialized multi-attack set.
---
---   Priority order:
---   1. BurtgangKC weapon set      >> sets.engaged.BurtgangKC
---   2. HybridMode (PDT/MDT)       >> sets.engaged[HybridMode]
---   3. Fallback                    >> base_set
---
---   @param base_set table Base engaged set from pld_sets.lua
---   @return table Selected engaged set (BurtgangKC if condition met, otherwise hybrid/base)
function SetBuilder.select_engaged_base(base_set)
    -- PRIORITY 1: Check for BurtgangKC weapon set (Kraken Club in sub)
    if state.MainWeapon and state.MainWeapon.current == 'BurtgangKC' and sets.engaged.BurtgangKC then
        return sets.engaged.BurtgangKC
    end

    -- PRIORITY 2: Check if Kraken Club is already equipped (manual equip or other weapon set)
    if player and player.equipment and player.equipment.sub then
        local sub_weapon = player.equipment.sub
        if sub_weapon == 'Kraken Club' and sets.engaged.BurtgangKC then
            return sets.engaged.BurtgangKC
        end
    end

    -- PRIORITY 3: Normal HybridMode logic (PDT, MDT or Sortie)
    local mode_set = hybrid_set(sets.engaged, ENGAGED_SET_BY_MODE)
    if mode_set then
        -- If Shining weapon, return HybridMode set WITHOUT sub (Alber will be applied after)
        if state.MainWeapon and state.MainWeapon.current == 'Shining' then
            local hybrid_no_sub = {}
            for slot, item in pairs(mode_set) do
                if slot ~= 'sub' then
                    hybrid_no_sub[slot] = item
                end
            end
            return hybrid_no_sub
        end
        return mode_set
    end

    return base_set
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED SET BUILDER
---  ═══════════════════════════════════════════════════════════════════════════

---   Build complete engaged set with all PLD logic
---   @param base_set table Base engaged set
---   @return table Complete engaged set
function SetBuilder.build_engaged_set(base_set)
    if not base_set then
        return {}
    end

    -- Step 1: Select base set (BurtgangKC detection + HybridMode)
    local result = SetBuilder.select_engaged_base(base_set)
    local is_shining = state.MainWeapon and state.MainWeapon.current == 'Shining'
    local is_burtgang_kc = state.MainWeapon and state.MainWeapon.current == 'BurtgangKC'

    -- Step 2: Apply main weapon
    result = SetBuilder.apply_weapon(result)

    -- Step 3: Apply Alber Strap if Shining (overrides HybridMode shield)
    -- SKIP if BurtgangKC (already has Kraken Club in sub)
    if is_shining and not is_burtgang_kc then
        result = set_combine(result, sets.Alber)
    end

    -- Step 4: Apply XP mode (meleeXp set when Xp = On)
    if state.Xp and state.Xp.value == 'On' and sets.meleeXp then
        result = set_combine(result, sets.meleeXp)
    end

    -- Step 5: Mode shield (Sortie weapon-driven, /SCH stance-driven)
    result = SetBuilder.apply_mode_shield(result)

    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE SET BUILDER
---  ═══════════════════════════════════════════════════════════════════════════

---   Build complete idle set with all PLD logic
---   @param base_set table Base idle set
---   @return table Complete idle set
function SetBuilder.build_idle_set(base_set)
    if not base_set then
        return {}
    end

    -- Step 1: Town detection - use town set as base
    local result, in_town = SetBuilder.select_idle_base(base_set)
    local is_shining = state.MainWeapon and state.MainWeapon.current == 'Shining'
    local is_burtgang_kc = state.MainWeapon and state.MainWeapon.current == 'BurtgangKC'

    -- Step 2: Apply main weapon (applies to both town and non-town)
    result = SetBuilder.apply_weapon(result)

    -- Step 3: Apply shield (handles town mode and Shining)
    -- SKIP if BurtgangKC (already has Kraken Club in sub)
    if not is_burtgang_kc then
        result = SetBuilder.apply_shield(result, in_town)
    end

    -- Step 4: Early return if in town (weapons/shields already applied)
    if in_town then
        return SetBuilder.apply_mode_shield(result)
    end

    -- Step 5: Apply HybridMode (PDT/MDT/Sortie) outside of town - SKIP sub if Shining or BurtgangKC
    local mode_set = hybrid_set(sets.idle, IDLE_SET_BY_MODE)
    if mode_set then
        if is_shining or is_burtgang_kc then
            -- Shining/BurtgangKC: Apply HybridMode WITHOUT sub (keep Alber Strap/Kraken Club)
            local hybrid_no_sub = {}
            for slot, item in pairs(mode_set) do
                if slot ~= 'sub' then
                    hybrid_no_sub[slot] = item
                end
            end
            result = set_combine(result, hybrid_no_sub)
        else
            -- Normal: Apply full HybridMode set (including sub)
            result = set_combine(result, mode_set)
        end
    end

    -- Step 6: Apply XP mode (idleXp set when Xp = On) - AFTER HybridMode to override
    if state.Xp and state.Xp.value == 'On' and sets.idleXp then
        result = set_combine(result, sets.idleXp)
    end

    -- Step 7: Apply movement speed
    result = SetBuilder.apply_movement(result)

    -- Step 8: Mode shield (Sortie weapon-driven, /SCH stance-driven)
    result = SetBuilder.apply_mode_shield(result)

    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return SetBuilder
