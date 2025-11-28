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
        values = {1, 2, 3, 4, 10, 5, 6, 6, 1, 7, 15},
        bust_effect = '0',
        effect_type = '% Double Attack',
        lucky = 5,
        unlucky = 9,
        phantom_roll_bonus = 1,
        job_bonus = {'WAR', 5}
    },

    ["Monk's Roll"] = {
        values = {8, 10, 32, 12, 14, 16, 4, 20, 22, 24, 40},
        bust_effect = '-10',
        effect_type = ' Subtle Blow',
        lucky = 3,
        unlucky = 7,
        phantom_roll_bonus = 4,
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
        effect_type = ' Magic Attack',
        lucky = 5,
        unlucky = 9,
        phantom_roll_bonus = 2,
        job_bonus = {'BLM', 10}
    },

    ["Warlock's Roll"] = {
        values = {10, 13, 15, 40, 18, 20, 25, 5, 28, 30, 50},
        bust_effect = '-15',
        effect_type = ' Magic Accuracy',
        lucky = 4,
        unlucky = 8,
        phantom_roll_bonus = 5,
        job_bonus = {'RDM', 15}
    },

    ["Rogue's Roll"] = {
        values = {1, 2, 3, 4, 10, 5, 6, 7, 1, 8, 14},
        bust_effect = '-5',
        effect_type = '% Critical Hit Rate',
        lucky = 5,
        unlucky = 9,
        phantom_roll_bonus = 1,
        job_bonus = {'THF', 5}
    },

    ["Gallant's Roll"] = {
        values = {4.69, 5.86, 19.53, 7.03, 8.59, 10.16, 3.13, 11.72, 13.67, 15.63, 23.44},
        bust_effect = '-11.72',
        effect_type = '% Defense',
        lucky = 3,
        unlucky = 7,
        phantom_roll_bonus = 2.34,
        job_bonus = {'PLD', 11.72}
    },

    ["Chaos Roll"] = {
        values = {6.25, 7.81, 9.37, 25, 10.93, 12.5, 15.62, 3.12, 17.18, 18.75, 31.25},
        bust_effect = '-9.76',
        effect_type = '% Attack',
        lucky = 4,
        unlucky = 8,
        phantom_roll_bonus = 3.12,
        job_bonus = {'DRK', 9.76}
    },

    ["Beast Roll"] = {
        values = {6.25, 7.81, 9.37, 25, 10.93, 12.5, 15.62, 3.12, 17.18, 18.75, 31.25},
        bust_effect = '0',
        effect_type = '% Pet Attack',
        lucky = 4,
        unlucky = 8,
        phantom_roll_bonus = 3.12,
        job_bonus = {'BST', 9.76}
    },

    ["Choral Roll"] = {
        values = {-8, -42, -11, -15, -19, -4, -23, -27, -31, -35, -50},
        bust_effect = '+25',
        effect_type = ' Spell Interruption Rate',
        lucky = 2,
        unlucky = 6,
        phantom_roll_bonus = -4,
        job_bonus = {'BRD', -25}
    },

    ["Hunter's Roll"] = {
        values = {10, 13, 15, 40, 18, 20, 25, 5, 28, 30, 50},
        bust_effect = '-15',
        effect_type = ' Accuracy',
        lucky = 4,
        unlucky = 8,
        phantom_roll_bonus = 5,
        job_bonus = {'RNG', 15}
    },

    ["Samurai Roll"] = {
        values = {8, 32, 10, 12, 14, 4, 16, 20, 22, 24, 40},
        bust_effect = '-10',
        effect_type = ' Store TP',
        lucky = 2,
        unlucky = 6,
        phantom_roll_bonus = 4,
        job_bonus = {'SAM', 10}
    },

    ["Ninja Roll"] = {
        values = {10, 13, 15, 40, 18, 20, 25, 5, 28, 30, 50},
        bust_effect = '-15',
        effect_type = ' Evasion',
        lucky = 4,
        unlucky = 8,
        phantom_roll_bonus = 5,
        job_bonus = {'NIN', 15}
    },

    ["Drachen Roll"] = {
        values = {10, 13, 15, 40, 18, 20, 25, 5, 28, 30, 50},
        bust_effect = '0',
        effect_type = ' Pet Accuracy',
        lucky = 4,
        unlucky = 8,
        phantom_roll_bonus = 5,
        job_bonus = {'DRG', 15}
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
        values = {5, 8, 35, 11, 14, 18, 2, 22, 26, 30, 40},
        bust_effect = '-12',
        effect_type = ' Pet Magic Acc./Atk.',
        lucky = 3,
        unlucky = 7,
        phantom_roll_bonus = 3,
        job_bonus = {'PUP', 12}
    },

    ["Dancer's Roll"] = {
        values = {3, 4, 12, 5, 6, 7, 1, 8, 9, 10, 16},
        bust_effect = '-4',
        effect_type = ' Regen',
        lucky = 3,
        unlucky = 7,
        phantom_roll_bonus = 2,
        job_bonus = {'DNC', 4}
    },

    ["Scholar's Roll"] = {
        values = {2, 10, 3, 4, 4, 1, 5, 6, 7, 7, 12},
        bust_effect = '-3',
        effect_type = '% Conserve MP',
        lucky = 2,
        unlucky = 6,
        phantom_roll_bonus = 1,
        job_bonus = {'SCH', 3}
    },

    ["Bolter's Roll"] = {
        values = {6, 6, 16, 8, 8, 10, 10, 12, 4, 14, 20},
        bust_effect = '0',
        effect_type = '% Movement Speed',
        lucky = 3,
        unlucky = 9,
        phantom_roll_bonus = 4,
        job_bonus = nil -- No job bonus
    },

    ["Caster's Roll"] = {
        values = {6, 15, 7, 8, 9, 10, 5, 11, 12, 13, 20},
        bust_effect = '-10',
        effect_type = '% Fast Cast',
        lucky = 2,
        unlucky = 7,
        phantom_roll_bonus = 3,
        job_bonus = nil -- No job bonus
    },

    ["Courser's Roll"] = {
        values = {2, 3, 11, 4, 5, 6, 7, 8, 1, 10, 12},
        bust_effect = '-3',
        effect_type = '% Snapshot',
        lucky = 3,
        unlucky = 9,
        phantom_roll_bonus = 1,
        job_bonus = nil -- No job bonus
    },

    ["Blitzer's Roll"] = {
        values = {2, 3, 4, 11, 5, 6, 7, 8, 1, 10, 12},
        bust_effect = '-3',
        effect_type = '% Delay Reduction',
        lucky = 4,
        unlucky = 9,
        phantom_roll_bonus = 1,
        job_bonus = nil -- No job bonus
    },

    ["Tactician's Roll"] = {
        values = {10, 10, 10, 10, 30, 10, 10, 0, 20, 20, 40},
        bust_effect = '-10',
        effect_type = ' Regain',
        lucky = 5,
        unlucky = 8,
        phantom_roll_bonus = 2,
        job_bonus = nil -- No job bonus
    },

    ["Allies' Roll"] = {
        values = {2, 3, 20, 5, 7, 9, 11, 13, 15, 1, 25},
        bust_effect = '-5',
        effect_type = '% Skillchain Damage',
        lucky = 3,
        unlucky = 10,
        phantom_roll_bonus = 1,
        job_bonus = nil -- No job bonus
    },

    ["Miser's Roll"] = {
        values = {30, 50, 70, 90, 200, 110, 20, 130, 150, 170, 250},
        bust_effect = '0',
        effect_type = ' Save TP',
        lucky = 5,
        unlucky = 7,
        phantom_roll_bonus = 15,
        job_bonus = nil -- No job bonus
    },

    ["Companion's Roll"] = {
        values = {20, 50, 20, 20, 30, 30, 30, 40, 40, 10, 60},
        bust_effect = '0',
        effect_type = ' Pet Regain/Regen',
        lucky = 2,
        unlucky = 10,
        phantom_roll_bonus = 5,
        job_bonus = nil -- No job bonus
    },

    ["Avenger's Roll"] = {
        values = {3, 4, 5, 14, 6, 7, 8, 1, 9, 10, 16},
        bust_effect = '-4',
        effect_type = '% Counter Rate',
        lucky = 4,
        unlucky = 8,
        phantom_roll_bonus = 1,
        job_bonus = nil -- No job bonus
    },

    ["Naturalist's Roll"] = {
        values = {6, 7, 15, 8, 9, 10, 5, 11, 12, 13, 20},
        bust_effect = '-5',
        effect_type = '% Enh. Magic Duration',
        lucky = 3,
        unlucky = 7,
        phantom_roll_bonus = 1,
        job_bonus = {'GEO', 5}
    },

    ["Runeist's Roll"] = {
        values = {10, 13, 15, 40, 18, 20, 25, 5, 28, 30, 50},
        bust_effect = '-15',
        effect_type = ' Magic Evasion',
        lucky = 4,
        unlucky = 8,
        phantom_roll_bonus = 5,
        job_bonus = {'RUN', 15}
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
