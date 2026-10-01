---============================================================================
--- PLD Keybind Configuration
---============================================================================
--- Paladin keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them.
---
--- @file    config/pld/PLD_KEYBINDS.lua
--- @author  ejouanchicot
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
--- Phalanx SIRD stays on Ctrl+Numpad2 under every subjob (On by default under
--- /SCH); Regen, /SCH only, takes Ctrl+Numpad3 (Rune Mode's key, which only /RUN uses).
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
    -- Phalanx SIRD: one key under every subjob (under /SCH On by default, Off for a
    -- fight where the Phalanx potency matters more than not being interrupted: Sortie Aminon)
    { key = "^numpad2", command = "cyclestate PhalanxSIRD", desc = "Phalanx SIRD", state = "PhalanxSIRD" },
    -- Regen: /SCH only. Macros can still set an explicit value with `gs c set Regen On|Off`.
    { key = "^numpad3", command = "cyclestate Regen", desc = "Regen", state = "Regen", subjob = "SCH" },
    { key = "^numpad5", command = "cyclestate WS1", desc = "WS Slot 1", state = "WS1" },
    { key = "^numpad6", command = "cyclestate WS2", desc = "WS Slot 2", state = "WS2" },
}

--- Keys this file used to bind and no longer does, unbound on every load.
--- ^numpad7 held SneakInviAOE, retired when /SCH started holding it On.
PLDKeybinds.retired_keys = {
    "^numpad7"
}

return require('shared/utils/keybinds/keybind_manager').create('PLD', PLDKeybinds)
