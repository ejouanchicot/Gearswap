---============================================================================
--- SCH Alt Commands - what the alt does when it is on SCH
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether SCH is the alt's
--- MAIN job or its SUBJOB.
---
--- Generated from Windower's res/spells.lua: only spells SCH can cast, every
--- tier of a family with the level it needs, and the target taken from the
--- spell's `targets` bitmask.
---
--- The engine picks the highest tier the alt is high enough for, from the level
--- it reported. A subjob caps far below a main (Master Level 50 reaches sub
--- 58), and a spell the alt has not learned is silently dropped by the client
--- rather than reported - so the tier has to be chosen before sending.
---
--- @file    config/alt/SCH_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- ENFEEBLING - select the mob first (/ta <stnpc>)
    -- ========================================================================
    breakspell     = { action = 'ma', target = 'lastst', desc = 'Break',
                       tiers = { { spell = 'Break', level = 90 } } },
    altdispel      = { action = 'ma', target = 'lastst', desc = 'Dispel',
                       tiers = { { spell = 'Dispel', level = 32 } } },
    dispelga       = { action = 'ma', target = 'lastst', desc = 'Dispelga',
                       tiers = { { spell = 'Dispelga', level = 99 } } },
    sleep          = { action = 'ma', target = 'lastst', desc = 'Sleep',
                       tiers = { { spell = 'Sleep II', level = 65 }, { spell = 'Sleep', level = 30 } } },

    -- ========================================================================
    -- ENHANCING - ally spells need /ta <stpc>, self spells go to the alt
    -- ========================================================================
    adloquium      = { action = 'ma', target = 'lastst', desc = 'Adloquium',
                       tiers = { { spell = 'Adloquium', level = 88 } } },
    animusaugeo    = { action = 'ma', target = 'lastst', desc = 'Animus Augeo',
                       tiers = { { spell = 'Animus Augeo', level = 85 } } },
    animusminuo    = { action = 'ma', target = 'lastst', desc = 'Animus Minuo',
                       tiers = { { spell = 'Animus Minuo', level = 85 } } },
    aquaveil       = { action = 'ma', target = 'me', desc = 'Aquaveil',
                       tiers = { { spell = 'Aquaveil', level = 13 } } },
    aurorastorm    = { action = 'ma', target = 'lastst', desc = 'Aurorastorm',
                       tiers = { { spell = 'Aurorastorm II', level = 99 }, { spell = 'Aurorastorm', level = 48 } } },
    blazespikes    = { action = 'ma', target = 'me', desc = 'Blaze Spikes',
                       tiers = { { spell = 'Blaze Spikes', level = 30 } } },
    blink          = { action = 'ma', target = 'me', desc = 'Blink',
                       tiers = { { spell = 'Blink', level = 29 } } },
    deodorize      = { action = 'ma', target = 'lastst', desc = 'Deodorize',
                       tiers = { { spell = 'Deodorize', level = 15 } } },
    embrava        = { action = 'ma', target = 'lastst', desc = 'Embrava',
                       tiers = { { spell = 'Embrava', level = 5 } } },
    erase          = { action = 'ma', target = 'lastst', desc = 'Erase',
                       tiers = { { spell = 'Erase', level = 39 } } },
    firestorm      = { action = 'ma', target = 'lastst', desc = 'Firestorm',
                       tiers = { { spell = 'Firestorm II', level = 99 }, { spell = 'Firestorm', level = 44 } } },
    hailstorm      = { action = 'ma', target = 'lastst', desc = 'Hailstorm',
                       tiers = { { spell = 'Hailstorm II', level = 99 }, { spell = 'Hailstorm', level = 45 } } },
    icespikes      = { action = 'ma', target = 'me', desc = 'Ice Spikes',
                       tiers = { { spell = 'Ice Spikes', level = 50 } } },
    invisible      = { action = 'ma', target = 'lastst', desc = 'Invisible',
                       tiers = { { spell = 'Invisible', level = 25 } } },
    protect        = { action = 'ma', target = 'lastst', desc = 'Protect',
                       tiers = { { spell = 'Protect V', level = 80 }, { spell = 'Protect IV', level = 66 }, { spell = 'Protect III', level = 50 }, { spell = 'Protect II', level = 30 }, { spell = 'Protect', level = 10 } } },
    rainstorm      = { action = 'ma', target = 'lastst', desc = 'Rainstorm',
                       tiers = { { spell = 'Rainstorm II', level = 99 }, { spell = 'Rainstorm', level = 42 } } },
    regen          = { action = 'ma', target = 'lastst', desc = 'Regen',
                       tiers = { { spell = 'Regen V', level = 99 }, { spell = 'Regen IV', level = 79 }, { spell = 'Regen III', level = 59 }, { spell = 'Regen II', level = 37 }, { spell = 'Regen', level = 18 } } },
    sandstorm      = { action = 'ma', target = 'lastst', desc = 'Sandstorm',
                       tiers = { { spell = 'Sandstorm II', level = 99 }, { spell = 'Sandstorm', level = 41 } } },
    shell          = { action = 'ma', target = 'lastst', desc = 'Shell',
                       tiers = { { spell = 'Shell V', level = 90 }, { spell = 'Shell IV', level = 71 }, { spell = 'Shell III', level = 60 }, { spell = 'Shell II', level = 40 }, { spell = 'Shell', level = 20 } } },
    shockspikes    = { action = 'ma', target = 'me', desc = 'Shock Spikes',
                       tiers = { { spell = 'Shock Spikes', level = 70 } } },
    altsneak       = { action = 'ma', target = 'lastst', desc = 'Sneak',
                       tiers = { { spell = 'Sneak', level = 20 } } },
    stoneskin      = { action = 'ma', target = 'me', desc = 'Stoneskin',
                       tiers = { { spell = 'Stoneskin', level = 44 } } },
    thunderstorm   = { action = 'ma', target = 'lastst', desc = 'Thunderstorm',
                       tiers = { { spell = 'Thunderstorm II', level = 99 }, { spell = 'Thunderstorm', level = 46 } } },
    voidstorm      = { action = 'ma', target = 'lastst', desc = 'Voidstorm',
                       tiers = { { spell = 'Voidstorm II', level = 99 }, { spell = 'Voidstorm', level = 47 } } },
    windstorm      = { action = 'ma', target = 'lastst', desc = 'Windstorm',
                       tiers = { { spell = 'Windstorm II', level = 99 }, { spell = 'Windstorm', level = 43 } } },

    -- ========================================================================
    -- HEALING - select the ally first (/ta <stpc>)
    -- ========================================================================
    blindna        = { action = 'ma', target = 'lastst', desc = 'Blindna',
                       tiers = { { spell = 'Blindna', level = 17 } } },
    cure           = { action = 'ma', target = 'lastst', desc = 'Cure',
                       tiers = { { spell = 'Cure IV', level = 55 }, { spell = 'Cure III', level = 30 }, { spell = 'Cure II', level = 17 }, { spell = 'Cure', level = 5 } } },
    cursna         = { action = 'ma', target = 'lastst', desc = 'Cursna',
                       tiers = { { spell = 'Cursna', level = 32 } } },
    paralyna       = { action = 'ma', target = 'lastst', desc = 'Paralyna',
                       tiers = { { spell = 'Paralyna', level = 12 } } },
    poisona        = { action = 'ma', target = 'lastst', desc = 'Poisona',
                       tiers = { { spell = 'Poisona', level = 10 } } },
    raise          = { action = 'ma', target = 'lastst', desc = 'Raise',
                       tiers = { { spell = 'Raise III', level = 91 }, { spell = 'Raise II', level = 70 }, { spell = 'Raise', level = 35 } } },
    reraise        = { action = 'ma', target = 'me', desc = 'Reraise',
                       tiers = { { spell = 'Reraise III', level = 91 }, { spell = 'Reraise II', level = 70 }, { spell = 'Reraise', level = 35 } } },
    silena         = { action = 'ma', target = 'lastst', desc = 'Silena',
                       tiers = { { spell = 'Silena', level = 22 } } },
    stona          = { action = 'ma', target = 'lastst', desc = 'Stona',
                       tiers = { { spell = 'Stona', level = 50 } } },
    viruna         = { action = 'ma', target = 'lastst', desc = 'Viruna',
                       tiers = { { spell = 'Viruna', level = 46 } } },

    -- ========================================================================
    -- DARK MAGIC - select the mob first (/ta <stnpc>)
    -- ========================================================================
    aspir          = { action = 'ma', target = 'lastst', desc = 'Aspir',
                       tiers = { { spell = 'Aspir II', level = 97 }, { spell = 'Aspir', level = 36 } } },
    drain          = { action = 'ma', target = 'lastst', desc = 'Drain',
                       tiers = { { spell = 'Drain', level = 21 } } },
    kaustra        = { action = 'ma', target = 'lastst', desc = 'Kaustra',
                       tiers = { { spell = 'Kaustra', level = 5 } } },
    altklimaform   = { action = 'ma', target = 'me', desc = 'Klimaform',
                       tiers = { { spell = 'Klimaform', level = 46 } } },

    -- ========================================================================
    -- ELEMENTAL - select the mob first (/ta <stnpc>)
    -- ========================================================================
    aero           = { action = 'ma', target = 'lastst', desc = 'Aero',
                       tiers = { { spell = 'Aero V', level = 87 }, { spell = 'Aero IV', level = 72 }, { spell = 'Aero III', level = 60 }, { spell = 'Aero II', level = 38 }, { spell = 'Aero', level = 12 } } },
    anemohelix     = { action = 'ma', target = 'lastst', desc = 'Anemohelix',
                       tiers = { { spell = 'Anemohelix II', level = 99 }, { spell = 'Anemohelix', level = 22 } } },
    blizzard       = { action = 'ma', target = 'lastst', desc = 'Blizzard',
                       tiers = { { spell = 'Blizzard V', level = 95 }, { spell = 'Blizzard IV', level = 74 }, { spell = 'Blizzard III', level = 66 }, { spell = 'Blizzard II', level = 46 }, { spell = 'Blizzard', level = 20 } } },
    cryohelix      = { action = 'ma', target = 'lastst', desc = 'Cryohelix',
                       tiers = { { spell = 'Cryohelix II', level = 99 }, { spell = 'Cryohelix', level = 26 } } },
    fire           = { action = 'ma', target = 'lastst', desc = 'Fire',
                       tiers = { { spell = 'Fire V', level = 91 }, { spell = 'Fire IV', level = 73 }, { spell = 'Fire III', level = 63 }, { spell = 'Fire II', level = 42 }, { spell = 'Fire', level = 16 } } },
    geohelix       = { action = 'ma', target = 'lastst', desc = 'Geohelix',
                       tiers = { { spell = 'Geohelix II', level = 99 }, { spell = 'Geohelix', level = 18 } } },
    hydrohelix     = { action = 'ma', target = 'lastst', desc = 'Hydrohelix',
                       tiers = { { spell = 'Hydrohelix II', level = 99 }, { spell = 'Hydrohelix', level = 20 } } },
    impact         = { action = 'ma', target = 'lastst', desc = 'Impact',
                       tiers = { { spell = 'Impact', level = 90 } } },
    ionohelix      = { action = 'ma', target = 'lastst', desc = 'Ionohelix',
                       tiers = { { spell = 'Ionohelix II', level = 99 }, { spell = 'Ionohelix', level = 28 } } },
    luminohelix    = { action = 'ma', target = 'lastst', desc = 'Luminohelix',
                       tiers = { { spell = 'Luminohelix II', level = 99 }, { spell = 'Luminohelix', level = 32 } } },
    noctohelix     = { action = 'ma', target = 'lastst', desc = 'Noctohelix',
                       tiers = { { spell = 'Noctohelix II', level = 99 }, { spell = 'Noctohelix', level = 30 } } },
    pyrohelix      = { action = 'ma', target = 'lastst', desc = 'Pyrohelix',
                       tiers = { { spell = 'Pyrohelix II', level = 99 }, { spell = 'Pyrohelix', level = 24 } } },
    stone          = { action = 'ma', target = 'lastst', desc = 'Stone',
                       tiers = { { spell = 'Stone V', level = 79 }, { spell = 'Stone IV', level = 70 }, { spell = 'Stone III', level = 54 }, { spell = 'Stone II', level = 30 }, { spell = 'Stone', level = 4 } } },
    thunder        = { action = 'ma', target = 'lastst', desc = 'Thunder',
                       tiers = { { spell = 'Thunder V', level = 99 }, { spell = 'Thunder IV', level = 75 }, { spell = 'Thunder III', level = 69 }, { spell = 'Thunder II', level = 51 }, { spell = 'Thunder', level = 24 } } },
    water          = { action = 'ma', target = 'lastst', desc = 'Water',
                       tiers = { { spell = 'Water V', level = 83 }, { spell = 'Water IV', level = 71 }, { spell = 'Water III', level = 57 }, { spell = 'Water II', level = 34 }, { spell = 'Water', level = 8 } } },
}

return M
