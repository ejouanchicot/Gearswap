---============================================================================
--- BLM Alt Commands - your overrides
---============================================================================
--- Merged on top of BLM_ALT_COMMANDS.lua, which is generated and rebuilt.
--- Nothing here is ever regenerated.
---
---   add     a name the generator does not produce
---   change  reuse an existing name, yours wins
---   remove  set the name to false
---
--- See BLM_ALT_CUSTOM.lua.example for the full format.
---
--- @file    config/alt/BLM_ALT_CUSTOM.lua
--- @author  Tetsouo
---============================================================================

local M = {}

M.commands = {

    -- ------------------------------------------------------------------
    -- Nukes that follow the main's BLM element
    -- ------------------------------------------------------------------
    altlight = {
        action = 'ma', target = 'lastst', group = 'elemental',
        spell_from_state = 'MainLightSpell', fallback = 'Fire V',
        desc = 'Nuke, follows the main light element',
    },
    altdark = {
        action = 'ma', target = 'lastst', group = 'elemental',
        spell_from_state = 'MainDarkSpell', fallback = 'Blizzard V',
        desc = 'Nuke, follows the main dark element',
    },
}

return M
