---  ═══════════════════════════════════════════════════════════════════════════
---   Timing Guards - Anti-spam protection for spell refinement
---  ═══════════════════════════════════════════════════════════════════════════
---   Two independent rate limiters:
---     • Replacement timer  - global cooldown after any spell refinement
---       (prevents recursive refinement when @input fires hooks again)
---     • Per-spell timer    - per-spell cooldown to throttle individual spells
---       (currently only used by Breakga -> Break to prevent lag-induced spam)
---
---   Module-local state persists across calls but resets on gs reload.
---
---   Public API:
---     • is_replacement_safe(now, cooldown?) -> bool
---     • update_replacement_time(now)
---     • is_spell_safe_to_cast(name, now)   -> bool
---     • update_cast_time(name, now)
---
---   @file    jobs/blm/functions/logic/refiner/timing_guards.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-09 (extracted from spell_refiner.lua)
---  ═══════════════════════════════════════════════════════════════════════════

local TimingGuards = {}

--- Default cooldown after any spell replacement (allows normal recast).
local REPLACEMENT_COOLDOWN = 0.2

--- Default per-spell cooldown (used by Breakga -> Break).
local CAST_COOLDOWN = 2.0

-- Module-local state (resets on gs reload)
local last_replacement_time = 0
local last_cast_times = {}  -- [spell_name] = timestamp

--- Check if global spell replacement is safe (not in cooldown window).
--- @param current_time number Result of os.clock()
--- @param cooldown number?   Optional override (defaults to REPLACEMENT_COOLDOWN)
--- @return boolean True if enough time has passed since last replacement
function TimingGuards.is_replacement_safe(current_time, cooldown)
    local cd = cooldown or REPLACEMENT_COOLDOWN
    return (current_time - last_replacement_time) >= cd
end

--- Stamp the current time as the latest replacement timestamp.
--- @param current_time number Result of os.clock()
function TimingGuards.update_replacement_time(current_time)
    last_replacement_time = current_time
end

--- Check if a specific spell can be cast (not in per-spell cooldown).
--- @param spell_name string  Spell name key (e.g. 'Breakga_to_Break')
--- @param current_time number Result of os.clock()
--- @return boolean True if enough time has passed since last cast of this spell
function TimingGuards.is_spell_safe_to_cast(spell_name, current_time)
    local last_cast = last_cast_times[spell_name]
    if not last_cast then
        return true
    end
    return (current_time - last_cast) >= CAST_COOLDOWN
end

--- Stamp the current time as the latest cast timestamp for this spell.
--- @param spell_name string
--- @param current_time number Result of os.clock()
function TimingGuards.update_cast_time(spell_name, current_time)
    last_cast_times[spell_name] = current_time
end

return TimingGuards
