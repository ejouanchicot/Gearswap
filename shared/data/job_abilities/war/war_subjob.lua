---============================================================================
--- WAR Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Warrior abilities accessible as subjob (5 total)
---
--- Contents:
---   - Provoke (Lv5) - Enmity generation
---   - Berserk (Lv15) - Attack/Defense trade-off
---   - Defender (Lv25) - Defense/Attack trade-off
---   - Warcry (Lv35) - Party attack boost
---   - Aggressor (Lv45) - Accuracy/Evasion trade-off
---
--- @file war_subjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @updated 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Warrior
---============================================================================

local WAR_SUBJOB = {}

WAR_SUBJOB.abilities = {
    ['Provoke'] = {
        description = 'Generate enmity',
        level = 5,
        recast = 30,
        main_job_only = false,
        cumulative_enmity = 1,
        volatile_enmity = 1800
    },
    ['Berserk'] = {
        description = 'ATK+25% DEF-25% (3min)',
        level = 15,
        recast = 300,  -- 5 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Defender'] = {
        description = 'DEF+25% ATK-25% (3min)',
        level = 25,
        recast = 300,  -- 5 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Warcry'] = {
        description = 'Party ATK boost (30s)',
        level = 35,
        recast = 300,  -- 5 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 320
    },
    ['Aggressor'] = {
        description = 'ACC+25 EVA-25 (3min)',
        level = 45,
        recast = 300,  -- 5 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return WAR_SUBJOB
