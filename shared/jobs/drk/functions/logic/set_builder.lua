---  ═══════════════════════════════════════════════════════════════════════════
---   DRK Set Builder - Shared Set Construction Logic
---  ═══════════════════════════════════════════════════════════════════════════
---   Provides centralized set building for engaged states with Aftermath support.
---   Handles:
---   • Aftermath Lv.3 detection for Liberator (sets.engaged.AM3)
---   • PDT mode support (sets.engaged.PDT for all weapons)
---   • Weapon application via weapon sets (sets.Liberator, etc.)
---   • Buff variant integration (Dark Seal, Nether Void)
---
---   Engaged sets (3 total):
---   • sets.engaged        - Base DPS set (all weapons)
---   • sets.engaged.PDT    - Physical defense mode (all weapons)
---   • sets.engaged.AM3    - Aftermath Lv.3 (Liberator mythic)
---   • Weapons applied separately via WeaponResolver.set_for (sets[weapon_name])
---
---   Used by: DRK_ENGAGED.lua, DRK_IDLE.lua
---
---   @file    shared/jobs/drk/functions/logic/set_builder.lua
---   @author  ejouanchicot
---   @version 2.2
---   @date    Created: 2025-11-10 | Updated: 2025-11-10
---  ═══════════════════════════════════════════════════════════════════════════

local DRKSetBuilder = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES
---  ═══════════════════════════════════════════════════════════════════════════

-- Load DRK buff anticipation logic
local DRKBuffAnticipation = require('shared/jobs/drk/functions/logic/drk_buff_anticipation')


-- Town set and movement speed, shared with the other jobs
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

---  ═══════════════════════════════════════════════════════════════════════════
---   AFTERMATH LV.3 DETECTION (ENGAGED)
---  ═══════════════════════════════════════════════════════════════════════════

---   Select engaged base set with Liberator Aftermath Lv.3 detection
---   Aftermath Lv.3 (buff ID: 272) + Liberator = Use specialized AM3 set
---
---   Priority order:
---   0. The weapon's own sets.engaged.<Weapon>AFM3 while its Aftermath is up
---      (weapon_aftermath.lua, any weapon)
---   1. Aftermath Lv.3 + Liberator      >> sets.engaged.AM3
---   2. HybridMode = 'PDT'              >> sets.engaged.PDT
---   3. HybridMode = 'Accu'             >> sets.engaged.Accu, else sets.engaged
---
---   @param weapon_name string Current main weapon name
---   @param hybrid_mode string Current HybridMode ('PDT' or 'Accu')
---   @return table Selected engaged set
function DRKSetBuilder.select_engaged_base(weapon_name, hybrid_mode)
    local weapon_am = require('shared/utils/equipment/weapon_aftermath').set(weapon_name)
    if weapon_am then
        return weapon_am
    end

    -- PRIORITY 1: Check for Aftermath Lv.3 (buff ID 272) + Liberator
    if buffactive[272] and weapon_name == 'Liberator' then
        if sets.engaged.AM3 then
            return sets.engaged.AM3
        end
    end

    -- PRIORITY 2: PDT mode (only HybridMode with dedicated set)
    if hybrid_mode == 'PDT' and sets.engaged.PDT then
        return sets.engaged.PDT
    end

    -- PRIORITY 3: the Accu set when it exists, else the base engaged set
    if hybrid_mode == 'Accu' and sets.engaged.Accu then
        return sets.engaged.Accu
    end
    return sets.engaged
end

---  ═══════════════════════════════════════════════════════════════════════════
---   WEAPON APPLICATION
---  ═══════════════════════════════════════════════════════════════════════════

---   Apply weapon to set
---   Uses weapon sets defined in drk_sets.lua (e.g., sets.Liberator).
---   Falls back gracefully if weapon set not found.
---
---   @param result table Current equipment set
---   @param weapon_name string Weapon to apply
---   @return table Set with weapon applied (or unchanged if no weapon set)
function DRKSetBuilder.apply_weapon(result, weapon_name)
    return BaseSetBuilder.lay_weapon(result, 'main', weapon_name)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   BUFF VARIANTS APPLICATION
---  ═══════════════════════════════════════════════════════════════════════════

---   Apply buff variants (Dark Seal, Nether Void) to engaged set
---   Checks both buffactive[] and pending flags for instant detection.
---
---   @param result table Current equipment set
---   @param weapon_name string Current weapon name
---   @param hybrid_mode string Current HybridMode
---   @return table Set with buff variants applied
function DRKSetBuilder.apply_buff_variants(result, weapon_name, hybrid_mode)
    if DRKBuffAnticipation then
        return DRKBuffAnticipation.apply_buff_variants(result, weapon_name, hybrid_mode)
    end
    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE SET BUILDER (PUBLIC API)
---  ═══════════════════════════════════════════════════════════════════════════

---   Build complete idle set: town set on top of the idle in a city, else
---   sets.idle[HybridMode] (PDT) when it exists; then the weapon, then
---   movement speed outside town (as on the other jobs)
---   @param base_set table Base idle set from Mote-Include
---   @return table Complete idle set with weapon and movement applied
function DRKSetBuilder.build_idle_set(base_set)
    if not base_set then
        return {}
    end

    local result, in_town = BaseSetBuilder.select_idle_base(base_set)

    -- Apply current weapon
    local weapon_name = state.MainWeapon and state.MainWeapon.current
    if weapon_name then
        result = DRKSetBuilder.apply_weapon(result, weapon_name)
    end

    if in_town then
        return result
    end

    -- state.Moving is created and updated by AutoMove
    return BaseSetBuilder.apply_movement(result)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED SET BUILDER (PUBLIC API)
---  ═══════════════════════════════════════════════════════════════════════════

---   Build complete engaged set with all DRK logic (like WAR)
---   Processing order:
---   1. Select base (Aftermath Lv.3 detection + HybridMode)
---   2. Apply weapon (main/sub slots)
---   3. Apply buff variants (Dark Seal, Nether Void)
---
---   @param weapon_name string Current main weapon name
---   @param hybrid_mode string Current HybridMode ('PDT' or 'Accu')
---   @return table Complete engaged set with all modifications applied
function DRKSetBuilder.build_engaged_set(weapon_name, hybrid_mode)
    -- Step 1: Select base set (AM3 detection + HybridMode)
    local result = DRKSetBuilder.select_engaged_base(weapon_name, hybrid_mode)
    -- the party support's version of it (.Solo, .Group: shared/utils/party/support_tier.lua)
    result = require('shared/utils/party/support_tier').engaged(result)

    -- Step 2: Apply weapon (overwrites main/sub like WAR)
    result = DRKSetBuilder.apply_weapon(result, weapon_name)

    -- Step 3: Apply buff variants (Dark Seal, Nether Void)
    result = DRKSetBuilder.apply_buff_variants(result, weapon_name, hybrid_mode)

    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return DRKSetBuilder
