---============================================================================
--- Common Keybinds - keys shared by every job of a character
---============================================================================
--- Reads <Character>/_common/keys/COMMON_KEYBINDS.lua (same entry format as a
--- job's _KEYBINDS file) and appends its entries to the job's binds. A key
--- the job file already uses stays the job's: the job wins. No file, no
--- common keys.
---
--- @file shared/utils/keybinds/common_keybinds.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-09-24
---============================================================================

local CommonKeybinds = {}

--- The character's common binds, or an empty list.
--- @return table List of bind entries
function CommonKeybinds.load()
    local ok, config = require('shared/utils/core/char_paths').load('common', 'COMMON_KEYBINDS')
    if ok and type(config) == 'table' and type(config.binds) == 'table' then
        return config.binds
    end
    return {}
end

--- Append the common binds to a job's list. Whether one gives way to a job
--- key is decided when the keys are laid, with the job key's own conditions
--- (KeybindManager get_active_binds): a common key only used by a /WAR job
--- key is still bound under /DRK. A common entry without override yields to
--- a job or custom key that applies; one with override = true wins over it
--- (BindManager's subjob and alt layers ranked above the main job's). Common
--- entries sharing a key: the last one that applies wins, in file order.
--- Every such overlap is reported (shared/utils/keybinds/key_conflicts.lua).
--- Runs once per list: a second call finds the marker and does nothing.
--- @param binds table The job's bind list (modified in place)
--- @return number Common binds added
function CommonKeybinds.merge_into(binds)
    if type(binds) ~= 'table' or binds._common_merged then
        return 0
    end
    binds._common_merged = true

    local added = 0
    for _, bind in ipairs(CommonKeybinds.load()) do
        if bind.key and bind.command then
            bind._common = true
            binds[#binds + 1] = bind
            added = added + 1
        end
    end
    return added
end

return CommonKeybinds
