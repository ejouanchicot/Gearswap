---============================================================================
--- SMN States Configuration
---============================================================================
--- State definitions for Summoner job.
--- Loaded by user_setup() in Tetsouo_SMN.lua
---
--- @file config/smn/SMN_STATES.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-05-28
---============================================================================

local SMNStates = {}

--- Configure all SMN states
function SMNStates.configure()
    -- Idle mode: standard / damage taken / Avatar's Favor
    state.IdleMode = M{['description']='Idle Mode', 'Normal', 'DT', 'Avatar'}
    state.IdleMode:set('Normal')

    -- Casting mode for magic (resistance scaling on hard targets)
    state.CastingMode = M{['description']='Casting Mode', 'Normal', 'Resistant'}
    state.CastingMode:set('Normal')

    -- Avatar's Favor toggle - when ON, sets.idle.Avatar overrides the active idle
    state.AvatarFavor = M(false, 'Avatar Favor')

    -- Moving state (AutoMove writes here)
    state.Moving = M{['description']='Moving', 'false', 'true'}
    state.Moving:set('false')

    -- Fast Cast % for watchdog timeout calculation
    state.FastCast = M{
        ['description'] = 'Fast Cast %',
        0, 10, 20, 30, 40, 50, 60, 70, 80
    }
    state.FastCast:set(0)

    -- Universal toggle, created here rather than centrally: the keybind HUD
    -- renders from user_setup() and caches what it reads, so a state added
    -- afterwards shows as N/A until something forces a redraw.
    local ok, AutoMedicine = pcall(require, 'shared/utils/debuff/auto_medicine')
    if ok and AutoMedicine then
        AutoMedicine.init(state, M)
    end
end

return SMNStates
