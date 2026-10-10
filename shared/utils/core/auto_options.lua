---============================================================================
--- Auto Options - the automatic job abilities a character turns on
---============================================================================
--- Each is a switch of its job's own file, <Character>/<job>/combat/
--- <JOB>_CONFIG.lua (JobConfig; before 2026-10-10 they were all in
--- _common/combat/AUTO_ABILITIES.lua, still read where a folder has it). The
--- names below are the ones the jobs ask by; HOME gives the job and the key
--- of each. Two kinds of option.
---
--- Off unless the file sets it true (AutoOptions.on):
---   sam_hasso        SAM: the chosen stance (state.Stance) when engaging,
---                    unless Hasso or Seigan is up
---   geo_entrust      GEO: an Indi- aimed at a party member gets Entrust first
---   geo_full_circle  GEO: a Geo- cast while a luopan is out gets Full Circle first
---   blu_unbridled    BLU: Unbridled Learning before an unbridled spell
---                    (shared/jobs/blu/functions/logic/unbridled.lua)
---   blu_expiacion_window  BLU: Expiacion held once under 3000 TP without
---                    Aftermath: Lv.3 (logic/expiacion_guard.lua)
---
--- On unless the file sets it false (AutoOptions.enabled(name, true)): the
--- automations that always ran before they could be turned off:
---   sam_third_eye_ws        SAM: Third Eye before a weaponskill
---   pld_divine_emblem       PLD: Divine Emblem before Flash
---   pld_majesty             PLD: Majesty before Protect / Cure
---   blm_dark_arts           BLM/SCH: Dark Arts before a nuke
---   blm_klimaform           BLM/SCH: Klimaform before a storm (//gs c storm)
---   dnc_presto              DNC: Presto before a step (//gs c step)
---   war_retaliation_cancel  WAR: Retaliation cancelled after 5 s of running
---
--- @file    shared/utils/core/auto_options.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local AutoOptions = {}

-- The job and the key in its <JOB>_CONFIG.lua of each option
local HOME = {
    sam_hasso = {'SAM', 'auto_hasso'}, sam_third_eye_ws = {'SAM', 'auto_third_eye_ws'},
    geo_entrust = {'GEO', 'auto_entrust'}, geo_full_circle = {'GEO', 'auto_full_circle'},
    blu_unbridled = {'BLU', 'auto_unbridled'}, blu_expiacion_window = {'BLU', 'expiacion_window'},
    pld_divine_emblem = {'PLD', 'auto_divine_emblem'}, pld_majesty = {'PLD', 'auto_majesty'},
    blm_dark_arts = {'BLM', 'auto_dark_arts'}, blm_klimaform = {'BLM', 'auto_klimaform'},
    dnc_presto = {'DNC', 'auto_presto'}, war_retaliation_cancel = {'WAR', 'retaliation_cancel'},
}

--- What the character's file says of an option: true, false, or nil when it says nothing.
local function value_of(name)
    local home = HOME[name]
    if not home then return nil end
    return require('shared/utils/core/job_config').get(home[1], home[2])
end

--- Whether the character turned this option on.
--- @param name string Option name ('sam_hasso', ...)
--- @return boolean
function AutoOptions.on(name)
    return value_of(name) == true
end

--- An option with its own default: the file's true / false, else `default`.
--- @param name string Option name
--- @param default boolean Value when the file does not set it
--- @return boolean
function AutoOptions.enabled(name, default)
    local value = value_of(name)
    if value == nil then return default == true end
    return value == true
end

return AutoOptions
