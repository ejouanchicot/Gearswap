---============================================================================
--- RNG Test Suite - Ranger Complete Tests
---============================================================================
--- Tests all RNG job abilities and spells
---
--- @file tests/test_rng.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestRNG = {}

--- Run all RNG tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestRNG.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- RNG JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "RNG Job Abilities (15):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RNG', ability_name = 'Barrage', description = 'Fire multiple shots (4-13 based on level)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RNG', ability_name = 'Bounty Shot', description = 'Apply TH+2 to target'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RNG', ability_name = 'Camouflage', description = 'Invisible, reduced ranged enmity'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RNG', ability_name = 'Decoy Shot', description = 'Transfer 80% ranged enmity to party'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RNG', ability_name = 'Double Shot', description = '40% chance double damage'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RNG', ability_name = 'Eagle Eye Shot', description = 'Powerful accurate shot x5 damage'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RNG', ability_name = 'Flashy Shot', description = 'Next attack +enmity/ACC/damage'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RNG', ability_name = 'Hover Shot', description = 'Damage/ACC+ per shot from different position'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RNG', ability_name = 'Overkill', description = 'Ranged speed +50%, Double/Triple Shot 100%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RNG', ability_name = 'Scavenge', description = 'Recover spent ammunition'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RNG', ability_name = 'Shadowbind', description = 'Root enemy (30s, breaks on damage)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RNG', ability_name = 'Sharpshot', description = 'Ranged ACC +40'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RNG', ability_name = 'Stealth Shot', description = 'Next attack -enmity'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RNG', ability_name = 'Unlimited Shot', description = 'Next ranged attack no ammo cost'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RNG', ability_name = 'Velocity Shot', description = 'Ranged ATK/speed +15%, melee -15%'}) end)
    total = total + 15

    return total
end

return TestRNG
