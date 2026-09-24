---============================================================================
--- Warp Command Registry - Single source of truth for warp shortcuts
---============================================================================
--- Lists every short alias the warp system accepts. Imported by:
---   - shared/utils/core/COMMON_COMMANDS.lua     (command dispatch)
---   - shared/utils/warp/warp_ipc.lua            (IPC broadcast whitelist)
---   - shared/utils/warp/warp_ipc_register.lua   (IPC receiver whitelist)
---
--- Adding a new warp command:
---   1. Add the alias here (in the appropriate category)
---   2. Add its branch in WarpCommands.handle_command() (warp_commands.lua)
---   3. Define the destination in database/* (if a destination cmd)
---
--- @file shared/utils/warp/warp_command_registry.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-05-01
---============================================================================

local Registry = {}

--- Master list of every warp-related short command, grouped by category.
--- Order doesn't matter.
Registry.COMMANDS = {
    -- BLM Spells
    'w', 'warp', 'w2', 'warp2', 'ret', 'retrace', 'esc', 'escape',

    -- WHM Teleports
    'tph', 'tpholla', 'tpd', 'tpdem', 'tpm', 'tpmea',
    'tpa', 'tpaltep', 'tpy', 'tpyhoat', 'tpv', 'tpvahzl',

    -- WHM Recalls
    'rj', 'recjugner', 'rp', 'recpashh', 'rm', 'recmeriph',

    -- Nations
    'sd', 'sandoria', 'bt', 'bastok', 'wd', 'windurst',

    -- Jeuno
    'jn', 'jeuno',

    -- Outpost Cities
    'sb', 'selbina', 'mh', 'mhaura', 'rb', 'rabao', 'kz', 'kazham', 'ng', 'norg',

    -- Expansion Cities
    'tv', 'tavnazia', 'au', 'wg', 'whitegate', 'ns', 'nashmau', 'ad', 'adoulin',

    -- Chocobo Stables
    'stsd', 'stable-sd', 'stbt', 'stable-bt', 'stwd', 'stable-wd', 'stjn', 'stable-jn',

    -- Conquest Outposts
    'op', 'outpost',

    -- Adoulin Frontier
    'cz', 'ceizak', 'ys', 'yahse', 'hn', 'hennetiel', 'mm', 'morimar',
    'mj', 'marjami', 'yc', 'yorcia', 'km', 'kamihr',

    -- Special Locations
    'wj', 'wajaom', 'ar', 'arrapago', 'pg', 'purgonorgo', 'rl', 'rulude',
    'zv', 'zvahl', 'riv', 'riverne', 'yo', 'yoran', 'lf', 'leafallia',
    'bh', 'behemoth', 'cc', 'chocircuit', 'pt', 'parting', 'cg', 'chocogirl',

    -- Unique Mechanics
    'ld', 'leader', 'td', 'tidal',
}

--- O(1) lookup set built from COMMANDS array. Use Registry.is_warp_command(cmd).
Registry.SET = {}
for _, cmd in ipairs(Registry.COMMANDS) do
    Registry.SET[cmd] = true
end

--- Check whether a word is a registered warp alias.
--- @param cmd string Short alias (lowercased) to check
--- @return boolean true if cmd is a known warp command
function Registry.is_warp_command(cmd)
    return Registry.SET[cmd] == true
end

---============================================================================
--- SHARED TIMING CONSTANTS
---============================================================================
-- Debounce window for IPC messages between dual-boxed clients.
-- Used by both warp_ipc.lua (sender) and warp_ipc_register.lua (receiver) so
-- they MUST agree on the value. Don't override locally.
Registry.IPC_DEBOUNCE = 1.0

return Registry
