---============================================================================
--- COR Roll Data - Phantom Roll Game Data
---============================================================================
--- Complete database of all Corsair Phantom Rolls with game data:
--- - Roll values (1-11)
--- - Lucky/Unlucky numbers
--- - Effect descriptions
--- - Job-specific bonuses
--- - Bust effects
---
--- NOTE: This is GAME DATA (not user configuration)
--- These are fixed values from FFXI and should not be modified unless
--- game data changes (e.g., version update).
---
--- @file jobs/cor/functions/logic/roll_data.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-08
--- @date Updated: 2025-10-09 - Moved from config/ to logic/ (game data)
---
--- Database structure per roll:
---   values = {val1-11}      -- Bonus values for rolls 1-11
---   bust_effect = string    -- Effect when busting
---   effect_type = string    -- What the roll affects
---   lucky = number          -- Lucky number
---   unlucky = number        -- Unlucky number
---   phantom_roll_bonus = num -- +1 Phantom Roll gear bonus
---   job_bonus = {job, val}  -- Job-specific bonus (optional)
---============================================================================

local RollData = {}

---============================================================================
--- PHANTOM ROLL DATABASE
---============================================================================

RollData.rolls = {
    ["Fighter's Roll"] = {
        values = {2, 2, 3, 4, 12, 5, 6, 7, 1, 9, 18},
        bust_effect = '-4',
        effect_type = '% Double-Attack',
        lucky = 5,
        unlucky = 9,
        phantom_roll_bonus = 1,
        job_bonus = {'WAR', 5}
    },

    ["Monk's Roll"] = {
        values = {8, 10, 32, 12, 14, 15, 4, 20, 22, 24, 40},
        bust_effect = '-10',
        effect_type = ' Subtle Blow',
        lucky = 3,
        unlucky = 7,
        phantom_roll_bonus = 2,
        job_bonus = {'MNK', 10}
    },

    ["Healer's Roll"] = {
        values = {3, 4, 12, 5, 6, 7, 1, 8, 9, 10, 16},
        bust_effect = '-4',
        effect_type = '% Cure Potency Received',
        lucky = 3,
        unlucky = 7,
        phantom_roll_bonus = 1,
        job_bonus = {'WHM', 4}
    },

    ["Wizard's Roll"] = {
        values = {4, 6, 8, 10, 25, 12, 14, 17, 2, 20, 30},
        bust_effect = '-10',
        effect_type = ' MAB',
        lucky = 5,
        unlucky = 9,
        phantom_roll_bonus = 2,
        job_bonus = {'BLM', 5}
    },

    ["Warlock's Roll"] = {
        values = {2, 3, 4, 12, 5, 6, 7, 8, 1, 10, 14},
        bust_effect = '-5',
        effect_type = ' MACC',
        lucky = 4,
        unlucky = 9,
        phantom_roll_bonus = 1,
        job_bonus = {'RDM', 5}
    },

    ["Rogue's Roll"] = {
        values = {1, 1, 2, 3, 4, 5, 2, 6, 7, 8, 10},
        bust_effect = '-4',
        effect_type = '% Critical Hit Rate',
        lucky = 5,
        unlucky = 9,
        phantom_roll_bonus = 1,
        job_bonus = {'THF', 5}
    },

    ["Gallant's Roll"] = {
        values = {-2, -3, -4, 12, -5, -6, -7, -1, -10, -11, -15},
        bust_effect = '+8',
        effect_type = '% PDT',
        lucky = 4,
        unlucky = 8,
        phantom_roll_bonus = 1,
        job_bonus = {'PLD', 5}
    },

    ["Chaos Roll"] = {
        values = {4, 8, 12, 25, 16, 20, 24, 28, 6, 32, 40},
        bust_effect = '-20',
        effect_type = '% Attack',
        lucky = 4,
        unlucky = 9,
        phantom_roll_bonus = 4,
        job_bonus = {'DRK', 5}
    },

    ["Beast Roll"] = {
        values = {6, 8, 10, 25, 13, 16, 19, 22, 4, 26, 32},
        bust_effect = '-10',
        effect_type = '% Pet Attack',
        lucky = 4,
        unlucky = 9,
        phantom_roll_bonus = 3,
        job_bonus = {'BST', 5}
    },

    ["Choral Roll"] = {
        values = {8, 42, 11, 15, 19, 4, 23, 27, 31, 35, 50},
        bust_effect = '-25',
        effect_type = ' Spell Interruption Rate Down',
        lucky = 2,
        unlucky = 6,
        phantom_roll_bonus = 8,
        job_bonus = {'BRD', 5}
    },

    ["Hunter's Roll"] = {
        values = {10, 13, 15, 40, 18, 20, 25, 5, 28, 30, 50},
        bust_effect = '-15',
        effect_type = '% Accuracy',
        lucky = 4,
        unlucky = 9,
        phantom_roll_bonus = 5,
        job_bonus = {'RNG', 15}
    },

    ["Samurai Roll"] = {
        values = {3, 5, 7, 9, 11, 2, 13, 15, 17, 19, 24},
        bust_effect = '-10',
        effect_type = ' Store TP',
        lucky = 2,
        unlucky = 6,
        phantom_roll_bonus = 2,
        job_bonus = {'SAM', 5}
    },

    ["Ninja Roll"] = {
        values = {4, 5, 5, 14, 6, 7, 8, 9, 2, 10, 13},
        bust_effect = '-6',
        effect_type = '% Evasion',
        lucky = 4,
        unlucky = 8,
        phantom_roll_bonus = 1,
        job_bonus = {'NIN', 5}
    },

    ["Drachen Roll"] = {
        values = {10, 13, 15, 40, 18, 20, 25, 27, 5, 28, 50},
        bust_effect = '-15',
        effect_type = '% Pet Accuracy',
        lucky = 4,
        unlucky = 9,
        phantom_roll_bonus = 4,
        job_bonus = {'DRG', 5}
    },

    ["Evoker's Roll"] = {
        values = {1, 1, 1, 1, 3, 2, 2, 2, 1, 3, 4},
        bust_effect = '-1',
        effect_type = ' Refresh',
        lucky = 5,
        unlucky = 9,
        phantom_roll_bonus = 1,
        job_bonus = {'SMN', 1}
    },

    ["Magus's Roll"] = {
        values = {5, 20, 6, 8, 9, 3, 10, 13, 14, 15, 25},
        bust_effect = '-8',
        effect_type = ' MDB',
        lucky = 2,
        unlucky = 6,
        phantom_roll_bonus = 2,
        job_bonus = {'BLU', 8}
    },

    ["Corsair's Roll"] = {
        values = {10, 11, 11, 12, 20, 13, 15, 16, 8, 17, 24},
        bust_effect = '-6',
        effect_type = '% Exp / Limit / Capacity',
        lucky = 5,
        unlucky = 9,
        phantom_roll_bonus = 2,
        job_bonus = {'COR', 5}
    },

    ["Puppet Roll"] = {
        values = {5, 8, 11, 14, 3, 17, 20, 23, 26, 29, 35},
        bust_effect = '-8',
        effect_type = '% Pet MAB/MDB',
        lucky = 3,
        unlucky = 7,
        phantom_roll_bonus = 3,
        job_bonus = {'PUP', 5}
    },

    ["Dancer's Roll"] = {
        values = {3, 4, 12, 5, 6, 7, 1, 8, 9, 10, 16},
        bust_effect = '-4',
        effect_type = ' Regen',
        lucky = 3,
        unlucky = 7,
        phantom_roll_bonus = 1,
        job_bonus = {'DNC', 4}
    },

    ["Scholar's Roll"] = {
        values = {2, 3, 4, 5, 10, 6, 7, 1, 8, 9, 12},
        bust_effect = '-5',
        effect_type = ' Conserve MP',
        lucky = 2,
        unlucky = 6,
        phantom_roll_bonus = 1,
        job_bonus = {'SCH', 2}
    },

    ["Bolter's Roll"] = {
        values = {0.5, 1.9, 1.0, 1.5, 2.0, 2.5, 3.0, 0.4, 3.5, 4.0, 5.0},
        bust_effect = '-0.8',
        effect_type = '% Movement Speed',
        lucky = 3,
        unlucky = 9,
        phantom_roll_bonus = 0.5,
        job_bonus = nil -- No job bonus
    },

    ["Caster's Roll"] = {
        values = {6, 15, 7, 8, 9, 10, 5, 11, 12, 13, 20},
        bust_effect = '-10',
        effect_type = '% Fast Cast',
        lucky = 2,
        unlucky = 7,
        phantom_roll_bonus = 1,
        job_bonus = nil -- No job bonus
    },

    ["Courser's Roll"] = {
        values = {3, 4, 12, 5, 6, 7, 1, 8, 9, 10, 16},
        bust_effect = '-4',
        effect_type = ' Snapshot',
        lucky = 3,
        unlucky = 9,
        phantom_roll_bonus = 1,
        job_bonus = nil -- No job bonus
    },

    ["Blitzer's Roll"] = {
        values = {2, 3.5, 4, 5, 11, 6, 7, 1, 8.5, 10, 12},
        bust_effect = '-10',
        effect_type = '% Delay Reduction',
        lucky = 4,
        unlucky = 9,
        phantom_roll_bonus = 1,
        job_bonus = nil -- No job bonus
    },

    ["Tactician's Roll"] = {
        values = {5, 6, 7, 8, 9, 10, 3, 11, 12, 13, 20},
        bust_effect = '-10',
        effect_type = ' Regain',
        lucky = 5,
        unlucky = 8,
        phantom_roll_bonus = 1,
        job_bonus = nil -- No job bonus
    },

    ["Allies' Roll"] = {
        values = {5, 7, 9, 11, 23, 13, 15, 17, 3, 19, 29},
        bust_effect = '-12',
        effect_type = ' Skillchain Damage',
        lucky = 3,
        unlucky = 10,
        phantom_roll_bonus = 3,
        job_bonus = nil -- No job bonus
    },

    ["Miser's Roll"] = {
        values = {20, 30, 40, 50, 120, 60, 10, 70, 80, 90, 150},
        bust_effect = '-60',
        effect_type = ' Save TP',
        lucky = 5,
        unlucky = 7,
        phantom_roll_bonus = 20,
        job_bonus = nil -- No job bonus
    },

    ["Companion's Roll"] = {
        values = {2, 2, 3, 4, 8, 5, 6, 7, 1, 9, 10},
        bust_effect = '-4',
        effect_type = ' Pet Regain/Regen',
        lucky = 2,
        unlucky = 10,
        phantom_roll_bonus = 1,
        job_bonus = nil -- No job bonus
    },

    ["Avenger's Roll"] = {
        values = {4, 5, 6, 7, 15, 8, 2, 9, 10, 11, 20},
        bust_effect = '-8',
        effect_type = ' Counter Rate',
        lucky = 4,
        unlucky = 8,
        phantom_roll_bonus = 2,
        job_bonus = nil -- No job bonus
    },

    ["Naturalist's Roll"] = {
        values = {6, 7, 8, 9, 10, 11, 4, 12, 13, 14, 20},
        bust_effect = '-5',
        effect_type = ' Enh. Magic Duration',
        lucky = 3,
        unlucky = 7,
        phantom_roll_bonus = 1,
        job_bonus = nil -- No job bonus
    },

    ["Runeist's Roll"] = {
        values = {4, 6, 8, 10, 25, 12, 14, 17, 2, 20, 30},
        bust_effect = '-10',
        effect_type = ' Magic Evasion',
        lucky = 4,
        unlucky = 8,
        phantom_roll_bonus = 2,
        job_bonus = {'RUN', 5}
    },
}

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get roll data by name
--- @param roll_name string Name of the roll
--- @return table|nil Roll data or nil if not found
function RollData.get_roll(roll_name)
    return RollData.rolls[roll_name]
end

--- Get all roll names (for state options)
--- @return table Array of roll names
function RollData.get_roll_names()
    local names = {}
    for roll_name, _ in pairs(RollData.rolls) do
        table.insert(names, roll_name)
    end
    table.sort(names)
    return names
end

--- Calculate final bonus value including job bonus and gear bonus
--- @param roll_name string Name of the roll
--- @param roll_value number Roll value (1-11)
--- @param player_job string Current main job
--- @param phantom_roll_bonus number Total +Phantom Roll from gear
--- @param has_job_bonus boolean|nil Whether job bonus should be applied (auto-detected from party)
--- @return number Final bonus value
function RollData.calculate_bonus(roll_name, roll_value, player_job, phantom_roll_bonus, has_job_bonus)
    local roll_data = RollData.get_roll(roll_name)
    if not roll_data then
        return 0
    end

    -- Base value from roll
    local base_value = roll_data.values[roll_value] or 0

    -- Add job bonus if applicable
    -- has_job_bonus is explicitly passed (true/false) from roll_tracker after party check
    if roll_data.job_bonus and has_job_bonus then
        base_value = base_value + roll_data.job_bonus[2]
    end

    -- Add +Phantom Roll gear bonus
    local gear_bonus = (phantom_roll_bonus or 0) * (roll_data.phantom_roll_bonus or 0)
    base_value = base_value + gear_bonus

    return base_value
end

--- Check if roll value is lucky
--- @param roll_name string Name of the roll
--- @param roll_value number Roll value (1-11)
--- @return boolean True if lucky
function RollData.is_lucky(roll_name, roll_value)
    local roll_data = RollData.get_roll(roll_name)
    if not roll_data then
        return false
    end
    return roll_value == roll_data.lucky
end

--- Check if roll value is unlucky
--- @param roll_name string Name of the roll
--- @param roll_value number Roll value (1-11)
--- @return boolean True if unlucky
function RollData.is_unlucky(roll_name, roll_value)
    local roll_data = RollData.get_roll(roll_name)
    if not roll_data then
        return false
    end
    return roll_value == roll_data.unlucky
end

--- Calculate bust rate for NEXT Double-Up given current roll number
--- Formula: Number of bust faces / 6 * 100
--- Roll 6: 6+6=12 >> 1/6 faces bust = 16.7%
--- Roll 7: 7+5=12, 7+6=13 >> 2/6 faces bust = 33.3%
--- Roll 11: 11+1=12, ..., 11+6=17 >> 6/6 faces bust = 100%
--- @param roll_number number Current roll number (1-11)
--- @return number Bust rate percentage (0-100)
function RollData.calculate_bust_rate(roll_number)
    if roll_number <= 5 then
        return 0  -- Roll 1-5: impossible to bust (max is 5+6=11)
    end
    -- Exact calculation: (faces that bust) / 6 * 100
    return (roll_number - 5) / 6 * 100
end

return RollData
