---============================================================================
--- WAR Buff Management Module - Buff Change Handling & Automation
---============================================================================
--- Handles Warrior job ability automation and subjob buff coordination.
--- Provides intelligent buff management with:
---   • Mutual exclusion handling (Berserk vs Defender)
---   • Sequential casting to avoid conflicts
---   • Subjob-specific buff automation (SAM)
---   • Aftermath Lv.3 detection and gear updates
---
--- Delegates business logic to SmartbuffManager (logic module).
---
--- @file    jobs/war/functions/WAR_BUFFS.lua
--- @author  Tetsouo
--- @version 3.0 - Logic Extracted to logic/smartbuff_manager.lua
--- @date    Created: 2025-09-29 | Updated: 2025-10-06
--- @requires jobs/war/functions/logic/smartbuff_manager
---============================================================================
---============================================================================
--- DEPENDENCIES
---============================================================================
-- Load smart buff automation logic
local SmartbuffManager = require('shared/jobs/war/functions/logic/smartbuff_manager')
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- WARRIOR ABILITY AUTOMATION (Public API)
---============================================================================

--- Buff the player with key WAR job abilities automatically
--- Handles mutual exclusion between Berserk and Defender.
---
--- Abilities buffed:
---   • Berserk (or Defender if param = 'Defender')
---   • Aggressor
---   • Retaliation
---   • Restraint
---   • Warcry (or Blood Rage fallback)
---
--- @param param string Optional: 'Berserk' (exclude Defender) or 'Defender' (exclude Berserk)
--- @return void
function buff_war(param)
    SmartbuffManager.buff_war(param)
end

---============================================================================
--- SAM SUBJOB AUTOMATION (Public API)
---============================================================================

--- Activate Samurai subjob abilities
--- Uses Seigan if Defender active, otherwise Hasso.
---
--- Abilities:
---   • Hasso/Seigan (stance based on Defender status)
---   • Third Eye
---
--- @return void
function buff_sam_sub()
    SmartbuffManager.buff_sam_sub()
end

---============================================================================
--- BUFF CHANGE HOOK
---============================================================================

--- Called when buffs are gained or lost
--- Handles Aftermath Lv.3 detection to refresh engaged gear sets.
---
--- @param buff string Buff name (e.g., "Aftermath: Lv.3")
--- @param gain boolean True if buff gained, false if lost
--- @return void
function job_buff_change(buff, gain, eventArgs)
    -- Doom: HIGHEST PRIORITY - Must override everything
    -- Check buffactive directly (source of truth) instead of 'gain' parameter
    if buff == 'doom' then
        local is_doomed = buffactive['doom']

        if is_doomed then
            equip(sets.buff.Doom)
            -- Disable slots to prevent other gear swaps from overwriting Doom gear
            disable('neck', 'ring1', 'ring2', 'waist')
            MessageFormatter.show_warning("DOOM detected! Equipping Doom gear.")
        else
            -- Enable slots before restoring gear
            enable('neck', 'ring1', 'ring2', 'waist')
            handle_equipping_gear(player.status)
            MessageFormatter.show_success("Doom removed.")
        end
        return  -- Stop processing - Doom takes absolute priority
    end

    -- Aftermath Lv.3: Refresh engaged set to apply/remove AM3 gear
    -- BUT: If Doom is active, don't change gear (Doom priority)
    if buff == "Aftermath: Lv.3" then
        if not buffactive['doom'] then
            handle_equipping_gear(player.status)
        end
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.buff_war = buff_war
_G.buff_sam_sub = buff_sam_sub
_G.job_buff_change = job_buff_change

-- Export as module (for future require() usage)
return {
    buff_war = buff_war,
    buff_sam_sub = buff_sam_sub,
    job_buff_change = job_buff_change
}
