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

-- RDM (2026-10-29): the tiers of RDM_CURE_CONFIG.lua when the character has the file (CharPaths.optional), no
-- re-tiering at all without it; retier() cancels the cast and sends the new tier; setup_state() makes the mode
local RDM_CONFIG = dofile('_master/config/rdm/RDM_CURE_CONFIG.lua')

--- cure_manager.lua loaded as a RDM's, `config` what CharPaths.optional gives (nil: no file).
local function rdm_module(config, sent)
    local target = {name = 'Mage', id = 9, hpp = 50}
    local env = setmetatable({}, {__index = _G})
    env._G = env
    env.player = {name = 'Healer', id = 1, hp = 1800, max_hp = 1800, main_job = 'RDM', sub_job = 'WHM'}
    env.state = {}
    env.M = function(t)
        local m = {description = t.description, value = t[1]}
        function m:set(v) self.value = v end
        return m
    end
    env.send_command = function(cmd) sent[#sent + 1] = cmd end
    env.windower = {
        addon_path = './', register_event = function() end,
        ffxi = {
            get_party = function() return PARTY end,
            get_spell_recasts = function() return {} end,
            get_mob_by_target = function() return target end,
            get_mob_by_id = function() return target end,
        },
    }
    env.require = function(name)
        if name == 'shared/utils/core/char_paths' then
            return {optional = function(kind, file, job) return file == 'RDM_CURE_CONFIG' and job == 'RDM' and config or nil end}
        end
        return setmetatable({}, {__index = function() return function() end end})
    end
    local chunk = assert(loadfile('shared/utils/whm/cure_manager.lua'))
    setfenv(chunk, env)
    return chunk(), env
end

local sent = {}
local mod, env = rdm_module(RDM_CONFIG, sent)
check('RDM with its file: enabled', mod.enabled(), true)
mod.setup_state()
check('RDM: the mode made, On', env.state.CureAutoTier and env.state.CureAutoTier.value, 'On')
env.state.CureAutoTier:set('Off')
mod.setup_state()
check('RDM: a subjob change keeps the choice', env.state.CureAutoTier.value, 'Off')
env.state.CureAutoTier:set('On')
local args = {}
local spell = {name = 'Cure IV', action_type = 'Magic', target = {id = 9, raw = '<t>'}}
check('RDM: Cure IV on the mage (300 missing): replaced', mod.retier(spell, args), true)
check('RDM: the cast cancelled', args.cancel, true)
check('RDM: Cure III sent', sent[1], 'input /ma "Cure III" <t>')
check('RDM: Curaga III asked, 300 missing: Curaga II', mod.select_cure_tier({name = 'Curaga III'}, {name = 'Mage', id = 9, hpp = 50}), 'Curaga II')
env.state.CureAutoTier:set('Off')
check('RDM, mode Off: Cure IV kept', mod.select_cure_tier({name = 'Cure IV'}, {name = 'Mage', id = 9, hpp = 50}), nil)

sent = {}
mod, env = rdm_module(nil, sent)
check('RDM without the file: not enabled', mod.enabled(), false)
mod.setup_state()
check('RDM without the file: no mode', env.state.CureAutoTier, nil)
check('RDM without the file: Cure IV left', mod.retier({name = 'Cure IV', action_type = 'Magic', target = {id = 9, raw = '<t>'}}, {}), false)
check('RDM without the file: nothing sent', #sent, 0)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)
