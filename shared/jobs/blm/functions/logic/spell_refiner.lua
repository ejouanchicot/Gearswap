---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Spell Refinement Module - Intelligent Spell Tier Management (Facade)
---  ═══════════════════════════════════════════════════════════════════════════
---   Public entry point for BLM spell refinement. Orchestrates the 5
---   specialised sub-modules under refiner/ to handle:
---
---     • Intelligent tier downgrading (VI -> V -> IV -> III -> II -> I)
---     • MP and recast awareness
---     • Magic Burst announcement
---     • -ja spell special handling (Firaja -> Firaga III/II/I)
---     • Breakga -> Break fallback with lag protection
---     • Grouped recast display for unavailable spells
---
---   Sub-modules:
---     refiner/correspondence.lua    - tier downgrade lookup table (data)
---     refiner/timing_guards.lua     - anti-spam timers (replacement + per-spell)
---     refiner/replacement_logic.lua - find_available_tier / ja replacement / cancel
---     refiner/recast_display.lua    - grouped cooldown display for unavailable spells
---     refiner/special_handlers.lua  - magic burst announce / exec / Breakga
---
---   Public API: SpellRefiner.refine_various_spells(spell, eventArgs)
---     - Sole external caller: blm_functions.lua:191
---
---   @file    jobs/blm/functions/logic/spell_refiner.lua
---   @author  Tetsouo
---   @version 3.0 - Modular refactor (826 lines -> 200 lines facade + 5 modules)
---   @date    Migrated: 2025-10-15, Refactored: 2026-05-09
---  ═══════════════════════════════════════════════════════════════════════════

local Correspondence    = require('shared/jobs/blm/functions/logic/refiner/correspondence')
local TimingGuards      = require('shared/jobs/blm/functions/logic/refiner/timing_guards')
local ReplacementLogic  = require('shared/jobs/blm/functions/logic/refiner/replacement_logic')
local RecastDisplay     = require('shared/jobs/blm/functions/logic/refiner/recast_display')
local SpecialHandlers   = require('shared/jobs/blm/functions/logic/refiner/special_handlers')

local BLMMessages       = require('shared/utils/messages/formatters/jobs/message_blm')
local MessageCooldowns  = require('shared/utils/messages/formatters/combat/message_cooldowns')

local SpellRefiner = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   PRIVATE HELPERS
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle the -ja path: replace if needed, fire the new cast, OR show the
--- original -ja recast + -ga alternatives if no replacement found.
local function handle_ja_spell(spell, spell_recasts, player_mp, eventArgs, currentTime)
    local res = res or windower.res or require('resources')
    if not res then
        return
    end

    local newSpell = ReplacementLogic.find_ja_replacement(spell, spell_recasts, player_mp, res)

    -- Magic Burst announcement uses the refined spell name
    SpecialHandlers.announce_magic_burst(spell, newSpell)

    if newSpell ~= spell.english then
        -- A replacement was found - execute it
        SpecialHandlers.execute_replacement(spell, newSpell, eventArgs, currentTime)
        return
    end

    -- No replacement found AND -ja still on cooldown: collect cooldowns and display
    local jaSpellData = res.spells:with('en', spell.english)
    if not (jaSpellData and spell_recasts[jaSpellData.recast_id] > 0) then
        return -- spell is ready or unknown - nothing to display
    end

    eventArgs.cancel = true

    -- Build cooldown list: -ja itself + all -ga tiers
    local cooldowns = {{
        type = "cooldown",
        name = spell.english,
        value = spell_recasts[jaSpellData.recast_id] / 100, -- centiseconds -> seconds
        action_type = "Magic"
    }}

    -- Append -ga III/II/I tiers (delegates to RecastDisplay)
    local baseElement = string.gsub(spell.name, 'ja.*', '')
    local ga_cooldowns = RecastDisplay.collect_ga_tier_cooldowns(baseElement, spell_recasts)
    for _, cd in ipairs(ga_cooldowns) do
        table.insert(cooldowns, cd)
    end

    MessageCooldowns.show_multi_status(cooldowns)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PUBLIC API
---  ═══════════════════════════════════════════════════════════════════════════

--- Main refinement entry point. Decides whether to replace, cancel, or
--- proceed with the spell, and dispatches all the side effects (announce,
--- execute, display recasts, breakga fallback).
---
--- @param spell table     Spell being cast (from job_precast / job_midcast)
--- @param eventArgs table Event args (.cancel will be set to true if needed)
function SpellRefiner.refine_various_spells(spell, eventArgs)
    if not spell or not eventArgs then
        BLMMessages.show_spell_refinement_error()
        return
    end

    local currentTime = os.clock()

    -- Anti-spam guard: skip if we just refined another spell
    if not TimingGuards.is_replacement_safe(currentTime, 0.2) then
        return
    end

    local spell_recasts = windower.ffxi.get_spell_recasts()
    local player_mp = player.mp

    if not spell_recasts then
        BLMMessages.show_spell_recasts_error()
        return
    end

    -- SPECIAL CASE: -ja spells (no tier system, downgrade to -ga family)
    if spell.name:find('ja') then
        handle_ja_spell(spell, spell_recasts, player_mp, eventArgs, currentTime)
        return
    end

    -- NORMAL CASE: tiered spells (Fire VI, Firaga III, etc.)
    local spellCategory, spellLevel = spell.name:match('(%a+)%s*(%a*)')
    local correspondence = Correspondence.get(spellCategory)

    -- Find an available tier to actually cast
    local newSpell, replacement = ReplacementLogic.find_available_tier(
        spell, spell_recasts, player_mp, correspondence, spellCategory, spellLevel
    )

    -- Cancel if the player is too low on MP for any tier
    if ReplacementLogic.should_cancel(newSpell, replacement, player_mp, spell) then
        eventArgs.cancel = true
        BLMMessages.show_insufficient_mp_error(player_mp)
        return
    end

    -- Magic Burst announcement uses the refined spell name
    SpecialHandlers.announce_magic_burst(spell, newSpell)

    -- Either execute the replacement, or show recast info if nothing changed
    if newSpell ~= spell.english then
        SpecialHandlers.execute_replacement(spell, newSpell, eventArgs, currentTime)
    else
        RecastDisplay.show_for_unavailable_spell(
            spell, correspondence, spellCategory, spellLevel, spell_recasts, eventArgs
        )
    end

    -- Special Breakga -> Break fallback (no-op for other spells)
    SpecialHandlers.handle_breakga_to_break(spell, spell_recasts, eventArgs, currentTime)
end

return SpellRefiner
