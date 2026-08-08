---============================================================================
--- COR Alt Commands - what the alt does when it is on COR
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua when the alt character is on
--- COR. Type the key on the MAIN (//gs c chaos) and the alt performs it.
---
--- See config/alt/RDM_ALT_COMMANDS.lua for the full entry format reference.
--- Short version:
---   { action = 'ma'|'ja'|'ws'|'so'|'item'|'pet'|'ra'|'raw',
---     spell = 'Name', target = 'lastst'|'me'|'stpc'|..., desc = 'text' }
---
--- Rolls target the alt itself: the roll's area of effect covers the party,
--- so there is nothing to pick.
---
--- @file    config/alt/COR_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-07
---============================================================================

local M = {}

M.commands = {

    -- ========================================================================
    -- PHANTOM ROLLS (self-targeted, party-wide effect)
    -- ========================================================================
    chaos     = { action = 'ja', spell = "Chaos Roll",     target = 'me', desc = 'Attack +' },
    samurai   = { action = 'ja', spell = "Samurai Roll",   target = 'me', desc = 'Store TP +' },
    fighter   = { action = 'ja', spell = "Fighter's Roll", target = 'me', desc = 'Double Attack +' },
    hunter    = { action = 'ja', spell = "Hunter's Roll",  target = 'me', desc = 'Accuracy +' },
    wizard    = { action = 'ja', spell = "Wizard's Roll",  target = 'me', desc = 'Magic Attack +' },
    warlock   = { action = 'ja', spell = "Warlock's Roll", target = 'me', desc = 'Magic Accuracy +' },
    rogue     = { action = 'ja', spell = "Rogue's Roll",   target = 'me', desc = 'Critical rate +' },
    corsair   = { action = 'ja', spell = "Corsair's Roll", target = 'me', desc = 'Experience +' },
    tactician = { action = 'ja', spell = "Tactician's Roll", target = 'me', desc = 'Regain +' },
    caster    = { action = 'ja', spell = "Caster's Roll",  target = 'me', desc = 'Fast Cast +' },
    drachen   = { action = 'ja', spell = "Drachen Roll",   target = 'me', desc = 'Pet accuracy +' },
    companion = { action = 'ja', spell = "Companion's Roll", target = 'me', desc = 'Pet regain +' },

    altdoubleup = { action = 'ja', spell = 'Double-Up',      target = 'me', desc = 'Double-Up' },
    fold      = { action = 'ja', spell = 'Fold',           target = 'me', desc = 'Fold' },
    snakeeye  = { action = 'ja', spell = 'Snake Eye',      target = 'me', desc = 'Snake Eye' },
    randomdeal= { action = 'ja', spell = 'Random Deal',    target = 'me', desc = 'Random Deal' },

    -- ========================================================================
    -- QUICK DRAW - select the mob first (/ta <stnpc>)
    -- ========================================================================
    fireshot  = { action = 'ja', spell = 'Fire Shot',    target = 'lastst', desc = 'Fire Shot' },
    iceshot   = { action = 'ja', spell = 'Ice Shot',     target = 'lastst', desc = 'Ice Shot' },
    windshot  = { action = 'ja', spell = 'Wind Shot',    target = 'lastst', desc = 'Wind Shot' },
    earthshot = { action = 'ja', spell = 'Earth Shot',   target = 'lastst', desc = 'Earth Shot' },
    thundershot = { action = 'ja', spell = 'Thunder Shot', target = 'lastst', desc = 'Thunder Shot' },
    watershot = { action = 'ja', spell = 'Water Shot',   target = 'lastst', desc = 'Water Shot' },
    lightshot = { action = 'ja', spell = 'Light Shot',   target = 'lastst', desc = 'Light Shot (dispel)' },
    darkshot  = { action = 'ja', spell = 'Dark Shot',    target = 'lastst', desc = 'Dark Shot (drain aspir)' },

    -- Follows the main's BLM element when the main is BLM.
    altlight  = {
        action = 'ja',
        spell = function()
            local st = _G.state and state.MainLightSpell
            local element = st and tostring(st.value) or ''
            if element:find('Fire') then return 'Fire Shot' end
            if element:find('Aero') then return 'Wind Shot' end
            if element:find('Thunder') then return 'Thunder Shot' end
            return 'Light Shot'
        end,
        target = 'lastst',
        desc = 'Quick Draw, follows the main light element',
    },
    altdark   = {
        action = 'ja',
        spell = function()
            local st = _G.state and state.MainDarkSpell
            local element = st and tostring(st.value) or ''
            if element:find('Blizzard') then return 'Ice Shot' end
            if element:find('Stone') then return 'Earth Shot' end
            if element:find('Water') then return 'Water Shot' end
            return 'Dark Shot'
        end,
        target = 'lastst',
        desc = 'Quick Draw, follows the main dark element',
    },

    -- ========================================================================
    -- SUPPORT (from a magic subjob)
    -- ========================================================================
    cure      = { action = 'ma', spell = 'Cure IV',   target = 'lastst', desc = 'Cure IV' },
    haste     = { action = 'ma', spell = 'Haste',     target = 'lastst', desc = 'Haste' },
}

return M
