---============================================================================
--- BLM Alt Commands - what the alt does when it is on BLM
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether BLM is the alt's
--- MAIN job or its SUBJOB.
---
--- Generated from Windower's res/spells.lua: only spells BLM can cast, every
--- tier of a family with the level it needs, and the target taken from the
--- spell's `targets` bitmask.
---
--- The engine picks the highest tier the alt is high enough for, from the level
--- it reported. A subjob caps far below a main (Master Level 50 reaches sub
--- 58), and a spell the alt has not learned is silently dropped by the client
--- rather than reported - so the tier has to be chosen before sending.
---
--- @file    config/alt/BLM_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- ENFEEBLING - select the mob first (/ta <stnpc>)
    -- ========================================================================
    bind           = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Bind',
                       tiers = { { spell = 'Bind', level = 7 } } },
    blind          = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Blind',
                       tiers = { { spell = 'Blind', level = 4 } } },
    breakspell     = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Break',
                       tiers = { { spell = 'Break', level = 85 } } },
    breakga        = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Breakga',
                       tiers = { { spell = 'Breakga', level = 95 } } },
    poison         = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Poison',
                       tiers = { { spell = 'Poison II', level = 43 }, { spell = 'Poison', level = 3 } } },
    poisonga       = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Poisonga',
                       tiers = { { spell = 'Poisonga', level = 24 } } },
    sleep          = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Sleep',
                       tiers = { { spell = 'Sleep II', level = 41 }, { spell = 'Sleep', level = 20 } } },
    sleepga        = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Sleepga',
                       tiers = { { spell = 'Sleepga II', level = 56 }, { spell = 'Sleepga II', level = 56 }, { spell = 'Sleepga', level = 31 }, { spell = 'Sleepga', level = 31 } } },

    -- ========================================================================
    -- ENHANCING - ally spells need /ta <stpc>, self spells go to the alt
    -- ========================================================================
    blazespikes    = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Blaze Spikes',
                       tiers = { { spell = 'Blaze Spikes', level = 10 } } },
    escape         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Escape',
                       tiers = { { spell = 'Escape', level = 29 } } },
    icespikes      = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Ice Spikes',
                       tiers = { { spell = 'Ice Spikes', level = 20 } } },
    retrace        = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Retrace',
                       tiers = { { spell = 'Retrace', level = 55 } } },
    shockspikes    = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Shock Spikes',
                       tiers = { { spell = 'Shock Spikes', level = 30 } } },
    warp           = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Warp',
                       tiers = { { spell = 'Warp II', level = 40 }, { spell = 'Warp', level = 17 } } },

    -- ========================================================================
    -- DARK MAGIC - select the mob first (/ta <stnpc>)
    -- ========================================================================
    aspir          = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Aspir',
                       tiers = { { spell = 'Aspir III', level = 99 }, { spell = 'Aspir II', level = 83 }, { spell = 'Aspir', level = 25 } } },
    bio            = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Bio',
                       tiers = { { spell = 'Bio II', level = 35 }, { spell = 'Bio', level = 10 } } },
    death          = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Death',
                       tiers = { { spell = 'Death', level = 99 } } },
    drain          = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Drain',
                       tiers = { { spell = 'Drain', level = 12 } } },
    stun           = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Stun',
                       tiers = { { spell = 'Stun', level = 45 } } },
    tractor        = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Tractor',
                       tiers = { { spell = 'Tractor', level = 25 } } },

    -- ========================================================================
    -- ELEMENTAL - select the mob first (/ta <stnpc>)
    -- ========================================================================
    aero           = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Aero',
                       tiers = { { spell = 'Aero VI', level = 99 }, { spell = 'Aero V', level = 83 }, { spell = 'Aero IV', level = 72 }, { spell = 'Aero III', level = 59 }, { spell = 'Aero II', level = 34 }, { spell = 'Aero', level = 9 } } },
    aeroga         = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Aeroga',
                       tiers = { { spell = 'Aeroga III', level = 67 }, { spell = 'Aeroga II', level = 48 }, { spell = 'Aeroga', level = 23 } } },
    aeroja         = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Aeroja',
                       tiers = { { spell = 'Aeroja', level = 87 } } },
    blizzaga       = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Blizzaga',
                       tiers = { { spell = 'Blizzaga III', level = 71 }, { spell = 'Blizzaga II', level = 57 }, { spell = 'Blizzaga', level = 32 } } },
    blizzaja       = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Blizzaja',
                       tiers = { { spell = 'Blizzaja', level = 93 } } },
    blizzard       = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Blizzard',
                       tiers = { { spell = 'Blizzard VI', level = 99 }, { spell = 'Blizzard V', level = 89 }, { spell = 'Blizzard IV', level = 74 }, { spell = 'Blizzard III', level = 64 }, { spell = 'Blizzard II', level = 42 }, { spell = 'Blizzard', level = 17 } } },
    burn           = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Burn',
                       tiers = { { spell = 'Burn', level = 24 } } },
    burst          = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Burst',
                       tiers = { { spell = 'Burst II', level = 75 }, { spell = 'Burst', level = 56 } } },
    choke          = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Choke',
                       tiers = { { spell = 'Choke', level = 20 } } },
    comet          = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Comet',
                       tiers = { { spell = 'Comet', level = 94 } } },
    drown          = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Drown',
                       tiers = { { spell = 'Drown', level = 27 } } },
    firaga         = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Firaga',
                       tiers = { { spell = 'Firaga III', level = 69 }, { spell = 'Firaga II', level = 53 }, { spell = 'Firaga', level = 28 } } },
    firaja         = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Firaja',
                       tiers = { { spell = 'Firaja', level = 90 } } },
    fire           = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Fire',
                       tiers = { { spell = 'Fire VI', level = 99 }, { spell = 'Fire V', level = 86 }, { spell = 'Fire IV', level = 73 }, { spell = 'Fire III', level = 62 }, { spell = 'Fire II', level = 38 }, { spell = 'Fire', level = 13 } } },
    flare          = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Flare',
                       tiers = { { spell = 'Flare II', level = 75 }, { spell = 'Flare', level = 60 } } },
    flood          = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Flood',
                       tiers = { { spell = 'Flood II', level = 75 }, { spell = 'Flood', level = 58 } } },
    freeze         = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Freeze',
                       tiers = { { spell = 'Freeze II', level = 75 }, { spell = 'Freeze', level = 50 } } },
    frost          = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Frost',
                       tiers = { { spell = 'Frost', level = 22 } } },
    impact         = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Impact',
                       tiers = { { spell = 'Impact', level = 90 } } },
    meteor         = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Meteor',
                       tiers = { { spell = 'Meteor', level = 99 } } },
    quake          = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Quake',
                       tiers = { { spell = 'Quake II', level = 75 }, { spell = 'Quake', level = 54 } } },
    rasp           = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Rasp',
                       tiers = { { spell = 'Rasp', level = 18 } } },
    shock          = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Shock',
                       tiers = { { spell = 'Shock', level = 16 } } },
    stone          = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Stone',
                       tiers = { { spell = 'Stone VI', level = 99 }, { spell = 'Stone V', level = 77 }, { spell = 'Stone IV', level = 68 }, { spell = 'Stone III', level = 51 }, { spell = 'Stone II', level = 26 }, { spell = 'Stone', level = 1 } } },
    stonega        = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Stonega',
                       tiers = { { spell = 'Stonega III', level = 63 }, { spell = 'Stonega II', level = 40 }, { spell = 'Stonega', level = 15 } } },
    stoneja        = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Stoneja',
                       tiers = { { spell = 'Stoneja', level = 81 } } },
    thundaga       = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Thundaga',
                       tiers = { { spell = 'Thundaga III', level = 73 }, { spell = 'Thundaga II', level = 61 }, { spell = 'Thundaga', level = 36 } } },
    thundaja       = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Thundaja',
                       tiers = { { spell = 'Thundaja', level = 96 } } },
    thunder        = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Thunder',
                       tiers = { { spell = 'Thunder VI', level = 99 }, { spell = 'Thunder V', level = 92 }, { spell = 'Thunder IV', level = 75 }, { spell = 'Thunder III', level = 66 }, { spell = 'Thunder II', level = 46 }, { spell = 'Thunder', level = 21 } } },
    tornado        = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Tornado',
                       tiers = { { spell = 'Tornado II', level = 75 }, { spell = 'Tornado', level = 52 } } },
    water          = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Water',
                       tiers = { { spell = 'Water VI', level = 99 }, { spell = 'Water V', level = 80 }, { spell = 'Water IV', level = 70 }, { spell = 'Water III', level = 55 }, { spell = 'Water II', level = 30 }, { spell = 'Water', level = 5 } } },
    waterga        = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Waterga',
                       tiers = { { spell = 'Waterga III', level = 65 }, { spell = 'Waterga II', level = 44 }, { spell = 'Waterga', level = 19 } } },
    waterja        = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Waterja',
                       tiers = { { spell = 'Waterja', level = 84 } } },
}

return M
