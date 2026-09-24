---============================================================================
--- Common Keybinds - keys shared by every job of a character
---============================================================================
--- Reads <Character>/config/COMMON_KEYBINDS.lua (same entry format as a
--- job's _KEYBINDS file) and appends its entries to the job's binds. A key
--- the job file already uses stays the job's: the job wins. No file, no
--- common keys.
---
--- @file shared/utils/keybinds/common_keybinds.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-24
---============================================================================

local CommonKeybinds = {}

--- The character's common binds, or an empty list.
--- @return table List of bind entries
function CommonKeybinds.load()
    local ok, config = pcall(require, 'config/COMMON_KEYBINDS')
    if ok and type(config) == 'table' and type(config.binds) == 'table' then
        return config.binds
    end
    return {}
end

--- Append the common binds to a job's list, skipping keys the job uses.
--- Runs once per list: a second call finds the marker and does nothing.
--- @param binds table The job's bind list (modified in place)
--- @return number Common binds added
function CommonKeybinds.merge_into(binds)
    if type(binds) ~= 'table' or binds._common_merged then
        return 0
    end
    binds._common_merged = true

    local taken = {}
    for _, bind in ipairs(binds) do
        if bind.key then taken[bind.key] = true end
    end

    local added = 0
    for _, bind in ipairs(CommonKeybinds.load()) do
        if bind.key and bind.command and not taken[bind.key] then
            binds[#binds + 1] = bind
            taken[bind.key] = true
            added = added + 1
        end
    end
    return added
end

return CommonKeybinds
