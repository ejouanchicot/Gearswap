---============================================================================
--- BRD Keybind Configuration
---============================================================================
--- Complete keybind configuration for Bard job.
--- Migrated from old TETSOUO_BRD.lua system.
---
--- @file config/brd/BRD_KEYBINDS.lua
--- @author Kaories
--- @version 2.0 - Migrated from old system
--- @date Created: 2025-10-13
---============================================================================

local BRDKeybinds = {}

-- Load message formatter
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Keybind definitions
-- Format: { key = "key", command = "gs_command", desc = "description", state = "state_name" }
BRDKeybinds.binds = {
    ---========================================================================
    --- ALT + KEYS (States/Cycling) - !1 to !9, !-, !=
    ---========================================================================

    -- Alt+1: Idle Mode (Refresh/DT/Regen)
    { key = "!1", command = "cycle IdleMode", desc = "Idle Mode", state = "IdleMode" },

    -- Alt+2: Hybrid Mode (PDT/Normal)
    { key = "!2", command = "cycle HybridMode", desc = "Hybrid Mode", state = "HybridMode" },

    -- Alt+3: Song Pack Rotation (March/Dirge/Madrigal/Minne/Etude/Carol/Scherzo/Tank/Healer)
    { key = "!3", command = "cycle SongMode", desc = "Song Pack", state = "SongMode" },

    -- Alt+4: Main Instrument (Gjallarhorn/Marsyas/Daurdabla)
    { key = "!4", command = "cycle MainInstrument", desc = "Instrument", state = "MainInstrument" },

    -- Alt+5: Victory March Replacement Mode (Madrigal/Minne/Scherzo)
    { key = "!5", command = "cycle VictoryMarch", desc = "Victory March Replace", state = "VictoryMarch" },

    -- Alt+6: Main Weapon (Naegling/Twashtar/Carnwenhan/Mpu Gandring)
    { key = "!6", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon" },

    -- Alt+7: Sub Weapon (Demersal/Genmei/Centovente)
    { key = "!7", command = "cycle SubWeapon", desc = "Sub Weapon", state = "SubWeapon" },

    -- Alt+8: Etude Type (STR/DEX/VIT/AGI/INT/MND/CHR)
    { key = "!8", command = "cycle EtudeType", desc = "Etude Type", state = "EtudeType" },

    -- Alt+9: Carol Element (Fire/Ice/Wind/Earth/Lightning/Water/Light/Dark)
    { key = "!9", command = "cycle CarolElement", desc = "Carol Element", state = "CarolElement" },

    -- Alt+-: Threnody Element (Fire/Ice/Wind/Earth/Lightning/Water/Light/Dark)
    { key = "!-", command = "cycle ThrenodyElement", desc = "Threnody Element", state = "ThrenodyElement" },

    -- Alt+=: Auto-Marcato Song (HonorMarch/AriaPassion/Off)
    { key = "!=", command = "cycle MarcatoSong", desc = "Auto-Marcato Song", state = "MarcatoSong" },

    ---========================================================================
    --- CTRL + KEYS (Actions/Abilities) - ^1 to ^9, ^-, ^=
    ---========================================================================

    -- Ctrl+1: Soul Voice
    { key = "^1", command = "soul_voice", desc = "Soul Voice" },

    -- Ctrl+2: Nightingale
    { key = "^2", command = "nightingale", desc = "Nightingale" },

    -- Ctrl+3: Troubadour
    { key = "^3", command = "troubadour", desc = "Troubadour" },

    -- Ctrl+4: Nightingale + Troubadour Combo
    { key = "^4", command = "nt", desc = "Nightingale+Troubadour" },

    -- Ctrl+5: Cast current song pack
    { key = "^5", command = "songs", desc = "Cast Song Pack" },

    -- Ctrl+6: Cast dummy songs
    { key = "^6", command = "dummy", desc = "Cast Dummy Songs" },

    -- Ctrl+7: Marcato
    { key = "^7", command = "marcato", desc = "Marcato" },

    -- Ctrl+8: Pianissimo
    { key = "^8", command = "pianissimo", desc = "Pianissimo" },

    -- Ctrl+9: Cast Threnody (current element)
    { key = "^9", command = "threnody", desc = "Cast Threnody" },

    -- Ctrl+-: Cast Carol (current element)
    { key = "^-", command = "carol", desc = "Cast Carol" },

    -- Ctrl+=: Cast Etude (current type)
    { key = "^=", command = "etude", desc = "Cast Etude" },
}

---============================================================================
--- KEYBIND MANAGEMENT
---============================================================================

--- Apply all keybinds
function BRDKeybinds.bind_all()
    if not BRDKeybinds.binds or #BRDKeybinds.binds == 0 then
        MessageFormatter.show_no_binds_error("BRD")
        return false
    end

    local bound_count = 0
    for _, bind in ipairs(BRDKeybinds.binds) do
        local success, error_msg = pcall(send_command, 'bind ' .. bind.key .. ' gs c ' .. bind.command)
        if success then
            bound_count = bound_count + 1
        else
            MessageFormatter.show_bind_failed_error(bind.key, tostring(error_msg), "BRD")
        end
    end

    if bound_count > 0 then
        BRDKeybinds.show_intro()
        return true
    end

    return false
end

--- Remove all keybinds
function BRDKeybinds.unbind_all()
    if not BRDKeybinds.binds then return end

    for _, bind in ipairs(BRDKeybinds.binds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end

    MessageFormatter.show_success("BRD keybinds unloaded.")
end

--- Display BRD system intro message with macrobook and lockstyle info
function BRDKeybinds.show_intro()
    -- Try to get macro info from BRD_MACROBOOK module
    local macro_info = nil
    if _G.get_brd_macro_info then
        macro_info = _G.get_brd_macro_info()
    end

    -- Try to get lockstyle info from BRD_LOCKSTYLE module
    local lockstyle_info = nil
    local lockstyle_success, BRD_LOCKSTYLE = pcall(require, 'shared/jobs/brd/functions/BRD_LOCKSTYLE')
    if lockstyle_success and BRD_LOCKSTYLE and BRD_LOCKSTYLE.get_lockstyle_info then
        lockstyle_info = BRD_LOCKSTYLE.get_lockstyle_info()
    end

    -- Show complete intro with macro and lockstyle info
    if macro_info or lockstyle_info then
        MessageFormatter.show_system_intro_complete("BRD SYSTEM LOADED", BRDKeybinds.binds, macro_info, lockstyle_info)
    else
        -- Fallback to regular intro if no additional info available
        MessageFormatter.show_system_intro("BRD SYSTEM LOADED", BRDKeybinds.binds)
    end
end

--- Display current keybind configuration
function BRDKeybinds.show_binds()
    MessageFormatter.show_keybind_list("BRD Keybinds", BRDKeybinds.binds)
end

return BRDKeybinds
