---============================================================================
--- BRD State Configuration - Centralized State Management
---============================================================================
--- Centralizes all BRD state definitions for consistency and maintainability.
---
--- Features:
---   • Combat modes (HybridMode: PDT/Normal, IdleMode: Refresh/DT/Regen)
---   • Song pack system (SongMode: pre-configured 4-song rotations)
---   • Instrument selection (MainInstrument: Gjallarhorn/Daurdabla/etc.)
---   • Song customization (VictoryMarch replacement, Etude, Carol, Threnody)
---   • Default state values for optimal gameplay
---   • Validation API for state verification
---
--- State Purposes:
---   • HybridMode: PDT = 50% damage reduction, Normal = maximum DPS
---   • IdleMode: Refresh/DT/Regen (idle gear focus)
---   • SongMode: Pre-configured song rotation packs (March/Madrigal/Minuet/etc.)
---   • MainInstrument: Instrument selection (Gjallarhorn REMA default)
---   • VictoryMarch: Replacement when Haste capped (Madrigal/Minuet/etc.)
---   • EtudeType: Stat buff selection (STR/DEX/VIT/AGI/INT/MND/CHR)
---   • CarolElement: Resistance buff element (Fire/Ice/Wind/Earth/Thunder/Water)
---   • ThrenodyElement: Resistance debuff element
---
--- Dependencies:
---   • Mote-Include (M state creator, state:options(), state:set())
---
--- @file    config/brd/BRD_STATES.lua
--- @author  Typioni
--- @version 1.0
--- @date    Created: 2025-10-14
---============================================================================

local BRDStates = {}

---============================================================================
--- STATE CONFIGURATION
---============================================================================

function BRDStates.configure()
    -- ========================================
    -- COMBAT MODES
    -- ========================================

    state.HybridMode = M{['description']='Hybrid Mode', 'PDT', 'Normal'}
    state.HybridMode:set('PDT')

    state.IdleMode = M {
        ['description'] = 'Idle Mode',
        'Refresh',  -- MP Refresh gear
        'DT',       -- Damage Taken reduction
        'Regen'     -- HP Regen gear
    }
    state.IdleMode:set('Refresh')

    -- ========================================
    -- SONG SYSTEM
    -- ========================================

    state.SongMode = M {
        ['description'] = 'Song Pack',
        'Dirge',      -- Honor + Min5/4 + Dirge
        'March',      -- Honor + Min5/4 + Victory + Scherzo
        'Madrigal',   -- Honor + Min5/4 + Madrigal + Victory
        'Minne',      -- Honor + Min5/4 + Minne + Victory
        'Etude',      -- Honor + Min5/4 + Etude + Victory
        'Tank',       -- Victory + Minne + Ballad rotation (for tanks)
        'Healer',     -- Victory + Minne + Ballad rotation (for healers)
        'Carol',      -- Honor + Min5/4 + Carol + Victory
        'Scherzo'     -- Honor + Min5/4 + Scherzo + Victory
    }
    state.SongMode:set('Madrigal')

    state.MainInstrument = M {
        ['description'] = 'Main Instrument',
        'Gjallarhorn',  -- REMA horn (best)
        'Daurdabla',    -- Dummy songs instrument
        'Marsyas'       -- Alternative horn
    }
    state.MainInstrument:set('Gjallarhorn')

    state.VictoryMarch = M {
        ['description'] = 'Victory March Replace',
        'Madrigal',   -- Replace with Blade Madrigal
        'Minuet',     -- Replace with Minuet
        'None'        -- Keep Victory March
    }
    state.VictoryMarch:set('Madrigal')

    state.EtudeType = M {
        ['description'] = 'Etude Type',
        'STR', 'DEX', 'VIT', 'AGI', 'INT', 'MND', 'CHR'
    }
    state.EtudeType:set('STR')

    state.CarolElement = M {
        ['description'] = 'Carol Element',
        'Fire', 'Ice', 'Wind', 'Earth', 'Thunder', 'Water'
    }
    state.CarolElement:set('Fire')

    state.ThrenodyElement = M {
        ['description'] = 'Threnody Element',
        'Fire', 'Ice', 'Wind', 'Earth', 'Lightning', 'Water', 'Light', 'Dark'
    }
    state.ThrenodyElement:set('Fire')

    state.MarcatoSong = M {
        ['description'] = 'Auto-Marcato Song',
        'HonorMarch',   -- Auto-Marcato for Honor March with Nitro
        'AriaPassion',  -- Auto-Marcato for Aria of Passion with Nitro
        'Off'           -- Disable auto-Marcato
    }
    state.MarcatoSong:set('HonorMarch')

    -- ========================================
    -- WEAPON SELECTION
    -- ========================================

    state.MainWeapon = M {
        ['description'] = 'Main Weapon',
        'Naegling', 'Twashtar', 'Carnwenhan', 'Mpu Gandring'
    }
    state.MainWeapon:set('Naegling')

    state.SubWeapon = M {
        ['description'] = 'Sub Weapon',
        'Demersal', 'Genmei', 'Centovente'
    }
    state.SubWeapon:set('Demersal')

    -- ========================================
    -- SONG SLOTS (display only)
    -- ========================================

    state.BRDSong1 = M { ['description'] = 'Song 1', 'Empty' }
    state.BRDSong2 = M { ['description'] = 'Song 2', 'Empty' }
    state.BRDSong3 = M { ['description'] = 'Song 3', 'Empty' }
    state.BRDSong4 = M { ['description'] = 'Song 4', 'Empty' }
    state.BRDSong5 = M { ['description'] = 'Song 5', 'Empty' }

    -- NOTE: Song slots are initialized in user_setup() after states are configured
end

---============================================================================
--- VALIDATION
---============================================================================

function BRDStates.validate()
    if not state.HybridMode then return false, "HybridMode not configured" end
    if not state.IdleMode then return false, "IdleMode not configured" end
    if not state.SongMode then return false, "SongMode not configured" end
    if not state.MainInstrument then return false, "MainInstrument not configured" end
    if not state.VictoryMarch then return false, "VictoryMarch not configured" end
    if not state.EtudeType then return false, "EtudeType not configured" end
    if not state.CarolElement then return false, "CarolElement not configured" end
    if not state.ThrenodyElement then return false, "ThrenodyElement not configured" end
    if not state.MarcatoSong then return false, "MarcatoSong not configured" end
    return true, "All BRD states configured successfully"
end

return BRDStates
