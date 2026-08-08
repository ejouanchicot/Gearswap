---============================================================================
--- RDM Alt Commands - what the alt does when it is on RDM
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua when the alt character is on
--- RDM. Type the key on the MAIN (//gs c haste) and the alt performs it.
---
--- ENTRY FORMAT
---   <name> = {
---       action = 'ma',          -- ma | ja | ws | so | item | pet | ra | raw
---       spell  = 'Haste II',    -- what to use
---       target = 'lastst',      -- see below
---       desc   = 'free text',   -- shown by //gs c altcmds
---   }
---
--- TARGETS - two families, the difference matters
---
---   On YOUR screen. Sent as <tid>, <laststid>... which the `send` addon turns
---   into a numeric id on this client, so the alt acts on what you aim at:
---     t        your current target        (mobs, enfeebles, nukes)
---     lastst   your last subtarget        (allies: /ta <stpc> then fire)
---     bt / ft / scan
---
---   The ALT itself. Sent as a literal <me> / <pet>, which `send` leaves alone
---   (it only rewrites <...id>), so the alt resolves them to itself:
---     me       the alt                    (self buffs, rolls, Indi- spells)
---     pet      the alt's pet
---
---   Do NOT expect `me` to become <meid>: that would be the MAIN's id and every
---   self-buff would land on the wrong character.
---
---   For an ally, select once with `/ta <stpc>` (or bind it in a macro) and
---   every `lastst` command applies to them until you pick someone else.
---
--- ADVANCED
---   spell_from_state = 'MainLightSpell'  -- mirror one of the MAIN's states
---   fallback         = 'Fire'            -- used when that state is absent
---   spell            = function(args) return 'Cure IV' end
---
--- Edit freely: adding a line here is all it takes to add a command.
---
--- @file    config/alt/RDM_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-07
---============================================================================

local M = {}

M.commands = {

    -- ========================================================================
    -- BUFFS - select the ally first (/ta <stpc>)
    -- ========================================================================
    haste     = { action = 'ma', spell = 'Haste II',    target = 'lastst', desc = 'Haste II' },
    refresh   = { action = 'ma', spell = 'Refresh III', target = 'lastst', desc = 'Refresh III' },
    phalanx   = { action = 'ma', spell = 'Phalanx II',  target = 'lastst', desc = 'Phalanx II' },
    regen     = { action = 'ma', spell = 'Regen II',    target = 'lastst', desc = 'Regen II' },
    protect   = { action = 'ma', spell = 'Protectra V', target = 'lastst', desc = 'Protectra V' },
    shell     = { action = 'ma', spell = 'Shellra V',   target = 'lastst', desc = 'Shellra V' },

    -- ========================================================================
    -- HEALS - select the ally first (/ta <stpc>)
    -- ========================================================================
    cure      = { action = 'ma', spell = 'Cure IV',     target = 'lastst', desc = 'Cure IV' },
    curaga    = { action = 'ma', spell = 'Curaga III',  target = 'lastst', desc = 'Curaga III' },
    raise     = { action = 'ma', spell = 'Raise III',   target = 'lastst', desc = 'Raise III' },
    erase     = { action = 'ma', spell = 'Erase',       target = 'lastst', desc = 'Erase' },

    -- ========================================================================
    -- SELF BUFFS (on the alt)
    -- ========================================================================
    altrefresh = { action = 'ma', spell = 'Refresh III', target = 'me', desc = 'Refresh on the alt' },
    composure  = { action = 'ja', spell = 'Composure',   target = 'me', desc = 'Composure' },

    -- ========================================================================
    -- ENFEEBLES - select the mob first (/ta <stnpc>)
    -- ========================================================================
    dia       = { action = 'ma', spell = 'Dia III',     target = 'lastst', desc = 'Dia III' },
    slow      = { action = 'ma', spell = 'Slow II',     target = 'lastst', desc = 'Slow II' },
    para      = { action = 'ma', spell = 'Paralyze II', target = 'lastst', desc = 'Paralyze II' },
    blind     = { action = 'ma', spell = 'Blind II',    target = 'lastst', desc = 'Blind II' },
    silence   = { action = 'ma', spell = 'Silence',     target = 'lastst', desc = 'Silence' },
    altdispel = { action = 'ma', spell = 'Dispel',      target = 'lastst', desc = 'Dispel' },
    distract  = { action = 'ma', spell = 'Distract III', target = 'lastst', desc = 'Distract III' },
    frazzle   = { action = 'ma', spell = 'Frazzle III', target = 'lastst', desc = 'Frazzle III' },

    -- ========================================================================
    -- NUKES - select the mob first (/ta <stnpc>)
    -- ========================================================================
    -- When the main is BLM these mirror state.MainLightSpell / MainDarkSpell,
    -- so the alt nukes the same element you have selected. On any other main
    -- job the state does not exist and `fallback` is used instead.
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
