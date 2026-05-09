---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Midcast Router - Spell Skill Handlers
---  ═══════════════════════════════════════════════════════════════════════════
---   Per-skill handlers extracted from BLM_MIDCAST.lua. Each handler:
---     • Routes spell to MidcastManager.select_set() with the right config
---     • Applies BLM-specific post-overrides via equip() (layered on top)
---     • Emits the same debug messages as the original monolithic version
---
---   Public API (called by BLM_MIDCAST.job_post_midcast dispatcher):
---     • handle_impact(spell, ctx)        - Twilight Cloak lock
---     • handle_elemental(spell, ctx)     - MagicBurst + MP cons + ElementalMatch + Quanpur
---     • handle_dark(spell, ctx)          - Drain/Aspir
---     • handle_enfeebling(spell, ctx)    - Burn/Frost/Choke/etc.
---
---   ctx (context) table fields used by handlers:
---     • debug_enabled (boolean)
---     • messages (MessageBLMMidcast module)
---     • mp_config (BLMMPConfig: { mp_threshold = number })
---     • elemental_config (BLMElementalConfig: { auto_hachirin, check_storm/day/weather })
---     • enfeebling_database (function|nil: spell_name -> spell_family)
---
---   @file    jobs/blm/functions/logic/midcast_router.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-09
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastManager = nil
local ElementalMatcher = nil

local function ensure_loaded()
    if not MidcastManager then
        MidcastManager = require('shared/utils/midcast/midcast_manager')
    end
    if not ElementalMatcher then
        ElementalMatcher = require('shared/jobs/blm/functions/logic/elemental_matcher')
    end
end

local Router = {}

-- Spells that benefit from Quanpur Necklace (Stone-line ONLY, not Stonega/Quake)
local QUANPUR_SPELLS = S{
    'Stone', 'Stone II', 'Stone III', 'Stone IV', 'Stone V', 'Stone VI',
    'Stoneja',
    'Stonera', 'Stonera II', 'Stonera III'
}

---  ═══════════════════════════════════════════════════════════════════════════
---   PRIVATE HELPERS - Override layers for Elemental Magic
---  ═══════════════════════════════════════════════════════════════════════════

--- Apply MP conservation gear if player MP is below threshold.
--- Layered AFTER MidcastManager equip() - each equip() merges on top.
local function apply_mp_conservation(ctx)
    local current_mp = player and player.mp or 9999
    local mp_threshold = ctx.mp_config.mp_threshold or 1000

    if current_mp < mp_threshold then
        if ctx.debug_enabled then
            ctx.messages.show_mp_conservation(current_mp, mp_threshold)
        end
        if sets.midcast.MPConservation then
            equip(sets.midcast.MPConservation)
        end
    elseif ctx.debug_enabled then
        ctx.messages.show_normal_mp(current_mp, mp_threshold)
    end
end

--- Apply Hachirin-no-Obi gear if day/weather/storm matches spell element.
local function apply_elemental_match(spell, ctx)
    if not ctx.elemental_config.auto_hachirin then return end

    local has_match, reason = ElementalMatcher.has_elemental_match(spell, ctx.elemental_config)
    if has_match and sets.midcast.ElementalMatch then
        equip(sets.midcast.ElementalMatch)
        if ctx.debug_enabled then
            ctx.messages.show_elemental_match(reason)
        end
    end
end

--- Apply Quanpur Necklace for Stone-line spells.
local function apply_quanpur(spell)
    if QUANPUR_SPELLS:contains(spell.english) and sets.midcast.QuanpurStone then
        equip(sets.midcast.QuanpurStone)
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PUBLIC HANDLERS
---  ═══════════════════════════════════════════════════════════════════════════

--- Impact: requires Twilight Cloak. Body slot must NEVER be overwritten during cast.
--- Handles MagicBurst variant via dedicated sets.midcast['Impact'].MagicBurst.
function Router.handle_impact(spell, ctx)
    local impact_set = sets.midcast['Impact'] or sets.midcast['Elemental Magic']

    -- Apply MagicBurst variant if mode is on
    if state.MagicBurstMode and state.MagicBurstMode.current == 'On' then
        if sets.midcast['Impact'] and sets.midcast['Impact'].MagicBurst then
            impact_set = sets.midcast['Impact'].MagicBurst
        end
    end

    equip(impact_set)

    -- CRITICAL: Force Twilight Cloak protection (like Marsyas for BRD)
    -- Body MUST stay equipped - other gear changes during cast must not strip it.
    if _G.casting_impact and _G.impact_body then
        equip({body = _G.impact_body})
        if ctx.debug_enabled then
            ctx.messages.show_elemental_routing('Impact (Twilight Cloak locked)')
        end
    end
end

--- Elemental Magic: MidcastManager (with MagicBurst mode_value) + 3 BLM overrides.
--- Death is special-cased to its own set.
function Router.handle_elemental(spell, ctx)
    ensure_loaded()

    if ctx.debug_enabled then
        ctx.messages.show_elemental_routing(
            tostring(state.MagicBurstMode and state.MagicBurstMode.current or 'nil')
        )
    end

    -- Death uses its own dedicated set (not affected by MagicBurst/MP/etc.)
    if spell.english == 'Death' then
        MidcastManager.select_set({skill = 'Death', spell = spell})
        if ctx.debug_enabled then
            ctx.messages.show_elemental_return()
        end
        return
    end

    -- MagicBurst variant resolved by MidcastManager via mode_value
    -- Maps to sets.midcast['Elemental Magic'].MagicBurst (Priority 8)
    local mode_value = nil
    if state.MagicBurstMode and state.MagicBurstMode.current == 'On' then
        mode_value = 'MagicBurst'
    end

    if ctx.debug_enabled then
        ctx.messages.show_mode_value(tostring(mode_value or 'nil (base set)'))
    end

    MidcastManager.select_set({
        skill = 'Elemental Magic',
        spell = spell,
        mode_value = mode_value,
    })

    -- BLM-specific post-overrides (each equip() layers on top of MidcastManager set)
    apply_mp_conservation(ctx)
    apply_elemental_match(spell, ctx)
    apply_quanpur(spell)

    if ctx.debug_enabled then
        ctx.messages.show_elemental_return()
    end
end

--- Dark Magic: pure delegation to MidcastManager (Drain/Aspir).
function Router.handle_dark(spell, ctx)
    ensure_loaded()

    if ctx.debug_enabled then
        ctx.messages.show_dark_routing()
    end

    MidcastManager.select_set({
        skill = 'Dark Magic',
        spell = spell,
    })

    if ctx.debug_enabled then
        ctx.messages.show_dark_return()
    end
end

--- Enfeebling Magic: MidcastManager with optional spell_family database router.
function Router.handle_enfeebling(spell, ctx)
    ensure_loaded()

    if ctx.debug_enabled then
        ctx.messages.show_enfeebling_routing()
    end

    MidcastManager.select_set({
        skill = 'Enfeebling Magic',
        spell = spell,
        database_func = ctx.enfeebling_database,
    })

    if ctx.debug_enabled then
        ctx.messages.show_enfeebling_return()
    end
    -- Note: Spell messages handled by universal spell message system
end

return Router
