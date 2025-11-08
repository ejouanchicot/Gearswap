---============================================================================
--- THF Test Suite - Thief Complete Tests
---============================================================================
--- Tests all THF job abilities and spells
---
--- @file tests/test_thf.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestTHF = {}

--- Run all THF tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestTHF.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- THF JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "THF Job Abilities (14):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'THF', ability_name = 'Accomplice', description = 'Steal 50% enmity from ally'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'THF', ability_name = 'Bully', description = 'Intimidate target'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'THF', ability_name = 'Collaborator', description = 'Transfer 25% enmity to ally'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'THF', ability_name = 'Conspirator', description = 'Party ACC+, Subtle Blow+'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'THF', ability_name = 'Despoil', description = 'Steal items, inflict debuff'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'THF', ability_name = 'Feint', description = 'Enemy evasion -150>>-50'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'THF', ability_name = 'Flee', description = 'Movement speed +60%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'THF', ability_name = 'Hide', description = 'Invisible, reset enmity'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'THF', ability_name = 'Larceny', description = 'Steal buff from enemy'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'THF', ability_name = 'Mug', description = 'Steal gil, drain HP'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'THF', ability_name = 'Perfect Dodge', description = 'Dodge all melee attacks'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'THF', ability_name = 'Sneak Attack', description = 'Crit from behind, +DEX damage'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'THF', ability_name = 'Steal', description = 'Steal items from enemy'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'THF', ability_name = 'Trick Attack', description = 'Behind ally: Crit, +AGI, transfer enmity'}) end)
    total = total + 14

    return total
end

return TestTHF
