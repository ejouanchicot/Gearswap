---============================================================================
--- RDM Alt Commands - what the alt does when it is on RDM
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether RDM is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN (//gs c dia) and the alt
--- performs it.
---
--- Generated from Windower's res/spells.lua, not written by hand:
---   * only spells RDM can cast at all
---   * every tier of a family, each with the level it needs
---   * the target comes from the spell's `targets` bitmask
---
--- WHY EVERY TIER IS LISTED
---   The engine picks the highest tier the alt is high enough for, using the
---   level it reported. That matters because a subjob caps far below a main
---   (Master Level 50 reaches sub 58): as a main RDM //gs c dia sends Dia III,
---   as a /RDM it sends Dia II. Sending a spell the alt has not learned does
---   nothing at all - it is not "on recast", the client just drops it - so the
---   choice has to happen here.
---
---   Recast fallback is a separate thing and already handled on the alt side:
---   RDM_PRECAST runs TierRefiner, which walks down when the tier is on
---   cooldown. Level is ours, recast is theirs.
---
--- ENTRY FORMAT
---   <name> = {
---       action = 'ma',            -- ma | ja | ws | so | item | pet | ra | raw
---       target = 'lastst',        -- 'lastst' = what you subtargeted, 'me' = the alt
---       desc   = 'free text',     -- shown by //gs c altcmds
---       tiers  = { { spell = 'Dia III', level = 75 }, ... },  -- highest first
---   }
---   A fixed `spell = 'Name'` still works for anything without tiers.
---
--- @file    config/alt/RDM_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 3.0
--- @date    Created: 2026-08-07 | Updated: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- ENFEEBLING - select the mob first (/ta <stnpc>)
    -- ========================================================================
    addle          = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Addle',
                       tiers = { { spell = 'Addle II', level = 99 }, { spell = 'Addle', level = 83 } } },
    bind           = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Bind',
                       tiers = { { spell = 'Bind', level = 11 } } },
    blind          = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Blind',
                       tiers = { { spell = 'Blind II', level = 75 }, { spell = 'Blind', level = 8 } } },
    breakspell     = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Break',
                       tiers = { { spell = 'Break', level = 87 } } },
    dia            = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Dia',
                       tiers = { { spell = 'Dia III', level = 75 }, { spell = 'Dia II', level = 31 }, { spell = 'Dia', level = 1 } } },
    diaga          = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Diaga',
                       tiers = { { spell = 'Diaga', level = 15 } } },
    altdispel      = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Dispel',
                       tiers = { { spell = 'Dispel', level = 32 } } },
    distract       = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Distract',
                       tiers = { { spell = 'Distract III', level = 99 }, { spell = 'Distract II', level = 85 }, { spell = 'Distract', level = 35 } } },
    frazzle        = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Frazzle',
                       tiers = { { spell = 'Frazzle III', level = 99 }, { spell = 'Frazzle II', level = 92 }, { spell = 'Frazzle', level = 42 } } },
    gravity        = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Gravity',
                       tiers = { { spell = 'Gravity II', level = 98 }, { spell = 'Gravity', level = 21 } } },
    inundation     = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Inundation',
                       tiers = { { spell = 'Inundation', level = 64 } } },
    paralyze       = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Paralyze',
                       tiers = { { spell = 'Paralyze II', level = 75 }, { spell = 'Paralyze', level = 6 } } },
    poison         = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Poison',
                       tiers = { { spell = 'Poison II', level = 46 }, { spell = 'Poison', level = 5 } } },
    silence        = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Silence',
                       tiers = { { spell = 'Silence', level = 18 } } },
    sleep          = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Sleep',
                       tiers = { { spell = 'Sleep II', level = 46 }, { spell = 'Sleep', level = 25 } } },
    slow           = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Slow',
                       tiers = { { spell = 'Slow II', level = 75 }, { spell = 'Slow', level = 13 } } },

    -- ========================================================================
    -- ENHANCING - ally spells need /ta <stpc>, self spells go to the alt
    -- ========================================================================
    aquaveil       = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Aquaveil',
                       tiers = { { spell = 'Aquaveil', level = 12 } } },
    baraero        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Baraero',
                       tiers = { { spell = 'Baraero', level = 13 } } },
    baramnesia     = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Baramnesia',
                       tiers = { { spell = 'Baramnesia', level = 78 } } },
    barblind       = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barblind',
                       tiers = { { spell = 'Barblind', level = 18 } } },
    barblizzard    = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barblizzard',
                       tiers = { { spell = 'Barblizzard', level = 21 } } },
    barfire        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barfire',
                       tiers = { { spell = 'Barfire', level = 17 } } },
    barparalyze    = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barparalyze',
                       tiers = { { spell = 'Barparalyze', level = 12 } } },
    barpetrify     = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barpetrify',
                       tiers = { { spell = 'Barpetrify', level = 43 } } },
    barpoison      = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barpoison',
                       tiers = { { spell = 'Barpoison', level = 10 } } },
    barsilence     = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barsilence',
                       tiers = { { spell = 'Barsilence', level = 23 } } },
    barsleep       = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barsleep',
                       tiers = { { spell = 'Barsleep', level = 7 } } },
    barstone       = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barstone',
                       tiers = { { spell = 'Barstone', level = 5 } } },
    barthunder     = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barthunder',
                       tiers = { { spell = 'Barthunder', level = 25 } } },
    barvirus       = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barvirus',
                       tiers = { { spell = 'Barvirus', level = 39 } } },
    barwater       = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barwater',
                       tiers = { { spell = 'Barwater', level = 9 } } },
    blazespikes    = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Blaze Spikes',
                       tiers = { { spell = 'Blaze Spikes', level = 20 } } },
    blink          = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Blink',
                       tiers = { { spell = 'Blink', level = 23 } } },
    deodorize      = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Deodorize',
                       tiers = { { spell = 'Deodorize', level = 15 } } },
    enaero         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Enaero',
                       tiers = { { spell = 'Enaero II', level = 54 }, { spell = 'Enaero', level = 20 } } },
    enblizzard     = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Enblizzard',
                       tiers = { { spell = 'Enblizzard II', level = 56 }, { spell = 'Enblizzard', level = 22 } } },
    enfire         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Enfire',
                       tiers = { { spell = 'Enfire II', level = 58 }, { spell = 'Enfire', level = 24 } } },
    enstone        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Enstone',
                       tiers = { { spell = 'Enstone II', level = 52 }, { spell = 'Enstone', level = 18 } } },
    enthunder      = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Enthunder',
                       tiers = { { spell = 'Enthunder II', level = 50 }, { spell = 'Enthunder', level = 16 } } },
    enwater        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Enwater',
                       tiers = { { spell = 'Enwater II', level = 60 }, { spell = 'Enwater', level = 27 } } },
    flurry         = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Flurry',
                       tiers = { { spell = 'Flurry II', level = 96 }, { spell = 'Flurry', level = 48 } } },
    gainagi        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Gain-AGI',
                       tiers = { { spell = 'Gain-AGI', level = 90 } } },
    gainchr        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Gain-CHR',
                       tiers = { { spell = 'Gain-CHR', level = 87 } } },
    gaindex        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Gain-DEX',
                       tiers = { { spell = 'Gain-DEX', level = 99 } } },
    gainint        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Gain-INT',
                       tiers = { { spell = 'Gain-INT', level = 96 } } },
    gainmnd        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Gain-MND',
                       tiers = { { spell = 'Gain-MND', level = 84 } } },
    gainstr        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Gain-STR',
                       tiers = { { spell = 'Gain-STR', level = 93 } } },
    gainvit        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Gain-VIT',
                       tiers = { { spell = 'Gain-VIT', level = 81 } } },
    haste          = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Haste',
                       tiers = { { spell = 'Haste II', level = 96 }, { spell = 'Haste', level = 48 } } },
    icespikes      = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Ice Spikes',
                       tiers = { { spell = 'Ice Spikes', level = 40 } } },
    invisible      = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Invisible',
                       tiers = { { spell = 'Invisible', level = 25 } } },
    phalanx        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Phalanx',
                       tiers = { { spell = 'Phalanx II', level = 75 }, { spell = 'Phalanx', level = 33 } } },
    protect        = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Protect',
                       tiers = { { spell = 'Protect V', level = 77 }, { spell = 'Protect IV', level = 63 }, { spell = 'Protect III', level = 47 }, { spell = 'Protect II', level = 27 }, { spell = 'Protect', level = 7 } } },
    refresh        = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Refresh',
                       tiers = { { spell = 'Refresh III', level = 99 }, { spell = 'Refresh II', level = 82 }, { spell = 'Refresh', level = 41 } } },
    regen          = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Regen',
                       tiers = { { spell = 'Regen II', level = 76 }, { spell = 'Regen', level = 21 } } },
    shell          = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Shell',
                       tiers = { { spell = 'Shell V', level = 87 }, { spell = 'Shell IV', level = 68 }, { spell = 'Shell III', level = 57 }, { spell = 'Shell II', level = 37 }, { spell = 'Shell', level = 17 } } },
    shockspikes    = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Shock Spikes',
                       tiers = { { spell = 'Shock Spikes', level = 60 } } },
    altsneak       = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Sneak',
                       tiers = { { spell = 'Sneak', level = 20 } } },
    stoneskin      = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Stoneskin',
                       tiers = { { spell = 'Stoneskin', level = 34 } } },
    temper         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Temper',
                       tiers = { { spell = 'Temper II', level = 99 }, { spell = 'Temper', level = 95 } } },

    -- ========================================================================
    -- HEALING - select the ally first (/ta <stpc>)
    -- ========================================================================
    cure           = { action = 'ma', target = 'lastst', group = 'healing', desc = 'Cure',
                       tiers = { { spell = 'Cure IV', level = 48 }, { spell = 'Cure III', level = 26 }, { spell = 'Cure II', level = 14 }, { spell = 'Cure', level = 3 } } },
    raise          = { action = 'ma', target = 'lastst', group = 'healing', desc = 'Raise',
                       tiers = { { spell = 'Raise II', level = 95 }, { spell = 'Raise', level = 38 } } },

    -- ========================================================================
    -- DARK MAGIC - select the mob first (/ta <stnpc>)
    -- ========================================================================
    bio            = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Bio',
                       tiers = { { spell = 'Bio III', level = 75 }, { spell = 'Bio II', level = 36 }, { spell = 'Bio', level = 10 } } },

    -- ========================================================================
    -- ELEMENTAL - select the mob first (/ta <stnpc>)
    -- ========================================================================
    aero           = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Aero',
                       tiers = { { spell = 'Aero V', level = 99 }, { spell = 'Aero IV', level = 83 }, { spell = 'Aero III', level = 69 }, { spell = 'Aero II', level = 45 }, { spell = 'Aero', level = 14 } } },
    blizzard       = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Blizzard',
                       tiers = { { spell = 'Blizzard V', level = 99 }, { spell = 'Blizzard IV', level = 89 }, { spell = 'Blizzard III', level = 73 }, { spell = 'Blizzard II', level = 55 }, { spell = 'Blizzard', level = 24 } } },
    fire           = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Fire',
                       tiers = { { spell = 'Fire V', level = 99 }, { spell = 'Fire IV', level = 86 }, { spell = 'Fire III', level = 71 }, { spell = 'Fire II', level = 50 }, { spell = 'Fire', level = 19 } } },
    impact         = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Impact',
                       tiers = { { spell = 'Impact', level = 90 } } },
    stone          = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Stone',
                       tiers = { { spell = 'Stone V', level = 99 }, { spell = 'Stone IV', level = 77 }, { spell = 'Stone III', level = 65 }, { spell = 'Stone II', level = 35 }, { spell = 'Stone', level = 4 } } },
    thunder        = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Thunder',
                       tiers = { { spell = 'Thunder V', level = 99 }, { spell = 'Thunder IV', level = 92 }, { spell = 'Thunder III', level = 75 }, { spell = 'Thunder II', level = 60 }, { spell = 'Thunder', level = 29 } } },
    water          = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Water',
                       tiers = { { spell = 'Water V', level = 99 }, { spell = 'Water IV', level = 80 }, { spell = 'Water III', level = 67 }, { spell = 'Water II', level = 40 }, { spell = 'Water', level = 9 } } },

    -- ========================================================================
    -- JOB ABILITIES (main job only)
    -- ========================================================================
    composure    = { action = 'ja', spell = 'Composure', target = 'me', level = 50, desc = 'Enhancing duration on others' },
    saboteur     = { action = 'ja', spell = 'Saboteur',  target = 'me', level = 83, desc = 'Next enfeeble potency+' },
    convert      = { action = 'ja', spell = 'Convert',   target = 'me', level = 40, desc = 'Swap HP and MP' },

    -- ========================================================================
    -- NUKES THAT FOLLOW THE MAIN'S BLM ELEMENT
    -- ========================================================================
    altlight  = {
        action = 'ma',
        spell_from_state = 'MainLightSpell',
        fallback = 'Fire III',
        target = 'lastst',
        desc = 'Nuke, follows the main light element',
    },
    altdark   = {
        action = 'ma',
        spell_from_state = 'MainDarkSpell',
        fallback = 'Blizzard III',
        target = 'lastst',
        desc = 'Nuke, follows the main dark element',
    },
}

return M
