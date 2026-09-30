---============================================================================
--- Job Addons - whether a job may load / unload a Windower addon for you
---============================================================================
--- Some jobs drive an addon on their own: COR unloads rolltracker (its own
--- roll tracker replaces it) and loads it back when you leave COR, BST loads
--- bst-hud, GEO loads pettp, BLU loads AzureSets. The character's
--- _common/display/ADDONS_CONFIG.lua can stop any of them (name = false):
--- the job then leaves that addon alone. Everything allowed when the file
--- or the name is missing.
---
--- @file shared/utils/core/job_addons.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-09-30
---============================================================================

local JobAddons = {}

--- Whether the jobs may load / unload `addon`.
--- @param addon string Addon name (case ignored)
--- @return boolean
function JobAddons.allowed(addon)
    local ok, cfg = pcall(function()
        return require('shared/utils/core/char_paths').optional('common', 'ADDONS_CONFIG')
    end)
    if not ok or type(cfg) ~= 'table' then return true end
    for name, value in pairs(cfg) do
        if type(name) == 'string' and name:lower() == addon:lower() then
            return value ~= false
        end
    end
    return true
end

--- Send `lua load|unload <addon>` unless ADDONS_CONFIG.lua stops it.
--- @param action string 'load' or 'unload'
--- @param addon string Addon name
--- @return boolean True if the command was sent
function JobAddons.run(action, addon)
    if not JobAddons.allowed(addon) then return false end
    windower.send_command('lua ' .. action .. ' ' .. addon)
    return true
end

return JobAddons
