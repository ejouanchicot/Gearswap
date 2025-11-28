---============================================================================
--- WS Variant Selector - Buff-Based Weaponskill Set Selection (Logic Module)
---============================================================================
--- Selects weaponskill equipment set variants based on active buffs with
--- intelligent priority ordering.
---
--- Features:
---   • Saber Dance buff detection (-50% DW - allows different WS gear)
---   • Fan Dance buff detection (20% DT - allows different WS gear)
---   • Climactic Flourish buff detection (crit rate +15%)
---   • Climactic timestamp tracking (5s window for instant detection)
---   • Priority-based variant selection (SaberDance.Clim > SaberDance > FanDance.Clim > FanDance > Clim > Base)
---   • Automatic fallback if variants don't exist
---   • Buff combination support (Saber/Fan are mutually exclusive, but can combine with Clim)
---
--- Priority Order (NOTE: Saber Dance and Fan Dance are mutually exclusive):
---   1. SaberDance.Clim - Saber Dance + Climactic (highest DPS with Haste)
---   2. SaberDance - Saber Dance only (Haste/STP optimized)
---   3. FanDance.Clim - Fan Dance + Climactic (DPS + survivability)
---   4. FanDance - Fan Dance only (survivability with DPS)
---   5. Clim - Climactic only (pure DPS)
---   6. Base set - No buffs (standard WS gear)
---
--- @file    jobs/dnc/functions/logic/ws_variant_selector.lua
--- @author  Tetsouo
--- @version 1.1 - Saber Dance Support
--- @date    Created: 2025-10-06
--- @date    Updated: 2025-10-19
---============================================================================

local WSVariantSelector = {}

---============================================================================
--- SET VARIANT SELECTION
---============================================================================

--- Apply weaponskill set variant based on active buffs
--- NOTE: Saber Dance and Fan Dance are mutually exclusive - prioritize Saber Dance
--- @param spell table Weaponskill spell object
function WSVariantSelector.apply_variant(spell)
    -- Get the base WS sets for this weaponskill
    local ws_sets = sets.precast.WS[spell.name]
    if not ws_sets then return end

    -- Check active buffs
    local has_saber_dance = buffactive and buffactive['Saber Dance']
    local has_fan_dance = buffactive and buffactive['Fan Dance']
    local has_climactic = buffactive and buffactive['Climactic Flourish']

    -- If not in buffactive, check if Climactic was used recently (5 second window)
    -- This catches rapid macro execution where buff hasn't appeared yet
    if not has_climactic and _G.dnc_climactic_timestamp then
        local time_since_climactic = os.time() - _G.dnc_climactic_timestamp
        if time_since_climactic <= 5 then
            has_climactic = true
            -- Clear timestamp so it's only used once for the first WS after Climactic
            _G.dnc_climactic_timestamp = nil
        end
    end

    -- Select variant based on buff combination (priority order)
    -- Priority 1: Saber Dance (mutually exclusive with Fan Dance)
    if has_saber_dance then
        if has_climactic then
            -- Saber Dance + Climactic: use .SaberDance.Clim variant
            if ws_sets.SaberDance and ws_sets.SaberDance.Clim then
                equip(ws_sets.SaberDance.Clim)
            elseif ws_sets.SaberDance then
                -- Fallback to SaberDance only if .Clim variant doesn't exist
                equip(ws_sets.SaberDance)
            elseif ws_sets.Clim then
                -- Fallback to Clim only if .SaberDance variant doesn't exist
                equip(ws_sets.Clim)
            end
        else
            -- Saber Dance only: use .SaberDance variant
            if ws_sets.SaberDance then
                equip(ws_sets.SaberDance)
            end
        end
        return  -- Exit after Saber Dance handling (don't check Fan Dance)
    end

    -- Priority 2: Fan Dance (only if Saber Dance not active)
    if has_fan_dance and has_climactic then
        -- Both buffs active: use .FanDance.Clim variant
        if ws_sets.FanDance and ws_sets.FanDance.Clim then
            equip(ws_sets.FanDance.Clim)
        elseif ws_sets.FanDance then
            -- Fallback to FanDance only if .Clim variant doesn't exist
            equip(ws_sets.FanDance)
        elseif ws_sets.Clim then
            -- Fallback to Clim only if .FanDance variant doesn't exist
            equip(ws_sets.Clim)
        end
        -- If no variants exist, base set is already equipped by Mote
    elseif has_fan_dance then
        -- Fan Dance only: use .FanDance variant
        if ws_sets.FanDance then
            equip(ws_sets.FanDance)
        end
        -- If no .FanDance variant, base set is already equipped
    elseif has_climactic then
        -- Climactic Flourish only: use .Clim variant
        if ws_sets.Clim then
            equip(ws_sets.Clim)
        end
        -- If no .Clim variant, base set is already equipped
    end

    -- No buffs active: base set is already equipped by Mote
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return WSVariantSelector
