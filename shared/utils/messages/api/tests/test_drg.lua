---============================================================================
--- DRG Test Suite - Dragoon Complete Tests
---============================================================================
--- Tests all DRG job abilities and spells
---
--- @file tests/test_drg.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestDRG = {}

--- Run all DRG tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestDRG.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- DRG JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "DRG Job Abilities (14):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRG', ability_name = 'Ancient Circle', description = 'ATK/ACC/DEF+ vs Dragons (party AoE)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRG', ability_name = 'Angon', description = 'Enemy defense down'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRG', ability_name = 'Call Wyvern', description = 'Summons wyvern'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRG', ability_name = 'Deep Breathing', description = 'Next wyvern breath x2'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRG', ability_name = 'Dragon Breaker', description = 'Dragon debuff (ACC/EVA/MACC/MEVA/TP down)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRG', ability_name = 'Fly High', description = 'Reset Jump timers, 10s recast'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRG', ability_name = 'High Jump', description = 'Jumping attack, enmity -50%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRG', ability_name = 'Jump', description = 'Jumping attack'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRG', ability_name = 'Soul Jump', description = 'High jump, enmity suppression'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRG', ability_name = 'Spirit Bond', description = 'Take damage for wyvern'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRG', ability_name = 'Spirit Jump', description = 'Jump, enmity suppression'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRG', ability_name = 'Spirit Link', description = 'Transfer HP/status to wyvern'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRG', ability_name = 'Spirit Surge', description = 'Adds wyvern\'s strength to your own'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRG', ability_name = 'Super Jump', description = 'Reset enmity to 1'}) end)
    total = total + 14

    return total
end

return TestDRG
