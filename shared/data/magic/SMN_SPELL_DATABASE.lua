---============================================================================
--- SMN Spell Database - Complete Summoner Avatar & Blood Pact Data (Facade)
---============================================================================
--- Contains all SMN avatars/spirits and blood pacts (Rage/Ward)
--- Data extracted from FFXI SMN ability list.
---
--- @file shared/data/magic/SMN_SPELL_DATABASE.lua
--- @author ejouanchicot
--- @version 2.1 - Improved formatting - Improved alignment - Facade Architecture
--- @date Created: 2025-10-12 | Updated: 2025-11-06
--- @date Refactored: 2025-10-12 | Updated: 2025-11-06
---
--- NOTES:
--- - SMN uses Avatar system (summon avatars to fight)
--- - Spirits: Low-level elemental avatars (level 1-30)
--- - Avatars: Full avatars requiring quests (Ifrit, Shiva, etc.)
--- - Blood Pact: Rage = Offensive abilities
--- - Blood Pact: Ward = Support/Buff abilities
--- - Two-Hour abilities require Astral Flow
--- - Perpetuation Cost: Avatars drain MP/tick while summoned
--- - Restrictions: subjob, subjob_master_only, main_job_only, two_hour
---
--- ARCHITECTURE:
--- - This file is a FAÇADE that loads internal modules
--- - Internal modules: spirits, avatars, rage, ward
--- - Public API: SMNSpells.spells (every summon and blood pact, merged from
---   the internal modules), read by the message handlers and the data loader
---============================================================================

local SMNSpells = {}

---============================================================================
--- LOAD MODULAR FILES (NEW ARCHITECTURE - 15 files organized by avatar)
---============================================================================

-- Load all avatar files from summoning/ directory
local carbuncle = require('shared/data/magic/summoning/carbuncle')
local cait_sith = require('shared/data/magic/summoning/cait_sith')
local diabolos = require('shared/data/magic/summoning/diabolos')
local fenrir = require('shared/data/magic/summoning/fenrir')
local garuda = require('shared/data/magic/summoning/garuda')
local ifrit = require('shared/data/magic/summoning/ifrit')
local leviathan = require('shared/data/magic/summoning/leviathan')
local ramuh = require('shared/data/magic/summoning/ramuh')
local shiva = require('shared/data/magic/summoning/shiva')
local siren = require('shared/data/magic/summoning/siren')
local spirits = require('shared/data/magic/summoning/spirits')
local titan = require('shared/data/magic/summoning/titan')
local odin = require('shared/data/magic/summoning/odin')
local alexander = require('shared/data/magic/summoning/alexander')
local atomos = require('shared/data/magic/summoning/atomos')

---============================================================================
--- MERGE SPELL DATA (143 total SMN spells from 15 files)
---============================================================================

-- Create unified .spells table for spell_message_handler compatibility
SMNSpells.spells = {}

-- Merge all avatar files into .spells table
for spell_name, spell_data in pairs(carbuncle.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(cait_sith.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(diabolos.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(fenrir.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(garuda.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(ifrit.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(leviathan.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(ramuh.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(shiva.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(siren.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(spirits.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(titan.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(odin.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(alexander.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(atomos.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

-- Merge all blood pacts from avatar files into .spells table
for pact_name, pact_data in pairs(carbuncle.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(cait_sith.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(diabolos.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(fenrir.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(garuda.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(ifrit.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(leviathan.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(ramuh.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(shiva.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(siren.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(titan.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(odin.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(alexander.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(atomos.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

return SMNSpells
