---============================================================================
--- GEO Test Suite - Geomancer Complete Tests
---============================================================================
--- Tests all GEO job abilities and spells
---
--- @file tests/test_geo.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestGEO = {}

--- Run all GEO tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestGEO.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- GEO JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "GEO Job Abilities (14):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'GEO', ability_name = 'Blaze of Glory', description = 'Next luopan +50%, -50% HP'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'GEO', ability_name = 'Bolster', description = 'Geomancy effects x2'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'GEO', ability_name = 'Collimated Fervor', description = 'Next Cardinal Chant +50%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'GEO', ability_name = 'Concentric Pulse', description = 'Dismiss luopan, AoE damage'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'GEO', ability_name = 'Dematerialize', description = 'Luopan damage immunity'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'GEO', ability_name = 'Ecliptic Attrition', description = 'Luopan +25%, HP consumption +6/tick'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'GEO', ability_name = 'Entrust', description = 'Next Indi targets party member'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'GEO', ability_name = 'Full Circle', description = 'Dismiss luopan, recover MP'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'GEO', ability_name = 'Lasting Emanation', description = 'Luopan HP consumption -7/tick'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'GEO', ability_name = 'Life Cycle', description = '25% your HP >> luopan'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'GEO', ability_name = 'Mending Halation', description = 'Dismiss luopan, party HP'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'GEO', ability_name = 'Radial Arcana', description = 'Dismiss luopan, party MP'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'GEO', ability_name = 'Theurgic Focus', description = 'Next -ra spell MAB+50'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'GEO', ability_name = 'Widened Compass', description = 'Geomancy range x2'}) end)
    total = total + 14


    ---========================================================================
    --- GEO DARK MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "GEO Dark Magic (3):")

    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'GEO', spell = string.char(0x1F, 200) .. "Aspir" .. gray_code, description = 'Absorbs MP (no undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'GEO', spell = string.char(0x1F, 200) .. "Aspir II" .. gray_code, description = 'Absorbs MP (no undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'GEO', spell = string.char(0x1F, 200) .. "Drain" .. gray_code, description = 'Absorbs HP (no undead).', target = '<t>'}) end)
    total = total + 3


    ---========================================================================
    --- GEO ELEMENTAL MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "GEO Elemental Magic (49):")

    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 14) .. "Aero" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 14) .. "Aero II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 14) .. "Aero III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 14) .. "Aero IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 14) .. "Aero V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 14) .. "Aerora" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 14) .. "Aerora II" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 14) .. "Aerora III" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 210) .. "Blizzara" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 210) .. "Blizzara II" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 210) .. "Blizzara III" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 210) .. "Blizzard" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 210) .. "Blizzard II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 210) .. "Blizzard III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 210) .. "Blizzard IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 210) .. "Blizzard V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 2) .. "Fira" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 2) .. "Fira II" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 2) .. "Fira III" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 2) .. "Fire" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 2) .. "Fire II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 2) .. "Fire III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 2) .. "Fire IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 2) .. "Fire V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 200) .. "Impact" .. gray_code, description = 'Deals dark dmg (DoT), lowers all stats.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 37) .. "Stone" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 37) .. "Stone II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 37) .. "Stone III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 37) .. "Stone IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 37) .. "Stone V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 37) .. "Stonera" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 37) .. "Stonera II" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 37) .. "Stonera III" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 16) .. "Thundara" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 16) .. "Thundara II" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 16) .. "Thundara III" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 16) .. "Thunder" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 16) .. "Thunder II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 16) .. "Thunder III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 16) .. "Thunder IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 16) .. "Thunder V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 219) .. "Water" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 219) .. "Water II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 219) .. "Water III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 219) .. "Water IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 219) .. "Water V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 219) .. "Watera" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 219) .. "Watera II" .. gray_code, description = 'Deals AOE dmg.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 219) .. "Watera III" .. gray_code, description = 'Deals AOE dmg.'}) end)
    total = total + 49


    ---========================================================================
    --- GEO ENFEEBLING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "GEO Enfeebling Magic (2):")

    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'GEO', spell = string.char(0x1F, 200) .. "Sleep" .. gray_code, description = 'Inflicts sleep.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'GEO', spell = string.char(0x1F, 200) .. "Sleep II" .. gray_code, description = 'Inflicts sleep.', target = '<t>'}) end)
    total = total + 2


    ---========================================================================
    --- GEO ENHANCING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "GEO Enhancing Magic (1):")

    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'GEO', spell = string.char(0x1F, 200) .. "Klimaform" .. gray_code, description = '+Elemental magic potency in weather'}) end)
    total = total + 1


    ---========================================================================
    --- GEO GEOMANCY
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "GEO Geomancy (60):")

    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 14) .. "Geo-AGI" .. gray_code, description = 'Boosts agility.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 210) .. "Geo-Acumen" .. gray_code, description = 'Boosts magic atk.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 187) .. "Geo-Attunement" .. gray_code, description = 'Boosts magic acc.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 37) .. "Geo-Barrier" .. gray_code, description = 'Boosts defense.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 187) .. "Geo-CHR" .. gray_code, description = 'Boosts charisma.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 16) .. "Geo-DEX" .. gray_code, description = 'Boosts dexterity.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 2) .. "Geo-Fade" .. gray_code, description = 'Lowers attack.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 219) .. "Geo-Fend" .. gray_code, description = 'Boosts defense.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 200) .. "Geo-Focus" .. gray_code, description = 'Boosts magic acc.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 14) .. "Geo-Frailty" .. gray_code, description = 'Lowers defense.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 2) .. "Geo-Fury" .. gray_code, description = 'Boosts attack.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 14) .. "Geo-Gravity" .. gray_code, description = 'Slows movement.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 14) .. "Geo-Haste" .. gray_code, description = 'Boosts attack speed.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 210) .. "Geo-INT" .. gray_code, description = 'Boosts intelligence.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 200) .. "Geo-Languor" .. gray_code, description = 'Slows foes.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 219) .. "Geo-MND" .. gray_code, description = 'Boosts mind.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 16) .. "Geo-Malaise" .. gray_code, description = 'Lowers magic def.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 210) .. "Geo-Paralysis" .. gray_code, description = 'Paralyzes foes.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 219) .. "Geo-Poison" .. gray_code, description = 'Boosts poison dmg.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 16) .. "Geo-Precision" .. gray_code, description = 'Boosts accuracy.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 187) .. "Geo-Refresh" .. gray_code, description = 'Restores MP.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 187) .. "Geo-Regen" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 2) .. "Geo-STR" .. gray_code, description = 'Boosts strength.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 37) .. "Geo-Slip" .. gray_code, description = 'Lowers accuracy.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 37) .. "Geo-Slow" .. gray_code, description = 'Slows foes.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 210) .. "Geo-Torpor" .. gray_code, description = 'Lowers evasion.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 37) .. "Geo-VIT" .. gray_code, description = 'Boosts vitality.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 187) .. "Geo-Vex" .. gray_code, description = 'Lowers magic def.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 14) .. "Geo-Voidance" .. gray_code, description = 'Boosts evasion.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 219) .. "Geo-Wilt" .. gray_code, description = 'Lowers attack.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 14) .. "Indi-AGI" .. gray_code, description = 'Boosts agility.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 210) .. "Indi-Acumen" .. gray_code, description = 'Boosts magic atk.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 187) .. "Indi-Attunement" .. gray_code, description = 'Boosts magic acc.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 37) .. "Indi-Barrier" .. gray_code, description = 'Boosts defense.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 187) .. "Indi-CHR" .. gray_code, description = 'Boosts charisma.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 16) .. "Indi-DEX" .. gray_code, description = 'Boosts dexterity.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 2) .. "Indi-Fade" .. gray_code, description = 'Lowers attack.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 219) .. "Indi-Fend" .. gray_code, description = 'Boosts defense.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 200) .. "Indi-Focus" .. gray_code, description = 'Boosts magic acc.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 14) .. "Indi-Frailty" .. gray_code, description = 'Lowers defense.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 2) .. "Indi-Fury" .. gray_code, description = 'Boosts attack.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 14) .. "Indi-Gravity" .. gray_code, description = 'Slows movement.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 14) .. "Indi-Haste" .. gray_code, description = 'Boosts attack speed.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 210) .. "Indi-INT" .. gray_code, description = 'Boosts intelligence.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 200) .. "Indi-Languor" .. gray_code, description = 'Slows foes.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 219) .. "Indi-MND" .. gray_code, description = 'Boosts mind.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 16) .. "Indi-Malaise" .. gray_code, description = 'Lowers magic def.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 210) .. "Indi-Paralysis" .. gray_code, description = 'Paralyzes foes.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 219) .. "Indi-Poison" .. gray_code, description = 'Boosts poison dmg.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 16) .. "Indi-Precision" .. gray_code, description = 'Boosts accuracy.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 187) .. "Indi-Refresh" .. gray_code, description = 'Restores MP.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 187) .. "Indi-Regen" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 2) .. "Indi-STR" .. gray_code, description = 'Boosts strength.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 37) .. "Indi-Slip" .. gray_code, description = 'Lowers accuracy.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 37) .. "Indi-Slow" .. gray_code, description = 'Slows nearby foes.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 210) .. "Indi-Torpor" .. gray_code, description = 'Lowers evasion.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 37) .. "Indi-VIT" .. gray_code, description = 'Boosts vitality.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 187) .. "Indi-Vex" .. gray_code, description = 'Lowers magic def.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 14) .. "Indi-Voidance" .. gray_code, description = 'Boosts evasion.'}) end)
    test(function() M.send('GEO', 'indi_cast', {job = 'GEO', spell = string.char(0x1F, 219) .. "Indi-Wilt" .. gray_code, description = 'Lowers attack.'}) end)
    total = total + 60

    return total
end

return TestGEO
