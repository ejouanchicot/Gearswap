---============================================================================
--- COR Test Suite - Corsair Complete Tests
---============================================================================
--- Tests all COR job abilities and spells
---
--- @file tests/test_cor.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestCOR = {}

--- Run all COR tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestCOR.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- COR JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "COR Job Abilities (9):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'COR', ability_name = 'Crooked Cards', description = 'Next roll +20% (bust penalty +20%)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'COR', ability_name = 'Cutting Cards', description = 'Party SP recast -5-50%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'COR', ability_name = 'Double-Up', description = 'Reroll last roll (max 11)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'COR', ability_name = 'Fold', description = 'Remove longest roll/bust'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'COR', ability_name = 'Quick Draw', description = 'Ranged elemental damage'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'COR', ability_name = 'Random Deal', description = 'Random party ability reset'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'COR', ability_name = 'Snake Eye', description = 'Force roll = 1, auto-11 chance'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'COR', ability_name = 'Triple Shot', description = '40% triple shot'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'COR', ability_name = 'Wild Card', description = 'Random party ability reset (1-6)'}) end)
    total = total + 9

    return total
end

return TestCOR
