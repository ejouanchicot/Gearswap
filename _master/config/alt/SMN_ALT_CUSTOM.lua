---============================================================================
--- SMN Alt Commands - your overrides
---============================================================================
--- Merged on top of SMN_ALT_COMMANDS.lua, which is generated and rebuilt.
--- Nothing here is ever regenerated.
---
---   add     a name the generator does not produce
---   change  reuse an existing name, yours wins
---   remove  set the name to false
---
--- @file    config/alt/SMN_ALT_CUSTOM.lua
--- @author  Tetsouo
---============================================================================

local M = {}

M.commands = {

    -- ------------------------------------------------------------------
    -- SMN job abilities
    -- ------------------------------------------------------------------
    -- The generated file is built from shared/data/magic/summoning/, which
    -- covers the avatars and their Blood Pacts but not SMN's own abilities:
    -- SMN is the one job with no shared/data/job_abilities/ folder, so there
    -- is nothing to read their levels from. They are written out by hand here.
    -- Targeting comes from res; the levels are the published ones - correct
    -- them here if the game disagrees, nothing regenerates this file.
    astralflow      = { action = 'ja',  spell = 'Astral Flow',      target = 'me', level = 1,  main_only = true, group = 'ja', desc = 'SP: Blood Pacts free, unlocks the ultimate pact' },
    astralconduit   = { action = 'ja',  spell = 'Astral Conduit',   target = 'me', level = 96, main_only = true, group = 'ja', desc = 'SP: Blood Pacts with no recast' },
    elementalsiphon = { action = 'ja',  spell = 'Elemental Siphon', target = 'me', level = 45, group = 'ja', desc = 'Drain MP from the summoned spirit' },
    manacede        = { action = 'ja',  spell = 'Mana Cede',        target = 'me', level = 87, main_only = true, group = 'ja', desc = 'Give the avatar your MP for its next pact' },
    apogee          = { action = 'ja',  spell = 'Apogee',           target = 'me', level = 95, main_only = true, group = 'ja', desc = 'Next Blood Pact: Rage hits harder' },

    -- Pet commands: no avatar out, nothing happens.
    avatarsfavor    = { action = 'pet', spell = "Avatar's Favor",   target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Aura from the avatar, grows while it stays out' },
    release         = { action = 'pet', spell = 'Release',          target = 'me', level = 1,  group = 'ja', desc = 'Dismiss the avatar' },
    assault         = { action = 'pet', spell = 'Assault',          target = 'lastst', level = 1, group = 'ja', desc = 'Send the avatar at your target' },
    retreat         = { action = 'pet', spell = 'Retreat',          target = 'me', level = 1,  group = 'ja', desc = 'Call the avatar back' },
}

return M
