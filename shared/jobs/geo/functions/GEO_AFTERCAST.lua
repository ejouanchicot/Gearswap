---  ═══════════════════════════════════════════════════════════════════════════
---   GEO Aftercast Module - Post-Action Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Aftercast hook for Geomancer: watchdog notification, Entrust pending flag,
---   and the escort follow-up. Gear return is left to Mote.
---
---   @file    shared/jobs/geo/functions/GEO_AFTERCAST.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2025-10-09
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   ENTRUST PENDING FLAG (Initialize global tracker)
---  ═══════════════════════════════════════════════════════════════════════════
-- Track Entrust usage (persist until Indi spell is cast or buff expires)
if _G.geo_entrust_pending == nil then
    _G.geo_entrust_pending = false
end

---  ═══════════════════════════════════════════════════════════════════════════
---   AFTERCAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Aftercast hook (called by Mote-Include)
---   @param spell table Spell/ability that just finished
---   @param action table Action information from GearSwap
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- GEO-SPECIFIC AFTERCAST LOGIC

    -- Track Entrust usage for immediate gear application (before buff appears
    -- in buffactive). Precast raises the flag optimistically, so an interrupted
    -- Entrust has to lower it here - no buff will arrive, hence no buff_change.
    if spell.type == 'JobAbility' and spell.english == 'Entrust' then
        _G.geo_entrust_pending = not spell.interrupted
    end

    -- Escort: follow the leader the moment the escort Indi- is done
    if _G.geo_escort_on_aftercast then
        _G.geo_escort_on_aftercast(spell)
    end

    -- When this character's last spell / ability ended: our queued abilities wait for a gap after it
    -- (shared/utils/precast/ability_queue.lua)
    require('shared/utils/precast/ability_queue').note_end(spell)

    -- A bubble placed: Ecliptic Attrition on it when the fight opening asked for it (logic/fight_opening.lua)
    if spell.skill == 'Geomancy' and spell.english and spell.english:find("^Geo%-") and not spell.interrupted then
        require('shared/jobs/geo/functions/logic/fight_opening').on_bubble_placed()
    end

    -- Clear Entrust pending flag after Indi spell completes (buff consumed)
    if spell.skill == 'Geomancy' and spell.english and spell.english:find("^Indi%-") and not spell.interrupted then
        -- the last Indi- this character put up, for //gs c indiensure (on windower: outlives a load)
        if spell.target and spell.target.type == 'SELF' then windower._geo_last_indi = spell.english end
        _G.geo_entrust_pending = false
    end

    -- Gear refresh is handled by Mote (status_change) + MidcastWatchdog (packet
    -- loss). The forced 'gs c update' here was redundant (removed 2026-06-09,
    -- validated in-game on WAR in Odyssey + Sortie).
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export global for GearSwap (Mote-Include)
_G.job_aftercast = job_aftercast

