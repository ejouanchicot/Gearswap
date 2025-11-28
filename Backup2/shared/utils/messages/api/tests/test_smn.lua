---============================================================================
--- SMN Test Suite - Summoner Complete Tests
---============================================================================
--- Tests all SMN job abilities and spells
---
--- @file tests/test_smn.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestSMN = {}

--- Run all SMN tests
--- @param test function Test runner function
--- @return number total_tests Total number of tests
function TestSMN.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0


    ---========================================================================
    --- SMN ELEMENTAL MAGIC
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "SMN Elemental Magic (1):")

    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Impact" .. gray_code, description = 'Deals dark dmg (DoT), lowers all stats.'}) end)
    total = total + 1


    ---========================================================================
    --- SMN INTERNAL
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "SMN Internal (143):")

    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Aerial Armor" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Aerial Blast" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Aero II" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Aero IV" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Air Spirit" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Alexander" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Altana\'s Favor" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Atomos" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 210) .. "Axe Kick" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 219) .. "Barracuda Dive" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Bitter Elegy" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Blindside" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 210) .. "Blizzard II" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 210) .. "Blizzard IV" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 2) .. "Burning Strike" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Cait Sith" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Camisado" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Carbuncle" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 16) .. "Chaotic Strike" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Chinook" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Chronoshift" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Clarsach Call" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Claw" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 2) .. "Conflag Strike" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 37) .. "Crag Throw" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Crescent Fang" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 2) .. "Crimson Howl" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 210) .. "Crystal Blessing" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Dark Spirit" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Deconstruction" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Diabolos" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 210) .. "Diamond Dust" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 210) .. "Diamond Storm" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 2) .. "Double Punch" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 210) .. "Double Slap" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Dream Shroud" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 37) .. "Earth Spirit" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 37) .. "Earthen Armor" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 37) .. "Earthen Fury" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 37) .. "Earthen Ward" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Eclipse Bite" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Ecliptic Growl" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Ecliptic Howl" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Eerie Eye" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Fenrir" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 2) .. "Fire II" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 2) .. "Fire IV" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 2) .. "Fire Spirit" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 2) .. "Flaming Crush" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Fleet Wind" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 210) .. "Frost Armor" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Garuda" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 37) .. "Geocrush" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Glittering Ruby" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 219) .. "Grand Fall" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Hastega" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Hastega II" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Healing Ruby" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Healing Ruby II" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 210) .. "Heavenly Strike" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Heavenward Howl" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Holy Mist" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Howling Moon" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Hysteric Assault" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 210) .. "Ice Spirit" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 2) .. "Ifrit" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Impact" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 2) .. "Inferno" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 2) .. "Inferno Howl" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 16) .. "Judgment Bolt" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Katabatic Blades" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Level ? Holy" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 219) .. "Leviathan" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Light Spirit" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 16) .. "Lightning Armor" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Lunar Bay" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Lunar Cry" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Lunar Roar" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Lunatic Voice" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 37) .. "Megalith Throw" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 2) .. "Meteor Strike" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Meteorite" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Mewing Lullaby" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Moonlit Charge" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 37) .. "Mountain Buster" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Nether Blast" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Night Terror" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Nightmare" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Noctoshield" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Odin" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Pacifying Ruby" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Pavor Nocturnus" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Perfect Defense" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Poison Nails" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Predator Claws" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 2) .. "Punch" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Raise II" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 16) .. "Ramuh" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Regal Gash" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Regal Scratch" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Reraise II" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 37) .. "Rock Buster" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 37) .. "Rock Throw" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 16) .. "Rolling Thunder" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Roundhouse" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Ruinous Omen" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 210) .. "Rush" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Searing Light" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Shining Ruby" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 210) .. "Shiva" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 16) .. "Shock Squall" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 16) .. "Shock Strike" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Siren" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 210) .. "Sleepga" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 219) .. "Slowga" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Somnolence" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Sonic Buffet" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 219) .. "Soothing Current" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Soothing Ruby" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 219) .. "Spinning Dive" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 219) .. "Spring Water" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 37) .. "Stone II" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 37) .. "Stone IV" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 219) .. "Tail Whip" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 16) .. "Thunder II" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 16) .. "Thunder IV" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 16) .. "Thunder Spirit" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 16) .. "Thunderspark" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 16) .. "Thunderstorm" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 219) .. "Tidal Roar" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 219) .. "Tidal Wave" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 37) .. "Titan" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Tornado II" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Ultimate Terror" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 16) .. "Volt Strike" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 219) .. "Water II" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 219) .. "Water IV" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 219) .. "Water Spirit" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Welt" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Whispering Wind" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Wind Blade" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Wind\'s Blessing" .. gray_code, description = 'Unknown effect'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Zantetsuken" .. gray_code, description = 'Unknown effect'}) end)
    total = total + 143


    ---========================================================================
    --- SMN SUMMONING
    ---========================================================================

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "SMN Summoning (19):")

    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Air Spirit" .. gray_code, description = 'Summons Air Spirit.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Cait Sith" .. gray_code, description = 'Summons Cait Sith.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Carbuncle" .. gray_code, description = 'Summons Carbuncle.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Dark Spirit" .. gray_code, description = 'Summons Dark Spirit.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Diabolos" .. gray_code, description = 'Summons Diabolos.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 37) .. "Earth Spirit" .. gray_code, description = 'Summons Earth Spirit.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 200) .. "Fenrir" .. gray_code, description = 'Summons Fenrir.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 2) .. "Fire Spirit" .. gray_code, description = 'Summons Fire Spirit.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Garuda" .. gray_code, description = 'Summons Garuda.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 210) .. "Ice Spirit" .. gray_code, description = 'Summons Ice Spirit.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 2) .. "Ifrit" .. gray_code, description = 'Summons Ifrit.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 219) .. "Leviathan" .. gray_code, description = 'Summons Leviathan.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 187) .. "Light Spirit" .. gray_code, description = 'Summons Light Spirit.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 16) .. "Ramuh" .. gray_code, description = 'Summons Ramuh.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 210) .. "Shiva" .. gray_code, description = 'Summons Shiva.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 14) .. "Siren" .. gray_code, description = 'Summons Siren.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 16) .. "Thunder Spirit" .. gray_code, description = 'Summons Thunder Spirit.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 37) .. "Titan" .. gray_code, description = 'Summons Titan.'}) end)
    test(function() M.send('MAGIC', 'spell_activated_full', {job = 'SMN', spell = string.char(0x1F, 219) .. "Water Spirit" .. gray_code, description = 'Summons Water Spirit.'}) end)
    total = total + 19

    return total
end

return TestSMN
