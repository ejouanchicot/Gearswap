---============================================================================
--- Cleanse - //gs c cleanse takes the debuffs off you and your alts
---============================================================================
--- Each character looks at its own debuffs (most urgent first) and, for
--- each one: its own spell (Paralyna, Silena, Cursna, Erase...) if it can
--- cast it now, else a partner that has the spell is asked, else an item.
--- Every debuff, its ids and what takes it off:
--- shared/data/debuffs/DEBUFF_REMOVAL.lua (the keys used below).
---
--- The values below are the defaults. Change what you want; a line removed
--- goes back to its default.
---
--- @file _common/combat/CLEANSE_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-10-01
---============================================================================

return {
    -- This character's own spell before an item (WHM, SCH with Addendum:
    -- White, Cure for a sleeping partner)
    use_spells = true,

    -- Ask a partner that has the spell before using an item, and give its
    -- spell this many seconds before the item goes
    ask_partner = true,
    partner_wait = 5,

    -- Doom: Holy Water works one time in three; tries in a row while Doom stays
    doom_tries = 5,

    -- Debuffs never touched, e.g. {'dia', 'bio'} (keys of DEBUFF_REMOVAL.lua)
    skip = {},

    -- Debuffs taken off before the others, in this order, e.g. {'silence'}
    first = {},

    -- Items per debuff, tried in order. `erasable` covers every debuff Erase
    -- takes off (Slow, Weight, Bind, Addle, the Downs, Bio, Dia...).
    -- Auto Medicine (AUTOCURE_CONFIG.lua) uses silence and paralysis too.
    items = {
        doom      = {'Holy Water'},
        curse     = {'Holy Water'},
        silence   = {'Echo Drops', 'Remedy'},
        paralysis = {'Remedy'},
        blindness = {'Eye Drops', 'Remedy'},
        poison    = {'Antidote', 'Remedy'},
        erasable  = {'Panacea'},
    },
}
