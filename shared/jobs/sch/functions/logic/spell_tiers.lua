---  ═══════════════════════════════════════════════════════════════════════════
---   SCH Spell Tiers - tier families handed to the shared TierRefiner
---  ═══════════════════════════════════════════════════════════════════════════
---   A tiered spell on recast (or short of MP, or not learned) is replaced by
---   the highest lower tier that can go out (shared/utils/precast/
---   tier_refiner.lua), instead of being cancelled by the recast check:
---     nukes, -ra and Aspir   shared/data/spells/NUKE_TIERS.lua (BLM, RDM,
---                            GEO use the same table)
---     helices, storms        II -> base, below (Pyrohelix II -> Pyrohelix,
---                            Firestorm II -> Firestorm)
---   A tier the character has not learned is skipped by the refiner, so a
---   Scholar without the Helix II / Storm II gifts falls to tier I.
---
---   @file    shared/jobs/sch/functions/logic/spell_tiers.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local SpellTiers = {}

local NukeTiers = require('shared/data/spells/NUKE_TIERS')

local TWO_TIERS = {['II'] = {replace = ''}}

--- Families with a tier II above the base spell.
local SCH_FAMILIES = {
    Pyrohelix = TWO_TIERS, Cryohelix = TWO_TIERS, Anemohelix = TWO_TIERS,
    Geohelix = TWO_TIERS, Ionohelix = TWO_TIERS, Hydrohelix = TWO_TIERS,
    Luminohelix = TWO_TIERS, Noctohelix = TWO_TIERS,
    Firestorm = TWO_TIERS, Hailstorm = TWO_TIERS, Windstorm = TWO_TIERS,
    Sandstorm = TWO_TIERS, Thunderstorm = TWO_TIERS, Rainstorm = TWO_TIERS,
    Aurorastorm = TWO_TIERS, Voidstorm = TWO_TIERS,
}

--- Tier mapping of a spell, nil when it has no tiers.
--- @param spell table Spell from job_precast
--- @return table|nil
function SpellTiers.get(spell)
    if not spell or spell.action_type ~= 'Magic' or type(spell.english) ~= 'string' then
        return nil
    end
    local family = spell.english:match('^(%a+)')
    return SCH_FAMILIES[family] or NukeTiers.get(family)
end

return SpellTiers
