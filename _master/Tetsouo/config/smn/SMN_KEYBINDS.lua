---============================================================================
--- SMN Keybind Configuration
---============================================================================
--- SMN keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua.
---
--- @file    config/smn/SMN_KEYBINDS.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2026-05-28 | Updated: 2026-09-24 (KeybindManager)
---============================================================================

local SMNKeybinds = {}

---============================================================================
--- KEYBIND DEFINITIONS
---============================================================================
SMNKeybinds.binds = {
    ---==========================================================================
    --- CASTING / IDLE MODES (Number Keys)
    ---==========================================================================
    { key = "^numpad1", command = "cyclestate IdleMode",     desc = "Idle Mode",     state = "IdleMode"     },
    { key = "^numpad2", command = "cyclestate CastingMode",  desc = "Casting Mode",  state = "CastingMode"  },
    { key = "^numpad3", command = "cyclestate AvatarFavor",  desc = "Avatar Favor",  state = "AvatarFavor"  },
    { key = "#numpad0", command = "cyclestate AutoMedicine", desc = "Auto Medicine", state = "AutoMedicine" },

    ---==========================================================================
    --- JOB ABILITIES (Function keys + modifiers)
    ---==========================================================================

    ---==========================================================================
    --- AVATAR SUMMONS (numpad)
    ---==========================================================================
}

return require('shared/utils/keybinds/keybind_manager').create('SMN', SMNKeybinds)
