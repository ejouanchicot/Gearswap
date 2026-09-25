---============================================================================
--- BRD Keybinds - Blodykiller
---============================================================================
--- Our BRD keys (numpad, same as the template) plus the ones Blody had in
--- BindManager (jobs.main_jobs.BRD): abilities on Alt+F1-F3, songs on Alt+1-6,
--- dummy songs and debuffs on Win+keys. The "/recast" they sent first is not
--- kept: a song on recast is already reported by CooldownChecker.
---
--- @file    config/brd/BRD_KEYBINDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
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


    ---========================================================================
    --- BLODY'S OWN KEYS (from BindManager)
    ---========================================================================
    { key = "!f1", command = [[/ja "Nightingale" <me>]], desc = "Nightingale" },
    { key = "!f2", command = [[/ja "Troubadour" <me>]], desc = "Troubadour" },
    { key = "!f3", command = [[/ja "Marcato" <me>]], desc = "Marcato" },
    { key = "!`", command = [[/ma "Chocobo Mazurka" <me>]], desc = "Chocobo Mazurka" },

    { key = "!1", command = [[/ma "Honor March" <stpc>]], desc = "Honor March" },
    { key = "!2", command = [[/ma "Victory March" <stpc>]], desc = "Victory March" },
    { key = "!3", command = [[/ma "Valor Minuet V" <stpc>]], desc = "Valor Minuet V" },
    { key = "!4", command = [[/ma "Valor Minuet IV" <stpc>]], desc = "Valor Minuet IV" },
    { key = "!5", command = [[/ma "Valor Minuet III" <stpc>]], desc = "Valor Minuet III" },
    { key = "!6", command = [[/ma "Valor Minuet II" <stpc>]], desc = "Valor Minuet II" },

    -- Dummy songs
    { key = "@1", command = [[/ma "Fowl Aubade" <stpc>]], desc = "Dummy: Fowl Aubade" },
    { key = "@2", command = [[/ma "Army's Paeon" <stpc>]], desc = "Dummy: Army's Paeon" },
    { key = "@3", command = [[/ma "Knight's Minne" <stpc>]], desc = "Dummy: Knight's Minne" },
    { key = "@4", command = [[/ma "Enchanting Etude" <stpc>]], desc = "Dummy: Enchanting Etude" },
    { key = "@5", command = [[/ma "Shining Fantasia" <stpc>]], desc = "Dummy: Shining Fantasia" },
    { key = "@6", command = [[/ma "Blade Madrigal" <stpc>]], desc = "Blade Madrigal" },
    { key = "@7", command = [[/ma "Sword Madrigal" <stpc>]], desc = "Sword Madrigal" },

    -- Debuffs
    { key = "@q", command = [[/ma "Horde Lullaby" <stnpc>]], desc = "Horde Lullaby" },
    { key = "@w", command = [[/ma "Horde Lullaby II" <stnpc>]], desc = "Horde Lullaby II" },
    { key = "@e", command = [[/ma "Carnage Elegy" <stnpc>]], desc = "Carnage Elegy" },
    { key = "@r", command = [[/ma "Foe Lullaby" <stnpc>]], desc = "Foe Lullaby" },
    { key = "@t", command = [[/ma "Foe Lullaby II" <stnpc>]], desc = "Foe Lullaby II" },
    { key = "@a", command = [[/ma "Pining Nocturne" <stnpc>]], desc = "Pining Nocturne" },
    { key = "@f", command = [[/ma "Foe Requiem VII" <stnpc>]], desc = "Foe Requiem VII" },
    { key = "@x", command = [[/ma "Magic Finale" <stnpc>]], desc = "Magic Finale" },

    -- Ballads
    { key = "@c", command = [[/ma "Mage's Ballad III" <stpc>]], desc = "Mage's Ballad III" },
    { key = "@v", command = [[/ma "Mage's Ballad II" <stpc>]], desc = "Mage's Ballad II" },
    { key = "@b", command = [[/ma "Mage's Ballad" <stpc>]], desc = "Mage's Ballad" },
}

return require('shared/utils/keybinds/keybind_manager').create('BRD', BRDKeybinds)
