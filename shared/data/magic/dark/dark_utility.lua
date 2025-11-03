---============================================================================
--- DARK MAGIC DATABASE - Utility Spells Module
---============================================================================
--- Dark Magic utility and special spells (7 total)
--- Data source: bg-wiki.com (official FFXI documentation)
---
--- Contents:
---   - Death (Lv99 JP BLM) - Instant death or massive self damage
---   - Dread Spikes (Lv71 DRK) - Absorbs physical damage as HP
---   - Endark (Lv85 DRK) - Adds darkness to melee attacks
---   - Endark II (Lv99 JP DRK) - Enhanced darkness to melee attacks
---   - Kaustra (Lv5 SCH SP) - Multi-target dark damage (Ebullience)
---   - Stun (Lv37-45) - LIGHTNING element! Stuns target
---   - Tractor (Lv25-32) - Pulls target player to caster
---
--- Notes:
---   - STUN is the ONLY Dark Magic spell with Lightning element
---   - Death can kill caster if it fails
---   - Dread Spikes is DRK-exclusive defensive buff
---   - Endark series are DRK-exclusive offensive buffs
---   - Kaustra requires Ebullience (Scholar SP ability) active
---
--- @file dark_utility.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Category:Dark_Magic
---============================================================================

local DARK_UTILITY = {}

DARK_UTILITY.spells = {

    ["Death"] = {
        description = "Uses all MP; may KO or deal dark dmg (no undead).",
        category = "Dark",
        element = "Dark",
        magic_type = "Black",
        type = "single",
        main_job_only = false,
        subjob_master_only = false,
        BLM = "JP",
        notes = "Consumes all MP. Chance to instantly KO target; if fails, deals dark damage. Requires Job Points (BLM). Ineffective vs undead.",
    },

    ["Dread Spikes"] = {
        description = "Covers you in dark spikes; absorbs HP (no undead).",
        category = "Dark",
        element = "Dark",
        magic_type = "Black",
        type = "self",
        main_job_only = true,
        subjob_master_only = false,
        DRK = 71,
        notes = "Defensive buff. Absorbs physical damage as HP when hit. DRK-only. Ineffective vs undead.",
    },

    ["Endark"] = {
        description = "Adds dark dmg to attacks.",
        category = "Dark",
        element = "Dark",
        magic_type = "Black",
        tier = "I",
        type = "self",
        main_job_only = true,
        subjob_master_only = false,
        DRK = 85,
        notes = "Weapon enhancement. Adds darkness damage to physical attacks. DRK-only.",
    },

    ["Endark II"] = {
        description = "Adds dark dmg to attacks.",
        category = "Dark",
        element = "Dark",
        magic_type = "Black",
        tier = "II",
        type = "self",
        main_job_only = true,
        subjob_master_only = false,
        DRK = "JP",
        notes = "Enhanced weapon enchantment. Adds darkness damage to physical attacks. Requires Job Points (DRK).",
    },

    ["Kaustra"] = {
        description = "Uses 20% MP; inflicts dark DoT.",
        category = "Dark",
        element = "Dark",
        magic_type = "Black",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        SCH = 5,
        notes = "Consumes 20% max MP. Dark damage-over-time effect. Requires Ebullience (SCH SP ability). SCH-only.",
    },

    ["Stun"] = {
        description = "Stuns target briefly.",
        category = "Dark",
        element = "Lightning",
        magic_type = "Black",
        type = "single",
        main_job_only = false,
        subjob_master_only = false,
        BLM = 45,
        DRK = 37,
        notes = "EXCEPTION: Only Dark Magic spell with Lightning element. No damage. Interrupts casting/actions. BLM/DRK.",
    },

    ["Tractor"] = {
        description = "Pulls a KO'd ally toward you.",
        category = "Dark",
        element = "Dark",
        magic_type = "Black",
        type = "single",
        main_job_only = false,
        subjob_master_only = false,
        BLM = 25,
        DRK = 32,
        notes = "Utility spell. Drags knocked-out party member to caster. BLM/DRK.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DARK_UTILITY
