---============================================================================
--- Test of the tier walk (shared/utils/precast/tier_refiner.lua) and of the
--- stratagem charges (shared/utils/scholar/stratagem_charges.lua)
---============================================================================
--- TierRefiner: the highest tier that is learned, off recast (exactly 0) and
--- paid for in MP, else the spell asked for. StratagemCharges: the charges
--- left from the shared recast (231) and the minutes to the next one.
---
--- Run from data/: lua5.1 scripts/atelier/tier_refiner_test.lua
---
--- @file scripts/atelier/tier_refiner_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-28
---============================================================================

package.path = './?.lua;' .. package.path

local done, failed = 0, 0
local function check(what, got, want)
    done = done + 1
    if got ~= want then
        failed = failed + 1
        print(('FAILED %s: got %s, wanted %s'):format(what, tostring(got), tostring(want)))
    end
end

package.loaded['shared/utils/messages/message_formatter'] =
    setmetatable({}, {__index = function() return function() end end})
package.loaded['shared/utils/messages/formatters/combat/message_cooldowns'] =
    setmetatable({}, {__index = function() return function() end end})
package.loaded['shared/utils/core/job_config'] = {common = function(_, _, default) return default end}

-- three tiers of Dia: id, recast id, MP
local SPELLS = {
    {id = 23, en = 'Dia', recast_id = 23, mp_cost = 7},
    {id = 24, en = 'Dia II', recast_id = 24, mp_cost = 30},
    {id = 25, en = 'Dia III', recast_id = 25, mp_cost = 45},
}
local spells = {}
function spells:with(field, value)
    for _, s in ipairs(SPELLS) do if s[field] == value then return s end end
    return nil
end
local learned = {[23] = true, [24] = true, [25] = true}
windower = {res = {spells = spells}, ffxi = {get_spells = function() return learned end}}

local TierRefiner = require('shared/utils/precast/tier_refiner')
local DIA = {III = {replace = 'II'}, II = {replace = ''}}
local function walk(recasts, mp) return TierRefiner.find_available_tier('Dia III', DIA, 'Dia', 'III', recasts, mp) end

check('every tier ready: the one asked for', walk({[23] = 0, [24] = 0, [25] = 0}, 999), 'Dia III')
check('III on recast: II', walk({[23] = 0, [24] = 0, [25] = 300}, 999), 'Dia II')
check('III and II on recast: the base tier', walk({[23] = 0, [24] = 100, [25] = 300}, 999), 'Dia')
check('all on recast: the spell asked for', walk({[23] = 50, [24] = 100, [25] = 300}, 999), 'Dia III')
check('a recast of 1 is not ready (exactly 0)', walk({[23] = 0, [24] = 1, [25] = 1}, 999), 'Dia')
check('MP short for III: II', walk({[23] = 0, [24] = 0, [25] = 0}, 40), 'Dia II')
check('MP short for all: the spell asked for', walk({[23] = 0, [24] = 0, [25] = 0}, 5), 'Dia III')
learned[24] = nil
check('II never learned: skipped to the base', walk({[23] = 0, [24] = 0, [25] = 300}, 999), 'Dia')
learned[24] = true

local cds = TierRefiner.collect_tier_cooldowns('Dia', 'III', DIA, {[23] = 0, [24] = 150, [25] = 300})
check('cooldowns below III: one (II)', #cds, 1)
check('II recast in seconds', cds[1] and cds[1].value, 1.5)

-- Stratagems: /SCH 99 -> 5 charges, 240 s for the full pool (48 s a charge)
local StratagemCharges = require('shared/utils/scholar/stratagem_charges')
local recast = 0
windower.ffxi.get_ability_recasts = function() return {[231] = recast} end
player = {main_job = 'BLM', main_job_level = 99, sub_job = 'SCH', sub_job_level = 49}
check('/SCH 49: 2 charges', StratagemCharges.get_max(), 2)
player.sub_job_level = 50
check('/SCH 50: 3 charges', StratagemCharges.get_max(), 3)
player = {main_job = 'SCH', main_job_level = 99, sub_job = 'RDM', sub_job_level = 49}
check('SCH 99: 5 charges', StratagemCharges.get_max(), 5)
check('pool full: 5 available', StratagemCharges.available(), 5)
recast = 48
check('one charge spent: 4 available', StratagemCharges.available(), 4)
check('next charge in 48 s', StratagemCharges.next_charge_minutes(), 48 / 60)
recast = 100
check('100 s left: 2 available', StratagemCharges.available(), 2)
check('next charge when 96 s are left: in 4 s', math.floor(StratagemCharges.next_charge_minutes() * 60 + 0.5), 4)
recast = 240
check('pool empty: 0 available', StratagemCharges.available(), 0)
check('pool empty: no charge', StratagemCharges.has_charge(), false)
player = {main_job = 'WAR', main_job_level = 99, sub_job = 'SAM', sub_job_level = 49}
check('no Scholar: 0', StratagemCharges.available(), 0)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)
