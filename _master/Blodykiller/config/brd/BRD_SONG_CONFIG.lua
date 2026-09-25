---============================================================================
--- BRD Song Configuration - Blodykiller
---============================================================================
--- Centralized configuration for BRD song rotations, packs, and settings.
--- Pack names must match the values of state.SongMode (BRD_STATES.lua).
---
--- Blodykiller: copy of the template plus his 'Gab' pack, and his own dummy
--- songs (his dummy_map / Win+1-5 keys) in DUMMY_SONGS.
---
--- @file config/brd/BRD_SONG_CONFIG.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-13
---============================================================================

local BRDSongConfig = {}

---============================================================================
--- SONG ROTATION PACKS
---============================================================================

BRDSongConfig.SONG_PACKS = {
    -- Blody's "buffs" command. The rotation sings songs 1-4 without Clarion
    -- Call and 1-5 with it; his command did the same: Honor March, Minuet IV,
    -- Minuet V and the STR Etude, plus Minuet III under Clarion Call. So
    -- Minuet III is last here.
    -- Under /WHM his command also sang Mage's Ballad III on himself with
    -- Pianissimo after the pack; a pack cannot hold a sub-job extra, so that
    -- song is not part of it.
    Gab = {
        name = "Gab Pack",
        description = "Honor March, Minuets, STR Etude",
        songs = {
            'Honor March',       -- [1] Haste + Attack + Accuracy (Marsyas)
            'Valor Minuet V',    -- [2] Attack
            'Valor Minuet IV',   -- [3] Attack
            'Herculean Etude',   -- [4] STR
            'Valor Minuet III',  -- [5] Attack (Clarion Call only)
        }
    },

    -- Melee DPS Packs (Party-wide buffs)
    Dirge = {
        name = "Dirge Pack",
        description = "Balanced offense with EXP protection",
        songs = {
            'Honor March',         -- [1] Haste + Attack + Accuracy (REQUIRES Marsyas!)
            'Valor Minuet V',      -- [2] Attack +112
            'Valor Minuet IV',     -- [3] Attack +96
            'Adventurer\'s Dirge', -- [4] Reduces EXP loss on death
            'Victory March',       -- [5] Haste + Attack
        }
    },
    March = {
        name = "March Pack",
        description = "Double march rotation",
        songs = {
            'Honor March',        -- [1] Haste + Attack + Accuracy
            'Valor Minuet V',     -- [2] Attack +112
            'Valor Minuet IV',    -- [3] Attack +96
            'Victory March',      -- [4] Haste + Attack
            'Sentinel\'s Scherzo' -- [5] Critical hit evasion
        }
    },
    Madrigal = {
        name = "Madrigal Pack",
        description = "Maximum accuracy for high-evasion targets",
        songs = {
            'Honor March',     -- [1] Haste + Attack + Accuracy
            'Valor Minuet V',  -- [2] Attack +112
            'Valor Minuet IV', -- [3] Attack +96
            'Blade Madrigal',  -- [4] Accuracy +60
            'Victory March',   -- [5] Haste + Attack
        }
    },
    Minne = {
        name = "Minne Pack",
        description = "Offensive power with defensive buffer",
        songs = {
            'Honor March',       -- [1] Haste + Attack + Accuracy
            'Valor Minuet V',    -- [2] Attack +112
            'Valor Minuet IV',   -- [3] Attack +96
            'Knight\'s Minne V', -- [4] Defense +200
            'Victory March',     -- [5] Haste + Attack
        }
    },
    Etude = {
        name = "Etude Pack",
        description = "STR enhancement for heavy WS damage",
        songs = {
            'Honor March',     -- [1] Haste + Attack + Accuracy
            'Valor Minuet V',  -- [2] Attack +112
            'Valor Minuet IV', -- [3] Attack +96
            'Herculean Etude', -- [4] STR +13
            'Victory March',   -- [5] Haste + Attack
        }
    },

    -- Support Packs (Single-target via Pianissimo)
    Tank = {
        name = "Tank Pack",
        description = "Defense and MP recovery for tanks",
        songs = {
            'Victory March',      -- [1] Haste for enmity
            'Knight\'s Minne V',  -- [2] Defense +200
            'Mage\'s Ballad III', -- [3] MP Recovery +10/tick
            'Mage\'s Ballad II',  -- [4] MP Recovery +7/tick
            'Sentinel\'s Scherzo' -- [5] Critical hit evasion
        }
    },
    Healer = {
        name = "Healer Pack",
        description = "MP recovery and protection for healers",
        songs = {
            'Victory March',      -- [1] Haste for faster casting
            'Knight\'s Minne V',  -- [2] Defense +200
            'Mage\'s Ballad III', -- [3] MP Recovery +10/tick
            'Mage\'s Ballad II',  -- [4] MP Recovery +7/tick
            'Sentinel\'s Scherzo' -- [5] Critical hit evasion
        }
    },
    Carol = {
        name = "Carol Pack",
        description = "Elemental resistance and defensive buffs",
        songs = {
            'Honor March',     -- [1] Haste + Attack + Accuracy
            'Valor Minuet V',  -- [2] Attack +112
            'Valor Minuet IV', -- [3] Attack +96
            'Fire Carol II',   -- [4] Fire resistance +50%
            'Victory March',   -- [5] Haste + Attack
        }
    },
    Scherzo = {
        name = "Scherzo Pack",
        description = "Critical hit evasion and defensive buffs",
        songs = {
            'Honor March',         -- [1] Haste + Attack + Accuracy
            'Valor Minuet V',      -- [2] Attack +112
            'Valor Minuet IV',     -- [3] Attack +96
            'Sentinel\'s Scherzo', -- [4] Critical hit evasion
            'Victory March',       -- [5] Haste + Attack
        }
    },
    Arebati = {
        name = "Arebati",
        description = "Critical hit evasion and defensive buffs",
        songs = {
            "Adventurer's Dirge",  -- [1] Reduces EXP loss on death
            "Honor March",         -- [2] Haste + Attack + Accuracy
            'Valor Minuet V',      -- [3] Attack +112
            'Valor Minuet IV',     -- [4] Attack +96
            'Knight\'s Minne V',   -- [5] Defense +200
        }
    },
    Ngai = {
        name = "Ngai",
        description = "Critical hit evasion and defensive buffs",
        songs = {
            "Honor March",         -- [1] Haste + Attack + Accuracy
            "Valor Minuet V",      -- [2] Attack +112
            'Water Carol II',      -- [3] Water resistance
            'Knight\'s Minne V',   -- [4] Defense +200
            'Sentinel\'s Scherzo', -- [5] Critical hit evasion
        }
    }
}

---============================================================================
--- DUMMY SONG CONFIGURATION
---============================================================================

BRDSongConfig.DUMMY_SONGS = {
    -- His dummy_map, in the order of his Win+1-5 keys. Each one has a
    -- by-name alias of sets.midcast.DummySong in brd_sets.lua.
    standard = {
        'Fowl Aubade',       -- [1] Sleep resistance
        "Army's Paeon",      -- [2] Regen (tier I)
        "Knight's Minne",    -- [3] Defense (tier I)
        'Enchanting Etude',  -- [4] CHR (tier I)
        'Shining Fantasia'   -- [5] Blind resistance
    }
}

---============================================================================
--- ETUDE SONGS BY STAT
---============================================================================

BRDSongConfig.ETUDES = {
    STR = 'Herculean Etude',
    DEX = 'Uncanny Etude',
    VIT = 'Vital Etude',
    AGI = 'Swift Etude',
    INT = 'Sage Etude',
    MND = 'Logical Etude',
    CHR = 'Bewitching Etude'
}

---============================================================================
--- VICTORY MARCH REPLACEMENT
---============================================================================

--- Mode comes from state.VictoryMarch (Ctrl+Numpad7). Two modes are absent from
--- the table on purpose: 'Etude' resolves at cast time from state.EtudeType (Apps+Numpad1),
--- and 'None' has no entry so the lookup misses and Victory March stays.
BRDSongConfig.VICTORY_MARCH_REPLACE = {
    enabled = true,
    default = 'Madrigal',
    replacements = {
        Madrigal = 'Blade Madrigal',
        Minuet = 'Valor Minuet III'
    }
}

---============================================================================
--- SHORT NAMES FOR DISPLAY
---============================================================================

BRDSongConfig.SHORT_NAMES = {
    -- March songs
    ['Honor March'] = 'Honor',
    ['Victory March'] = 'Victory',

    -- Minuet songs
    ['Valor Minuet V'] = 'Min5',
    ['Valor Minuet IV'] = 'Min4',
    ['Valor Minuet III'] = 'Min3',

    -- Madrigal songs
    ['Blade Madrigal'] = 'Madrigal',
    ['Sword Madrigal'] = 'Sword Mad',

    -- Minne songs
    ['Knight\'s Minne V'] = 'Minne5',
    ['Knight\'s Minne IV'] = 'Minne4',

    -- Ballad songs
    ['Mage\'s Ballad III'] = 'Ballad3',
    ['Mage\'s Ballad II'] = 'Ballad2',
    ['Mage\'s Ballad'] = 'Ballad1',

    -- Other songs
    ['Adventurer\'s Dirge'] = 'Dirge',
    ['Sentinel\'s Scherzo'] = 'Scherzo',

    -- Etude songs (stat buffs)
    ['Herculean Etude'] = 'STR',
    ['Uncanny Etude'] = 'DEX',
    ['Vital Etude'] = 'VIT',
    ['Swift Etude'] = 'AGI',
    ['Sage Etude'] = 'INT',
    ['Logical Etude'] = 'MND',
    ['Bewitching Etude'] = 'CHR',

    -- Carol songs (elemental resistance)
    ['Fire Carol II'] = 'FireCarol',
    ['Ice Carol II'] = 'IceCarol',
    ['Wind Carol II'] = 'WindCarol',
    ['Earth Carol II'] = 'EarthCarol',
    ['Lightning Carol II'] = 'LtngCarol',
    ['Water Carol II'] = 'WaterCarol',
    ['Light Carol II'] = 'LightCarol',
    ['Dark Carol II'] = 'DarkCarol',

    -- Threnody songs (elemental resistance debuff)
    ['Fire Threnody II'] = 'FireThren',
    ['Ice Threnody II'] = 'IceThren',
    ['Wind Threnody II'] = 'WindThren',
    ['Earth Threnody II'] = 'EarthThren',
    ['Ltng. Threnody II'] = 'LtngThren',
    ['Water Threnody II'] = 'WaterThren',
    ['Light Threnody II'] = 'LightThren',
    ['Dark Threnody II'] = 'DarkThren',

    -- Dummy songs
    ['Gold Capriccio'] = 'GoldCap',
    ['Goblin Gavotte'] = 'Gavotte',
    ['Fowl Aubade'] = 'Aubade',
    ['Herb Pastoral'] = 'Pastoral',
    ['Shining Fantasia'] = 'Fantasia',
    ["Army's Paeon"] = 'Paeon',
    ["Knight's Minne"] = 'Minne1',
    ['Enchanting Etude'] = 'CHR1'
}

---============================================================================
--- SONG REFINEMENT SYSTEM
---============================================================================
--- When a listed song is on cooldown, the mapped song is cast instead
--- (usually a lower tier; Horde Lullaby maps up to tier II)
--- Useful for Lullaby and Threnody where tier II has longer recast

BRDSongConfig.SONG_REFINE = {
    -- Enable/disable the refine system
    enabled = true,

    -- Song tier replacements (tier >> upgrade/downgrade mapping)
    tiers = {
        -- Lullaby spells
        ['Horde Lullaby'] = 'Horde Lullaby II',    -- AOE: tier 1 >> upgrade to tier 2 if tier 1 on cooldown
        ['Foe Lullaby II'] = 'Foe Lullaby',        -- Single: tier 2 >> downgrade to tier 1 if tier 2 on cooldown

        -- Elegy spells
        ['Carnage Elegy'] = 'Battlefield Elegy',

        -- Requiem spells
        ['Foe Requiem VII'] = 'Foe Requiem VI',

        -- Threnody spells (all elements)
        ['Fire Threnody II'] = 'Fire Threnody',
        ['Ice Threnody II'] = 'Ice Threnody',
        ['Wind Threnody II'] = 'Wind Threnody',
        ['Earth Threnody II'] = 'Earth Threnody',
        ['Ltng. Threnody II'] = 'Ltng. Threnody',
        ['Water Threnody II'] = 'Water Threnody',
        ['Light Threnody II'] = 'Light Threnody',
        ['Dark Threnody II'] = 'Dark Threnody'
    }
}

return BRDSongConfig
