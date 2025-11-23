---============================================================================
--- Set Builder - Shared Set Construction Logic (PLD)
---============================================================================
--- Provides centralized set building for both engaged and idle states.
--- Handles complex PLD-specific gear logic:
---   • Main weapon selection (Burtgang, Naegling, Shining, Malevo)
---   • Shield selection (Duban, Aegis, Blurred Shield +1)
---   • Shining exception (Alber Strap grip requirement requirement)
---   • HybridMode application (PDT/MDT with shield awareness)
---   • XP mode support (idleXp/meleeXp sets)
---   • Movement speed gear
---   • Town detection and town gear
---
--- Features:
---   • Shared logic for both idle and engaged
---   • Safe pcall for set_combine operations
---   • Modular functions for easy maintenance
---
--- @file    jobs/pld/functions/logic/set_builder.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-06
---============================================================================
local SetBuilder = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Load base set builder (universal functions)
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

-- Load message formatter for error display
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- WEAPON/SHIELD APPLICATION
---============================================================================

--- Apply main weapon to set
--- Uses weapon sets defined in pld_sets.lua (sets.Burtgang, sets.Naegling, etc.)
--- @param result table Current equipment set
--- @return table Set with main weapon applied
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

--- Apply sub weapon (shield) to set
--- Uses shield sets defined in pld_sets.lua (sets.Duban, sets.Aegis, etc.)
--- Handles Shining exception (Alber Strap).
--- @param result table Current equipment set
--- @param in_town boolean Whether player is in town
--- @return table Set with shield applied
function SetBuilder.apply_shield(result, in_town)
    -- Exception 1: Shining always uses Alber Strap (Polearm needs grip)
    if state.MainWeapon and state.MainWeapon.current == 'Shining' then
        result = set_combine(result, sets.Alber)
        return result
    end

    -- Exception 2: In town, use HybridMode shield
    if in_town and state.HybridMode and state.HybridMode.value then
        if state.HybridMode.value == 'PDT' and sets.idle.PDT and sets.idle.PDT.sub then
            result = set_combine(result, {
                sub = sets.idle.PDT.sub
            })
        elseif state.HybridMode.value == 'MDT' and sets.idle.MDT and sets.idle.MDT.sub then
            result = set_combine(result, {
                sub = sets.idle.MDT.sub
            })
        end
        return result
    end


    return result
end

---============================================================================
--- MOVEMENT SPEED (INHERITED FROM BASE)
---============================================================================

-- Inherit universal movement function from BaseSetBuilder
SetBuilder.apply_movement = BaseSetBuilder.apply_movement


---============================================================================
--- TOWN DETECTION (INHERITED FROM BASE)
---============================================================================

-- Inherit universal town detection function from BaseSetBuilder
SetBuilder.select_idle_base = BaseSetBuilder.select_idle_base_town

---============================================================================
--- ENGAGED BASE SELECTION
---============================================================================

--- Select engaged base set with BurtgangKC detection
--- BurtgangKC (Kraken Club) detection takes priority for specialized multi-attack set.
---
--- Priority order:
---   1. BurtgangKC weapon set      >> sets.engaged.BurtgangKC
---   2. HybridMode (PDT/MDT)       >> sets.engaged[HybridMode]
---   3. Fallback                    >> base_set
---
--- @param base_set table Base engaged set from pld_sets.lua
--- @return table Selected engaged set (BurtgangKC if condition met, otherwise hybrid/base)
function SetBuilder.select_engaged_base(base_set)
    MessageFormatter.show_debug('PLD SetBuilder', '========== select_engaged_base START ==========')
    MessageFormatter.show_debug('PLD SetBuilder', 'MainWeapon: ' .. tostring(state.MainWeapon and state.MainWeapon.current or 'nil'))
    MessageFormatter.show_debug('PLD SetBuilder', 'HybridMode: ' .. tostring(state.HybridMode and state.HybridMode.current or 'nil'))

    -- PRIORITY 1: Check for BurtgangKC weapon set (Kraken Club in sub)
    if state.MainWeapon and state.MainWeapon.current == 'BurtgangKC' and sets.engaged.BurtgangKC then
        MessageFormatter.show_debug('PLD SetBuilder', 'PRIORITY 1: BurtgangKC weapon set detected')
        return sets.engaged.BurtgangKC
    end

    -- PRIORITY 2: Check if Kraken Club is already equipped (manual equip or other weapon set)
    if player and player.equipment and player.equipment.sub then
        local sub_weapon = player.equipment.sub
        if sub_weapon == 'Kraken Club' and sets.engaged.BurtgangKC then
            MessageFormatter.show_debug('PLD SetBuilder', 'PRIORITY 2: Kraken Club manually equipped')
            return sets.engaged.BurtgangKC
        end
    end

    -- PRIORITY 3: Normal HybridMode logic (PDT or MDT)
    if state.HybridMode and state.HybridMode.current then
        local hybrid_set = sets.engaged[state.HybridMode.current]
        if hybrid_set then
            -- If Shining weapon, return HybridMode set WITHOUT sub (Alber will be applied after)
            if state.MainWeapon and state.MainWeapon.current == 'Shining' then
                MessageFormatter.show_debug('PLD SetBuilder', 'PRIORITY 3: SHINING DETECTED - Stripping sub from HybridMode')
                MessageFormatter.show_debug('PLD SetBuilder', 'Original HybridMode sub: ' .. tostring(hybrid_set.sub))
                local hybrid_no_sub = {}
                for slot, item in pairs(hybrid_set) do
                    if slot ~= 'sub' then
                        hybrid_no_sub[slot] = item
                    end
                end
                MessageFormatter.show_debug('PLD SetBuilder', 'Returning: HybridMode WITHOUT sub')
                return hybrid_no_sub
            end
            MessageFormatter.show_debug('PLD SetBuilder', 'PRIORITY 3: Normal HybridMode (' .. state.HybridMode.current .. ')')
            MessageFormatter.show_debug('PLD SetBuilder', 'HybridMode sub: ' .. tostring(hybrid_set.sub))
            return hybrid_set
        end
    end

    MessageFormatter.show_debug('PLD SetBuilder', 'Returning: base_set (no overrides)')
    return base_set
end

---============================================================================
--- ENGAGED SET BUILDER
---============================================================================

--- Build complete engaged set with all PLD logic
--- @param base_set table Base engaged set
--- @return table Complete engaged set
function SetBuilder.build_engaged_set(base_set)
    if not base_set then
        return {}
    end

    MessageFormatter.show_debug('PLD SetBuilder', '========== build_engaged_set START ==========')

    -- Step 1: Select base set (BurtgangKC detection + HybridMode)
    local result = SetBuilder.select_engaged_base(base_set)
    local is_shining = state.MainWeapon and state.MainWeapon.current == 'Shining'
    local is_burtgang_kc = state.MainWeapon and state.MainWeapon.current == 'BurtgangKC'

    MessageFormatter.show_debug('PLD SetBuilder', 'After select_engaged_base:')
    MessageFormatter.show_debug('PLD SetBuilder', '  is_shining=' .. tostring(is_shining))
    MessageFormatter.show_debug('PLD SetBuilder', '  is_burtgang_kc=' .. tostring(is_burtgang_kc))
    MessageFormatter.show_debug('PLD SetBuilder', '  result.sub=' .. tostring(result.sub))

    -- Step 2: Apply main weapon
    result = SetBuilder.apply_weapon(result)

    MessageFormatter.show_debug('PLD SetBuilder', 'After apply_weapon:')
    MessageFormatter.show_debug('PLD SetBuilder', '  result.main=' .. tostring(result.main))
    MessageFormatter.show_debug('PLD SetBuilder', '  result.sub=' .. tostring(result.sub))

    -- Step 3: Apply Alber Strap if Shining (overrides HybridMode shield)
    -- SKIP if BurtgangKC (already has Kraken Club in sub)
    if is_shining and not is_burtgang_kc then
        MessageFormatter.show_debug('PLD SetBuilder', 'APPLYING ALBER STRAP (Shining weapon)')
        MessageFormatter.show_debug('PLD SetBuilder', '  Before: result.sub=' .. tostring(result.sub))
        result = set_combine(result, sets.Alber)
        MessageFormatter.show_debug('PLD SetBuilder', '  After: result.sub=' .. tostring(result.sub))
    end

    -- Step 4: Apply XP mode (meleeXp set when Xp = On)
    if state.Xp and state.Xp.value == 'On' and sets.meleeXp then
        result = set_combine(result, sets.meleeXp)
        MessageFormatter.show_debug('PLD SetBuilder', 'Applied meleeXp set')
    end

    MessageFormatter.show_debug('PLD SetBuilder', '========== FINAL ENGAGED SET ==========')
    MessageFormatter.show_debug('PLD SetBuilder', '  main=' .. tostring(result.main))
    MessageFormatter.show_debug('PLD SetBuilder', '  sub=' .. tostring(result.sub))

    return result
end

---============================================================================
--- IDLE SET BUILDER
---============================================================================

--- Build complete idle set with all PLD logic
--- @param base_set table Base idle set
--- @return table Complete idle set
function SetBuilder.build_idle_set(base_set)
    if not base_set then
        return {}
    end

    MessageFormatter.show_debug('PLD SetBuilder', '========== build_idle_set START ==========')

    -- Step 1: Town detection - use town set as base
    local result, in_town = SetBuilder.select_idle_base(base_set)
    local is_shining = state.MainWeapon and state.MainWeapon.current == 'Shining'
    local is_burtgang_kc = state.MainWeapon and state.MainWeapon.current == 'BurtgangKC'

    MessageFormatter.show_debug('PLD SetBuilder', 'After select_idle_base:')
    MessageFormatter.show_debug('PLD SetBuilder', '  in_town=' .. tostring(in_town))
    MessageFormatter.show_debug('PLD SetBuilder', '  is_shining=' .. tostring(is_shining))
    MessageFormatter.show_debug('PLD SetBuilder', '  is_burtgang_kc=' .. tostring(is_burtgang_kc))

    -- Step 2: Apply main weapon (applies to both town and non-town)
    result = SetBuilder.apply_weapon(result)

    MessageFormatter.show_debug('PLD SetBuilder', 'After apply_weapon:')
    MessageFormatter.show_debug('PLD SetBuilder', '  result.main=' .. tostring(result.main))
    MessageFormatter.show_debug('PLD SetBuilder', '  result.sub=' .. tostring(result.sub))

    -- Step 3: Apply shield (handles town mode and Shining)
    -- SKIP if BurtgangKC (already has Kraken Club in sub)
    if not is_burtgang_kc then
        result = SetBuilder.apply_shield(result, in_town)
        MessageFormatter.show_debug('PLD SetBuilder', 'After apply_shield:')
        MessageFormatter.show_debug('PLD SetBuilder', '  result.sub=' .. tostring(result.sub))
    end

    -- Step 4: Early return if in town (weapons/shields already applied)
    if in_town then
        MessageFormatter.show_debug('PLD SetBuilder', 'IN TOWN - early return')
        return result
    end

    -- Step 5: Apply HybridMode (PDT/MDT) outside of town - SKIP sub if Shining or BurtgangKC
    if state.HybridMode and state.HybridMode.value then
        local hybrid_set = nil
        if state.HybridMode.value == 'PDT' and sets.idle.PDT then
            hybrid_set = sets.idle.PDT
        elseif state.HybridMode.value == 'MDT' and sets.idle.MDT then
            hybrid_set = sets.idle.MDT
        end

        if hybrid_set then
            if is_shining or is_burtgang_kc then
                MessageFormatter.show_debug('PLD SetBuilder', 'Applying HybridMode WITHOUT sub (Shining/BurtgangKC)')
                -- Shining/BurtgangKC: Apply HybridMode WITHOUT sub (keep Alber Strap/Kraken Club)
                local hybrid_no_sub = {}
                for slot, item in pairs(hybrid_set) do
                    if slot ~= 'sub' then
                        hybrid_no_sub[slot] = item
                    end
                end
                result = set_combine(result, hybrid_no_sub)
            else
                MessageFormatter.show_debug('PLD SetBuilder', 'Applying full HybridMode (with sub)')
                -- Normal: Apply full HybridMode set (including sub)
                result = set_combine(result, hybrid_set)
            end
        end
    end

    -- Step 6: Apply XP mode (idleXp set when Xp = On) - AFTER HybridMode to override
    if state.Xp and state.Xp.value == 'On' and sets.idleXp then
        result = set_combine(result, sets.idleXp)
        MessageFormatter.show_debug('PLD SetBuilder', 'Applied idleXp set')
    end

    -- Step 7: Apply movement speed
    result = SetBuilder.apply_movement(result)

    MessageFormatter.show_debug('PLD SetBuilder', '========== FINAL IDLE SET ==========')
    MessageFormatter.show_debug('PLD SetBuilder', '  main=' .. tostring(result.main))
    MessageFormatter.show_debug('PLD SetBuilder', '  sub=' .. tostring(result.sub))

    return result
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SetBuilder
