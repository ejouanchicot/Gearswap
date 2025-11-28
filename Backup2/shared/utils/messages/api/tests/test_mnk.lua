---============================================================================
--- MNK Test Suite - Monk Complete Tests
---============================================================================
--- Tests all MNK job abilities and spells
---
--- @file tests/test_mnk.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestMNK = {}

--- Run all MNK tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestMNK.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- MNK JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "MNK Job Abilities (13):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'MNK', ability_name = 'Boost', description = 'Enhance next attack'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'MNK', ability_name = 'Chakra', description = 'Restore HP, remove Blind/Poison'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'MNK', ability_name = 'Chi Blast', description = 'Ranged attack (TP based)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'MNK', ability_name = 'Counterstance', description = 'Counter boost, DEF penalty'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'MNK', ability_name = 'Dodge', description = 'Evasion boost'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'MNK', ability_name = 'Focus', description = 'Accuracy boost'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'MNK', ability_name = 'Footwork', description = 'Kick attack rate/damage +20%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'MNK', ability_name = 'Formless Strikes', description = 'Bypass physical immunities'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'MNK', ability_name = 'Hundred Fists', description = 'Attack speed +75%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'MNK', ability_name = 'Impetus', description = 'Attack boost per hit (stacks)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'MNK', ability_name = 'Inner Strength', description = 'Max HP x2, Counter/Guard 100%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'MNK', ability_name = 'Mantra', description = 'Party max HP boost'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'MNK', ability_name = 'Perfect Counter', description = 'Counter rate 100%'}) end)
    total = total + 13

    return total
end

return TestMNK
