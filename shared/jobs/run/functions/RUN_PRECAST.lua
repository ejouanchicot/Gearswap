---  ═══════════════════════════════════════════════════════════════════════════
---   RUN Precast Module - Precast Action Handling & Fast Cast
---  ═══════════════════════════════════════════════════════════════════════════
---   Debuff guard, cooldown check, WS handling.
---   FC fallback: spell-specific > skill-specific > base set.
---
---   @file    RUN_PRECAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-05
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MessagePrecast = nil
local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local RUNTPConfig = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local success, result

    success, result = pcall(require, 'shared/utils/messages/formatters/magic/message_precast')
    if success then MessagePrecast = result end

    success, result = pcall(require, 'shared/utils/precast/cooldown_checker')
    if success then CooldownChecker = result end

    success, result = pcall(require, 'shared/utils/debuff/precast_guard')
    if success then PrecastGuard = result end

    success, result = pcall(require, 'shared/utils/precast/ws_precast_handler')
    if success then WSPrecastHandler = result end

    RUNTPConfig = _G.RUNTPConfig or {}

    modules_loaded = true
end

-- Scholar Stratagems skipped from cooldown check (charge-based, player manages manually)

local cooldown_exclusions = {
    -- Scholar Stratagems (charge-based abilities)
    ['Light Arts'] = true,
    ['Dark Arts'] = true,
    ['Addendum: White'] = true,
    ['Addendum: Black'] = true,
    ['Stratagem'] = true,
    ['Tabula Rasa'] = true,
    -- Individual stratagems
    ['Ebullience'] = true,
    ['Rapture'] = true,
    ['Altruism'] = true,
    ['Tranquility'] = true,
    ['Perpetuance'] = true,
    ['Immanence'] = true,
    ['Accession'] = true,
    ['Manifestation'] = true,
    ['Parsimony'] = true,
    ['Penury'] = true,
    ['Celerity'] = true,
    ['Alacrity'] = true,
    ['Focalization'] = true,
    ['Equanimity'] = true,
    ['Enlightenment'] = true,
    ['Klimaform'] = true
}

-- No auto-abilities for RUN

local auto_abilities = {
    -- No auto-abilities for RUN
}

--- Precast order: debuff guard → cooldown → WS handler
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- Debuff guard
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- Cooldown check (skip Scholar Stratagems)
    local is_excluded = cooldown_exclusions[spell.name]
    if not is_excluded and CooldownChecker then
        if spell.action_type == 'Ability' then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        elseif spell.action_type == 'Magic' then
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end
        if eventArgs.cancel then return end
    end

    -- No auto-abilities for RUN
    if spell.action_type == 'Magic' and auto_abilities[spell.name] then
        auto_abilities[spell.name](spell, eventArgs)
    end

    -- WS handling (range check, TP requirement, gear)
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, RUNTPConfig) then
        return
    end
    -- Fast Cast handled automatically by Mote-Include (sets.precast.FC)
end

---   Apply final gear adjustments before equipping
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- DEBUG: PRECAST SET DISPLAY (Universal System)
    -- ══════════════════════════════════════════════════════════════════════════
    -- Mote-Include already handles FC fallback: spell.name > spell.skill > base
    -- We just add debug display to show which set was selected
    if _G.PrecastDebugState and spell.action_type == 'Magic' then
        local selected_set = nil
        local set_name = 'sets.precast.FC'

        -- Detect which set Mote-Include selected
        if sets.precast.FC[spell.name] then
            selected_set = sets.precast.FC[spell.name]
            set_name = 'sets.precast.FC.' .. spell.name
        elseif spell.skill and sets.precast.FC[spell.skill] then
            selected_set = sets.precast.FC[spell.skill]
            set_name = 'sets.precast.FC[\'' .. spell.skill .. '\']'
        else
            selected_set = sets.precast.FC
            set_name = 'sets.precast.FC'
        end

        -- Show debug info
        MessagePrecast.show_debug_header(spell.name, spell.skill or 'Unknown')
        MessagePrecast.show_equipped_set(set_name)

        if selected_set then
            MessagePrecast.show_equipment(selected_set)
        end

        MessagePrecast.show_completion()
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_precast = job_precast,
    job_post_precast = job_post_precast,
}
