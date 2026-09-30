---  ═══════════════════════════════════════════════════════════════════════════
---   Set Builder - Shared Set Construction Logic (PLD)
---  ═══════════════════════════════════════════════════════════════════════════
---   Provides centralized set building for both engaged and idle states.
---   Handles complex PLD-specific gear logic:
---   • Main weapon selection (MainWeapon state, a stance's own weapon)
---   • Shield per weapon for the modes that own it, and the grip of a
---     two-handed weapon: the player's PLD_WEAPONS.lua (weapons_config below)
---   • HybridMode application (PDT/MDT/Sortie, or DPS/Tanking/Hoxne
---     under /SCH, with shield awareness)
---   • XP mode support (idleXp/meleeXp sets)
---   • Movement speed gear (idle only)
---   • Town detection and town gear (idle only)
---   • Hoxne Ampulla ammo in the Hoxne stance
---
---   Features:
---   • Shared logic for both idle and engaged
---   • Safe pcall for set_combine operations
---   • Modular functions for easy maintenance
---
---   @file    shared/jobs/pld/functions/logic/set_builder.lua
---   @author  ejouanchicot
---   @version 1.0.0
---   @date    Created: 2025-10-06
---  ═══════════════════════════════════════════════════════════════════════════
local SetBuilder = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES
---  ═══════════════════════════════════════════════════════════════════════════

local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')
-- Unused here; kept so the module still loads MessageFormatter as it always did.
require('shared/utils/messages/message_formatter')

---  ═══════════════════════════════════════════════════════════════════════════
---   HYBRIDMODE → SET MAPPING
---  ═══════════════════════════════════════════════════════════════════════════

--- Which set each HybridMode wears. Most modes name their own set, but some
--- borrow: Sortie wants the mitigation/TP mix while engaged and the magic
--- mitigation set while idle, and /SCH's Tanking and Hoxne stances idle in
--- that same magic mitigation set - all of which already exist. DPS and Hoxne
--- each own their engaged build: the Ampulla's charge supplies the Double
--- Attack that DPS has to buy with gear.
local ENGAGED_SET_BY_MODE = {
    PDT     = 'PDT',
    MDT     = 'MDT',
    Sortie  = 'TP',
    DPS     = 'DPS',
    Tanking = 'MDT',
    Hoxne   = 'Hoxne'
}

local IDLE_SET_BY_MODE = {
    PDT     = 'PDT',
    MDT     = 'MDT',
    Sortie  = 'MDT',
    DPS     = 'MDT',
    Tanking = 'MDT',
    Hoxne   = 'MDT'
}

--- The player's pld/combat/PLD_WEAPONS.lua (see the template for examples):
---   shields        {[HybridMode] = {[weapon] = shield}}: in those modes the
---                  shield follows the weapon, winning over the set's sub
---                  (Sortie shares the mitigation sets of the other modes,
---                  which carry their own sub). Other modes: the set's sub.
---   stance_weapon  {[HybridMode] = weapon}: the weapon a mode puts in hand
---                  whatever MainWeapon says (the hate stance's weapon)
---   grips          {[weapon] = grip}: two-handed weapons take a grip, not a
---                  shield. Default {Shining = 'Alber Strap'}: a polearm has
---                  to (a rule of the game, not a gear choice).
--- Nothing forced when the file is missing, except the default grip.
local DEFAULT_GRIPS = {Shining = 'Alber Strap'}

--- The config, read once per load.
local weapons_cfg = nil
local function weapons_config()
    if weapons_cfg == nil then
        local ok, cfg = pcall(function()
            return require('shared/utils/core/char_paths').optional('job', 'PLD_WEAPONS', 'PLD')
        end)
        weapons_cfg = (ok and type(cfg) == 'table') and cfg or false
    end
    return weapons_cfg or {}
end

local function current_mode()
    return state.HybridMode and state.HybridMode.value
end

--- The weapon a stance puts in hand, or nil when the mode keeps MainWeapon.
--- @return string|nil Weapon set name
local function stance_weapon()
    local mode = current_mode()
    local by_mode = weapons_config().stance_weapon
    return mode and type(by_mode) == 'table' and by_mode[mode] or nil
end

--- The grip of the weapon in hand, or nil for a one-handed weapon.
--- @return string|nil
local function grip_for(weapon)
    local grips = weapons_config().grips
    if type(grips) ~= 'table' then grips = DEFAULT_GRIPS end
    return weapon and grips[weapon] or nil
end


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

---   The weapon actually in hand, stance override included
---   state.MainWeapon is the player's choice, but the Tanking stance holds
---   Burtgang whatever that choice says. Anything that has to know what is
---   being swung - the weaponskill slots, not just the gear - asks here.
---   @return string|nil Weapon set name
function SetBuilder.current_weapon()
    return stance_weapon() or (state.MainWeapon and state.MainWeapon.value)
end

---   Apply main weapon to set
---   Uses weapon sets defined in pld_sets.lua (sets.Burtgang, sets.Naegling, etc.)
---   @param result table Current equipment set
---   @return table Set with main weapon applied
function SetBuilder.apply_weapon(result)
    local weapon = SetBuilder.current_weapon()
    if not weapon then
        return result
    end

    -- Use sets.* directly (defined in pld_sets.lua)
    local weapon_set = sets[weapon]
    if weapon_set then
        result = set_combine(result, weapon_set)
    end

    return result
end

---   Apply sub weapon (shield) to set
---   A two-handed weapon takes its grip (PLD_WEAPONS.lua grips).
---   @param result table Current equipment set
---   @param in_town boolean Whether player is in town
---   @return table Set with shield applied
function SetBuilder.apply_shield(result, in_town)
    -- Exception 1: a two-handed weapon takes its grip, not a shield
    local grip = grip_for(state.MainWeapon and state.MainWeapon.current)
    if grip then
        result = set_combine(result, {sub = grip})
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

---   The Hoxne stance carries its Ampulla in every set, the way the stances
---   carry their shield (ampulla_lock.lua; every other mode leaves the slot to
---   its set)
SetBuilder.apply_mode_ammo = require('shared/utils/equipment/ampulla_lock').stance_ammo

---   Force the shield the current mode calls for, where the mode owns it
---   (PLD_WEAPONS.lua shields: the shield follows the weapon in hand); every
---   other mode leaves the sub to its own set. Runs last so it wins over the
---   sub carried by that set.
---   @param result table Current equipment set
---   @return table Set with the mode's shield applied
function SetBuilder.apply_mode_shield(result)
    local mode = current_mode()
    local shields = weapons_config().shields
    local by_weapon = mode and type(shields) == 'table' and shields[mode]
    local shield = type(by_weapon) == 'table' and by_weapon[SetBuilder.current_weapon() or ''] or nil
    if shield then
        result = set_combine(result, {sub = shield})
    end
    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MOVEMENT SPEED (INHERITED FROM BASE)
---  ═══════════════════════════════════════════════════════════════════════════

SetBuilder.apply_movement = BaseSetBuilder.apply_movement

---  ═══════════════════════════════════════════════════════════════════════════
---   TOWN DETECTION (INHERITED FROM BASE)
---  ═══════════════════════════════════════════════════════════════════════════

SetBuilder.select_idle_base = BaseSetBuilder.select_idle_base_town

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED BASE SELECTION
---  ═══════════════════════════════════════════════════════════════════════════

---   Select engaged base set with BurtgangKC detection
---   BurtgangKC (Kraken Club) detection takes priority for specialized multi-attack set.
---
---   Priority order:
---   1. BurtgangKC weapon set, or Kraken Club already in the sub slot
---                                  >> sets.engaged.BurtgangKC
---   2. HybridMode                  >> sets.engaged[ENGAGED_SET_BY_MODE[mode]]
---   3. Fallback                    >> base_set
---
---   @param base_set table Base engaged set from pld_sets.lua
---   @return table Selected engaged set (BurtgangKC if condition met, otherwise hybrid/base)
function SetBuilder.select_engaged_base(base_set)
    -- PRIORITY 1: Check for BurtgangKC weapon set (Kraken Club in sub)
    if state.MainWeapon and state.MainWeapon.current == 'BurtgangKC' and sets.engaged.BurtgangKC then
        return sets.engaged.BurtgangKC
    end

    -- PRIORITY 2: Kraken Club still in the off hand (BaseSetBuilder.kraken_in_offhand)
    if sets.engaged.BurtgangKC and BaseSetBuilder.kraken_in_offhand() then
        return sets.engaged.BurtgangKC
    end

    -- PRIORITY 3: HybridMode set (ENGAGED_SET_BY_MODE)
    local mode_set = hybrid_set(sets.engaged, ENGAGED_SET_BY_MODE)
    if mode_set then
        -- A two-handed weapon: the HybridMode set WITHOUT sub (its grip goes on after)
        if grip_for(state.MainWeapon and state.MainWeapon.current) then
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
    local is_two_handed = grip_for(state.MainWeapon and state.MainWeapon.current) ~= nil
    local is_burtgang_kc = state.MainWeapon and state.MainWeapon.current == 'BurtgangKC'

    -- Step 2: Apply main weapon
    result = SetBuilder.apply_weapon(result)

    -- Step 3: a two-handed weapon's grip (overrides HybridMode shield)
    -- SKIP if BurtgangKC (already has Kraken Club in sub)
    if is_two_handed and not is_burtgang_kc then
        result = set_combine(result, {sub = grip_for(state.MainWeapon.current)})
    end

    -- Step 4: Apply XP mode (meleeXp set when Xp = On)
    if state.Xp and state.Xp.value == 'On' and sets.meleeXp then
        result = set_combine(result, sets.meleeXp)
    end

    -- Step 5: Mode shield (PLD_WEAPONS.lua shields, weapon-driven)
    result = SetBuilder.apply_mode_shield(result)
    result = SetBuilder.apply_mode_ammo(result)

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
    local is_two_handed = grip_for(state.MainWeapon and state.MainWeapon.current) ~= nil
    local is_burtgang_kc = state.MainWeapon and state.MainWeapon.current == 'BurtgangKC'

    -- Step 2: Apply main weapon (applies to both town and non-town)
    result = SetBuilder.apply_weapon(result)

    -- Step 3: Apply shield (handles town mode and the grip of a two-handed weapon)
    -- SKIP if BurtgangKC (already has Kraken Club in sub)
    if not is_burtgang_kc then
        result = SetBuilder.apply_shield(result, in_town)
    end

    -- Step 4: Early return if in town (weapons/shields already applied)
    if in_town then
        return SetBuilder.apply_mode_ammo(SetBuilder.apply_mode_shield(result))
    end

    -- Step 5: Apply HybridMode set (IDLE_SET_BY_MODE) outside of town - SKIP sub if two-handed or BurtgangKC
    local mode_set = hybrid_set(sets.idle, IDLE_SET_BY_MODE)
    if mode_set then
        if is_two_handed or is_burtgang_kc then
            -- Two-handed / BurtgangKC: HybridMode WITHOUT sub (keep the grip / Kraken Club)
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

    -- Step 6b: Regen set (/SCH only, idle only), laid over whatever the stance
    -- chose: DPS, Tanking and Hoxne keep every slot sets.idleRegen leaves out.
    if state.Regen and state.Regen.value == 'On' and sets.idleRegen then
        result = set_combine(result, sets.idleRegen)
    end

    -- Step 7: Apply movement speed
    result = SetBuilder.apply_movement(result)

    -- Step 8: Mode shield (PLD_WEAPONS.lua shields, weapon-driven)
    result = SetBuilder.apply_mode_shield(result)
    result = SetBuilder.apply_mode_ammo(result)

    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return SetBuilder
