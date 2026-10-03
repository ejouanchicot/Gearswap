---  ═══════════════════════════════════════════════════════════════════════════
---   Set Builder - Shared Set Construction Logic (WAR)
---  ═══════════════════════════════════════════════════════════════════════════
---   Provides centralized set building for both engaged and idle states.
---   Handles:
---   • Engaged base selection: Kraken Club, stances (SubtleBlow/Hoxne),
---     Aftermath Lv.3 on Ukonvasara, weapon-specific sets, HybridMode
---   • Weapon selection and set application
---   • Town detection (safe zones with optimized gear)
---   • Movement speed gear application
---   • HybridMode support (PDT/Normal)
---
---   Used by: WAR_IDLE.lua and WAR_ENGAGED.lua
---
---   @file    shared/jobs/war/functions/logic/set_builder.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2025-10-06
---  ═══════════════════════════════════════════════════════════════════════════
local SetBuilder = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES
---  ═══════════════════════════════════════════════════════════════════════════

-- Load base set builder (universal functions)
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')


---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED BASE SELECTION (KRAKEN CLUB, STANCE, AFTERMATH LV.3, WEAPON)
---  ═══════════════════════════════════════════════════════════════════════════

--- HybridMode values that are explicit stances: their set wins over the
--- Aftermath and weapon-specific sets, since the player picked them on purpose.
local STANCE_MODES = {
    SubtleBlow = true,
    Hoxne      = true,
}

---   Aftermath Lv.3 (buff ID 272) is up on Ukonvasara
---   @return boolean
local function ukonvasara_am3()
    return buffactive[272] ~= nil and state.MainWeapon ~= nil
        and state.MainWeapon.current == 'Ukonvasara'
end

---   The current weapon's own Aftermath set (sets.engaged.<Weapon>AFM3, e.g.
---   LaphriaAFM3), common to every job: shared/utils/equipment/weapon_aftermath.lua
---   (none when the player chose AftermathSet = FastTP).
---   @return table|nil
local function weapon_am3_set()
    return require('shared/utils/equipment/weapon_aftermath').set(state.MainWeapon and state.MainWeapon.current)
end

---   Engaged set of the active stance (sets.engaged.SubtleBlow / .Hoxne)
---   Under Ukonvasara AM3 the stance's AFM3 variant wins when it is defined
---   (sets.engaged.HoxneAFM3).
---   @return table|nil Stance set, or nil outside a stance or if undefined
local function select_stance_engaged()
    local mode = state.HybridMode and state.HybridMode.current
    if not (mode and STANCE_MODES[mode]) then
        return nil
    end
    if ukonvasara_am3() and sets.engaged[mode .. 'AFM3'] then
        return sets.engaged[mode .. 'AFM3']
    end
    return sets.engaged[mode]
end

---   Engaged set dedicated to the current weapon set (e.g. sets.engaged.Naegling)
---   @return table|nil Weapon engaged set, or nil if none is defined
local function select_weapon_engaged()
    if not (state.MainWeapon and state.MainWeapon.current) then
        return nil
    end
    return sets.engaged[state.MainWeapon.current]
end

---   Select engaged base set with Kraken Club and Aftermath Lv.3 detection
---   Kraken Club detection takes highest priority for specialized multi-attack set.
---   Aftermath Lv.3 (buff ID: 272) + a weapon = its own AFM3 set (UkonvasaraAFM3, LaphriaAFM3)
---
---   Priority order:
---   1. Kraken Club weapon set       >> sets.engaged.PDTKC
---   2. Stance (SubtleBlow / Hoxne)  >> sets.engaged[HybridMode] (or its AFM3 variant)
---   3. Aftermath + weapon AFM3 set  >> sets.engaged[MainWeapon .. 'AFM3'] (LaphriaAFM3)
---   4. Weapon-specific set          >> sets.engaged[MainWeapon] (e.g. Naegling)
---   5. HybridMode (PDT/Normal)      >> sets.engaged[HybridMode]
---   6. Fallback                     >> base_set
---
---   @param base_set table Base engaged set from war_sets.lua
---   @return table Selected engaged set (PDTKC / the weapon's AFM3 set if conditions met, otherwise hybrid/base)
function SetBuilder.select_engaged_base(base_set)
    -- PRIORITY 1: Check for NaeglingKC weapon set (Kraken Club in sub)
    if state.MainWeapon and state.MainWeapon.current == 'NaeglingKC' and sets.engaged.PDTKC then
        return sets.engaged.PDTKC
    end

    -- Kraken Club still in the off hand (BaseSetBuilder.kraken_in_offhand)
    if sets.engaged.PDTKC and BaseSetBuilder.kraken_in_offhand() then
        return sets.engaged.PDTKC
    end

    -- PRIORITY 2: Explicit stance chosen by the player
    local stance_set = select_stance_engaged()
    if stance_set then
        return stance_set
    end

    -- PRIORITY 3: Aftermath: the weapon's own AFM3 set (UkonvasaraAFM3, LaphriaAFM3)
    local am3_set = weapon_am3_set()
    if am3_set then
        return am3_set
    end

    -- PRIORITY 4: Weapon-specific set (sets.engaged.Naegling, .Ukonvasara...)
    local weapon_set = select_weapon_engaged()
    if weapon_set then
        return weapon_set
    end

    -- PRIORITY 5: Normal HybridMode logic (PDT or Normal)
    if state.HybridMode and state.HybridMode.current then
        local hybrid_set = sets.engaged[state.HybridMode.current]
        if hybrid_set then
            return hybrid_set
        end
    end

    return base_set
end

---  ═══════════════════════════════════════════════════════════════════════════
---   WEAPON APPLICATION
---  ═══════════════════════════════════════════════════════════════════════════

---   Apply main weapon to set
---   Uses weapon sets defined in war_sets.lua (e.g., sets.Ukonvasara).
---   Falls back gracefully if weapon set not found.
---
---   @param result table Current equipment set
---   @return table Set with main weapon applied (or unchanged if no weapon set)
function SetBuilder.apply_weapon(result)
    return BaseSetBuilder.lay_weapon(result, 'main', state.MainWeapon and state.MainWeapon.current)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MOVEMENT SPEED (INHERITED FROM BASE)
---  ═══════════════════════════════════════════════════════════════════════════

-- Inherit universal movement function from BaseSetBuilder
SetBuilder.apply_movement = BaseSetBuilder.apply_movement


---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE BASE SELECTION (TOWN + HYBRIDMODE)
---  ═══════════════════════════════════════════════════════════════════════════

---   Select idle base set with Town detection AND HybridMode support
---   Priority order:
---   1. In town                     >> sets.idle.Town
---   2. HybridMode (PDT/Normal)     >> sets.idle[HybridMode]
---   3. Fallback                    >> base_set
---
---   @param base_set table Base idle set from war_sets.lua
---   @return table Selected idle set
---   @return boolean True if in town
SetBuilder.select_idle_base = BaseSetBuilder.select_idle_base

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED SET BUILDER (PUBLIC API)
---  ═══════════════════════════════════════════════════════════════════════════

--- The Hoxne stance carries its Ampulla, as on PLD (ampulla_lock.lua)
local apply_stance_ammo = require('shared/utils/equipment/ampulla_lock').stance_ammo

---   Build complete engaged set with all WAR logic
---   Processing order:
---   1. Select base (see select_engaged_base)
---   2. Apply weapon
---
---   @param base_set table Base engaged set from war_sets.lua
---   @return table Complete engaged set with all modifications applied
function SetBuilder.build_engaged_set(base_set)
    if not base_set then
        return {}
    end

    -- Step 1: Select base set (see select_engaged_base)
    local result = SetBuilder.select_engaged_base(base_set)
    -- the party support's version of it (.Solo, .Group: shared/utils/party/support_tier.lua)
    result = require('shared/utils/party/support_tier').engaged(result)

    -- Step 2: Apply weapon
    result = SetBuilder.apply_weapon(result)

    -- Step 3: The stance's ammo (Hoxne Ampulla)
    return apply_stance_ammo(result)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE SET BUILDER (PUBLIC API)
---  ═══════════════════════════════════════════════════════════════════════════

---   Build complete idle set with all WAR logic
---   Processing order:
---   1. Town set, else sets.idle[HybridMode], else base_set
---   2. Apply weapon (applies to both town and non-town)
---   3. Apply movement speed (non-town only)
---
---   @param base_set table Base idle set from war_sets.lua
---   @return table Complete idle set with all modifications applied
function SetBuilder.build_idle_set(base_set)
    if not base_set then
        return {}
    end

    -- Step 1: Town set, else HybridMode idle set
    local result, in_town = SetBuilder.select_idle_base(base_set)

    -- Step 2: Apply weapon (applies to both town and non-town), then the
    -- stance's ammo (Hoxne Ampulla)
    result = apply_stance_ammo(SetBuilder.apply_weapon(result))

    -- Step 3: Early return if in town (skip movement gear)
    if in_town then
        return result
    end

    -- Step 4: Apply movement speed
    result = SetBuilder.apply_movement(result)

    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return SetBuilder
