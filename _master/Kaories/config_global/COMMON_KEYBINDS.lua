---============================================================================
--- Common Keybinds (Kaories) - keys bound for every job of this character
---============================================================================
--- Same entry format as a job's config/<job>/<JOB>_KEYBINDS.lua. A job file
--- that uses the same key keeps it: the job wins.
---
--- Keys: ^ = Ctrl, ! = Alt, @ = Win, # = Apps, ~ = Shift.
--- Numpad only, like the job files (.claude/rules/keybinds.md). F9-F12
--- belong to Mote-Include, Ctrl/Alt+F1-F8 to //gs c tb.
---
--- The //gs c alts commands reach the other characters of the box group
--- (DualBoxConfig.group in config/DUALBOX_CONFIG.lua), whoever is main.
---
--- @file config/COMMON_KEYBINDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-24
---============================================================================

local CommonKeybinds = {}

CommonKeybinds.binds = {
    { key = "#numpad0", command = "cyclestate AutoMedicine", desc = "Auto Medicine", state = "AutoMedicine" },
    { key = "!numpad7", command = "alts follow", desc = "Alts: follow me (toggle)" },
    { key = "!numpad8", command = "alts toggle", desc = "Alts: automation on/off" },
    { key = "!numpad9", command = "alts mirror", desc = "Alts: mirror" },
    -- Your own keys. Any command works:
    --   "//<command>"  console command of any addon, as typed in chat
    --   "/<command>"   game command (/p, /follow, /ma ...)
    --   "<command>"    GearSwap command (gs c <command>)
    --
    -- Every alt follows a given character:
    -- { key = "!numpad4", command = "alts follow Kaories", desc = "Alts follow Kaories" },
    -- Every alt runs a console command (here: stop following):
    -- { key = "!numpad5", command = "alts do sm follow off", desc = "Alts stop" },
    -- A console command on this character only:
    -- { key = "!numpad6", command = "//sm mirror", desc = "Mirror" },
    -- A game command:
    -- { key = "!numpad3", command = "/p Ready!", desc = "Party: ready" },
}

return CommonKeybinds
