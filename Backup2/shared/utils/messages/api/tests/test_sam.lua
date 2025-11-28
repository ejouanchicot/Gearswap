---============================================================================
--- SAM Test Suite - Samurai Complete Tests
---============================================================================
--- Tests all SAM job abilities and spells
---
--- @file tests/test_sam.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestSAM = {}

--- Run all SAM tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestSAM.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- SAM JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "SAM Job Abilities (14):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SAM', ability_name = 'Blade Bash', description = 'Stun attack'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SAM', ability_name = 'Hagakure', description = 'Convert Kenki >> HP/MP/TP'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SAM', ability_name = 'Hamanoha', description = 'Zanshin +100%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SAM', ability_name = 'Hasso', description = 'STR/Haste/ACC+'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SAM', ability_name = 'Konzen-ittai', description = 'WS TP bonus'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SAM', ability_name = 'Meditate', description = 'Restore TP'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SAM', ability_name = 'Meikyo Shisui', description = 'WS TP cost >> 1000'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SAM', ability_name = 'Seigan', description = 'Third Eye enhanced'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SAM', ability_name = 'Sekkanoki', description = 'Next WS TP cost >> 1000'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SAM', ability_name = 'Sengikori', description = 'Store TP boost'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SAM', ability_name = 'Shikikoyo', description = 'Share TP >1000 with party member'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SAM', ability_name = 'Third Eye', description = 'Anticipate/Counter next attack'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SAM', ability_name = 'Warding Circle', description = 'ATK/DEF+ vs Demons (party AoE)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SAM', ability_name = 'Yaegasumi', description = 'Evade special attacks, WS damage+'}) end)
    total = total + 14

    return total
end

return TestSAM
