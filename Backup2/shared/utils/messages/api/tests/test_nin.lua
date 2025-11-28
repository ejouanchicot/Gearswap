---============================================================================
--- NIN Test Suite - Ninja Complete Tests
---============================================================================
--- Tests all NIN job abilities and spells
---
--- @file tests/test_nin.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestNIN = {}

--- Run all NIN tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestNIN.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- NIN JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "NIN Job Abilities (7):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'NIN', ability_name = 'Futae', description = 'Next elemental ninjutsu +50% (2 tools)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'NIN', ability_name = 'Innin', description = '-Enmity/EVA, +Ninjutsu/Crit from behind'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'NIN', ability_name = 'Issekigan', description = 'Parry rate+, enmity on parry'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'NIN', ability_name = 'Mijin Gakure', description = 'Sacrifice self, damage enemy (~50% HP)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'NIN', ability_name = 'Mikage', description = 'Multi-attack based on Utsusemi shadows'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'NIN', ability_name = 'Sange', description = 'Daken 100%, consume shuriken'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'NIN', ability_name = 'Yonin', description = '+Enmity/EVA, -ACC'}) end)
    total = total + 7

    return total
end

return TestNIN
