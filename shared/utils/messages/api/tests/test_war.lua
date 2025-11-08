---============================================================================
--- WAR Test Suite - Warrior Complete Tests
---============================================================================
--- Tests all WAR job abilities and spells
---
--- @file tests/test_war.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestWAR = {}

--- Run all WAR tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestWAR.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- WAR JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "WAR Job Abilities (11):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WAR', ability_name = 'Aggressor', description = 'ACC+25 EVA-25'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WAR', ability_name = 'Berserk', description = 'ATK+25% DEF-25%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WAR', ability_name = 'Blood Rage', description = 'Party critical hit rate +20%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WAR', ability_name = 'Brazen Rush', description = 'Double attack 100%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WAR', ability_name = 'Defender', description = 'DEF+25% ATK-25%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WAR', ability_name = 'Mighty Strikes', description = 'All attacks critical'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WAR', ability_name = 'Provoke', description = 'Generate enmity'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WAR', ability_name = 'Restraint', description = 'Build WS damage bonus (max +30%)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WAR', ability_name = 'Retaliation', description = 'Counterattack 40%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WAR', ability_name = 'Tomahawk', description = 'Throw: Physical resistance -25%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WAR', ability_name = 'Warcry', description = 'Party ATK boost'}) end)
    total = total + 11

    return total
end

return TestWAR
