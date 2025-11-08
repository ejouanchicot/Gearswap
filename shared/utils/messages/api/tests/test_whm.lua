---============================================================================
--- WHM Test Suite - White Mage Complete Tests
---============================================================================
--- Tests all WHM job abilities and spells
---
--- @file tests/test_whm.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestWHM = {}

--- Run all WHM tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestWHM.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- WHM JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "WHM Job Abilities (9):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WHM', ability_name = 'Afflatus Misery', description = 'Damage taken dans la  Banish/Cura/Esuna boost'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WHM', ability_name = 'Afflatus Solace', description = 'Cure >> Stoneskin (25% of heal)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WHM', ability_name = 'Asylum', description = 'Party debuff/dispel immunity'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WHM', ability_name = 'Benediction', description = 'Restore party HP, remove status'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WHM', ability_name = 'Devotion', description = 'Sacrifice 25% HP >> ally MP'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WHM', ability_name = 'Divine Caress', description = 'Next status removal >> immunity'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WHM', ability_name = 'Divine Seal', description = 'Next cure x2 potency'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WHM', ability_name = 'Martyr', description = 'Sacrifice 25% HP >> heal ally 50%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'WHM', ability_name = 'Sacrosanctity', description = 'Party magic damage -75%'}) end)
    total = total + 9


    ---========================================================================
    --- WHM DIVINE MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "WHM Divine Magic (10):")

    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'WHM', spell = string.char(0x1F, 187) .. "Banish" .. gray_code, description = 'Deals light dmg (vs undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'WHM', spell = string.char(0x1F, 187) .. "Banish II" .. gray_code, description = 'Deals light dmg (vs undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'WHM', spell = string.char(0x1F, 187) .. "Banish III" .. gray_code, description = 'Deals light dmg (vs undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'WHM', spell = string.char(0x1F, 187) .. "Banish IV" .. gray_code, description = 'Deals light dmg (vs undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'WHM', spell = string.char(0x1F, 187) .. "Banishga" .. gray_code, description = 'Deals light dmg (vs undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'WHM', spell = string.char(0x1F, 187) .. "Banishga II" .. gray_code, description = 'Deals light dmg (vs undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'WHM', spell = string.char(0x1F, 187) .. "Flash" .. gray_code, description = 'Blinds target; Acc-; high enmity.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'WHM', spell = string.char(0x1F, 187) .. "Holy" .. gray_code, description = 'Deals light dmg (vs undead).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'WHM', spell = string.char(0x1F, 187) .. "Holy II" .. gray_code, description = 'Deals light dmg; Solace: potency+ from HP healed.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'divine_spell_activated_full_target', {job = 'WHM', spell = string.char(0x1F, 187) .. "Repose" .. gray_code, description = 'Puts target to sleep.', target = '<t>'}) end)
    total = total + 10


    ---========================================================================
    --- WHM ELEMENTAL MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "WHM Elemental Magic (1):")

    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 200) .. "Impact" .. gray_code, description = 'Deals dark dmg (DoT), lowers all stats.'}) end)
    total = total + 1


    ---========================================================================
    --- WHM ENFEEBLING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "WHM Enfeebling Magic (7):")

    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'WHM', spell = string.char(0x1F, 2) .. "Addle" .. gray_code, description = 'Lowers m.acc, raises cast time.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'WHM', spell = string.char(0x1F, 187) .. "Dia" .. gray_code, description = 'Light DoT + def down.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'WHM', spell = string.char(0x1F, 187) .. "Dia II" .. gray_code, description = 'Light DoT + def down.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'WHM', spell = string.char(0x1F, 187) .. "Diaga" .. gray_code, description = 'Light DoT (AOE).', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'WHM', spell = string.char(0x1F, 210) .. "Paralyze" .. gray_code, description = 'Inflicts paralysis.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'WHM', spell = string.char(0x1F, 14) .. "Silence" .. gray_code, description = 'Prevents spellcasting.', target = '<t>'}) end)
    test(function() M.send('MAGIC', 'enfeebling_spell_activated_full_target', {job = 'WHM', spell = string.char(0x1F, 37) .. "Slow" .. gray_code, description = 'Slows attacks.', target = '<t>'}) end)
    total = total + 7


    ---========================================================================
    --- WHM ENHANCING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "WHM Enhancing Magic (63):")

    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 219) .. "Aquaveil" .. gray_code, description = 'Reduces the chance of spell interruption.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Auspice" .. gray_code, description = '+Accuracy, add Light dmg to melee hits'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 210) .. "Baraera" .. gray_code, description = 'Party AoE: Wind resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 219) .. "Baramnesra" .. gray_code, description = 'Party AoE: Amnesia resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Barblindra" .. gray_code, description = 'Party AoE: Blind resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 2) .. "Barblizzara" .. gray_code, description = 'Party AoE: Ice resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 219) .. "Barfira" .. gray_code, description = 'Party AoE: Fire resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 2) .. "Barparalyzra" .. gray_code, description = 'Party AoE: Paralysis resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 14) .. "Barpetra" .. gray_code, description = 'Party AoE: Petrification resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 16) .. "Barpoisonra" .. gray_code, description = 'Party AoE: Poison resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 210) .. "Barsilencera" .. gray_code, description = 'Party AoE: Silence resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Barsleepra" .. gray_code, description = 'Party AoE: Sleep resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 14) .. "Barstonra" .. gray_code, description = 'Party AoE: Earth resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 37) .. "Barthundra" .. gray_code, description = 'Party AoE: Lightning resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 219) .. "Barvira" .. gray_code, description = 'Party AoE: Disease resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 16) .. "Barwatera" .. gray_code, description = 'Party AoE: Water resistance'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 14) .. "Blink" .. gray_code, description = 'Creates shadow copies that each absorb one physical attack.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 14) .. "Boost-AGI" .. gray_code, description = 'Increases Agility for party members within area of effect.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Boost-CHR" .. gray_code, description = 'Increases Charisma for party members within area of effect.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 16) .. "Boost-DEX" .. gray_code, description = 'Increases Dexterity for party members within area of effect.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 210) .. "Boost-INT" .. gray_code, description = 'Party AoE: +Intelligence'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 219) .. "Boost-MND" .. gray_code, description = 'Increases Mind for party members within area of effect.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 2) .. "Boost-STR" .. gray_code, description = 'Increases Strength for party members within area of effect.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 37) .. "Boost-VIT" .. gray_code, description = 'Increases Vitality for party members within area of effect.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 14) .. "Deodorize" .. gray_code, description = 'Reduces chance of being detected by scent-tracking monsters.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Erase" .. gray_code, description = 'Removes one detrimental status effect from target.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 14) .. "Haste" .. gray_code, description = 'Increases attack speed.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 14) .. "Invisible" .. gray_code, description = 'Reduces chance of being detected by sight-tracking monsters.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Protect" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Protect II" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Protect III" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Protect IV" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Protect V" .. gray_code, description = 'Increases defense.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Protectra" .. gray_code, description = 'Increases defense for party members within area of effect.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Protectra II" .. gray_code, description = 'Increases defense for party members within area of effect.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Protectra III" .. gray_code, description = 'Increases defense for party members within area of effect.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Protectra IV" .. gray_code, description = 'Increases defense for party members within area of effect.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Protectra V" .. gray_code, description = 'Increases defense for party members within area of effect.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Recall-Jugner" .. gray_code, description = 'Warp party to Jugner [S] HP'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Recall-Meriph" .. gray_code, description = 'Warp party to Meriphataud HP'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Recall-Pashh" .. gray_code, description = 'Warp party to Pashhow HP'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Regen" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Regen II" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Regen III" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Regen IV" .. gray_code, description = 'Gradually restores target'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Shell" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Shell II" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Shell III" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Shell IV" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Shell V" .. gray_code, description = 'Reduces magic damage taken.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Shellra" .. gray_code, description = 'Party AoE: Reduce magic damage taken'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Shellra II" .. gray_code, description = 'Party AoE: Reduce magic damage taken'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Shellra III" .. gray_code, description = 'Party AoE: Reduce magic damage taken'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Shellra IV" .. gray_code, description = 'Party AoE: Reduce magic damage taken'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Shellra V" .. gray_code, description = 'Party AoE: Reduce magic damage taken'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 14) .. "Sneak" .. gray_code, description = 'Reduces chance of being detected by sound-tracking monsters.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 37) .. "Stoneskin" .. gray_code, description = 'Absorbs damage from physical and magical attacks.'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Teleport-Altep" .. gray_code, description = 'Warp party to Crag of Holla'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Teleport-Dem" .. gray_code, description = 'Warp party to Crag of Dem'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Teleport-Holla" .. gray_code, description = 'Warp party to Crag of Holla'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Teleport-Mea" .. gray_code, description = 'Warp party to Crag of Mea'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Teleport-Vahzl" .. gray_code, description = 'Warp party to Crag of Vahzl'}) end)
    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Teleport-Yhoat" .. gray_code, description = 'Warp party to Crag of Yhoat'}) end)
    total = total + 63


    ---========================================================================
    --- WHM HEALING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "WHM Healing Magic (32):")

    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Arise" .. gray_code, description = 'Revives from KO, bestows a Reraise effect.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Blindna" .. gray_code, description = 'Removes blindness.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Cura" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Cura II" .. gray_code, description = 'AoE heal, Afflatus Misery: +potency'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Cura III" .. gray_code, description = 'AoE heal, Afflatus Misery: +potency'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Curaga" .. gray_code, description = 'Restores HP of all party members.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Curaga II" .. gray_code, description = 'Restores HP of all party members.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Curaga III" .. gray_code, description = 'Restores HP of all party members.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Curaga IV" .. gray_code, description = 'Restores HP of all party members.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Curaga V" .. gray_code, description = 'Restores HP of all party members.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Cure" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Cure II" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Cure III" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Cure IV" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Cure V" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Cure VI" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Cursna" .. gray_code, description = 'Removes curse or doom.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Esuna" .. gray_code, description = 'Removes ailments (AOE).'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Full Cure" .. gray_code, description = 'Full heal, cure ailments, costs all MP'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Paralyna" .. gray_code, description = 'Removes paralysis.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Poisona" .. gray_code, description = 'Removes poison.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Raise" .. gray_code, description = 'Revives from KO.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Raise II" .. gray_code, description = 'Revives from KO.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Raise III" .. gray_code, description = 'Revives from KO.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Reraise" .. gray_code, description = 'Grants you the effect of Raise when you are KO'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Reraise II" .. gray_code, description = 'Grants you the effect of Raise II when you are KO'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Reraise III" .. gray_code, description = 'Grants you the effect of Raise III when you are KO'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Reraise IV" .. gray_code, description = 'Auto-raise on death, less weakness'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Sacrifice" .. gray_code, description = 'Transfers ailment to self.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Silena" .. gray_code, description = 'Removes silence.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Stona" .. gray_code, description = 'Removes petrification.'}) end)
    test(function() M.send('MAGIC', 'healing_spell_activated_full', {job = 'WHM', spell = string.char(0x1F, 187) .. "Viruna" .. gray_code, description = 'Removes disease.'}) end)
    total = total + 32

    return total
end

return TestWHM
