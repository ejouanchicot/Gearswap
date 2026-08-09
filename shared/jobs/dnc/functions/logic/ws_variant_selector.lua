---  ═══════════════════════════════════════════════════════════════════════════
---   WS Variant Selector - Buff-Based Weaponskill Set Selection (Logic Module)
---  ═══════════════════════════════════════════════════════════════════════════
---   Selects weaponskill equipment set variants based on active buffs with
---   intelligent priority ordering.
---
---   Features:
---   • Saber Dance buff detection (-50% DW - allows different WS gear)
---   • Fan Dance buff detection (20% DT - allows different WS gear)
---   • Climactic Flourish buff detection (crit rate +15%)
---   • Climactic timestamp tracking (5s window for instant detection)
---   • Priority-based variant selection (SaberDance.Clim > SaberDance > FanDance.Clim > FanDance > Clim > Base)
---   • Automatic fallback if variants don't exist
---   • Buff combination support (Saber/Fan are mutually exclusive, but can combine with Clim)
---
---   Priority Order (NOTE: Saber Dance and Fan Dance are mutually exclusive):
---   1. SaberDance.Clim - Saber Dance + Climactic (highest DPS with Haste)
---   2. SaberDance - Saber Dance only (Haste/STP optimized)
---   3. FanDance.Clim - Fan Dance + Climactic (DPS + survivability)
---   4. FanDance - Fan Dance only (survivability with DPS)
---   5. Clim - Climactic only (pure DPS)
---   6. Base set - No buffs (standard WS gear)
---
---   @file    jobs/dnc/functions/logic/ws_variant_selector.lua
---   @author  Tetsouo
---   @version 1.1 - Saber Dance Support
---   @date    Created: 2025-10-06
---   @date    Updated: 2025-10-19
---  ═══════════════════════════════════════════════════════════════════════════

local WSVariantSelector = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   SET VARIANT SELECTION
---  ═══════════════════════════════════════════════════════════════════════════

--- Is Climactic Flourish in effect for this weaponskill?
---
--- Also true for five seconds after using it, because a macro that fires the
--- ability and the weaponskill back to back gets here before the buff has
--- appeared. The timestamp is consumed on the first weaponskill that uses it,
--- so the window covers one skill and not the next.
--- @return boolean
local function climactic_active()
    if buffactive and buffactive['Climactic Flourish'] then
        return true
    end

    if _G.dnc_climactic_timestamp
       and (os.time() - _G.dnc_climactic_timestamp) <= 5 then
        _G.dnc_climactic_timestamp = nil
        return true
    end

    return false
end

--- Which dance is up, if either.
---
--- Saber and Fan are mutually exclusive in game, and Saber wins here so a
--- stale Fan flag cannot pull the weaponskill into a defensive set.
--- @return string|nil Set key: 'SaberDance', 'FanDance' or nil
local function active_dance()
    if not buffactive then
        return nil
    end
    if buffactive['Saber Dance'] then
        return 'SaberDance'
    elseif buffactive['Fan Dance'] then
        return 'FanDance'
    end
    return nil
end

--- The most specific variant defined for this combination of buffs.
---
--- With both a dance and Climactic the order is the whole rule: the combined
--- set first, then the dance alone, then Climactic alone. A job that defines
--- only some of them still gets the closest thing rather than nothing, which
--- is why the fallbacks exist at all.
--- @param ws_sets table sets.precast.WS[<weaponskill>]
--- @param dance string|nil From active_dance
--- @param climactic boolean
--- @return table|nil Set to equip, nil to leave what Mote already put on
local function best_variant(ws_sets, dance, climactic)
    if dance and climactic then
        local dance_sets = ws_sets[dance]
        return (dance_sets and dance_sets.Clim) or dance_sets or ws_sets.Clim
    elseif dance then
        return ws_sets[dance]
    elseif climactic then
        return ws_sets.Clim
    end
    return nil
end

---   Equip the weaponskill variant matching the buffs that are up.
---   @param spell table Spell information from GearSwap
function WSVariantSelector.apply_variant(spell)
    local ws_sets = sets.precast.WS[spell.name]
    if not ws_sets then
        return
    end

    -- Read before branching: the Climactic check consumes its timestamp, and
    -- it has to be consumed whichever branch ends up being taken.
    local climactic = climactic_active()
    local dance = active_dance()

    local variant = best_variant(ws_sets, dance, climactic)
    if variant then
        equip(variant)
    end
    -- Nothing matched: Mote has already equipped the base set.
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return WSVariantSelector
