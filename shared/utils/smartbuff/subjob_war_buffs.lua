---============================================================================
--- Subjob WAR Buffs - Shared logic for DNC/THF /WAR support
---============================================================================
--- Provides the common "cast Berserk + Aggressor + Warcry in priority order"
--- pipeline used by DNC and THF when subbing /WAR. Centralizes the recast +
--- buffactive checks and sequential cast logic, eliminating duplication
--- between SmartbuffManager.apply_war_buffs() of each job.
---
--- The full WAR main-job buff pipeline (Defender, Retaliation, Restraint,
--- Blood Rage) lives in `shared/jobs/war/functions/logic/smartbuff_manager.lua`
--- and is intentionally NOT reused here — subjob /WAR doesn't have access to
--- those higher-level abilities.
---
--- @file shared/utils/smartbuff/subjob_war_buffs.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-05-18
---============================================================================

local SubjobWarBuffs = {}

--- WAR abilities available to subjob users, in cast priority order.
local ABILITIES = {
    { name = 'Berserk',   recast_id = 1 },
    { name = 'Aggressor', recast_id = 4 },
    { name = 'Warcry',    recast_id = 2 },
}

--- Cast spacing between abilities (seconds).
local CAST_SPACING = 2

--- Collect status_data + abilities_to_cast for subjob WAR buffs.
--- Reads windower.ffxi.get_ability_recasts() and buffactive directly.
--- @return table abilities_to_cast List of { name = string } ready to cast
--- @return table status_data       List of { name, status, time? } for display
function SubjobWarBuffs.collect()
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local abilities_to_cast = {}
    local status_data = {}

    for _, ability in ipairs(ABILITIES) do
        local recast = ability_recasts[ability.recast_id] or 0
        if buffactive[ability.name] then
            table.insert(status_data, { name = ability.name, status = 'active' })
        elseif is_recast_ready(recast) then
            table.insert(abilities_to_cast, { name = ability.name })
        else
            table.insert(status_data, {
                name   = ability.name,
                status = 'cooldown',
                time   = math.ceil(recast),
            })
        end
    end

    return abilities_to_cast, status_data
end

--- Cast collected abilities sequentially with fixed spacing.
--- @param abilities_to_cast table List of { name = string }
function SubjobWarBuffs.cast(abilities_to_cast)
    for i, ability in ipairs(abilities_to_cast) do
        local command = 'input /ja "' .. ability.name .. '" <me>'
        if i == 1 then
            send_command(command)
        else
            local wait_time = (i - 1) * CAST_SPACING
            send_command('wait ' .. wait_time .. '; ' .. command)
        end
    end
end

return SubjobWarBuffs
