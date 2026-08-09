---  ═══════════════════════════════════════════════════════════════════════════
---   DRK Midcast Module - Midcast Gear Selection
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles midcast for Dark Knight with specialized Dark Magic enhancements.
---
---   Features:
---   - Dark Magic: Dread Spikes, Absorb spells, Drain/Aspir
---   - Dark Seal buff enhancement (head)
---   - Nether Void buff enhancement (legs)
---   - Enfeebling Magic and Elemental Magic support
---
---   @file    DRK_MIDCAST.lua
---   @author  Tetsouo
---   @version 3.0 - Added spell_family database support
---   @date    Created: 2025-10-23 | Updated: 2025-11-05
---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastDeps = require('shared/utils/midcast/midcast_deps')

-- Filled in by the first midcast; the handlers below read them from here.
local MidcastManager = nil
local EnhancingSPELLS = nil

---   Pre-midcast hook (job-specific logic before set selection)
---   @param spell table Spell information from GearSwap
---   @param action string Action type
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments for cancellation/customization
function job_midcast(spell, action, spellMap, eventArgs)
    -- No DRK-specific PRE-midcast logic
end

---  ─────────────────────────────────────────────────────────────────────────
---   PER-BRANCH HANDLERS
---  ─────────────────────────────────────────────────────────────────────────
---   Extracted from job_post_midcast, which dispatched on spell.skill.
---   Each returns true once it has handled the call. Bodies unchanged.

--- Handle Dark Magic.
--- @return boolean True when this handler took the action
local function job_post_midcast_dark_magic(spell)
    -- Spell-specific routing
    if spell.name == 'Dread Spikes' then
        MidcastManager.select_set({
            skill = 'Dread Spikes',
            spell = spell
        })
    elseif spell.name:match('Absorb') then
        MidcastManager.select_set({
            skill = 'Absorb',
            spell = spell
        })
    else
        MidcastManager.select_set({
            skill = 'Dark Magic',
            spell = spell
        })
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- DARK SEAL & NETHER VOID BUFF ENHANCEMENT
    -- ══════════════════════════════════════════════════════════════════════════
    -- Applied AFTER MidcastManager to override with buff-specific gear
    local enhancements = {}

    -- Dark Seal (Buff ID 345)
    -- Effect: Dark Magic duration +10% per merit level
    -- Affects: Dread Spikes, Absorb spells, Drain III
    if buffactive['Dark Seal'] or buffactive[345] then
        if sets.buff and sets.buff['Dark Seal'] and sets.buff['Dark Seal'].head then
            enhancements.head = sets.buff['Dark Seal'].head
        end
    end

    -- Nether Void (Buff ID 439)
    -- Effect: +45% absorption potency (total 95% with gear)
    -- Affects: Absorb spells, Drain/Aspir (NOT Dread Spikes)
    if buffactive['Nether Void'] or buffactive[439] then
        -- Only apply to Absorb/Drain spells (Nether Void doesn't affect Dread Spikes)
        if spell.name:match('Absorb') or spell.name:match('Drain') or spell.name:match('Aspir') then
            if sets.buff and sets.buff['Nether Void'] and sets.buff['Nether Void'].legs then
                enhancements.legs = sets.buff['Nether Void'].legs
            end
        end
    end

    -- Apply buff enhancements if any buffs are active
    if next(enhancements) then
        equip(enhancements)
    end

    return true
end

--- Handle Enfeebling Magic.
--- @return boolean True when this handler took the action
local function job_post_midcast_enfeebling_magic(spell)
    MidcastManager.select_set({
        skill = 'Enfeebling Magic',
        spell = spell,
        database_func = EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
    })
    return true
end

--- Handle Elemental Magic.
--- @return boolean True when this handler took the action
local function job_post_midcast_elemental_magic(spell)
    MidcastManager.select_set({
        skill = 'Elemental Magic',
        spell = spell
    })
    return true
end

local JOB_POST_MIDCAST_HANDLERS = {
    ['Dark Magic'] = job_post_midcast_dark_magic,
    ['Enfeebling Magic'] = job_post_midcast_enfeebling_magic,
    ['Elemental Magic'] = job_post_midcast_elemental_magic,
}

---   Post-midcast hook (MidcastManager routing and gear selection)
---   @param spell table Spell information from GearSwap
---   @param action string Action type
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments for cancellation/customization
function job_post_midcast(spell, action, spellMap, eventArgs)
    MidcastManager, EnhancingSPELLS = MidcastDeps.load()

    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- DARK MAGIC (with spell-specific sets)
    -- ══════════════════════════════════════════════════════════════════════════

    local handler = JOB_POST_MIDCAST_HANDLERS[spell.skill]
    if handler and handler(spell) then
        return
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_midcast = job_midcast,
    job_post_midcast = job_post_midcast,
}

