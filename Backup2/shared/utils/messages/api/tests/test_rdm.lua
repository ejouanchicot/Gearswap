---============================================================================
--- RDM Test Suite - Red Mage Complete Tests
---============================================================================
--- Tests all RDM job abilities and spells
---
--- @file tests/test_rdm.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestRDM = {}

--- Run all RDM tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestRDM.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- RDM JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "RDM Job Abilities (6):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RDM', ability_name = 'Chainspell', description = 'Rapid spellcasting'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RDM', ability_name = 'Composure', description = 'Self-enhancing x3 duration, ACC+'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RDM', ability_name = 'Convert', description = 'Swap HP with MP'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RDM', ability_name = 'Saboteur', description = 'Enfeebling potency/duration x2'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RDM', ability_name = 'Spontaneity', description = 'Next spell instant cast'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RDM', ability_name = 'Stymie', description = 'Next enfeebling 100% MACC'}) end)
    total = total + 6


    ---========================================================================
    --- RDM DARK MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "RDM Dark Magic (2):")

    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 200) .. "Bio" .. gray_code, description = 'Weakens attacks, drains HP.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 200) .. "Bio II" .. gray_code, description = 'Weakens attacks, drains HP.', target = '<t>'}) end)
    total = total + 2


    ---========================================================================
    --- RDM ELEMENTAL MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "RDM Elemental Magic (31):")

    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Aero" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Aero II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Aero III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Aero IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Aero V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 210) .. "Blizzard" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 210) .. "Blizzard II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 210) .. "Blizzard III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 210) .. "Blizzard IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 210) .. "Blizzard V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 2) .. "Fire" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 2) .. "Fire II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 2) .. "Fire III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 2) .. "Fire IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 2) .. "Fire V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 200) .. "Impact" .. gray_code, description = 'Deals dark dmg (DoT), lowers all stats.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 37) .. "Stone" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 37) .. "Stone II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 37) .. "Stone III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 37) .. "Stone IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 37) .. "Stone V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 16) .. "Thunder" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 16) .. "Thunder II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 16) .. "Thunder III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 16) .. "Thunder IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 16) .. "Thunder V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 219) .. "Water" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 219) .. "Water II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 219) .. "Water III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 219) .. "Water IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 219) .. "Water V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    total = total + 31


    ---========================================================================
    --- RDM ENFEEBLING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "RDM Enfeebling Magic (31):")

    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 2) .. "Addle" .. gray_code, description = 'Lowers m.acc, raises cast time.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 2) .. "Addle II" .. gray_code, description = 'Lowers m.acc, raises cast time.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 210) .. "Bind" .. gray_code, description = 'Immobilizes target.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 200) .. "Bio" .. gray_code, description = 'Dark DoT + atk down.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 200) .. "Bio II" .. gray_code, description = 'Dark DoT + atk down.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 200) .. "Bio III" .. gray_code, description = 'Dark DoT + atk down.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 200) .. "Blind" .. gray_code, description = 'Lowers accuracy.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 200) .. "Blind II" .. gray_code, description = 'Lowers accuracy.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 37) .. "Break" .. gray_code, description = 'Inflicts petrify.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 187) .. "Dia" .. gray_code, description = 'Light DoT + def down.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 187) .. "Dia II" .. gray_code, description = 'Light DoT + def down.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 187) .. "Dia III" .. gray_code, description = 'Light DoT + def down.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 187) .. "Diaga" .. gray_code, description = 'Light DoT (AOE).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 200) .. "Dispel" .. gray_code, description = 'Removes 1 buff.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 210) .. "Distract" .. gray_code, description = 'Lowers evasion.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 210) .. "Distract II" .. gray_code, description = 'Lowers evasion.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 210) .. "Distract III" .. gray_code, description = 'Lowers evasion.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 200) .. "Frazzle" .. gray_code, description = 'Lowers magic evasion.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 200) .. "Frazzle II" .. gray_code, description = 'Lowers magic evasion.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 200) .. "Frazzle III" .. gray_code, description = 'Lowers magic evasion.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 14) .. "Gravity" .. gray_code, description = 'Lowers movement speed.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 14) .. "Gravity II" .. gray_code, description = 'Lowers movement speed.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 210) .. "Paralyze" .. gray_code, description = 'Inflicts paralysis.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 210) .. "Paralyze II" .. gray_code, description = 'Inflicts paralysis.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 219) .. "Poison" .. gray_code, description = 'Water DoT.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 219) .. "Poison II" .. gray_code, description = 'Water DoT.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 14) .. "Silence" .. gray_code, description = 'Prevents spellcasting.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 200) .. "Sleep" .. gray_code, description = 'Inflicts sleep.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 200) .. "Sleep II" .. gray_code, description = 'Inflicts sleep.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 37) .. "Slow" .. gray_code, description = 'Slows attacks.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = string.char(0x1F, 37) .. "Slow II" .. gray_code, description = 'Slows attacks.', target = '<t>'}) end)
    total = total + 31


    ---========================================================================
    --- RDM ENHANCING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "RDM Enhancing Magic (66):")

    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 219) .. "Aquaveil" .. gray_code, description = 'Reduces the chance of spell interruption.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 210) .. "Baraero" .. gray_code, description = 'Increases wind resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 219) .. "Baramnesia" .. gray_code, description = 'Increases amnesia resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Barblind" .. gray_code, description = 'Increases blind resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 2) .. "Barblizzard" .. gray_code, description = 'Increases ice resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 219) .. "Barfire" .. gray_code, description = 'Increases fire resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 2) .. "Barparalyze" .. gray_code, description = 'Increases paralysis resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Barpetrify" .. gray_code, description = 'Increases petrification resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 16) .. "Barpoison" .. gray_code, description = 'Increases poison resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 210) .. "Barsilence" .. gray_code, description = 'Increases silence resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Barsleep" .. gray_code, description = 'Increases sleep resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Barstone" .. gray_code, description = 'Increases earth resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 37) .. "Barthunder" .. gray_code, description = 'Increases lightning resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 219) .. "Barvirus" .. gray_code, description = 'Increases disease resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 16) .. "Barwater" .. gray_code, description = 'Increases water resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 2) .. "Blaze Spikes" .. gray_code, description = 'Fire damage on hit'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Blink" .. gray_code, description = 'Creates shadow copies that each absorb one physical attack.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Deodorize" .. gray_code, description = 'Reduces chance of being detected by scent-tracking monsters.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Enaero" .. gray_code, description = 'Adds wind damage to melee attacks.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Enaero II" .. gray_code, description = 'Add Wind dmg, lower target Ice res'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 210) .. "Enblizzard" .. gray_code, description = 'Adds ice damage to melee attacks.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 210) .. "Enblizzard II" .. gray_code, description = 'Add Ice dmg, lower target Fire res'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 2) .. "Enfire" .. gray_code, description = 'Adds fire damage to melee attacks.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 2) .. "Enfire II" .. gray_code, description = 'Add Fire dmg, lower target Water res'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 37) .. "Enstone" .. gray_code, description = 'Adds earth damage to melee attacks.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 37) .. "Enstone II" .. gray_code, description = 'Add Earth dmg, lower target Wind res'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 16) .. "Enthunder" .. gray_code, description = 'Adds lightning damage to melee attacks.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 16) .. "Enthunder II" .. gray_code, description = 'Add Thunder dmg, lower target Earth res'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 219) .. "Enwater" .. gray_code, description = 'Adds water damage to melee attacks.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 219) .. "Enwater II" .. gray_code, description = 'Add Water dmg, lower target Thunder res'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Flurry" .. gray_code, description = 'Increases ranged attack speed.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Flurry II" .. gray_code, description = 'Increases ranged attack speed.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Gain-AGI" .. gray_code, description = 'Increases Agility.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Gain-CHR" .. gray_code, description = 'Increases Charisma.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 16) .. "Gain-DEX" .. gray_code, description = 'Increases Dexterity.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 210) .. "Gain-INT" .. gray_code, description = 'Increases Intelligence.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 219) .. "Gain-MND" .. gray_code, description = 'Increases Mind.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 2) .. "Gain-STR" .. gray_code, description = 'Increases Strength.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 37) .. "Gain-VIT" .. gray_code, description = 'Increases Vitality.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Haste" .. gray_code, description = 'Increases attack speed.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Haste II" .. gray_code, description = 'Increases attack speed.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 210) .. "Ice Spikes" .. gray_code, description = 'Ice damage on hit, may paralyze'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 219) .. "Inundation" .. gray_code, description = 'Reduces target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Invisible" .. gray_code, description = 'Reduces chance of being detected by sight-tracking monsters.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Phalanx" .. gray_code, description = 'Reduces physical and magical damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Phalanx II" .. gray_code, description = 'Reduces physical and magical damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Protect" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Protect II" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Protect III" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Protect IV" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Protect V" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Refresh" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Refresh II" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Refresh III" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Regen" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Regen II" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Shell" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Shell II" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Shell III" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Shell IV" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Shell V" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 16) .. "Shock Spikes" .. gray_code, description = 'Thunder damage on hit, may stun'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 14) .. "Sneak" .. gray_code, description = 'Reduces chance of being detected by sound-tracking monsters.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 37) .. "Stoneskin" .. gray_code, description = 'Absorbs damage from physical and magical attacks.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Temper" .. gray_code, description = 'Increases Double Attack rate.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Temper II" .. gray_code, description = 'Increases Triple Attack rate.'}) end)
    total = total + 66


    ---========================================================================
    --- RDM HEALING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "RDM Healing Magic (6):")

    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Cure" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Cure II" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Cure III" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Cure IV" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Raise" .. gray_code, description = 'Revives from KO.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'RDM', spell = string.char(0x1F, 187) .. "Raise II" .. gray_code, description = 'Revives from KO.'}) end)
    total = total + 6

    return total
end

return TestRDM
