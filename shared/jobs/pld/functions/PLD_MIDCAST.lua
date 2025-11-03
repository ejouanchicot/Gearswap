---============================================================================
--- PLD Midcast Module - Powered by MidcastManager
---============================================================================
--- Handles midcast for Paladin with specialized Cure and enmity optimization.
---
--- Features:
---   - Cure III/IV: Dynamic CureSelf/CureOther via CureSetBuilder
---   - Enmity spells: Flash, Enlight
---   - Phalanx: XP mode (SIRD vs Potency)
---   - Divine Magic, Enhancing Magic
---   - Blue Magic support (PLD/BLU subjob)
---
--- @file PLD_MIDCAST.lua
--- @author Tetsouo
--- @version 4.0 - Migrated to MidcastManager
--- @date Created: 2025-10-03 | Updated: 2025-10-25
--- @requires shared/jobs/pld/functions/logic/cure_set_builder
---============================================================================

local MidcastManager = require('shared/utils/midcast/midcast_manager')
local CureSetBuilder = require('shared/jobs/pld/functions/logic/cure_set_builder')

function job_midcast(spell, action, spellMap, eventArgs)
    -- ==========================================================================
    -- CURE III/IV: DYNAMIC TARGET-BASED SETS (CureSetBuilder)
    -- ==========================================================================
    -- These spells use CureSetBuilder logic module for optimal gear selection
    -- Must be handled in job_midcast BEFORE MidcastManager
    if spell.name == 'Cure III' or spell.name == 'Cure IV' then
        local target_type = spell.target.type == 'SELF' and 'SELF' or 'OTHER'
        local cure_set = CureSetBuilder.generate(spell, target_type)
        if cure_set then
            equip(cure_set)
        end
        eventArgs.handled = true
        return
    end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- Skip if already handled (Cure III/IV)
    if eventArgs.handled then
        return
    end

    -- ==========================================================================
    -- HEALING MAGIC (Other Cure spells)
    -- ==========================================================================
    if spell.skill == 'Healing Magic' then
        MidcastManager.select_set({
            skill = 'Healing Magic',
            spell = spell,
            target_func = function(sp)
                return sp.target.type == 'SELF' and 'Self' or 'Other'
            end
        })
        return
    end

    -- ==========================================================================
    -- ENMITY SPELLS (Flash, Enlight)
    -- ==========================================================================
    if spell.name == 'Flash' then
        MidcastManager.select_set({
            skill = 'Flash',
            spell = spell
        })
        return
    end

    if spell.name == 'Enlight' or spell.name == 'Enlight II' then
        MidcastManager.select_set({
            skill = 'Enmity',
            spell = spell
        })
        return
    end

    -- ==========================================================================
    -- ENHANCING MAGIC
    -- ==========================================================================
    if spell.skill == 'Enhancing Magic' then
        -- Phalanx: XP mode switching (SIRD for XP, Potency for normal)
        if spell.name == 'Phalanx' then
            if state.Xp and state.Xp.value == 'On' and sets.midcast.SIRDPhalanx then
                -- XP mode: Use SIRD Phalanx set directly (overrides MidcastManager)
                equip(sets.midcast.SIRDPhalanx)
            else
                -- Normal mode: Use PhalanxPotency or fallback
                MidcastManager.select_set({
                    skill = 'Phalanx',
                    spell = spell
                })
            end
            return
        end

        -- Other Enhancing Magic
        MidcastManager.select_set({
            skill = 'Enhancing Magic',
            spell = spell,
            target_func = MidcastManager.get_enhancing_target
        })
        return
    end

    -- ==========================================================================
    -- DIVINE MAGIC
    -- ==========================================================================
    if spell.skill == 'Divine Magic' then
        MidcastManager.select_set({
            skill = 'Divine Magic',
            spell = spell
        })
        return
    end

    -- ==========================================================================
    -- BLUE MAGIC (PLD/BLU SUBJOB)
    -- ==========================================================================
    if spell.skill == 'Blue Magic' then
        -- Cocoon: Self-buff (defense+)
        if spell.name == 'Cocoon' then
            MidcastManager.select_set({
                skill = 'Cocoon',
                spell = spell
            })
        else
            -- Default Blue Magic: Offensive spells
            MidcastManager.select_set({
                skill = 'Blue Magic',
                spell = spell
            })
        end
        return
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

local PLD_MIDCAST = {}
PLD_MIDCAST.job_midcast = job_midcast
PLD_MIDCAST.job_post_midcast = job_post_midcast

return PLD_MIDCAST
