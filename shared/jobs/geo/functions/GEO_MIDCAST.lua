---  ═══════════════════════════════════════════════════════════════════════════
---   GEO Midcast Module - Midcast Gear Selection
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles midcast for Geomancer through MidcastManager.
---
---   Features:
---   - Geomancy: Indi/Geo spells (handbell + duration), Entrust override
---   - Healing, Enhancing (spell family + Composure target), Enfeebling,
---     Elemental, Dark: MidcastManager on sets.midcast[skill]
---
---   @file    GEO_MIDCAST.lua
---   @author  Tetsouo
---   @version 3.1 - Added spell_family database support
---   @date    Created: 2025-10-09 | Updated: 2025-11-05
---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastManager = nil
local MessageFormatter = nil
local EnhancingSPELLS = nil
local EnhancingSPELLS_success = false

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local mm_ok, mm = pcall(require, 'shared/utils/midcast/midcast_manager')
    if not mm_ok then mm = nil end
    MidcastManager = mm
    local mf_ok, mf = pcall(require, 'shared/utils/messages/message_formatter')
    if not mf_ok then mf = nil end
    MessageFormatter = mf

    -- Load ENHANCING_MAGIC_DATABASE for spell_family routing
    EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

    modules_loaded = true
end

---   Pre-midcast hook (job-specific logic before set selection)
---   @param spell table Spell information from GearSwap
---   @param action string Action type
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments for cancellation/customization
function job_midcast(spell, action, spellMap, eventArgs)
    -- No GEO-specific PRE-midcast logic
end

---   Geomancy: cast message, Entrust override, then MidcastManager.
---   @param spell table Spell information from GearSwap
local function midcast_geomancy(spell)
    -- Display casting message
    if spell.english and spell.english:find("^Indi%-") then
        MessageFormatter.show_indi_cast(spell.english)
    elseif spell.english and spell.english:find("^Geo%-") then
        MessageFormatter.show_geo_cast(spell.english)
    end

    -- Check for Entrust + Indi on someone else (special gear)
    if spell.english and spell.english:find("^Indi%-") then
        -- Check active buff OR pending flag (instant detection before buffactive updates)
        local has_entrust = (buffactive and buffactive['Entrust']) or _G.geo_entrust_pending
        -- Check if target is NOT self (casting on party member)
        local target_is_other = spell.target and spell.target.type ~= 'SELF'

        if has_entrust and target_is_other then
            -- Entrust + Indi on party member = special set for duration/potency
            -- Direct equip: sets.midcast.Indi.Entrust (logical naming)
            if sets.midcast.Indi and sets.midcast.Indi.Entrust then
                equip(sets.midcast.Indi.Entrust)
                return
            end
        end
    end

    -- Standard Geomancy gear (self Indi or Geo spells)
    MidcastManager.select_set({
        skill = 'Geomancy',
        spell = spell
    })
end

---   Skills other than Geomancy that go through MidcastManager with no extra
---   metadata. A skill without sets.midcast[skill] equips nothing more, so
---   Mote's default choice (sets.midcast.Cure by spell map, for instance) stands.
local PLAIN_SKILLS = {
    ['Healing Magic'] = true,
    ['Enfeebling Magic'] = true,
    ['Elemental Magic'] = true,
    ['Dark Magic'] = true,
}

---   Post-midcast hook (MidcastManager routing and gear selection)
---   @param spell table Spell information from GearSwap
---   @param action string Action type
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments for cancellation/customization
function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Lazy load modules on first spell cast
    ensure_modules_loaded()

    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    if spell.skill == 'Geomancy' then
        midcast_geomancy(spell)
    elseif spell.skill == 'Enhancing Magic' then
        MidcastManager.select_set({
            skill = 'Enhancing Magic',
            spell = spell,
            target_func = MidcastManager.get_enhancing_target,
            database_func = EnhancingSPELLS_success and EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
        })
    elseif PLAIN_SKILLS[spell.skill] then
        MidcastManager.select_set({
            skill = spell.skill,
            spell = spell
        })
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

