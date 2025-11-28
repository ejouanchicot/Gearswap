---============================================================================
--- BST Test Suite - Beastmaster Complete Tests
---============================================================================
--- Tests all BST job abilities and spells
---
--- @file tests/test_bst.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestBST = {}

--- Run all BST tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestBST.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- BST JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "BST Job Abilities (9):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BST', ability_name = 'Bestial Loyalty', description = 'Summon jug pet (no consume)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BST', ability_name = 'Call Beast', description = 'Summon jug pet (consumes jug)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BST', ability_name = 'Charm', description = 'Tame monster as pet'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BST', ability_name = 'Familiar', description = 'Pet powers enhanced'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BST', ability_name = 'Feral Howl', description = 'Terrorize target'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BST', ability_name = 'Gauge', description = 'Check charm success rate'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BST', ability_name = 'Reward', description = 'Restore pet HP (food required)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BST', ability_name = 'Tame', description = 'Lower enemy resistance to charm'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BST', ability_name = 'Unleash', description = 'Charm 95% success, Sic/Ready no recast'}) end)
    total = total + 9

    return total
end

return TestBST
