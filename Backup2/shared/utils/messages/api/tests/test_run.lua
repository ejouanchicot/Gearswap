---============================================================================
--- RUN Test Suite - Runemaster Complete Tests
---============================================================================
--- Tests all RUN job abilities and spells
---
--- @file tests/test_run.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestRUN = {}

--- Run all RUN tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestRUN.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- RUN JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "RUN Job Abilities (23):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Battuta', description = 'Parry rate +40%, counter damage'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Elemental Sforzo', description = 'Immune to all magic attacks'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Embolden', description = 'Next enhancing +50% potency, -50% duration'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Flabra', description = 'Wind rune, resist earth'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Gambit', description = 'Reduce enemy elemental defense (all runes)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Gelus', description = 'Ice rune, resist fire'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Ignis', description = 'Fire rune, resist ice'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Liement', description = 'Absorb elemental damage'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Lunge', description = 'Single-target damage (all runes)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Lux', description = 'Light rune, resist dark'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Odyllic Subterfuge', description = 'Enemy MACC -40'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'One for All', description = 'Party Magic Shield (HP × 0.2)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Pflug', description = 'Enhance elemental status resistance'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Rayke', description = 'Reduce enemy elemental resistance'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Sulpor', description = 'Thunder rune, resist water'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Swipe', description = 'Single-target damage (1 rune)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Swordplay', description = 'ACC/EVA boost (stacking)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Tellus', description = 'Earth rune, resist wind'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Tenebrae', description = 'Dark rune, resist light'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Unda', description = 'Water rune, resist thunder'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Valiance', description = 'Party elemental damage reduction'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Vallation', description = 'Reduce elemental damage by runes'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'RUN', ability_name = 'Vivacious Pulse', description = 'Restore HP based on runes'}) end)
    total = total + 23


    ---========================================================================
    --- RUN DIVINE MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "RUN Divine Magic (1):")

    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'RUN', spell = string.char(0x1F, 187) .. "Flash" .. gray_code, description = 'Blinds target; Acc-; high enmity.', target = '<t>'}) end)
    total = total + 1


    ---========================================================================
    --- RUN ENHANCING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "RUN Enhancing Magic (37):")

    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 219) .. "Aquaveil" .. gray_code, description = 'Reduces the chance of spell interruption.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 210) .. "Baraero" .. gray_code, description = 'Increases wind resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 219) .. "Baramnesia" .. gray_code, description = 'Increases amnesia resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 187) .. "Barblind" .. gray_code, description = 'Increases blind resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 2) .. "Barblizzard" .. gray_code, description = 'Increases ice resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 219) .. "Barfire" .. gray_code, description = 'Increases fire resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 2) .. "Barparalyze" .. gray_code, description = 'Increases paralysis resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 14) .. "Barpetrify" .. gray_code, description = 'Increases petrification resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 16) .. "Barpoison" .. gray_code, description = 'Increases poison resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 210) .. "Barsilence" .. gray_code, description = 'Increases silence resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 187) .. "Barsleep" .. gray_code, description = 'Increases sleep resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 14) .. "Barstone" .. gray_code, description = 'Increases earth resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 37) .. "Barthunder" .. gray_code, description = 'Increases lightning resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 219) .. "Barvirus" .. gray_code, description = 'Increases disease resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 16) .. "Barwater" .. gray_code, description = 'Increases water resistance.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 2) .. "Blaze Spikes" .. gray_code, description = 'Fire damage on hit'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 14) .. "Blink" .. gray_code, description = 'Creates shadow copies that each absorb one physical attack.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 200) .. "Crusade" .. gray_code, description = 'Increases enmity gain.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 14) .. "Foil" .. gray_code, description = 'Prevents one dispel effect when hit by physical attack.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 210) .. "Ice Spikes" .. gray_code, description = 'Ice damage on hit, may paralyze'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 187) .. "Phalanx" .. gray_code, description = 'Reduces physical and magical damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 187) .. "Protect" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 187) .. "Protect II" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 187) .. "Protect III" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 187) .. "Protect IV" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 187) .. "Regen" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 187) .. "Regen II" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 187) .. "Regen III" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 187) .. "Regen IV" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 187) .. "Shell" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 187) .. "Shell II" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 187) .. "Shell III" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 187) .. "Shell IV" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 187) .. "Shell V" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 16) .. "Shock Spikes" .. gray_code, description = 'Thunder damage on hit, may stun'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 37) .. "Stoneskin" .. gray_code, description = 'Absorbs damage from physical and magical attacks.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RUN', spell = string.char(0x1F, 187) .. "Temper" .. gray_code, description = 'Increases Double Attack rate.'}) end)
    total = total + 37

    return total
end

return TestRUN
