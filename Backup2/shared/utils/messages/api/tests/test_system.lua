---============================================================================
--- SYSTEM Test Suite - General System Messages
---============================================================================
--- Tests system messages, error handling, and generic templates
---
--- @file tests/test_system.lua
--- @author Tetsouo
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestSystem = {}

--- Run all SYSTEM tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestSystem.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- ELEMENTAL MAGIC (BLM)
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "Elemental Magic (6):")

    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 2) .. 'Fire VI' .. gray_code, description = 'Deals fire damage'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 30) .. 'Blizzard VI' .. gray_code, description = 'Deals ice damage'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 14) .. 'Aero VI' .. gray_code, description = 'Deals wind damage'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 37) .. 'Stone VI' .. gray_code, description = 'Deals earth damage'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 16) .. 'Thunder VI' .. gray_code, description = 'Deals lightning damage'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BLM', spell = string.char(0x1F, 219) .. 'Water VI' .. gray_code, description = 'Deals water damage'}) end)
    total = total + 6

    ---========================================================================
    --- ENHANCING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "Enhancing Magic (3):")

    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = 'Haste II', description = 'Speeds casting/attacks'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'RDM', spell = 'Protect V', description = 'Boosts defense'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = 'Stoneskin', description = 'Absorbs damage'}) end)
    total = total + 3

    ---========================================================================
    --- ENFEEBLING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "Enfeebling Magic (3):")

    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = 'Slow II', target = '<t>', description = 'Lowers attack speed'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = 'Paralyze II', target = '<t>', description = 'Inhibits movement'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'RDM', spell = 'Silence', target = '<t>', description = 'Prevents magic'}) end)
    total = total + 3

    ---========================================================================
    --- DIVINE MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "Divine Magic (2):")

    test(function() M.send('MAGIC', 'divine_spell_activated_full', {job = 'WHM', spell = 'Banish III', description = 'Deals light damage'}) end)
    test(function() M.send('MAGIC', 'divine_spell_activated_full', {job = 'WHM', spell = 'Holy II', description = 'Deals light damage'}) end)
    total = total + 2

    ---========================================================================
    --- HEALING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "Healing Magic (4):")

    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = 'Cure IV', description = 'Restores HP'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = 'Curaga III', description = 'Restores HP (AoE)'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full_target', {job = 'WHM', spell = 'Cure V', description = 'Restores HP', target = 'Ally'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'RDM', spell = 'Regen IV', description = 'HP recovered while healing'}) end)
    total = total + 4

    ---========================================================================
    --- DARK MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "Dark Magic (3):")

    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = 'Drain III', target = '<t>', description = 'Steals HP'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = 'Aspir III', target = '<t>', description = 'Steals MP'}) end)
    test(function() M.send('MAGIC', 'dark_spell_activated_full_target', {job = 'DRK', spell = 'Bio III', target = '<t>', description = 'Damage over time'}) end)
    total = total + 3

    ---========================================================================
    --- BLUE MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "Blue Magic (3):")

    test(function() M.send('MAGIC', 'blue_spell_activated_full_target', {job = 'BLU', spell = 'Head Butt', target = '<t>', description = 'Physical damage'}) end)
    test(function() M.send('MAGIC', 'blue_spell_activated_full', {job = 'BLU', spell = 'Cocoon', description = 'Boosts defense'}) end)
    test(function() M.send('MAGIC', 'blue_spell_activated_full_target', {job = 'BLU', spell = 'Magic Hammer', target = '<t>', description = 'Damage + MP drain'}) end)
    total = total + 3

    ---========================================================================
    --- JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "Job Abilities (4):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WAR', ability_name = 'Berserk', description = 'ATK+25% DEF-25%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'DRK', ability_name = 'Last Resort', description = 'ATK+25% DEF-25%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'SAM', ability_name = 'Hasso', description = 'STR/Haste/ACC+'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'PLD', ability_name = 'Sentinel', description = 'Physical damage -90>>-50%, +enmity'}) end)
    total = total + 4

    ---========================================================================
    --- WEAPONSKILLS
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "Weaponskills (3):")

    test(function() M.send('COMBAT', 'ws_activated_ultimate', {job = 'WAR', ws_name = 'Upheaval', description = 'Dmg varies with TP', tp = '3000'}) end)
    test(function() M.send('COMBAT', 'ws_activated_enhanced', {job = 'DRK', ws_name = 'Torcleaver', description = 'Dmg varies with TP', tp = '2000'}) end)
    test(function() M.send('COMBAT', 'ws_activated_normal', {job = 'SAM', ws_name = 'Tachi: Fudo', description = 'Light/Fusion', tp = '1000'}) end)
    total = total + 3

    ---========================================================================
    --- SYSTEM MESSAGES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "System Messages (6):")

    test(function() M.success("Operation successful") end)
    test(function() M.warning("Low MP warning") end)
    test(function() M.error("Unable to perform action") end)
    test(function() M.info("Information message") end)
    test(function() M.toggle(); M.toggle() end)
    test(function() M.set_color_mode('normal') end)
    total = total + 6

    ---========================================================================
    --- ERROR HANDLING
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "Error Handling (2):")

    test(function()
        local ok = M.send('BLM', 'buff_cast', {job = 'BLM', buff = 'Haste'})
        return ok
    end)
    test(function()
        M.error("Namespace error test")
        return true
    end)
    total = total + 2

    return total
end

return TestSystem
