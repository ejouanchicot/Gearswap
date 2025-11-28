---============================================================================
--- BLM Test Suite - Black Mage Complete Tests
---============================================================================
--- Tests all BLM job abilities and spells
---
--- @file tests/test_blm.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestBLM = {}

--- Run all BLM tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestBLM.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- BLM JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "BLM Job Abilities (7):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BLM', ability_name = 'Cascade', description = 'Next spell damage +10% TP (consumed)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BLM', ability_name = 'Elemental Seal', description = 'Next elemental spell MACC +256'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BLM', ability_name = 'Enmity Douse', description = 'Reduces enmity to 0'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BLM', ability_name = 'Mana Wall', description = 'Take damage with MP instead of HP'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BLM', ability_name = 'Manafont', description = 'Spells cost 0 MP'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BLM', ability_name = 'Manawell', description = 'Next spell costs 0 MP (target)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BLM', ability_name = 'Subtle Sorcery', description = 'Enmity- MACC+ bypass resists'}) end)
    total = total + 7


    ---========================================================================
    --- BLM DARK MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "BLM Dark Magic (7):")

    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 200) .. "Aspir" .. gray_code, description = 'Absorbs MP (no undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 200) .. "Aspir II" .. gray_code, description = 'Absorbs MP (no undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 200) .. "Bio" .. gray_code, description = 'Weakens attacks, drains HP.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 200) .. "Bio II" .. gray_code, description = 'Weakens attacks, drains HP.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 200) .. "Drain" .. gray_code, description = 'Absorbs HP (no undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 16) .. "Stun" .. gray_code, description = 'Stuns target briefly.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 200) .. "Tractor" .. gray_code, description = 'Pulls a KO', target = '<t>'}) end)
    total = total + 7


    ---========================================================================
    --- BLM ELEMENTAL MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "BLM Elemental Magic (81):")

    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 14) .. "Aero" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 14) .. "Aero II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 14) .. "Aero III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 14) .. "Aero IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 14) .. "Aero V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 14) .. "Aero VI" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 14) .. "Aeroga" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 14) .. "Aeroga II" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 14) .. "Aeroga III" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 14) .. "Aeroja" .. gray_code, description = 'Deals AOE dmg (stacks).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 210) .. "Blizzaga" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 210) .. "Blizzaga II" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 210) .. "Blizzaga III" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 210) .. "Blizzaja" .. gray_code, description = 'Deals AOE dmg (stacks).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 210) .. "Blizzard" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 210) .. "Blizzard II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 210) .. "Blizzard III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 210) .. "Blizzard IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 210) .. "Blizzard V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 210) .. "Blizzard VI" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 2) .. "Burn" .. gray_code, description = 'Lowers intelligence, drains HP.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 16) .. "Burst" .. gray_code, description = 'Deals thunder dmg, lowers earth resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 16) .. "Burst II" .. gray_code, description = 'Deals thunder dmg, lowers earth resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 14) .. "Choke" .. gray_code, description = 'Lowers vitality, drains HP.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 200) .. "Comet" .. gray_code, description = 'Deals dark dmg (single, stacks).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 219) .. "Drown" .. gray_code, description = 'Lowers strength, drains HP.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 2) .. "Firaga" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 2) .. "Firaga II" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 2) .. "Firaga III" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 2) .. "Firaja" .. gray_code, description = 'Deals AOE dmg (stacks).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 2) .. "Fire" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 2) .. "Fire II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 2) .. "Fire III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 2) .. "Fire IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 2) .. "Fire V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 2) .. "Fire VI" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 2) .. "Flare" .. gray_code, description = 'Deals fire dmg, lowers water resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 2) .. "Flare II" .. gray_code, description = 'Deals fire dmg, lowers water resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 219) .. "Flood" .. gray_code, description = 'Deals water dmg, lowers thunder resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 219) .. "Flood II" .. gray_code, description = 'Deals water dmg, lowers thunder resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 210) .. "Freeze" .. gray_code, description = 'Deals ice dmg, lowers fire resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 210) .. "Freeze II" .. gray_code, description = 'Deals ice dmg, lowers fire resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 210) .. "Frost" .. gray_code, description = 'Lowers intelligence, drains HP.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 200) .. "Impact" .. gray_code, description = 'Deals dark dmg (DoT), lowers all stats.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 2) .. "Meteor" .. gray_code, description = 'Deals fire dmg (AOE).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 37) .. "Quake" .. gray_code, description = 'Deals earth dmg, lowers wind resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 37) .. "Quake II" .. gray_code, description = 'Deals earth dmg, lowers wind resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 37) .. "Rasp" .. gray_code, description = 'Lowers dexterity, drains HP.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 16) .. "Shock" .. gray_code, description = 'Lowers mind, drains HP.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 37) .. "Stone" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 37) .. "Stone II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 37) .. "Stone III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 37) .. "Stone IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 37) .. "Stone V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 37) .. "Stone VI" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 37) .. "Stonega" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 37) .. "Stonega II" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 37) .. "Stonega III" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 37) .. "Stoneja" .. gray_code, description = 'Deals AOE dmg (stacks).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 16) .. "Thundaga" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 16) .. "Thundaga II" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 16) .. "Thundaga III" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 16) .. "Thundaja" .. gray_code, description = 'Deals AOE dmg (stacks).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 16) .. "Thunder" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 16) .. "Thunder II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 16) .. "Thunder III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 16) .. "Thunder IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 16) .. "Thunder V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 16) .. "Thunder VI" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 14) .. "Tornado" .. gray_code, description = 'Deals wind dmg, lowers ice resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 14) .. "Tornado II" .. gray_code, description = 'Deals wind dmg, lowers ice resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 219) .. "Water" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 219) .. "Water II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 219) .. "Water III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 219) .. "Water IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 219) .. "Water V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 219) .. "Water VI" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 219) .. "Waterga" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 219) .. "Waterga II" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 219) .. "Waterga III" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 219) .. "Waterja" .. gray_code, description = 'Deals AOE dmg (stacks).'}) end)
    total = total + 81


    ---========================================================================
    --- BLM ENFEEBLING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "BLM Enfeebling Magic (13):")

    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 210) .. "Bind" .. gray_code, description = 'Immobilizes target.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 200) .. "Bio" .. gray_code, description = 'Dark DoT + atk down.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 200) .. "Bio II" .. gray_code, description = 'Dark DoT + atk down.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 200) .. "Blind" .. gray_code, description = 'Lowers accuracy.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 37) .. "Break" .. gray_code, description = 'Inflicts petrify.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 37) .. "Breakga" .. gray_code, description = 'Inflicts petrify (AOE).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 219) .. "Poison" .. gray_code, description = 'Water DoT.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 219) .. "Poison II" .. gray_code, description = 'Water DoT.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 219) .. "Poisonga" .. gray_code, description = 'Water DoT (AOE).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 200) .. "Sleep" .. gray_code, description = 'Inflicts sleep.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 200) .. "Sleep II" .. gray_code, description = 'Inflicts sleep.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 200) .. "Sleepga" .. gray_code, description = 'Inflicts sleep (AOE).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'BLM', spell = string.char(0x1F, 200) .. "Sleepga II" .. gray_code, description = 'Inflicts sleep (AOE).', target = '<t>'}) end)
    total = total + 13


    ---========================================================================
    --- BLM ENHANCING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "BLM Enhancing Magic (7):")

    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 2) .. "Blaze Spikes" .. gray_code, description = 'Fire damage on hit'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 200) .. "Escape" .. gray_code, description = 'Warp party to dungeon entrance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 210) .. "Ice Spikes" .. gray_code, description = 'Ice damage on hit, may paralyze'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 200) .. "Retrace" .. gray_code, description = 'Returns you to last visited location.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 16) .. "Shock Spikes" .. gray_code, description = 'Thunder damage on hit, may stun'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 200) .. "Warp" .. gray_code, description = 'Returns you to your current Home Point.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 200) .. "Warp II" .. gray_code, description = 'Leader to HP, party to yours'}) end)
    total = total + 7

    return total
end

return TestBLM
