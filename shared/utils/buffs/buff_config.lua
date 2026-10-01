---============================================================================
--- Buff Config - the buff lists, shared defaults and the character's own
---============================================================================
--- The character's _common/combat/BUFF_CONFIG.lua over the defaults below:
--- `job` and `subjob` merged per job (a job not named keeps its default
--- list), the other keys replaced whole. The names are read by
--- shared/utils/buffs/self_buff_manager.lua.
---
--- @file shared/utils/buffs/buff_config.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01 (smartbuff_config.lua before)
---============================================================================

local BuffConfig = {}

--- The lists the code used before they could be set (2026-10-01).
BuffConfig.DEFAULTS = {
    -- Tiers best first: the first one available goes (self_buff_manager.lua).
    -- No list: BRD (songs), COR (rolls), GEO (bubbles), BST / SMN / PUP (pets),
    -- DNC (dance and samba: job_buff_extra), WAR (berserk / defender), BLU
    -- (the game does not tell which blue spells are set), DRG, THF.
    job = {
        BLM = {'Stoneskin', 'Blink', 'Aquaveil', 'Ice Spikes'},
        RDM = {'Composure', 'Haste II', 'Haste', 'Refresh III', 'Refresh II', 'Refresh',
               'Phalanx', 'Temper II', 'Temper', '$GainSpell', {'$EnSpell II', '$EnSpell'},
               'Protect V', 'Protect IV', 'Shell V', 'Shell IV', 'Stoneskin', 'Blink', 'Aquaveil'},
        WHM = {'Afflatus Solace', 'Reraise IV', 'Reraise III', 'Haste', 'Protect V', 'Protect IV',
               'Shell V', 'Shell IV', 'Auspice', 'Stoneskin', 'Blink', 'Aquaveil'},
        PLD = {'Majesty', 'Crusade', 'Reprisal', 'Enlight II', 'Enlight', 'Phalanx',
               'Protect V', 'Protect IV', 'Shell IV'},
        RUN = {'Swordplay', 'Crusade', 'Temper', 'Phalanx', 'Regen IV', 'Refresh',
               'Protect IV', 'Shell V', 'Shell IV', 'Foil', 'Aquaveil', 'Stoneskin', 'Blink'},
        SCH = {'Protect V', 'Protect IV', 'Shell V', 'Shell IV', 'Regen V', 'Regen IV',
               'Stoneskin', 'Blink', 'Aquaveil'},
        NIN = {'Utsusemi', 'Migawari: Ichi', 'Kakka: Ichi', 'Myoshu: Ichi'},
        SAM = {'Hasso', 'Third Eye'},
        DRK = {'Last Resort', 'Endark II', 'Endark'},
        MNK = {'Impetus', 'Focus'},
        RNG = {'Velocity Shot'},
    },
    -- Added for the weapon in hand, on any job (none by default)
    weapon = {},
    subjob = {
        WAR = {'Berserk', 'Aggressor', 'Warcry'},
        SAM = {'Hasso', 'Third Eye'},
        NIN = {'Utsusemi'},
        DNC = {'Haste Samba'},
    },
    war_berserk  = {'Berserk', 'Aggressor', 'Retaliation', 'Restraint', 'Warcry'},
    war_defender = {'Defender', 'Aggressor', 'Retaliation', 'Restraint', 'Warcry'},
    war_add_sam  = true,
    wait_after_spell   = 3.0,
    wait_after_ability = 0.5,
}

local PER_JOB = {job = true, subjob = true, weapon = true}

--- The settings: defaults with the character's file over them.
--- @return table
function BuffConfig.get()
    local D = BuffConfig.DEFAULTS
    local ok, user = pcall(function()
        return require('shared/utils/core/char_paths').optional('common', 'BUFF_CONFIG')
    end)
    if not (ok and type(user) == 'table') then user = {} end
    local out = {}
    for key, value in pairs(D) do
        local mine = user[key]
        if PER_JOB[key] then
            out[key] = {}
            for job, list in pairs(value) do out[key][job] = list end
            for job, list in pairs(type(mine) == 'table' and mine or {}) do
                if type(list) == 'table' then out[key][job] = list end
            end
        elseif mine ~= nil and type(mine) == type(value) then
            -- not `cond and mine or value`: mine may be false
            out[key] = mine
        else
            out[key] = value
        end
    end
    return out
end

return BuffConfig
