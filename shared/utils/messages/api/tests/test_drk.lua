---============================================================================
--- DRK Test Suite - Dark Knight Complete Tests
---============================================================================
--- Tests all DRK job abilities and spells
---
--- @file tests/test_drk.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestDRK = {}

--- Run all DRK tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestDRK.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- DRK JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "DRK Job Abilities (12):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRK', ability_name = 'Arcane Circle', description = 'ATK/DEF+ vs Arcana (party AoE)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRK', ability_name = 'Arcane Crest', description = 'Arcana: ACC/EVA/MACC/MEVA/TP down'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRK', ability_name = 'Blood Weapon', description = 'Drain HP with melee attacks'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRK', ability_name = 'Consume Mana', description = 'All MP >> damage (1 per 10 MP)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRK', ability_name = 'Dark Seal', description = 'Next dark magic MACC+'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRK', ability_name = 'Diabolic Eye', description = 'ACC+20, max HP-15%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRK', ability_name = 'Last Resort', description = 'ATK+25% DEF-25%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRK', ability_name = 'Nether Void', description = 'Next Absorb/Drain +50%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRK', ability_name = 'Scarlet Delirium', description = 'Damage taken >> ATK/MATT boost'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRK', ability_name = 'Soul Enslavement', description = 'Absorb TP with melee attacks'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRK', ability_name = 'Souleater', description = 'HP >> damage, ACC+25'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRK', ability_name = 'Weapon Bash', description = 'Stun attack'}) end)
    total = total + 12


    ---========================================================================
    --- DRK DARK MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "DRK Dark Magic (20):")

    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Absorb-ACC" .. gray_code, description = 'Steals Accuracy.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Absorb-AGI" .. gray_code, description = 'Steals Agility.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Absorb-Attri" .. gray_code, description = 'Steals beneficial status effects.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Absorb-CHR" .. gray_code, description = 'Steals Charisma.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Absorb-DEX" .. gray_code, description = 'Steals Dexterity.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Absorb-INT" .. gray_code, description = 'Steals Intelligence.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Absorb-MND" .. gray_code, description = 'Steals Mind.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Absorb-STR" .. gray_code, description = 'Steals Strength.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Absorb-TP" .. gray_code, description = 'Steals TP.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Absorb-VIT" .. gray_code, description = 'Steals Vitality.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Aspir" .. gray_code, description = 'Absorbs MP (no undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Aspir II" .. gray_code, description = 'Absorbs MP (no undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Bio" .. gray_code, description = 'Weakens attacks, drains HP.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Bio II" .. gray_code, description = 'Weakens attacks, drains HP.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Drain" .. gray_code, description = 'Absorbs HP (no undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Drain II" .. gray_code, description = 'Absorbs HP; Max HP+ (no undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Dread Spikes" .. gray_code, description = 'Covers you in dark spikes; absorbs HP (no undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Endark" .. gray_code, description = 'Adds dark dmg to attacks.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 16) .. "Stun" .. gray_code, description = 'Stuns target briefly.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Tractor" .. gray_code, description = 'Pulls a KO', target = '<t>'}) end)
    total = total + 20


    ---========================================================================
    --- DRK ELEMENTAL MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "DRK Elemental Magic (19):")

    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 14) .. "Aero" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 14) .. "Aero II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 14) .. "Aero III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 210) .. "Blizzard" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 210) .. "Blizzard II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 210) .. "Blizzard III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 2) .. "Fire" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 2) .. "Fire II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 2) .. "Fire III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 200) .. "Impact" .. gray_code, description = 'Deals dark dmg (DoT), lowers all stats.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 37) .. "Stone" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 37) .. "Stone II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 37) .. "Stone III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 16) .. "Thunder" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 16) .. "Thunder II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 16) .. "Thunder III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 219) .. "Water" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 219) .. "Water II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'DRK', spell = string.char(0x1F, 219) .. "Water III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    total = total + 19


    ---========================================================================
    --- DRK ENFEEBLING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "DRK Enfeebling Magic (9):")

    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 210) .. "Bind" .. gray_code, description = 'Immobilizes target.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Bio" .. gray_code, description = 'Dark DoT + atk down.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Bio II" .. gray_code, description = 'Dark DoT + atk down.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 37) .. "Break" .. gray_code, description = 'Inflicts petrify.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 219) .. "Poison" .. gray_code, description = 'Water DoT.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 219) .. "Poison II" .. gray_code, description = 'Water DoT.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 219) .. "Poisonga" .. gray_code, description = 'Water DoT (AOE).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Sleep" .. gray_code, description = 'Inflicts sleep.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'DRK', spell = string.char(0x1F, 200) .. "Sleep II" .. gray_code, description = 'Inflicts sleep.', target = '<t>'}) end)
    total = total + 9

    return total
end

return TestDRK
