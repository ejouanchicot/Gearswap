---============================================================================
--- SA/TA Manager - Sneak Attack & Trick Attack WS Set Selection (Logic Module)
---============================================================================
--- Automatically selects weaponskill equipment set variants based on active
--- Sneak Attack and/or Trick Attack buffs with intelligent pending flag detection.
---
--- Features:
---   • Buff-based WS set variant selection (SATA/SA/TA/Base)
---   • Pending flag detection (instant detection before buff appears in buffactive)
---   • Priority-based variant selection (SATA > SA > TA > Base)
---   • Automatic fallback if variants don't exist
---   • Buff combination support (both SA and TA active simultaneously)
---
--- Priority Order:
---   1. SATA - Both SA and TA active (highest damage multiplier)
---   2. SA - Sneak Attack only (critical hit + damage bonus)
---   3. TA - Trick Attack only (enmity transfer + damage bonus)
---   4. Base set - No buffs (standard WS gear)
---
--- Dependencies:
---   • sets.precast.WS (weaponskill sets with optional .SA/.TA/.SATA variants)
---   • _G.thf_sa_pending, _G.thf_ta_pending (pending flag globals)
---
--- @file    jobs/thf/functions/logic/sa_ta_manager.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

local SATAManager = {}

---============================================================================
--- SET VARIANT SELECTION
---============================================================================

--- Apply weaponskill set variant based on active SA/TA buffs
--- @param spell table Weaponskill spell object
function SATAManager.apply_variant(spell)
    -- Only process weaponskills
    if spell.type ~= 'WeaponSkill' then
        return
    end

    -- Get the base WS sets for this weaponskill
    local ws_sets = sets.precast.WS[spell.name]
    if not ws_sets then
        return
    end

    -- Check active buffs OR pending (just used, not yet in buffactive due to lag)
    local has_sneak_attack = (buffactive and buffactive['Sneak Attack']) or _G.thf_sa_pending
    local has_trick_attack = (buffactive and buffactive['Trick Attack']) or _G.thf_ta_pending

    -- Select variant based on buff combination (priority order)
    if has_sneak_attack and has_trick_attack then
        -- Both buffs active: use .SATA variant
        if ws_sets.SATA then
            equip(ws_sets.SATA)
        elseif ws_sets.SA then
            -- Fallback to SA only if .SATA variant doesn't exist
            equip(ws_sets.SA)
        elseif ws_sets.TA then
            -- Fallback to TA only if .SA variant doesn't exist
            equip(ws_sets.TA)
        end
        -- If no variants exist, base set is already equipped by Mote
    elseif has_sneak_attack then
        -- Sneak Attack only: use .SA variant
        if ws_sets.SA then
            equip(ws_sets.SA)
        end
        -- If no .SA variant, base set is already equipped
    elseif has_trick_attack then
        -- Trick Attack only: use .TA variant
        if ws_sets.TA then
            equip(ws_sets.TA)
        end
        -- If no .TA variant, base set is already equipped
    end

    -- No buffs active: base set is already equipped by Mote
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SATAManager
