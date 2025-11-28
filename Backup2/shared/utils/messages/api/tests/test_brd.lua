---============================================================================
--- BRD Test Suite - Bard Complete Tests
---============================================================================
--- Tests all BRD job abilities and spells
---
--- @file tests/test_brd.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestBRD = {}

--- Run all BRD tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestBRD.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    ---========================================================================
    --- BRD JOB ABILITIES
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "BRD Job Abilities (7):")

    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BRD', ability_name = 'Clarion Call', description = '+1 song slot for party'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BRD', ability_name = 'Marcato', description = 'Next song effect x1.5'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BRD', ability_name = 'Nightingale', description = 'Song cast/recast -50%'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BRD', ability_name = 'Pianissimo', description = 'Next song affects single target'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BRD', ability_name = 'Soul Voice', description = 'Song effects x2'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BRD', ability_name = 'Tenuto', description = 'Next self song no overwrite (5 max)'}) end)
    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = 'BRD', ability_name = 'Troubadour', description = 'Song duration x2'}) end)
    total = total + 7


    ---========================================================================
    --- BRD ENHANCING MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "BRD Enhancing Magic (1):")

    test(function() M.send('MAGIC', 'enhancing_spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Refresh" .. gray_code, description = 'Gradually restores target'}) end)
    total = total + 1


    ---========================================================================
    --- BRD SONGS
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "BRD Songs (107):")

    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 16) .. "Advancing March" .. gray_code, description = 'Boosts attack speed.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Adventurer\'s Dirge" .. gray_code, description = 'Reduces enmity.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 16) .. "Archer\'s Prelude" .. gray_code, description = 'Boosts ranged accuracy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 2) .. "Aria of Passion" .. gray_code, description = 'Boosts physical dmg limit.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Army\'s Paeon" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Army\'s Paeon II" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Army\'s Paeon III" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Army\'s Paeon IV" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Army\'s Paeon V" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Army\'s Paeon VI" .. gray_code, description = 'Restores HP.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 37) .. "Battlefield Elegy" .. gray_code, description = 'Lowers attack speed.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Bewitching Etude" .. gray_code, description = 'Boosts charisma.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 16) .. "Blade Madrigal" .. gray_code, description = 'Boosts melee accuracy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 37) .. "Carnage Elegy" .. gray_code, description = 'Lowers attack speed.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 14) .. "Chocobo Mazurka" .. gray_code, description = 'Greatly boosts movement speed.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 14) .. "Chocobo Mazurka" .. gray_code, description = 'Raises movement speed.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Dark Carol" .. gray_code, description = 'Boosts dark resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Dark Carol II" .. gray_code, description = 'Boosts dark resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Dark Threnody" .. gray_code, description = 'Lowers resistance against Dark.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Dark Threnody II" .. gray_code, description = 'Lowers resistance against Dark.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 16) .. "Dextrous Etude" .. gray_code, description = 'Boosts dexterity.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 14) .. "Dragonfoe Mambo" .. gray_code, description = 'Boosts evasion.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 14) .. "Earth Carol" .. gray_code, description = 'Boosts earth resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 14) .. "Earth Carol II" .. gray_code, description = 'Boosts earth resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 14) .. "Earth Threnody" .. gray_code, description = 'Lowers resistance against Earth.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 14) .. "Earth Threnody II" .. gray_code, description = 'Lowers resistance against Earth.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Enchanting Etude" .. gray_code, description = 'Boosts charisma.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 219) .. "Fire Carol" .. gray_code, description = 'Boosts fire resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 219) .. "Fire Carol II" .. gray_code, description = 'Boosts fire resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 219) .. "Fire Threnody" .. gray_code, description = 'Lowers resistance against Fire.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 219) .. "Fire Threnody II" .. gray_code, description = 'Lowers resistance against Fire.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Foe Lullaby" .. gray_code, description = 'Puts an enemy to sleep.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Foe Lullaby II" .. gray_code, description = 'Puts an enemy to sleep.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Foe Requiem" .. gray_code, description = 'Deals damage.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Foe Requiem II" .. gray_code, description = 'Deals damage.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Foe Requiem III" .. gray_code, description = 'Deals damage.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Foe Requiem IV" .. gray_code, description = 'Deals damage.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Foe Requiem V" .. gray_code, description = 'Deals damage.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Foe Requiem VI" .. gray_code, description = 'Deals damage.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Foe Requiem VII" .. gray_code, description = 'Deals damage.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Foe Sirvente" .. gray_code, description = 'Reduces enmity loss.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Fowl Aubade" .. gray_code, description = 'Boosts sleep resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 2) .. "Goblin Gavotte" .. gray_code, description = 'Boosts bind resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Goddess\' Hymnus" .. gray_code, description = 'Grants reraise.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 14) .. "Gold Capriccio" .. gray_code, description = 'Boosts petrification resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 16) .. "Herb Pastoral" .. gray_code, description = 'Boosts poison resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 2) .. "Herculean Etude" .. gray_code, description = 'Boosts strength.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 16) .. "Honor March" .. gray_code, description = 'Boosts attack speed.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Horde Lullaby" .. gray_code, description = 'Puts enemies to sleep.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Horde Lullaby II" .. gray_code, description = 'Puts enemies to sleep.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 16) .. "Hunter\'s Prelude" .. gray_code, description = 'Boosts ranged accuracy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 2) .. "Ice Carol" .. gray_code, description = 'Boosts ice resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 2) .. "Ice Carol II" .. gray_code, description = 'Boosts ice resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 2) .. "Ice Threnody" .. gray_code, description = 'Lowers resistance against Ice.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 2) .. "Ice Threnody II" .. gray_code, description = 'Lowers resistance against Ice.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 37) .. "Knight\'s Minne" .. gray_code, description = 'Boosts defense.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 37) .. "Knight\'s Minne II" .. gray_code, description = 'Boosts defense.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 37) .. "Knight\'s Minne III" .. gray_code, description = 'Boosts defense.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 37) .. "Knight\'s Minne IV" .. gray_code, description = 'Boosts defense.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 37) .. "Knight\'s Minne V" .. gray_code, description = 'Boosts defense.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 210) .. "Learned Etude" .. gray_code, description = 'Boosts intelligence.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 200) .. "Light Carol" .. gray_code, description = 'Boosts light resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 200) .. "Light Carol II" .. gray_code, description = 'Boosts light resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 200) .. "Light Threnody" .. gray_code, description = 'Lowers resistance against Light.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 200) .. "Light Threnody II" .. gray_code, description = 'Lowers resistance against Light.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 37) .. "Lightning Carol" .. gray_code, description = 'Boosts lightning resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 37) .. "Lightning Carol II" .. gray_code, description = 'Boosts lightning resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 37) .. "Lightning Threnody" .. gray_code, description = 'Lowers resistance against Lightning.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 37) .. "Lightning Threnody II" .. gray_code, description = 'Lowers resistance against Lightning.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 219) .. "Logical Etude" .. gray_code, description = 'Boosts mind.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Mage\'s Ballad" .. gray_code, description = 'Restores MP.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Mage\'s Ballad II" .. gray_code, description = 'Restores MP.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Mage\'s Ballad III" .. gray_code, description = 'Restores MP.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Magic Finale" .. gray_code, description = 'Removes one beneficial magic effect from an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Maiden\'s Virelai" .. gray_code, description = 'Charms an enemy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 2) .. "Pining Nocturne" .. gray_code, description = 'Lowers magic accuracy, Raises cast time.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 210) .. "Puppet\'s Operetta" .. gray_code, description = 'Boosts silence resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 14) .. "Quick Etude" .. gray_code, description = 'Boosts agility.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 14) .. "Raptor Mazurka" .. gray_code, description = 'Boosts movement speed.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 14) .. "Raptor Mazurka" .. gray_code, description = 'Raises movement speed.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 210) .. "Sage Etude" .. gray_code, description = 'Boosts intelligence.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 210) .. "Scop\'s Operetta" .. gray_code, description = 'Boosts silence resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 37) .. "Sentinel\'s Scherzo" .. gray_code, description = 'Grants damage absorption.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 14) .. "Sheepfoe Mambo" .. gray_code, description = 'Boosts evasion.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Shining Fantasia" .. gray_code, description = 'Boosts blindness resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 2) .. "Sinewy Etude" .. gray_code, description = 'Boosts strength.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 219) .. "Spirited Etude" .. gray_code, description = 'Boosts mind.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 14) .. "Swift Etude" .. gray_code, description = 'Boosts agility.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 16) .. "Sword Madrigal" .. gray_code, description = 'Boosts melee accuracy.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 16) .. "Uncanny Etude" .. gray_code, description = 'Boosts dexterity.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 2) .. "Valor Minuet" .. gray_code, description = 'Boosts attack.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 2) .. "Valor Minuet II" .. gray_code, description = 'Boosts attack.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 2) .. "Valor Minuet III" .. gray_code, description = 'Boosts attack.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 2) .. "Valor Minuet IV" .. gray_code, description = 'Boosts attack.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 2) .. "Valor Minuet V" .. gray_code, description = 'Boosts attack.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 16) .. "Victory March" .. gray_code, description = 'Boosts attack speed.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 37) .. "Vital Etude" .. gray_code, description = 'Boosts vitality.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 37) .. "Vivacious Etude" .. gray_code, description = 'Boosts vitality.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 187) .. "Warding Round" .. gray_code, description = 'Boosts curse resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 16) .. "Water Carol" .. gray_code, description = 'Boosts water resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 16) .. "Water Carol II" .. gray_code, description = 'Boosts water resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 16) .. "Water Threnody" .. gray_code, description = 'Lowers resistance against Water.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 16) .. "Water Threnody II" .. gray_code, description = 'Lowers resistance against Water.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 210) .. "Wind Carol" .. gray_code, description = 'Boosts wind resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 210) .. "Wind Carol II" .. gray_code, description = 'Boosts wind resist.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 210) .. "Wind Threnody" .. gray_code, description = 'Lowers resistance against Wind.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'BRD', spell = string.char(0x1F, 210) .. "Wind Threnody II" .. gray_code, description = 'Lowers resistance against Wind.'}) end)
    total = total + 107

    return total
end

return TestBRD
