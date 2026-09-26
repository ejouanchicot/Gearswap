---============================================================================
--- THF Keybinds - Gabvanstronger
---============================================================================
--- The template's THF keys with his keys where he had one for the same
--- state, plus his BindManager THF key (jobs.main_jobs.all.THF). Data only:
--- KeybindManager binds, filters, refreshes and unbinds them.
---
--- From his setup:
---   * !`  'gs c cycle treasuremode' (BindManager THF)   -> TreasureMode
---         (replaces the template's ^numpad3)
---   * ^` / ^~`  WeaponSet / SubSet (BindManager login.all) -> MainWeapon /
---         SubWeapon (replace the template's ^numpad1 / ^numpad2)
---   * f9   OffenseMode (Mote key)  -> HybridMode, his Normal / DT
---         (replaces the template's ^numpad9)
---   * ^f12 IdleMode, !f9 RangedMode (Mote keys, bound here to show in the HUD)
--- Template keys kept: ^numpad4 / ^numpad5 (his OffenseMode Abyssea, now the
--- AbyProc toggle and AbyWeapon; on every subjob, as his Abyssea mode was)
--- and ^numpad6 RangeLock. ~f9 (his WeaponLock) is Combat Mode
--- (config/combat_mode.lua). His RangedSet key @` is in THF_CUSTOM.lua.
--- His THF.lua bound nothing itself (shared_load only ran //find).
---
--- @file    config/thf/THF_KEYBINDS.lua
--- @author  Tetsouo
--- @version 2.1
--- @date    Created: 2025-10-06 | Updated: 2026-09-26 (Gabvanstronger)
---============================================================================

local THFKeybinds = {}

-- Format: { key = "key_combination", command = "gs_command", desc = "description", state = "state_name", subjob = "required_subjob" }
THFKeybinds.binds = {
    -- Weapons
    { key = "^`",       command = "cyclestate MainWeapon",   desc = "Main Weapon",  state = "MainWeapon" },
    { key = "^~`",      command = "cyclestate SubWeapon",    desc = "Sub Weapon",   state = "SubWeapon" },

    -- Modes
    { key = "f9",       command = "cyclestate HybridMode",   desc = "Offense Mode", state = "HybridMode" },
    { key = "^f12",     command = "cyclestate IdleMode",     desc = "Idle Mode",    state = "IdleMode" },
    { key = "!f9",      command = "cyclestate RangedMode",   desc = "Ranged Mode",  state = "RangedMode" },

    -- Treasure Hunter Mode (his BindManager THF key)
    { key = "!`",       command = "cyclestate TreasureMode", desc = "TH Mode",      state = "TreasureMode" },

    -- Abyssea Proc Mode
    { key = "^numpad4", command = "toggle AbyProc",          desc = "Aby Proc",     state = "AbyProc" },
    { key = "^numpad5", command = "cyclestate AbyWeapon",    desc = "Aby Weapon",   state = "AbyWeapon" },

    -- Ranged Weapon Lock
    { key = "^numpad6", command = "toggle RangeLock",        desc = "Range Lock",   state = "RangeLock" },
}

return require('shared/utils/keybinds/keybind_manager').create('THF', THFKeybinds)
