---============================================================================
--- Universal Job Ability Database - Auto-merged from all job databases
---============================================================================
--- Automatically loads and merges all individual job ability databases.
--- Used by all PRECAST modules to support both main job and subjob abilities.
---
--- This eliminates the subjob problem:
---   • WAR/SAM can display Third Eye messages (from SAM_JA_DATABASE)
---   • PLD/WAR can display Provoke messages (from WAR_JA_DATABASE)
---   • Any job combination gets full JA coverage
---
--- Architecture:
---   • Individual databases remain separate (easy to maintain)
---   • Universal database merges them at runtime
---   • All PRECAST modules use this universal database
---
--- @file    UNIVERSAL_JA_DATABASE.lua
--- @author  Tetsouo
--- @version 1.0 - Improved formatting
--- @date    Created: 2025-10-29
--- @see     shared/data/job_abilities/README.md
---============================================================================

local UNIVERSAL_JA_DB = {}

-- List of all jobs with JA databases
local jobs = {
    'BLM',  -- Black Mage
    'BLU',  -- Blue Mage
    'BRD',  -- Bard
    'BST',  -- Beastmaster
    'COR',  -- Corsair
    'DNC',  -- Dancer
    'DRG',  -- Dragoon
    'DRK',  -- Dark Knight
    'GEO',  -- Geomancer
    'MNK',  -- Monk
    'NIN',  -- Ninja
    'PLD',  -- Paladin
    'PUP',  -- Puppetmaster
    'RDM',  -- Red Mage
    'RNG',  -- Ranger
    'RUN',  -- Rune Fencer
    'SAM',  -- Samurai
    'SCH',  -- Scholar
    'THF',  -- Thief
    'WAR',  -- Warrior
    'WHM'   -- White Mage
    -- Total: 21 jobs, 300+ abilities
}

-- Load and merge all job databases
for _, job in ipairs(jobs) do
    local success, job_db = pcall(require, 'shared/data/job_abilities/' .. job .. '_JA_DATABASE')
    if success and job_db then
        -- Merge job database into universal
        for ability_name, description in pairs(job_db) do
            UNIVERSAL_JA_DB[ability_name] = description
        end
    else
        -- Failed to load database (suppressed warning)
    end
end

return UNIVERSAL_JA_DB
