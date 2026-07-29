---============================================================================
--- Stratagem Charges - Scholar stratagem availability
---============================================================================
--- Scholar stratagems (Accession, Manifestation, Addendum, Penury...) do not
--- work like ordinary abilities: they all share a single pool of charges and a
--- single recast slot (recast_id 231). The API reports the time until the pool
--- is FULL again, not the time until the next charge, so the number of usable
--- charges has to be derived.
---
--- Formula: floor(max - max * recast / FULL_RECHARGE)
---
--- Caveat: FULL_RECHARGE is the unmerited value. Scholar's "Stratagems" merits
--- shorten it, which makes this estimate slightly optimistic for a merited SCH
--- main. It is exact for a job subbing /SCH without those merits, which is the
--- case this module exists for (BLM/SCH and friends).
---
--- @file shared/utils/scholar/stratagem_charges.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-07-28
---============================================================================

local StratagemCharges = {}

--- Every stratagem shares this recast slot.
local STRATAGEM_RECAST_ID = 231

--- Seconds to regenerate the whole pool, without merits.
local FULL_RECHARGE = 240

--- Charge count granted at each Scholar level breakpoint, highest first.
local CHARGE_TIERS = {
    { level = 90, charges = 5 },
    { level = 70, charges = 4 },
    { level = 50, charges = 3 },
    { level = 30, charges = 2 },
    { level = 10, charges = 1 },
}

--- Resolve the Scholar level in play, whether SCH is main or sub
--- @return number Scholar level, 0 when Scholar is neither main nor sub
local function get_scholar_level()
    if player.main_job == 'SCH' then
        return player.main_job_level or 0
    elseif player.sub_job == 'SCH' then
        return player.sub_job_level or 0
    end

    return 0
end

--- Maximum stratagem charges at the current Scholar level
--- @return number Charge capacity (0 when Scholar is not main or sub)
function StratagemCharges.get_max()
    local level = get_scholar_level()

    for _, tier in ipairs(CHARGE_TIERS) do
        if level >= tier.level then
            return tier.charges
        end
    end

    return 0
end

--- Number of stratagem charges currently usable
--- @return number Available charges (0 when Scholar is not main or sub)
function StratagemCharges.available()
    local max_charges = StratagemCharges.get_max()
    if max_charges == 0 then return 0 end

    local recast = windower.ffxi.get_ability_recasts()[STRATAGEM_RECAST_ID] or 0
    if recast <= 0 then return max_charges end

    local charges = math.floor(max_charges - max_charges * recast / FULL_RECHARGE)

    return math.max(0, charges)
end

--- Whether at least one stratagem can be used right now
--- @return boolean True when a charge is available
function StratagemCharges.has_charge()
    return StratagemCharges.available() > 0
end

--- Minutes until the next charge comes back, for display
--- @return number Minutes remaining (0 when a charge is already available)
function StratagemCharges.next_charge_minutes()
    local max_charges = StratagemCharges.get_max()
    if max_charges == 0 then return 0 end

    local recast = windower.ffxi.get_ability_recasts()[STRATAGEM_RECAST_ID] or 0
    if recast <= 0 then return 0 end

    -- The pool refills one charge at a time; the next one lands when the
    -- remaining time drops to the next whole-charge boundary.
    local per_charge = FULL_RECHARGE / max_charges
    local charging = math.ceil(recast / per_charge)
    local next_charge_seconds = recast - (charging - 1) * per_charge

    return math.max(0, next_charge_seconds) / 60
end

return StratagemCharges
