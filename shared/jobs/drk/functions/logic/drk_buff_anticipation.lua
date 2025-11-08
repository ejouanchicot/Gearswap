---============================================================================
--- DRK Buff Anticipation Manager - Dark Seal & Nether Void Tracking (Logic Module)
---============================================================================
--- Automatically handles engaged set variant selection based on Dark Seal and
--- Nether Void buffs with intelligent pending flag detection (instant detection
--- before buff appears in buffactive).
---
--- Features:
---   • Dark Seal buff tracking (Dark Magic duration +10% per merit)
---   • Nether Void buff tracking (Absorb potency +45%)
---   • Pending flag detection (instant before buff in buffactive)
---   • Automatic engaged set variant application
---
--- Why This System Exists:
---   FFXI has network lag between using a JA and the buff appearing in buffactive[].
---   If you use Dark Seal >> cast Dark Magic immediately, buffactive['Dark Seal']
---   may still be nil for 0.1-0.3 seconds. Pending flags detect the buff INSTANTLY.
---
--- Processing Order:
---   1. Player uses JA (e.g., Dark Seal)
---   2. PRECAST: Set _G.drk_dark_seal_pending = true (INSTANT)
---   3. AFTERCAST: Confirm flag (if not interrupted)
---   4. ENGAGED: Check buffactive['Dark Seal'] OR _G.drk_dark_seal_pending
---   5. BUFFS: Clear flag when buff appears in buffactive
---
--- Dependencies:
---   • sets.engaged[weapon][mode] with optional buff variants
---   • _G.drk_dark_seal_pending, _G.drk_nether_void_pending global flags
---
--- @file    jobs/drk/functions/logic/drk_buff_anticipation.lua
--- @author  Tetsouo
--- @version 2.0 - Dark Seal/Nether Void Only
--- @date    Created: 2025-10-23 | Updated: 2025-10-23
---============================================================================

local DRKBuffAnticipation = {}

---============================================================================
--- BUFF DETECTION
---============================================================================

--- Check if Dark Seal is active (buffactive or pending)
--- @return boolean True if Dark Seal is active or pending
function DRKBuffAnticipation.has_dark_seal()
    return (buffactive and buffactive['Dark Seal']) or _G.drk_dark_seal_pending
end

--- Check if Nether Void is active (buffactive or pending)
--- @return boolean True if Nether Void is active or pending
function DRKBuffAnticipation.has_nether_void()
    return (buffactive and buffactive['Nether Void']) or _G.drk_nether_void_pending
end

---============================================================================
--- ENGAGED SET VARIANT APPLICATION
---============================================================================

--- Apply engaged set variant based on Dark Seal and Nether Void buffs
--- Called from customize_melee_set() to enhance engaged gear with buff bonuses.
---
--- Variant Priority:
---   1. Dark Seal + Nether Void (if .DarkSealNetherVoid exists)
---   2. Dark Seal only (if .DarkSeal exists)
---   3. Nether Void only (if .NetherVoid exists)
---   4. Base engaged set (no buffs)
---
--- @param current_set table Current engaged set
--- @param weapon_name string Current weapon name (from state.MainWeapon)
--- @param hybrid_mode string Current hybrid mode (PDT/Accu)
--- @return table Enhanced engaged set with buff-specific gear
function DRKBuffAnticipation.apply_buff_variants(current_set, weapon_name, hybrid_mode)
    if not current_set or not weapon_name then
        return current_set
    end

    -- Get weapon-specific engaged table
    local weapon_table = sets.engaged[weapon_name]
    if not weapon_table then
        return current_set
    end

    -- Get base set for this weapon + hybrid mode
    local base_set = weapon_table[hybrid_mode]
    if not base_set then
        -- Fallback to Accu if hybrid mode doesn't exist
        base_set = weapon_table.Accu or current_set
    end

    -- Check active buffs
    local has_ds = DRKBuffAnticipation.has_dark_seal()
    local has_nv = DRKBuffAnticipation.has_nether_void()

    -- Priority 1: Dark Seal + Nether Void combo
    if has_ds and has_nv then
        if base_set.DarkSealNetherVoid then
            return set_combine(current_set, base_set.DarkSealNetherVoid)
        elseif base_set.DarkSeal then
            -- Fallback to Dark Seal only
            return set_combine(current_set, base_set.DarkSeal)
        elseif base_set.NetherVoid then
            -- Fallback to Nether Void only
            return set_combine(current_set, base_set.NetherVoid)
        end
    end

    -- Priority 2: Dark Seal only
    if has_ds then
        if base_set.DarkSeal then
            return set_combine(current_set, base_set.DarkSeal)
        end
    end

    -- Priority 3: Nether Void only
    if has_nv then
        if base_set.NetherVoid then
            return set_combine(current_set, base_set.NetherVoid)
        end
    end

    -- No buff variants or no buffs active
    return current_set
end

---============================================================================
--- PENDING FLAG INITIALIZATION
---============================================================================

--- Initialize DRK pending flags for Dark Seal and Nether Void
--- Called from DRK_AFTERCAST.lua at module load time
function DRKBuffAnticipation.initialize_flags()
    if not _G.drk_dark_seal_pending then
        _G.drk_dark_seal_pending = false
    end

    if not _G.drk_nether_void_pending then
        _G.drk_nether_void_pending = false
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return DRKBuffAnticipation
