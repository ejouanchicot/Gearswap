---============================================================================
--- BRD Keybinds - Blodykiller
---============================================================================
--- Our BRD keys (numpad, same as the template) plus the ones Blody had in
--- BindManager (jobs.main_jobs.BRD): abilities on Alt+F1-F3, songs on Alt+1-6,
--- dummy songs and debuffs on Win+keys. Sent exactly as BindManager sent them
--- (raw = true: "/recast" first, the "[Fake #n]" echo of the dummy songs).
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

    -- Apps+Numpad2: Auto Nitro (Nightingale + Troubadour before //gs c songs)
    { key = "#numpad2", command = "cyclestate AutoNitro", desc = "Auto Nitro", state = "AutoNitro" },


    ---========================================================================
    --- BLODY'S OWN KEYS (from BindManager)
    ---========================================================================
    { key = "!f1", command = "input /ja \"Nightingale\" <me>", raw = true, desc = "Nightingale" },
    { key = "!f2", command = "input /ja \"Troubadour\" <me>", raw = true, desc = "Troubadour" },
    { key = "!f3", command = "input /ja \"Marcato\" <me>", raw = true, desc = "Marcato" },
    { key = "!`", command = "input /ma \"Chocobo Mazurka\" <me>", raw = true, desc = "Chocobo Mazurka" },

    { key = "!1", command = "input /recast \"Honor March\"; input /ma \"Honor March\" <stpc>", raw = true, desc = "Honor March" },
    { key = "!2", command = "input /recast \"Victory March\"; input /ma \"Victory March\" <stpc>", raw = true, desc = "Victory March" },
    { key = "!3", command = "input /recast \"Valor Minuet V\"; input /ma \"Valor Minuet V\" <stpc>", raw = true, desc = "Valor Minuet V" },
    { key = "!4", command = "input /recast \"Valor Minuet IV\"; input /ma \"Valor Minuet IV\" <stpc>", raw = true, desc = "Valor Minuet IV" },
    { key = "!5", command = "input /recast \"Valor Minuet III\"; input /ma \"Valor Minuet III\" <stpc>", raw = true, desc = "Valor Minuet III" },
    { key = "!6", command = "input /recast \"Valor Minuet II\"; input /ma \"Valor Minuet II\" <stpc>", raw = true, desc = "Valor Minuet II" },

    -- Dummy songs
    { key = "@1", command = "input /echo [Fake #1]; input /recast \"Fowl Aubade\"; input /ma \"Fowl Aubade\" <stpc>", raw = true, desc = "Dummy: Fowl Aubade" },
    { key = "@2", command = "input /echo [Fake #2]; input /recast \"Army's Paeon\"; input /ma \"Army's Paeon\" <stpc>", raw = true, desc = "Dummy: Army's Paeon" },
    { key = "@3", command = "input /echo [Fake #3]; input /recast \"Knight's Minne\"; input /ma \"Knight's Minne\" <stpc>", raw = true, desc = "Dummy: Knight's Minne" },
    { key = "@4", command = "input /echo [Fake #4]; input /recast \"Enchanting Etude\"; input /ma \"Enchanting Etude\" <stpc>", raw = true, desc = "Dummy: Enchanting Etude" },
    { key = "@5", command = "input /echo [Fake #5]; input /recast \"Shining Fantasia\"; input /ma \"Shining Fantasia\" <stpc>", raw = true, desc = "Dummy: Shining Fantasia" },
    { key = "@6", command = "input /recast \"Blade Madrigal\"; input /ma \"Blade Madrigal\" <stpc>", raw = true, desc = "Blade Madrigal" },
    { key = "@7", command = "input /recast \"Sword Madrigal\"; input /ma \"Sword Madrigal\" <stpc>", raw = true, desc = "Sword Madrigal" },

    -- Debuffs
    { key = "@q", command = "input /recast \"Horde Lullaby\"; input /ma \"Horde Lullaby\" <stnpc>", raw = true, desc = "Horde Lullaby" },
    { key = "@w", command = "input /recast \"Horde Lullaby II\"; input /ma \"Horde Lullaby II\" <stnpc>", raw = true, desc = "Horde Lullaby II" },
    { key = "@e", command = "input /recast \"Carnage Elegy\"; input /ma \"Carnage Elegy\" <stnpc>", raw = true, desc = "Carnage Elegy" },
    { key = "@r", command = "input /recast \"Foe Lullaby\"; input /ma \"Foe Lullaby\" <stnpc>", raw = true, desc = "Foe Lullaby" },
    { key = "@t", command = "input /recast \"Foe Lullaby II\"; input /ma \"Foe Lullaby II\" <stnpc>", raw = true, desc = "Foe Lullaby II" },
    { key = "@a", command = "input /recast \"Pining Nocturne\"; input /ma \"Pining Nocturne\" <stnpc>", raw = true, desc = "Pining Nocturne" },
    { key = "@f", command = "input /recast \"Foe Requiem VII\"; input /ma \"Foe Requiem VII\" <stnpc>", raw = true, desc = "Foe Requiem VII" },
    { key = "@x", command = "input /recast \"Magic Finale\"; input /ma \"Magic Finale\" <stnpc>", raw = true, desc = "Magic Finale" },

    -- Ballads
    { key = "@c", command = "input /recast \"Mage's Ballad III\"; input /ma \"Mage's Ballad III\" <stpc>", raw = true, desc = "Mage's Ballad III" },
    { key = "@v", command = "input /recast \"Mage's Ballad II\"; input /ma \"Mage's Ballad II\" <stpc>", raw = true, desc = "Mage's Ballad II" },
    { key = "@b", command = "input /recast \"Mage's Ballad\"; input /ma \"Mage's Ballad\" <stpc>", raw = true, desc = "Mage's Ballad" },
}

return require('shared/utils/keybinds/keybind_manager').create('BRD', BRDKeybinds)
