---============================================================================
--- SCH Test Suite - Scholar Complete Tests
---============================================================================
--- Tests all SCH job abilities and spells
---
--- @file tests/test_sch.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestSCH = {}

--- Run all SCH tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestSCH.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- SCH JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "SCH Job Abilities (8):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SCH', ability_name = 'Caper Emissarius', description = 'Transfer all enmity to party member'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SCH', ability_name = 'Dark Arts', description = 'Black magic optimized, -10% cost/time'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SCH', ability_name = 'Enlightenment', description = 'Both Arts active, both Addenda'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SCH', ability_name = 'Libra', description = 'Examine target enmity levels'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SCH', ability_name = 'Light Arts', description = 'White magic optimized, -10% cost/time'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SCH', ability_name = 'Modus Veritas', description = 'Helix DoT x2, duration -50%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SCH', ability_name = 'Sublimation', description = 'Convert HP >> MP over time'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SCH', ability_name = 'Tabula Rasa', description = 'All Arts/Stratagems no recast'}) end)
    total = total + 8


    ---========================================================================
    --- SCH DARK MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "SCH Dark Magic (5):")

    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'SCH', spell = string.char(0x1F, 200) .. "Aspir" .. gray_code, description = 'Absorbs MP (no undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'SCH', spell = string.char(0x1F, 200) .. "Aspir II" .. gray_code, description = 'Absorbs MP (no undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'SCH', spell = string.char(0x1F, 200) .. "Bio III" .. gray_code, description = 'Weakens attacks, drains HP.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'SCH', spell = string.char(0x1F, 200) .. "Drain" .. gray_code, description = 'Absorbs HP (no undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'SCH', spell = string.char(0x1F, 200) .. "Kaustra" .. gray_code, description = 'Uses 20% MP; inflicts dark DoT.', target = '<t>'}) end)
    total = total + 5


    ---========================================================================
    --- SCH ELEMENTAL MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "SCH Elemental Magic (47):")

    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 14) .. "Aero" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 14) .. "Aero II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 14) .. "Aero III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 14) .. "Aero IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 14) .. "Aero V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 14) .. "Anemohelix" .. gray_code, description = 'Deals wind DoT (weather+).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 14) .. "Anemohelix II" .. gray_code, description = 'Deals wind DoT (weather+).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 210) .. "Blizzard" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 210) .. "Blizzard II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 210) .. "Blizzard III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 210) .. "Blizzard IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 210) .. "Blizzard V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 210) .. "Cryohelix" .. gray_code, description = 'Deals ice DoT (weather+).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 210) .. "Cryohelix II" .. gray_code, description = 'Deals ice DoT (weather+).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 2) .. "Fire" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 2) .. "Fire II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 2) .. "Fire III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 2) .. "Fire IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 2) .. "Fire V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 37) .. "Geohelix" .. gray_code, description = 'Deals earth DoT (weather+).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 37) .. "Geohelix II" .. gray_code, description = 'Deals earth DoT (weather+).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 219) .. "Hydrohelix" .. gray_code, description = 'Deals water DoT (weather+).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 219) .. "Hydrohelix II" .. gray_code, description = 'Deals water DoT (weather+).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 200) .. "Impact" .. gray_code, description = 'Deals dark dmg (DoT), lowers all stats.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 16) .. "Ionohelix" .. gray_code, description = 'Deals thunder DoT (weather+).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 16) .. "Ionohelix II" .. gray_code, description = 'Deals thunder DoT (weather+).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Luminohelix" .. gray_code, description = 'Deals light DoT (weather+).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Luminohelix II" .. gray_code, description = 'Deals light DoT (weather+).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 200) .. "Noctohelix" .. gray_code, description = 'Deals dark DoT (weather+).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 200) .. "Noctohelix II" .. gray_code, description = 'Deals dark DoT (weather+).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 2) .. "Pyrohelix" .. gray_code, description = 'Deals fire DoT (weather+).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 2) .. "Pyrohelix II" .. gray_code, description = 'Deals fire DoT (weather+).'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 37) .. "Stone" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 37) .. "Stone II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 37) .. "Stone III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 37) .. "Stone IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 37) .. "Stone V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 16) .. "Thunder" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 16) .. "Thunder II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 16) .. "Thunder III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 16) .. "Thunder IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 16) .. "Thunder V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 219) .. "Water" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 219) .. "Water II" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 219) .. "Water III" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 219) .. "Water IV" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 219) .. "Water V" .. gray_code, description = 'Deals damage to an enemy.'}) end)
    total = total + 47


    ---========================================================================
    --- SCH ENFEEBLING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "SCH Enfeebling Magic (4):")

    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'SCH', spell = string.char(0x1F, 37) .. "Break" .. gray_code, description = 'Inflicts petrify.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'SCH', spell = string.char(0x1F, 200) .. "Dispel" .. gray_code, description = 'Removes 1 buff.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'SCH', spell = string.char(0x1F, 200) .. "Sleep" .. gray_code, description = 'Inflicts sleep.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'SCH', spell = string.char(0x1F, 200) .. "Sleep II" .. gray_code, description = 'Inflicts sleep.', target = '<t>'}) end)
    total = total + 4


    ---========================================================================
    --- SCH ENHANCING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "SCH Enhancing Magic (48):")

    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Adloquium" .. gray_code, description = '+Max HP, +MDEF, reduce interrupt'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 200) .. "Animus Augeo" .. gray_code, description = 'Increases pet'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Animus Minuo" .. gray_code, description = 'Reduces pet'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 219) .. "Aquaveil" .. gray_code, description = 'Reduces the chance of spell interruption.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Aurorastorm" .. gray_code, description = 'Light weather: +dmg and resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Aurorastorm II" .. gray_code, description = 'Light weather: +dmg and resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 2) .. "Blaze Spikes" .. gray_code, description = 'Fire damage on hit'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 14) .. "Blink" .. gray_code, description = 'Creates shadow copies that each absorb one physical attack.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 14) .. "Deodorize" .. gray_code, description = 'Reduces chance of being detected by scent-tracking monsters.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Embrava" .. gray_code, description = 'Increases magic accuracy and grants haste effect.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Erase" .. gray_code, description = 'Removes one detrimental status effect from target.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 2) .. "Firestorm" .. gray_code, description = 'Fire weather: +dmg and resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 2) .. "Firestorm II" .. gray_code, description = 'Fire weather: +dmg and resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 210) .. "Hailstorm" .. gray_code, description = 'Ice weather: +dmg and resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 210) .. "Hailstorm II" .. gray_code, description = 'Ice weather: +dmg and resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 210) .. "Ice Spikes" .. gray_code, description = 'Ice damage on hit, may paralyze'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 14) .. "Invisible" .. gray_code, description = 'Reduces chance of being detected by sight-tracking monsters.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 200) .. "Klimaform" .. gray_code, description = '+Elemental magic potency in weather'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Protect" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Protect II" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Protect III" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Protect IV" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Protect V" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 219) .. "Rainstorm" .. gray_code, description = 'Water weather: +dmg and resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 219) .. "Rainstorm II" .. gray_code, description = 'Water weather: +dmg and resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Refresh" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Refresh II" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Regen" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Regen II" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Regen III" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Regen IV" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Regen V" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 37) .. "Sandstorm" .. gray_code, description = 'Earth weather: +dmg and resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 37) .. "Sandstorm II" .. gray_code, description = 'Earth weather: +dmg and resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Shell" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Shell II" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Shell III" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Shell IV" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Shell V" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 16) .. "Shock Spikes" .. gray_code, description = 'Thunder damage on hit, may stun'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 14) .. "Sneak" .. gray_code, description = 'Reduces chance of being detected by sound-tracking monsters.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 37) .. "Stoneskin" .. gray_code, description = 'Absorbs damage from physical and magical attacks.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 16) .. "Thunderstorm" .. gray_code, description = 'Lightning weather: +dmg and resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 16) .. "Thunderstorm II" .. gray_code, description = 'Lightning weather: +dmg and resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 200) .. "Voidstorm" .. gray_code, description = 'Dark weather: +dmg and resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 200) .. "Voidstorm II" .. gray_code, description = 'Dark weather: +dmg and resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 14) .. "Windstorm" .. gray_code, description = 'Wind weather: +dmg and resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 14) .. "Windstorm II" .. gray_code, description = 'Wind weather: +dmg and resistance'}) end)
    total = total + 48


    ---========================================================================
    --- SCH HEALING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "SCH Healing Magic (17):")

    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Blindna" .. gray_code, description = 'Removes blindness.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Cure" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Cure II" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Cure III" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Cure IV" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Cursna" .. gray_code, description = 'Removes curse or doom.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Paralyna" .. gray_code, description = 'Removes paralysis.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Poisona" .. gray_code, description = 'Removes poison.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Raise" .. gray_code, description = 'Revives from KO.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Raise II" .. gray_code, description = 'Revives from KO.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Raise III" .. gray_code, description = 'Revives from KO.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Reraise" .. gray_code, description = 'Grants you the effect of Raise when you are KO'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Reraise II" .. gray_code, description = 'Grants you the effect of Raise II when you are KO'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Reraise III" .. gray_code, description = 'Grants you the effect of Raise III when you are KO'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Silena" .. gray_code, description = 'Removes silence.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Stona" .. gray_code, description = 'Removes petrification.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'SCH', spell = string.char(0x1F, 187) .. "Viruna" .. gray_code, description = 'Removes disease.'}) end)
    total = total + 17

    return total
end

return TestSCH
