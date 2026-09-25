---============================================================================
--- PLD Keybind Configuration
---============================================================================
--- Paladin keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them.
---
--- @file    config/pld/PLD_KEYBINDS.lua
--- @author  Tetsouo
--- @version 2.0.0
--- @date    Created: 2025-10-03 | Updated: 2026-09-24 (KeybindManager)
---============================================================================

local PLDKeybinds = {}

--- Keybind definitions for PLD job
--- Format: { key = "key_combo", command = "gs_command", desc = "description",
---           state = "state_name", subjob = "required_subjob",
---           exclude_subjob = "subjob_that_skips_this_bind",
---           visible = function() ... end }
---
--- `subjob` and `exclude_subjob` are settled once per load; `visible` is asked
--- again on every HUD refresh, for a bind whose usefulness depends on a state
--- rather than on the job.
---
--- Under /SCH Phalanx SIRD is held on, so its bind is excluded rather than
--- left cycling a state nothing reads any more; Ctrl+Numpad2 is free there.
--- The weapon stays cyclable: the /SCH stances pick the set, not the sword.
PLDKeybinds.binds = { -- Hybrid Mode (PDT/MDT/Sortie, DPS/Tanking/Hoxne under /SCH)
{
    key = "^numpad9",
    command = "cyclestate HybridMode",
    desc = "Hybrid Mode",
    state = "HybridMode"
}, -- Weapon Management
{
    key = "^numpad1",
    command = "cyclestate MainWeapon",
    desc = "Main Weapon",
    state = "MainWeapon",
    -- Under /SCH the Tanking stance holds Burtgang whatever this says, so the
    -- choice has nothing to act on there: hide the row and drop the key rather
    -- than leave a live-looking control that changes nothing until you leave
    -- the stance.
    visible = function()
        return not (player and player.sub_job == 'SCH'
            and state and state.HybridMode and state.HybridMode.value == 'Tanking')
    end
}, -- XP Mode (PLD/RDM subjob only)
{
    key = "^numpad4",
    command = "cyclestate Xp",
    desc = "XP Mode",
    state = "Xp",
    subjob = "RDM"
}, -- Rune Mode (PLD/RUN subjob only)
{
    key = "^numpad3",
    command = "cyclestate RuneMode",
    desc = "Rune Mode",
    state = "RuneMode",
    subjob = "RUN"
},
    { key = "^numpad2", command = "cyclestate PhalanxSIRD", desc = "Phalanx SIRD", state = "PhalanxSIRD", exclude_subjob = "SCH" },
    -- Regen: ^numpad2 toggles it under /SCH, where Phalanx SIRD (the same
    -- key on the other subjobs) is off. Macros can still set an explicit
    -- value with `gs c set Regen On|Off`.
    { key = "^numpad2", command = "cyclestate Regen", desc = "Regen", state = "Regen", subjob = "SCH" },
    { key = "^numpad5", command = "cyclestate WS1", desc = "WS Slot 1", state = "WS1" },
    { key = "^numpad6", command = "cyclestate WS2", desc = "WS Slot 2", state = "WS2" },
}

--- Keys this file used to bind and no longer does, unbound on every load.
--- ^numpad7 held SneakInviAOE, retired when /SCH started holding it On.
PLDKeybinds.retired_keys = {
    "^numpad7"
}

return require('shared/utils/keybinds/keybind_manager').create('PLD', PLDKeybinds)
