---============================================================================
--- BRD Keybind Configuration
---============================================================================
--- BRD keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua.
---
--- @file    config/brd/BRD_KEYBINDS.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-10-13 | Updated: 2026-09-24 (KeybindManager)
---============================================================================

local BRDKeybinds = {}

-- Keybind definitions
-- Format: { key = "key", command = "gs_command", desc = "description", state = "state_name" }
BRDKeybinds.binds = {
    ---========================================================================
    --- STATE CYCLING - Ctrl+Numpad (^) and Apps+Numpad (#)
    ---========================================================================

    -- Ctrl+Numpad4: Idle Mode (Refresh/DT/Regen)
    { key = "^numpad4", command = "cyclestate IdleMode", desc = "Idle Mode", state = "IdleMode" },

    -- Ctrl+Numpad5: Engaged Mode (STP/Acc/DT/SB)
    { key = "^numpad5", command = "cyclestate EngagedMode", desc = "Engaged Mode", state = "EngagedMode" },

    -- Ctrl+Numpad6: Song Pack (packs defined in BRD_SONG_CONFIG.lua)
    { key = "^numpad6", command = "cyclestate SongMode", desc = "Song Pack", state = "SongMode" },

    -- Ctrl+Numpad3: Main Instrument (Gjallarhorn/Daurdabla/Marsyas)
    { key = "^numpad3", command = "cyclestate MainInstrument", desc = "Instrument", state = "MainInstrument" },

    -- Ctrl+Numpad7: Victory March Replacement Mode (Madrigal/Minuet/Etude/None)
    { key = "^numpad7", command = "cyclestate VictoryMarch", desc = "Victory March Replace", state = "VictoryMarch" },

    -- Ctrl+Numpad1: Main Weapon (Naegling/Twashtar/Carnwenhan/Mpu Gandring)
    { key = "^numpad1", command = "cyclestate MainWeapon", desc = "Main Weapon", state = "MainWeapon" },

    -- Ctrl+Numpad2: Sub Weapon (Kraken/Demersal/Genmei/Centovente)
    { key = "^numpad2", command = "cyclestate SubWeapon", desc = "Sub Weapon", state = "SubWeapon" },

    -- Apps+Numpad1: Etude Type (STR/DEX/VIT/AGI/INT/MND/CHR)
    { key = "#numpad1", command = "cyclestate EtudeType", desc = "Etude Type", state = "EtudeType" },

    -- Ctrl+Numpad0: Carol Element (Fire/Ice/Wind/Earth/Lightning/Water/Light/Dark)
    { key = "^numpad0", command = "cyclestate CarolElement", desc = "Carol Element", state = "CarolElement" },

    -- Ctrl+Numpad.: Threnody Element (Fire/Ice/Wind/Earth/Lightning/Water/Light/Dark)
    { key = "^numpad.", command = "cyclestate ThrenodyElement", desc = "Threnody Element", state = "ThrenodyElement" },

    -- Ctrl+Numpad8: Auto-Marcato Song (HonorMarch/AriaPassion/Off)
    { key = "^numpad8", command = "cyclestate MarcatoSong", desc = "Auto-Marcato Song", state = "MarcatoSong" },

    -- Apps+Numpad0: Auto Medicine (universal toggle)

    -- No action keys (abilities, song casts) are bound in this file.
}

return require('shared/utils/keybinds/keybind_manager').create('BRD', BRDKeybinds)
