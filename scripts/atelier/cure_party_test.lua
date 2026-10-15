---============================================================================
--- Test of the WHM Cure tier on another member (shared/utils/whm/cure_manager.lua)
---============================================================================
--- windower.ffxi.get_party() as the game gives it: each member's hp and hpp,
--- no max HP, the party under p0..p5 and the alliance under a10..a15 and
--- a20..a25. The tier must follow the HP really missing: a tank with many HP
--- gets a bigger Cure than a mage at the same HP percent.
---
--- Run from data/: lua5.1 scripts/atelier/cure_party_test.lua
---
--- @file scripts/atelier/cure_party_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-15
---============================================================================

local done, failed = 0, 0
local function check(what, got, want)
    done = done + 1
    if got ~= want then
        failed = failed + 1
        print(('FAILED %s: got %s, wanted %s'):format(what, tostring(got), tostring(want)))
    end
end

-- the shape of _master/config/whm/WHM_CURE_CONFIG.lua
local CURE_CONFIG = {
    auto_tier_enabled = true, force_max_cure = false, debug_messages = false, safety_margin = 50,
    cure_tiers = {
        {min = 0, max = 200, spell = 'Cure'}, {min = 200, max = 400, spell = 'Cure II'},
        {min = 400, max = 700, spell = 'Cure III'}, {min = 700, max = 1100, spell = 'Cure IV'},
        {min = 1100, max = 1600, spell = 'Cure V'}, {min = 1600, max = 99999, spell = 'Cure VI'},
    },
    curaga_tiers = {
        {min = 0, max = 300, spell = 'Curaga'}, {min = 300, max = 800, spell = 'Curaga II'},
        {min = 800, max = 99999, spell = 'Curaga III'},
    },
}

local PARTY = {
    p0 = {name = 'Healer', hp = 1800, hpp = 100},
    p1 = {name = 'Tank', hp = 1750, hpp = 50},       -- 3500 max: 1750 missing
    p2 = {name = 'Mage', hp = 300, hpp = 50},        -- 600 max: 300 missing
    a10 = {name = 'Other', hp = 2400, hpp = 40},     -- 6000 max: 3600 missing
    a23 = {name = 'Far', hp = 90, hpp = 30},         -- 300 max: 210 missing
}

--- The Cure the module casts for `name` when Cure VI is asked (nil from the module: Cure VI kept).
local function tier_for(name)
    local hpp = 100
    for _, m in pairs(PARTY) do if m.name == name then hpp = m.hpp end end
    local target = {name = name, id = 9, hpp = hpp}
    local env = setmetatable({}, {__index = _G})
    env._G = env
    env.player = {name = 'Healer', id = 1, hp = 1800, max_hp = 1800, main_job = 'WHM', sub_job = 'RDM'}
    env.state = {CureAutoTier = {value = 'On'}}
    env.windower = {
        addon_path = './', register_event = function() end,
        ffxi = {
            get_party = function() return PARTY end,
            get_spell_recasts = function() return {} end,
            get_player = function() return {name = 'Healer'} end,
            get_mob_by_target = function() return target end,
            get_mob_by_id = function() return target end,
        },
    }
    env.print, env.add_to_chat = function() end, function() end
    env.require = function(name)
        if name:find('CURE_CONFIG') then return CURE_CONFIG end
        return setmetatable({}, {__index = function() return function() end end})
    end
    env.dofile = function() return CURE_CONFIG end
    local chunk = assert(loadfile('shared/utils/whm/cure_manager.lua'))
    setfenv(chunk, env)
    local mod = chunk()
    return mod.select_cure_tier({name = 'Cure VI'}, target) or 'Cure VI'
end

check('the tank at 50 % (1750 missing): Cure VI', tier_for('Tank'), 'Cure VI')
check('the mage at 50 % (300 missing): Cure II', tier_for('Mage'), 'Cure II')
check('alliance a10 (3600 missing): Cure VI', tier_for('Other'), 'Cure VI')
check('alliance a23 (210 missing): Cure II', tier_for('Far'), 'Cure II')

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)
