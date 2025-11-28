---============================================================================
--- DNC Test Suite - Dancer Complete Tests
---============================================================================
--- Tests all DNC job abilities and spells
---
--- @file tests/test_dnc.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestDNC = {}

--- Run all DNC tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestDNC.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- DNC JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "DNC Job Abilities (7):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DNC', ability_name = 'Contradance', description = 'Doubles next Waltz potency'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DNC', ability_name = 'Fan Dance', description = 'PDT- Enmity+ but disables Sambas'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DNC', ability_name = 'Grand Pas', description = 'Flourishes without FM cost (30s or 3 uses)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DNC', ability_name = 'No Foot Rise', description = 'Instantly grants FM (1 per merit)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DNC', ability_name = 'Presto', description = 'Enhances next Step and grants +FM'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DNC', ability_name = 'Saber Dance', description = 'Double Attack+ but disables Waltzes'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DNC', ability_name = 'Trance', description = 'Dances and steps TP cost 0'}) end)
    total = total + 7

    return total
end

return TestDNC
