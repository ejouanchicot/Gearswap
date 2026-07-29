---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Midcast Module - Gear Selection during Midcast
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles two distinct flows:
---
---   1. Blood Pacts (spell.type == 'BloodPactRage' or 'BloodPactWard'):
---      Routed via blood_pact_classifier to sets.pet_midcast.<category>
---      (BPRage.Physical / Magical / Hybrid / AstralFlow,
---       BPWard.Buff / Debuff / Heal)
---
---   2. Subjob magic (Cure, Stoneskin, Phalanx, Refresh, etc.):
---      Routed via MidcastManager with its 7-level fallback chain.
---
---   @file    shared/jobs/smn/functions/SMN_MIDCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-28
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastManager = nil
local MessageFormatter = nil
local BloodPactClassifier = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local _, mm = pcall(require, 'shared/utils/midcast/midcast_manager')
    MidcastManager = mm

    local _, mf = pcall(require, 'shared/utils/messages/message_formatter')
    MessageFormatter = mf

    local _, bpc = pcall(require, 'shared/jobs/smn/functions/logic/blood_pact_classifier')
    BloodPactClassifier = bpc

    modules_loaded = true
end

local function is_blood_pact(spell)
    return spell.type == 'BloodPactRage' or spell.type == 'BloodPactWard'
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MIDCAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Pre-midcast hook (no job-specific gear here, all handled in job_post_midcast)
function job_midcast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()
end

--- Post-midcast hook: dispatch BPs and subjob magic
function job_post_midcast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- =========================================================================
    -- BLOOD PACTS - master casts a /pet BP, equip the avatar's damage/effect set
    -- =========================================================================
    if is_blood_pact(spell) then
        if not BloodPactClassifier then return end

        local bp_set, category = BloodPactClassifier.resolve(spell.english or spell.name)

        if bp_set then
            equip(bp_set)
            if _G.MidcastManagerDebugState == true and MessageFormatter then
                MessageFormatter.show_debug('SMN',
                    'BP "' .. (spell.english or spell.name) .. '" -> sets.pet_midcast.' .. category)
            end
        elseif MessageFormatter and _G.MidcastManagerDebugState == true then
            MessageFormatter.show_debug('SMN',
                'BP unclassified: "' .. (spell.english or spell.name or '?') .. '"')
        end
        return
    end

    -- =========================================================================
    -- SUMMONING MAGIC (avatar summon - reduces Pact Delay)
    -- =========================================================================
    if spell.skill == 'Summoning Magic' then
        if MidcastManager then
            MidcastManager.select_set({
                skill = 'Summoning Magic',
                spell = spell
            })
        end
        return
    end

    -- =========================================================================
    -- SUBJOB HEALING / ENHANCING / etc.
    -- =========================================================================
    if spell.skill == 'Healing Magic' then
        if MidcastManager then
            MidcastManager.select_set({
                skill = 'Healing Magic',
                spell = spell
            })
        end
        return
    end

    if spell.skill == 'Enhancing Magic' then
        if MidcastManager then
            MidcastManager.select_set({
                skill = 'Enhancing Magic',
                spell = spell,
                target_func = MidcastManager.get_enhancing_target
            })
        end
        return
    end

    if spell.skill == 'Divine Magic' then
        if MidcastManager then
            MidcastManager.select_set({ skill = 'Divine Magic', spell = spell })
        end
        return
    end

    if spell.skill == 'Dark Magic' then
        if MidcastManager then
            MidcastManager.select_set({ skill = 'Dark Magic', spell = spell })
        end
        return
    end

    if spell.skill == 'Elemental Magic' then
        if MidcastManager then
            MidcastManager.select_set({
                skill = 'Elemental Magic',
                spell = spell,
                mode_state = state.CastingMode
            })
        end
        return
    end

    if spell.skill == 'Enfeebling Magic' then
        if MidcastManager then
            MidcastManager.select_set({
                skill = 'Enfeebling Magic',
                spell = spell,
                mode_state = state.CastingMode
            })
        end
        return
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

return {
    job_midcast = job_midcast,
    job_post_midcast = job_post_midcast,
}
