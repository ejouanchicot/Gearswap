# Message System - Job Test Suites

Modular job-based test system for the new message framework.

## Usage

```lua
//gs c testmsg           -- Run ALL test suites (300+ tests)
//gs c testmsg brd       -- Run BRD tests only
//gs c testmsg geo       -- Run GEO tests only
//gs c testmsg system    -- Run system tests only
```

## Available Test Suites

### General System Tests
- **SYSTEM** (37 tests) - Magic types, JA, WS, system messages
  - Elemental Magic (6)
  - Enhancing Magic (3)
  - Enfeebling Magic (3)
  - Divine Magic (2)
  - Healing Magic (4)
  - Dark Magic (3)
  - Blue Magic (3)
  - Job Abilities (4)
  - Weaponskills (3)
  - System Messages (6)
  - Error Handling (2)

### Job-Specific Tests

#### Support Jobs
- **BRD** (24 tests) - Bard abilities and songs
  - Job Abilities (6): Soul Voice, Nightingale, Troubadour, Marcato, Pianissimo, Tenuto
  - Buff Songs (12): Minuet, March, Madrigal, Mambo, Etude, Carol
  - Debuff Songs (6): Threnody, Lullaby, Elegy, Requiem

- **GEO** (28 tests) - Geomancer spells and abilities
  - Job Abilities (6): Bolster, Life Cycle, Blaze of Glory, etc.
  - Indi Spells (8): Fire, Ice, Wind, Light elements
  - Geo Spells (8): Fire, Ice, Wind, Light elements
  - Elemental -ra (6): AOE nukes

- **COR** (33 tests) - Corsair rolls and abilities
  - Job Abilities (8): Quick Draw, Random Deal, Wild Card, etc.
  - Attack/Accuracy Rolls (6): Chaos, Samurai, Hunter's, etc.
  - Magic Rolls (4): Wizard's, Warlock's, Scholar's, Evoker's
  - Defense/Support Rolls (5): Monk's, Bolter's, Tactician's, etc.
  - Ranged WS (6): Leaden Salute, Wildfire, Last Stand
  - Sword WS (4): Savage Blade, Requiescat, etc.

#### Mage Jobs
- **BLM** (28 tests) - Black Mage nukes and abilities
  - Job Abilities (8): Manafont, Manawall, Elemental Seal, etc.
  - Tier 6 Nukes (6): Fire VI, Blizzard VI, etc.
  - Tier 5 Nukes (6): Fire V, Blizzard V, etc.
  - Ancient Magic (4): Flare, Freeze, Burst, Quake
  - Enfeebling (4): Burn, Frost, Choke, Shock

- **WHM** (35 tests) - White Mage healing and support
  - Job Abilities (6): Benediction, Divine Seal, Afflatus, etc.
  - Cure Spells (6): Cure VI, V, IV, Curaga
  - Regen/Recovery (6): Regen, Raise, Erase, Esuna, Cursna
  - Protection (4): Protect, Shell, Protectra, Shellra
  - Buffs (5): Haste, Auspice, Boost-STR, Aquaveil, Stoneskin
  - Divine Magic (4): Banish, Banishga, Holy

#### Melee Jobs
- **WAR** (23 tests) - Warrior abilities and weaponskills
  - Job Abilities (10): Berserk, Defender, Warcry, etc.
  - Great Axe WS (6): Upheaval, Ukko's Fury, etc.
  - Great Sword WS (4): Resolution, Scourge, etc.
  - Polearm WS (3): Stardiver, Impulse Drive, etc.

- **PLD** (30 tests) - Paladin tanking and support
  - Job Abilities (10): Sentinel, Cover, Rampart, Invincible, etc.
  - Healing Spells (4): Cure, Flash, Raise
  - Enhancing (6): Protect, Shell, Enlight, Crusade, etc.
  - Divine Magic (4): Banish, Holy
  - Sword WS (6): Atonement, Savage Blade, Chant du Cygne

- **DRK** (38 tests) - Dark Knight dark magic and melee
  - Job Abilities (10): Last Resort, Souleater, Blood Weapon, etc.
  - Drain/Aspir (6): Drain III, Aspir III, Endark, etc.
  - Absorb Spells (8): STR, DEX, VIT, AGI, INT, MND, CHR, TP
  - Enfeebling (4): Bio III, Poison II, Blind II, Sleep II
  - Great Sword WS (6): Torcleaver, Resolution, etc.
  - Scythe WS (4): Catastrophe, Entropy, etc.

- **SAM** (22 tests) - Samurai melee combat
  - Job Abilities (10): Hasso, Seigan, Third Eye, Meditate, etc.
  - Great Katana WS (8): Tachi: Fudo, Shoha, Rana, etc.
  - Polearm WS (4): Stardiver, Impulse Drive, etc.

- **THF** (22 tests) - Thief abilities and daggers
  - Job Abilities (10): Steal, Sneak Attack, Trick Attack, etc.
  - Dagger WS (8): Rudra's Storm, Evisceration, etc.
  - Sword WS (4): Savage Blade, Chant du Cygne, etc.

- **DNC** (43 tests) - Dancer support and melee
  - Job Abilities (8): Saber Dance, Fan Dance, Sambas, etc.
  - Steps (5): Box, Quickstep, Stutter, Feather
  - Flourishes (6): Violent, Desperate, Climactic, etc.
  - Healing Waltzes (5): Curing Waltz V-III, Divine Waltz
  - Status Waltzes (3): Healing Waltz, etc.
  - Dagger WS (8): Rudra's Storm, Pyrrhic Kleos, etc.

## Test Coverage Summary

**Total Test Suites**: 12 (1 system + 11 jobs)
**Total Tests**: ~300+

### By Category:
- **Support Jobs**: BRD (24), GEO (28), COR (33) = 85 tests
- **Mage Jobs**: BLM (28), WHM (35) = 63 tests
- **Melee Jobs**: WAR (23), PLD (30), DRK (38), SAM (22), THF (22), DNC (43) = 178 tests
- **System**: 37 tests

## Architecture

Each test file follows this structure:

```lua
local M = require('shared/utils/messages/api/messages')
local TestJOB = {}

function TestJOB.run(test)
    local total = 0

    -- Section: Job Abilities
    test(function() M.send(...) end)
    total = total + 1

    -- Section: Spells/Weaponskills
    test(function() M.send(...) end)
    total = total + 1

    return total
end

return TestJOB
```

## Adding New Jobs

1. Create `test_[job].lua` in this directory
2. Follow the template structure above
3. Add job to the list in `messages.lua:394-407`
4. Update this README

## Color Coding

Tests verify proper color usage:
- **Weaponskills**: Pink (code 011) with `{gray}[...]` brackets
- **Job Abilities**: Yellow (code 050) with `{gray}[...]` brackets
- **Healing Magic**: Green (code 006)
- **Enhancing Magic**: Code 206
- **Enfeebling Magic**: Code 004
- **Divine Magic**: Code 022
- **Dark Magic**: Code 015
- **Blue Magic**: Code 219
- **Elemental Spells**: Element-specific colors from database
- **BRD Songs**: Element colors (Fire=002, Ice=030, Thunder=016, etc.)
- **GEO Spells**: Element colors from database

## Notes

- All delimiters `[]`, `()`, `{}` use gray color (code 160)
- Element colors are fetched from spell databases
- Tests are silent (errors suppressed during testing)
- Each test returns pass/fail status
- Final report shows total passed/failed count
