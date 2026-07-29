---============================================================================
--- RDM Enfeeble Tiers - Tier downgrade lookup for Red Mage
---============================================================================
--- Correspondence table consumed by shared/utils/precast/tier_refiner.lua.
--- When the requested tier is on recast, the refiner walks this table down
--- until it finds a castable tier.
---
--- Format: TIERS[family][tier].replace = next_lower_tier
--- '' means the base tier, i.e. the spell name without a roman numeral
--- ('Blind II' -> 'Blind').
---
--- Only families that actually have several tiers on RDM are listed. Bind,
--- Break, Silence and Dispel have no tiers, so they are absent and keep the
--- standard cooldown check.
---
--- @file shared/data/spells/RDM_ENFEEBLE_TIERS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-07-28
---============================================================================

local RDM_ENFEEBLE_TIERS = {}

RDM_ENFEEBLE_TIERS.TIERS = {
    -- Dark/light damage-over-time
    Dia = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Bio = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },

    -- Stat and accuracy debuffs
    Distract = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Frazzle  = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },

    -- Single-upgrade families
    Blind    = { ['II'] = { replace = '' } },
    Slow     = { ['II'] = { replace = '' } },
    Paralyze = { ['II'] = { replace = '' } },
    Poison   = { ['II'] = { replace = '' } },
    Addle    = { ['II'] = { replace = '' } },
    Sleep    = { ['II'] = { replace = '' } },

    -- Gravity II recasts far faster than Gravity (11s vs 60s), so downgrading
    -- trades a short wait for a weaker spell on a much longer timer. Kept in
    -- the table by explicit request: any unavailable tier falls through.
    Gravity  = { ['II'] = { replace = '' } },
}

--- Look up the tier mapping for a spell family
--- @param family string Family prefix parsed from the spell name (e.g. 'Blind')
--- @return table|nil Tier mapping, nil when the family has no tiers on RDM
function RDM_ENFEEBLE_TIERS.get(family)
    if not family then return nil end
    return RDM_ENFEEBLE_TIERS.TIERS[family]
end

return RDM_ENFEEBLE_TIERS
