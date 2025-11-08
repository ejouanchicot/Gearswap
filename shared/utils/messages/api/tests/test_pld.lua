---============================================================================
--- PLD Test Suite - Paladin Complete Tests
---============================================================================
--- Tests all PLD job abilities and spells
---
--- @file tests/test_pld.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestPLD = {}

--- Run all PLD tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestPLD.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- PLD JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "PLD Job Abilities (13):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PLD', ability_name = 'Chivalry', description = 'TP >> MP'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PLD', ability_name = 'Cover', description = 'Redirect ally damage to self'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PLD', ability_name = 'Divine Emblem', description = 'Next divine spell MACC+, enmity+'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PLD', ability_name = 'Fealty', description = 'Enfeebling resist, blocks Charm'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PLD', ability_name = 'Holy Circle', description = 'ATK/DEF+ vs Undead (party AoE)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PLD', ability_name = 'Intervene', description = 'Shield strike, ATK/ACC >> 1'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PLD', ability_name = 'Invincible', description = 'Physical damage immunity'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PLD', ability_name = 'Majesty', description = 'Cure/Protect AoE, +potency/-recast'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PLD', ability_name = 'Palisade', description = 'Shield block +30%, no enmity loss'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PLD', ability_name = 'Rampart', description = 'Party damage -25%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PLD', ability_name = 'Sentinel', description = 'Physical damage -90>>-50%, +enmity'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PLD', ability_name = 'Sepulcher', description = 'Undead: ACC/EVA/MACC/MEVA/TP down'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PLD', ability_name = 'Shield Bash', description = 'Stun attack'}) end)
    total = total + 13


    ---========================================================================
    --- PLD DIVINE MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "PLD Divine Magic (7):")

    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'PLD', spell = string.char(0x1F, 187) .. "Banish" .. gray_code, description = 'Deals light dmg (vs undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'PLD', spell = string.char(0x1F, 187) .. "Banish II" .. gray_code, description = 'Deals light dmg (vs undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'PLD', spell = string.char(0x1F, 187) .. "Banishga" .. gray_code, description = 'Deals light dmg (vs undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'PLD', spell = string.char(0x1F, 187) .. "Enlight" .. gray_code, description = 'Adds light dmg to attacks.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'PLD', spell = string.char(0x1F, 187) .. "Flash" .. gray_code, description = 'Blinds target; Acc-; high enmity.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'PLD', spell = string.char(0x1F, 187) .. "Holy" .. gray_code, description = 'Deals light dmg (vs undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'PLD', spell = string.char(0x1F, 187) .. "Holy II" .. gray_code, description = 'Deals light dmg; Solace: potency+ from HP healed.', target = '<t>'}) end)
    total = total + 7


    ---========================================================================
    --- PLD ENHANCING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "PLD Enhancing Magic (12):")

    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'PLD', spell = string.char(0x1F, 200) .. "Crusade" .. gray_code, description = 'Increases enmity gain.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'PLD', spell = string.char(0x1F, 187) .. "Phalanx" .. gray_code, description = 'Reduces physical and magical damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'PLD', spell = string.char(0x1F, 187) .. "Protect" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'PLD', spell = string.char(0x1F, 187) .. "Protect II" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'PLD', spell = string.char(0x1F, 187) .. "Protect III" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'PLD', spell = string.char(0x1F, 187) .. "Protect IV" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'PLD', spell = string.char(0x1F, 187) .. "Protect V" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'PLD', spell = string.char(0x1F, 187) .. "Reprisal" .. gray_code, description = 'Reflects damage back to attacker when you parry.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'PLD', spell = string.char(0x1F, 187) .. "Shell" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'PLD', spell = string.char(0x1F, 187) .. "Shell II" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'PLD', spell = string.char(0x1F, 187) .. "Shell III" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'PLD', spell = string.char(0x1F, 187) .. "Shell IV" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    total = total + 12


    ---========================================================================
    --- PLD HEALING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "PLD Healing Magic (5):")

    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'PLD', spell = string.char(0x1F, 187) .. "Cure" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'PLD', spell = string.char(0x1F, 187) .. "Cure II" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'PLD', spell = string.char(0x1F, 187) .. "Cure III" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'PLD', spell = string.char(0x1F, 187) .. "Cure IV" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'PLD', spell = string.char(0x1F, 187) .. "Raise" .. gray_code, description = 'Revives from KO.'}) end)
    total = total + 5

    return total
end

return TestPLD
