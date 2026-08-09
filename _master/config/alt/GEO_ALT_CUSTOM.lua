---============================================================================
--- GEO Alt Commands - your overrides
---============================================================================
--- Merged on top of GEO_ALT_COMMANDS.lua, which is generated and rebuilt.
--- Nothing here is ever regenerated.
---
---   add     a name the generator does not produce
---   change  reuse an existing name, yours wins
---   remove  set the name to false
---
--- See GEO_ALT_CUSTOM.lua.example for the full format.
---
--- @file    config/alt/GEO_ALT_CUSTOM.lua
--- @author  Tetsouo
---============================================================================

local M = {}

M.commands = {

    -- ------------------------------------------------------------------
    -- Entrust chains: the JA on the alt, then the Indi- on your pick
    -- ------------------------------------------------------------------
    entrusthaste = {
        target = 'lastst', step_delay = 2, group = 'ja',
        desc = 'Entrust + Indi-Haste',
        chain = {
            { action = 'ja', spell = 'Entrust', target = 'me' },
            { action = 'ma', spell = 'Indi-Haste' },
        },
    },
    entrustrefresh = {
        target = 'lastst', step_delay = 2, group = 'ja',
        desc = 'Entrust + Indi-Refresh',
        chain = {
            { action = 'ja', spell = 'Entrust', target = 'me' },
            { action = 'ma', spell = 'Indi-Refresh' },
        },
    },
    entrustfury = {
        target = 'lastst', step_delay = 2, group = 'ja',
        desc = 'Entrust + Indi-Fury',
        chain = {
            { action = 'ja', spell = 'Entrust', target = 'me' },
            { action = 'ma', spell = 'Indi-Fury' },
        },
    },

    -- `sets_alt_buff` marks Entrust up straight away so the next Indi- knows to
    -- ask for a target even if the alt is not reporting its buffs. `sync_after`
    -- then asks for the truth: FFXI never fires buff_change when Entrust is
    -- GAINED, only when it is lost, so a resync is the only way to learn it.
    altentrust = {
        action = 'ja', spell = 'Entrust', target = 'me', group = 'ja',
        sets_alt_buff = 'Entrust', alt_buff_duration = 60, sync_after = 3,
        desc = 'Entrust (next Indi on an ally)',
    },

    -- ------------------------------------------------------------------
    -- Nukes that follow the main's BLM element
    -- ------------------------------------------------------------------
    altlight = {
        action = 'ma', target = 'lastst', group = 'elemental',
        spell_from_state = 'MainLightSpell', fallback = 'Fire IV',
        desc = 'Nuke, follows the main light element',
    },
    altdark = {
        action = 'ma', target = 'lastst', group = 'elemental',
        spell_from_state = 'MainDarkSpell', fallback = 'Blizzard IV',
        desc = 'Nuke, follows the main dark element',
    },
}

---============================================================================
--- REFINE - one pass over every command, after the merge
---============================================================================

--- Where an Indi- has to land.
---
--- An Indi- normally sits on the caster, so it is cast on the alt. But while
--- the alt holds Entrust the very next Indi- goes on someone else instead, and
--- that is the whole point of pressing Entrust - so the command has to ask you
--- to pick a target rather than silently landing back on the alt.
--- @return string GearSwap target token
local function indi_target()
    local ok, AltBuffs = pcall(require, 'shared/utils/dualbox/alt_buff_reporter')
    if ok and AltBuffs and AltBuffs.active('Entrust') then
        return 'lastst'
    end
    return 'me'
end

--- Retarget every Indi- without listing them.
--- @param entry table Merged command (a copy, safe to edit)
--- @param name string Command name
--- @return table Command to use
function M.refine(entry, name)
    if name:sub(1, 4) == 'indi' and entry.target == 'me' then
        entry.target = indi_target
    end
    return entry
end

return M
