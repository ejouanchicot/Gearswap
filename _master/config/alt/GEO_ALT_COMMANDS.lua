---============================================================================
--- GEO Alt Commands - what the alt does when it is on GEO
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua when the alt character is on
--- GEO. Type the key on the MAIN (//gs c indifury) and the alt performs it.
---
--- See config/alt/RDM_ALT_COMMANDS.lua for the full entry format reference.
--- Short version:
---   { action = 'ma'|'ja'|'ws'|'so'|'item'|'pet'|'ra'|'raw',
---     spell = 'Name', target = 'lastst'|'me', desc = 'text' }
---
--- Covers all 30 Indi- and all 30 Geo- spells. Names, effects and the
--- buff/debuff split are taken from the project's own geomancy data
--- (shared/data/magic/geomancy/), not written by hand.
---
--- GEOCOLURE TARGETING - the reason this file is split in sections
---   Indi-        always the alt, nothing to select        -> target 'me'
---   Indi- via Entrust  the ONLY case an Indi- leaves the
---                alt: needs a PC                          -> /ta <stpc>
---   Geo- buffs   are PC ONLY     -> /ta <stpc> the ally, then fire
---   Geo- debuffs are ENEMY ONLY  -> /ta <stnpc> the mob
---
---   A Geocolure refuses the wrong target type outright, so the split is not
---   cosmetic: fire a Geo- buff with a mob selected and nothing happens.
---   Both kinds use `lastst`, which is fed by <stpc> and <stnpc> alike - only
---   the selection you make beforehand differs.
---
--- @file    config/alt/GEO_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-07
---============================================================================

local M = {}

--- Where an Indi- should land.
---
--- Normally the alt itself. But Entrust redirects the next Indi- onto an ally,
--- and the alt tells us when it holds that buff (see alt_buff_reporter), so the
--- same command adapts and aims at your last subtarget instead.
---
--- Bind it as a two-line macro so FFXI does the waiting for you:
---     /target <stal>
---     /console gs c indifury
--- The second line does not run until you confirm the cursor, and by then
--- `lastst` holds your pick. The same macro works with or without Entrust: the
--- selection is simply ignored when the spell goes on the alt.
---
--- Reads the shared globals directly rather than requiring alt_commands, which
--- would be a require cycle (alt_commands loads this file). `AltBuffExpiry`
--- guards the case where the main assumed Entrust after //gs c altentrust but
--- the alt never confirmed it - without that check a wrong guess would latch on
--- and every Indi- would keep asking for a target.
--- @return string 'lastst' while the alt holds Entrust, 'me' otherwise
local function indi_target()
    local buffs = _G.AltBuffState
    if not buffs or not buffs['Entrust'] then
        return 'me'
    end

    local expires = _G.AltBuffExpiry and _G.AltBuffExpiry['Entrust']
    if expires and os.clock() > expires then
        buffs['Entrust'] = false
        return 'me'
    end

    return 'lastst'
end

M.commands = {

    -- ========================================================================
    -- INDI- SPELLS
    -- ========================================================================
    -- On the alt by default. With Entrust up they aim at your last subtarget
    -- instead - see indi_target above. Names and effects come from
    -- shared/data/magic/geomancy/geomancy_indi.lua.
    indiacumen       = { action = 'ma', spell = 'Indi-Acumen',        target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Boosts magic atk.' },
    indiagi          = { action = 'ma', spell = 'Indi-AGI',           target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Boosts agility.' },
    indiattunement   = { action = 'ma', spell = 'Indi-Attunement',    target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Boosts magic acc.' },
    indibarrier      = { action = 'ma', spell = 'Indi-Barrier',       target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Boosts defense.' },
    indichr          = { action = 'ma', spell = 'Indi-CHR',           target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Boosts charisma.' },
    indidex          = { action = 'ma', spell = 'Indi-DEX',           target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Boosts dexterity.' },
    indifend         = { action = 'ma', spell = 'Indi-Fend',          target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Boosts defense.' },
    indifocus        = { action = 'ma', spell = 'Indi-Focus',         target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Boosts magic acc.' },
    indifury         = { action = 'ma', spell = 'Indi-Fury',          target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Boosts attack.' },
    indihaste        = { action = 'ma', spell = 'Indi-Haste',         target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Boosts attack speed.' },
    indiint          = { action = 'ma', spell = 'Indi-INT',           target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Boosts intelligence.' },
    indimnd          = { action = 'ma', spell = 'Indi-MND',           target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Boosts mind.' },
    indipoison       = { action = 'ma', spell = 'Indi-Poison',        target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Boosts poison dmg.' },
    indiprecision    = { action = 'ma', spell = 'Indi-Precision',     target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Boosts accuracy.' },
    indirefresh      = { action = 'ma', spell = 'Indi-Refresh',       target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Restores MP.' },
    indiregen        = { action = 'ma', spell = 'Indi-Regen',         target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Restores HP.' },
    indistr          = { action = 'ma', spell = 'Indi-STR',           target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Boosts strength.' },
    indivit          = { action = 'ma', spell = 'Indi-VIT',           target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Boosts vitality.' },
    indivoidance     = { action = 'ma', spell = 'Indi-Voidance',      target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Boosts evasion.' },
    indislow         = { action = 'ma', spell = 'Indi-Slow',          target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Slows nearby foes.' },
    indislip         = { action = 'ma', spell = 'Indi-Slip',          target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Lowers accuracy.' },
    inditorpor       = { action = 'ma', spell = 'Indi-Torpor',        target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Lowers evasion.' },
    indifade         = { action = 'ma', spell = 'Indi-Fade',          target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Lowers attack.' },
    indifrailty      = { action = 'ma', spell = 'Indi-Frailty',       target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Lowers defense.' },
    indigravity      = { action = 'ma', spell = 'Indi-Gravity',       target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Slows movement.' },
    indilanguor      = { action = 'ma', spell = 'Indi-Languor',       target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Slows foes.' },
    indimalaise      = { action = 'ma', spell = 'Indi-Malaise',       target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Lowers magic def.' },
    indiparalysis    = { action = 'ma', spell = 'Indi-Paralysis',     target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Paralyzes foes.' },
    indivex          = { action = 'ma', spell = 'Indi-Vex',           target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Lowers magic def.' },
    indiwilt         = { action = 'ma', spell = 'Indi-Wilt',          target = indi_target, consumes_alt_buff = 'Entrust', desc = 'Lowers attack.' },

    -- ========================================================================
    -- GEO- BUFFS - PC ONLY: select an ally first (/ta <stpc>)
    -- ========================================================================
    -- A buffing Geocolure will not accept an enemy as its target.
    geoacumen        = { action = 'ma', spell = 'Geo-Acumen',         target = 'lastst', desc = 'Boosts magic atk. (on a PC)' },
    geoagi           = { action = 'ma', spell = 'Geo-AGI',            target = 'lastst', desc = 'Boosts agility. (on a PC)' },
    geoattunement    = { action = 'ma', spell = 'Geo-Attunement',     target = 'lastst', desc = 'Boosts magic acc. (on a PC)' },
    geobarrier       = { action = 'ma', spell = 'Geo-Barrier',        target = 'lastst', desc = 'Boosts defense. (on a PC)' },
    geochr           = { action = 'ma', spell = 'Geo-CHR',            target = 'lastst', desc = 'Boosts charisma. (on a PC)' },
    geodex           = { action = 'ma', spell = 'Geo-DEX',            target = 'lastst', desc = 'Boosts dexterity. (on a PC)' },
    geofend          = { action = 'ma', spell = 'Geo-Fend',           target = 'lastst', desc = 'Boosts defense. (on a PC)' },
    geofocus         = { action = 'ma', spell = 'Geo-Focus',          target = 'lastst', desc = 'Boosts magic acc. (on a PC)' },
    geofury          = { action = 'ma', spell = 'Geo-Fury',           target = 'lastst', desc = 'Boosts attack. (on a PC)' },
    geohaste         = { action = 'ma', spell = 'Geo-Haste',          target = 'lastst', desc = 'Boosts attack speed. (on a PC)' },
    geoint           = { action = 'ma', spell = 'Geo-INT',            target = 'lastst', desc = 'Boosts intelligence. (on a PC)' },
    geomnd           = { action = 'ma', spell = 'Geo-MND',            target = 'lastst', desc = 'Boosts mind. (on a PC)' },
    geopoison        = { action = 'ma', spell = 'Geo-Poison',         target = 'lastst', desc = 'Boosts poison dmg. (on a PC)' },
    geoprecision     = { action = 'ma', spell = 'Geo-Precision',      target = 'lastst', desc = 'Boosts accuracy. (on a PC)' },
    georefresh       = { action = 'ma', spell = 'Geo-Refresh',        target = 'lastst', desc = 'Restores MP. (on a PC)' },
    georegen         = { action = 'ma', spell = 'Geo-Regen',          target = 'lastst', desc = 'Restores HP. (on a PC)' },
    geostr           = { action = 'ma', spell = 'Geo-STR',            target = 'lastst', desc = 'Boosts strength. (on a PC)' },
    geovit           = { action = 'ma', spell = 'Geo-VIT',            target = 'lastst', desc = 'Boosts vitality. (on a PC)' },
    geovoidance      = { action = 'ma', spell = 'Geo-Voidance',       target = 'lastst', desc = 'Boosts evasion. (on a PC)' },

    -- ========================================================================
    -- GEO- DEBUFFS - ENEMY ONLY: select the mob first (/ta <stnpc>)
    -- ========================================================================
    -- A debuffing Geocolure will not accept a player as its target.
    geofade          = { action = 'ma', spell = 'Geo-Fade',           target = 'lastst', desc = 'Lowers attack. (on a mob)' },
    geofrailty       = { action = 'ma', spell = 'Geo-Frailty',        target = 'lastst', desc = 'Lowers defense. (on a mob)' },
    geogravity       = { action = 'ma', spell = 'Geo-Gravity',        target = 'lastst', desc = 'Slows movement. (on a mob)' },
    geolanguor       = { action = 'ma', spell = 'Geo-Languor',        target = 'lastst', desc = 'Slows foes. (on a mob)' },
    geomalaise       = { action = 'ma', spell = 'Geo-Malaise',        target = 'lastst', desc = 'Lowers magic def. (on a mob)' },
    geoparalysis     = { action = 'ma', spell = 'Geo-Paralysis',      target = 'lastst', desc = 'Paralyzes foes. (on a mob)' },
    geoslip          = { action = 'ma', spell = 'Geo-Slip',           target = 'lastst', desc = 'Lowers accuracy. (on a mob)' },
    geoslow          = { action = 'ma', spell = 'Geo-Slow',           target = 'lastst', desc = 'Slows foes. (on a mob)' },
    geotorpor        = { action = 'ma', spell = 'Geo-Torpor',         target = 'lastst', desc = 'Lowers evasion. (on a mob)' },
    geovex           = { action = 'ma', spell = 'Geo-Vex',            target = 'lastst', desc = 'Lowers magic def. (on a mob)' },
    geowilt          = { action = 'ma', spell = 'Geo-Wilt',           target = 'lastst', desc = 'Lowers attack. (on a mob)' },

    -- ========================================================================
    -- LUOPAN MANAGEMENT
    -- ========================================================================
    fullcircle  = { action = 'ja', spell = 'Full Circle',  target = 'me', desc = 'Absorb the luopan' },
    -- `sets_alt_buff` marks Entrust as up right away, so the next Indi- knows
    -- to ask for a target even if the alt is not reporting its buffs back.
    -- The alt's own report still overrides this when it arrives.
    -- `sync_after` is REQUIRED here, not a safety net.
    --
    -- Verified in game (trace 2026-08-08): FFXI never fires buff_change when
    -- Entrust is GAINED - only when it is lost. So the alt has nothing to
    -- report at cast time, and the main would never learn the buff is up.
    -- Asking the alt to resend its buff list 3s later is what makes it work.
    --
    -- It doubles as the answer to "what if the alt was paralysed / on recast":
    -- the resync returns the truth either way, so a failed Entrust correctly
    -- leaves the Indi- commands aimed at the alt.
    altentrust  = {
        action = 'ja', spell = 'Entrust', target = 'me',
        sets_alt_buff = 'Entrust', alt_buff_duration = 60,
        sync_after = 3,
        desc = 'Entrust (next Indi on an ally)',
    },
    lifecycle   = { action = 'ja', spell = 'Life Cycle',   target = 'me', desc = 'Restore luopan HP' },
    blazeofglory= { action = 'ja', spell = 'Blaze of Glory', target = 'me', desc = 'Boost the current bubble' },
    ecliptic    = { action = 'ja', spell = 'Ecliptic Attrition', target = 'me', desc = 'Strengthen the bubble' },

    -- ========================================================================
    -- ENTRUST - the ONLY case where an Indi- leaves the alt
    -- ========================================================================
    -- Entrust redirects the next Indi- onto an ally, so these need a PC
    -- selected first (/ta <stpc>). `chain` runs the two actions in order, each
    -- sent to the alt separately: the JA on <me>, the Indi- on your pick.
    -- Only buffs are worth entrusting - an Indi- debuff following an ally is
    -- useless.
    entrusthaste = {
        target = 'lastst', step_delay = 2,
        desc = 'Entrust + Indi-Haste (on a PC)',
        chain = {
            { action = 'ja', spell = 'Entrust', target = 'me' },
            { action = 'ma', spell = 'Indi-Haste' },
        },
    },
    entrustrefresh = {
        target = 'lastst', step_delay = 2,
        desc = 'Entrust + Indi-Refresh (on a PC)',
        chain = {
            { action = 'ja', spell = 'Entrust', target = 'me' },
            { action = 'ma', spell = 'Indi-Refresh' },
        },
    },
    entrustfury = {
        target = 'lastst', step_delay = 2,
        desc = 'Entrust + Indi-Fury (on a PC)',
        chain = {
            { action = 'ja', spell = 'Entrust', target = 'me' },
            { action = 'ma', spell = 'Indi-Fury' },
        },
    },
    entrustacumen = {
        target = 'lastst', step_delay = 2,
        desc = 'Entrust + Indi-Acumen (on a PC)',
        chain = {
            { action = 'ja', spell = 'Entrust', target = 'me' },
            { action = 'ma', spell = 'Indi-Acumen' },
        },
    },
    entrustfocus = {
        target = 'lastst', step_delay = 2,
        desc = 'Entrust + Indi-Focus (on a PC)',
        chain = {
            { action = 'ja', spell = 'Entrust', target = 'me' },
            { action = 'ma', spell = 'Indi-Focus' },
        },
    },
    entrustregen = {
        target = 'lastst', step_delay = 2,
        desc = 'Entrust + Indi-Regen (on a PC)',
        chain = {
            { action = 'ja', spell = 'Entrust', target = 'me' },
            { action = 'ma', spell = 'Indi-Regen' },
        },
    },
    entrustprecision = {
        target = 'lastst', step_delay = 2,
        desc = 'Entrust + Indi-Precision (on a PC)',
        chain = {
            { action = 'ja', spell = 'Entrust', target = 'me' },
            { action = 'ma', spell = 'Indi-Precision' },
        },
    },

    -- ========================================================================
    -- NUKES THAT FOLLOW THE MAIN'S BLM ELEMENT
    -- ========================================================================
    altlight = {
        action = 'ma',
        spell_from_state = 'MainLightSpell',
        fallback = 'Fire IV',
        target = 'lastst',
        desc = 'Nuke, follows the main light element',
    },
    altdark = {
        action = 'ma',
        spell_from_state = 'MainDarkSpell',
        fallback = 'Blizzard IV',
        target = 'lastst',
        desc = 'Nuke, follows the main dark element',
    },

    -- ========================================================================
    -- SUPPORT (from a magic subjob)
    -- ========================================================================
    cure  = { action = 'ma', spell = 'Cure IV', target = 'lastst', desc = 'Cure IV' },
    raise = { action = 'ma', spell = 'Raise',   target = 'lastst', desc = 'Raise' },
}

return M
