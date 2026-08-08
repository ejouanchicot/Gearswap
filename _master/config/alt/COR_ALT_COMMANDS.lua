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
    -- ========================================================================
    -- PHANTOM ROLLS (self-targeted, the effect covers the party)
    -- ========================================================================
    -- All 31 rolls, names and effects taken from the project's own roll data
    -- (shared/data/job_abilities/cor/cor_rolls_*.lua).
    allies       = { action = 'ja', spell = "Allies' Roll",           target = 'me', desc = 'Skillchain damage+' },
    avenger      = { action = 'ja', spell = "Avenger's Roll",         target = 'me', desc = 'Counter rate+' },
    beast        = { action = 'ja', spell = "Beast Roll",             target = 'me', desc = 'Pet Attack/Ranged Attack+' },
    blitzer      = { action = 'ja', spell = "Blitzer's Roll",         target = 'me', desc = 'Attack delay-' },
    bolter       = { action = 'ja', spell = "Bolter's Roll",          target = 'me', desc = 'Movement speed+' },
    caster       = { action = 'ja', spell = "Caster's Roll",          target = 'me', desc = 'Fast Cast+' },
    chaos        = { action = 'ja', spell = "Chaos Roll",             target = 'me', desc = 'Attack+' },
    choral       = { action = 'ja', spell = "Choral Roll",            target = 'me', desc = 'Spell interruption rate-' },
    companion    = { action = 'ja', spell = "Companion's Roll",       target = 'me', desc = 'Pet Regain/Regen' },
    corsair      = { action = 'ja', spell = "Corsair's Roll",         target = 'me', desc = 'EXP/CP/EP bonus' },
    courser      = { action = 'ja', spell = "Courser's Roll",         target = 'me', desc = 'Snapshot+' },
    dancer       = { action = 'ja', spell = "Dancer's Roll",          target = 'me', desc = 'Regen (HP/tick)' },
    drachen      = { action = 'ja', spell = "Drachen Roll",           target = 'me', desc = 'Pet Accuracy/Ranged Accuracy+' },
    evoker       = { action = 'ja', spell = "Evoker's Roll",          target = 'me', desc = 'Refresh (MP regen)' },
    fighter      = { action = 'ja', spell = "Fighter's Roll",         target = 'me', desc = 'Double Attack rate+' },
    gallant      = { action = 'ja', spell = "Gallant's Roll",         target = 'me', desc = 'Defense+' },
    healer       = { action = 'ja', spell = "Healer's Roll",          target = 'me', desc = 'Cure potency+' },
    hunter       = { action = 'ja', spell = "Hunter's Roll",          target = 'me', desc = 'Accuracy/Ranged Accuracy+' },
    magus        = { action = 'ja', spell = "Magus's Roll",           target = 'me', desc = 'Magic Defense+' },
    miser        = { action = 'ja', spell = "Miser's Roll",           target = 'me', desc = 'Save TP' },
    monk         = { action = 'ja', spell = "Monk's Roll",            target = 'me', desc = 'Subtle Blow+' },
    naturalist   = { action = 'ja', spell = "Naturalist's Roll",      target = 'me', desc = 'Enhancing magic duration+' },
    ninja        = { action = 'ja', spell = "Ninja Roll",             target = 'me', desc = 'Evasion+' },
    puppet       = { action = 'ja', spell = "Puppet Roll",            target = 'me', desc = 'Pet Magic Attack/Magic Accuracy+' },
    rogue        = { action = 'ja', spell = "Rogue's Roll",           target = 'me', desc = 'Critical hit rate+' },
    runeist      = { action = 'ja', spell = "Runeist's Roll",         target = 'me', desc = 'Magic Evasion+' },
    samurai      = { action = 'ja', spell = "Samurai Roll",           target = 'me', desc = 'Store TP+' },
    scholar      = { action = 'ja', spell = "Scholar's Roll",         target = 'me', desc = 'Conserve MP+' },
    tactician    = { action = 'ja', spell = "Tactician's Roll",       target = 'me', desc = 'Regain (TP/tick)' },
    warlock      = { action = 'ja', spell = "Warlock's Roll",         target = 'me', desc = 'Magic Accuracy+' },
    wizard       = { action = 'ja', spell = "Wizard's Roll",          target = 'me', desc = 'Magic Attack+' },

    -- Roll management
    altdoubleup  = { action = 'ja', spell = 'Double-Up',   target = 'me', desc = 'Double-Up' },
    fold         = { action = 'ja', spell = 'Fold',        target = 'me', desc = 'Fold' },
    snakeeye     = { action = 'ja', spell = 'Snake Eye',   target = 'me', desc = 'Snake Eye' },
    randomdeal   = { action = 'ja', spell = 'Random Deal', target = 'me', desc = 'Random Deal' },

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
