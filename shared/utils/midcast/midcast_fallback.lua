---============================================================================
--- Midcast Fallback - spells a job's midcast does not route
---============================================================================
--- Each job's job_post_midcast hands MidcastManager the skills it knows
--- (COR: Healing, Elemental, Enfeebling, Enhancing, ranged). A spell of
--- another skill - a subjob's magic: COR/DRK Drain or Stun, WAR/NIN
--- Utsusemi - used to get Mote's default set only, and //gs c debugmidcast
--- said nothing. After job_post_midcast, such a spell is routed with its own
--- skill, so it follows the same set chain and the debug reports it.
---
--- Left alone: a cancelled action, a spell the job equipped itself and
--- flagged (eventArgs.handled, e.g. PLD / RUN / WHM cures), anything but
--- magic, and a spell select_set already saw (_G._midcast_routed, set by
--- MidcastManager.select_set).
---
--- @file    shared/utils/midcast/midcast_fallback.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-27
---============================================================================

local MidcastFallback = {}

--- Route `spell` when nothing did during this midcast.
--- @param spell table
--- @param eventArgs table|nil
function MidcastFallback.route(spell, eventArgs)
    local routed = rawget(_G, '_midcast_routed')
    _G._midcast_routed = nil
    if routed == spell or not spell or spell.action_type ~= 'Magic' or not spell.skill then return end
    if eventArgs and (eventArgs.cancel or eventArgs.handled) then return end
    local ok, MidcastManager = pcall(require, 'shared/utils/midcast/midcast_manager')
    if ok and MidcastManager then
        MidcastManager.select_set({skill = spell.skill, spell = spell})
    end
end

--- Leave `spell` alone: the job dressed it itself on purpose, without
--- select_set (RDM Phalanx under Accession, BLM Impact, GEO Entrust, PLD
--- Phalanx SIRD, BRD dummy and debuff songs). Without this, route() would
--- see no routing and lay the skill chain's set over the job's choice.
--- @param spell table
function MidcastFallback.skip(spell)
    _G._midcast_routed = spell
end

--- Hook route() on Mote's cleanup_midcast, which runs after job_post_midcast
--- on every midcast. Once per sandbox; INIT_SYSTEMS calls it after Mote
--- defined cleanup_midcast and before the custom states wrap it, so the
--- player's custom gear still goes on last.
function MidcastFallback.install()
    if rawget(_G, '_midcast_fallback_installed') then return end
    local original = rawget(_G, 'cleanup_midcast')
    if type(original) ~= 'function' then return end
    _G._midcast_fallback_installed = true
    _G.cleanup_midcast = function(spell, spellMap, eventArgs)
        MidcastFallback.route(spell, eventArgs)
        return original(spell, spellMap, eventArgs)
    end
end

return MidcastFallback
