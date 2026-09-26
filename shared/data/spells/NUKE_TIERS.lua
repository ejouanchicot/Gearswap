---============================================================================
--- Nuke Tiers - Tier downgrade lookup for elemental nukes, -ra and Aspir
---============================================================================
--- Correspondence table consumed by shared/utils/precast/tier_refiner.lua.
--- When the requested tier is on recast (or short on MP), the refiner walks
--- this table down until it finds a tier the character knows and can cast.
---
--- Format: TIERS[family][tier].replace = next_lower_tier
--- '' means the base tier, i.e. the spell name without a roman numeral
--- ('Fire II' -> 'Fire').
---
--- Used by RDM (nukes) and GEO (nukes, -ra, Aspir). The tiers a job lacks are
--- never cast: the refiner skips a spell the character has not learned.
---
--- @file shared/data/spells/NUKE_TIERS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-26
---============================================================================

local NUKE_TIERS = {}

local FIVE_TIERS = {
    ['V'] = { replace = 'IV' },
    ['IV'] = { replace = 'III' },
    ['III'] = { replace = 'II' },
    ['II'] = { replace = '' },
}

local THREE_TIERS = {
    ['III'] = { replace = 'II' },
    ['II'] = { replace = '' },
}

NUKE_TIERS.TIERS = {
    -- Single-target nukes
    Fire = FIVE_TIERS, Blizzard = FIVE_TIERS, Aero = FIVE_TIERS,
    Stone = FIVE_TIERS, Thunder = FIVE_TIERS, Water = FIVE_TIERS,

    -- Area nukes (GEO)
    Fira = THREE_TIERS, Blizzara = THREE_TIERS, Aera = THREE_TIERS,
    Stonera = THREE_TIERS, Thundara = THREE_TIERS, Watera = THREE_TIERS,

    -- MP drain
    Aspir = THREE_TIERS,
}

--- Look up the tier mapping for a spell family
--- @param family string Family prefix parsed from the spell name (e.g. 'Fire')
--- @return table|nil Tier mapping, nil when the family has no tiers here
function NUKE_TIERS.get(family)
    if not family then return nil end
    return NUKE_TIERS.TIERS[family]
end

return NUKE_TIERS
