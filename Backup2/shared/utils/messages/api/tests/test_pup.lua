---============================================================================
--- PUP Test Suite - Puppetmaster Complete Tests
---============================================================================
--- Tests all PUP job abilities and spells
---
--- @file tests/test_pup.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestPUP = {}

--- Run all PUP tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestPUP.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- PUP JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "PUP Job Abilities (10):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PUP', ability_name = 'Activate', description = 'Summon automaton'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PUP', ability_name = 'Cooldown', description = 'Reduce burden, remove overload'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PUP', ability_name = 'Deus Ex Automata', description = 'Summon automaton low HP (1min recast)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PUP', ability_name = 'Heady Artifice', description = 'Head-specific special ability'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PUP', ability_name = 'Maintenance', description = 'Remove automaton status (oil required)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PUP', ability_name = 'Overdrive', description = 'Automaton max power, no overload'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PUP', ability_name = 'Repair', description = 'Restore automaton HP (oil required)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PUP', ability_name = 'Role Reversal', description = 'Swap HP with automaton'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PUP', ability_name = 'Tactical Switch', description = 'Swap TP with automaton'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PUP', ability_name = 'Ventriloquy', description = 'Swap enmity with automaton'}) end)
    total = total + 10

    return total
end

return TestPUP
