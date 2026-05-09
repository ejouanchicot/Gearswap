---  ═══════════════════════════════════════════════════════════════════════════
---   CraftCommands - Craft / fish gear command handlers
---  ═══════════════════════════════════════════════════════════════════════════
---   Extracted from COMMON_COMMANDS.lua to keep that file under the 600-line
---   soft limit. Mirrors the DEBUG_COMMANDS extraction pattern: a focused
---   sub-module re-exposed via aliases on CommonCommands.
---
---   Public API (called by COMMON_COMMANDS.handle_command dispatcher):
---     CraftCommands.handle_craft(variant)   - equip bonecraft set + lock slots
---     CraftCommands.handle_fish(variant)    - equip fishing set + lock slots
---     CraftCommands.handle_uncraft()        - unlock + restore previous gear
---
---   @file shared/utils/craft/craft_commands.lua
---  ═══════════════════════════════════════════════════════════════════════════

local CraftCommands = {}

local MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')

--- Lazy-load craft_manager. Reports a clean error via MessageFormatter on miss.
--- @return table|nil The craft manager module, or nil on failure.
local function load_craft_manager()
    local ok, m = pcall(require, 'shared/utils/craft/craft_manager')
    if ok and m then return m end
    local MessageFormatter = require('shared/utils/messages/message_formatter')
    MessageFormatter.show_error("Failed to load craft manager: " .. tostring(m))
    return nil
end

--- Equip a resolved craft set. Same synchronous-equip + delayed-disable
--- pattern as handle_naked, which is the known-working approach in user-env.
--- @param entry table  with .description and .gear
--- @param label string fallback name for messaging
local function equip_craft_gear(entry, label)
    -- Defensive: unlock all slots in case a previous //gs c wo or craft
    -- session left them disabled (equip respects gs disable, would no-op).
    windower.send_command('gs enable all')

    local count = 0
    for _ in pairs(entry.gear) do count = count + 1 end
    MessageCommands.show_craft_equipping(entry.description or label, count)

    equip(entry.gear)

    -- Lock slots after FFXI has time to process all packet swaps (~2s).
    coroutine.schedule(function()
        windower.send_command('gs disable all')
        MessageCommands.show_craft_ready(entry.description or label)
    end, 2.0)
end

--- Handle //gs c craft [variant]   (default = bonecraft, hq variant).
function CraftCommands.handle_craft(variant)
    local m = load_craft_manager()
    if not m then return false end

    if variant and (variant:lower() == 'off' or variant:lower() == 'stop'
                    or variant:lower() == 'uncraft') then
        m.unequip()
        return true
    end

    local entry, err = m.resolve_set('bonecraft', variant)
    if not entry then
        local MF = require('shared/utils/messages/message_formatter')
        MF.show_error('[Craft] ' .. (err or 'Unknown craft set'))
        return false
    end

    equip_craft_gear(entry, 'bonecraft')
    m.mark_active(entry.description or 'bonecraft')
    return true
end

--- Handle //gs c fish [variant]    (loads fishing_sets.lua).
function CraftCommands.handle_fish(variant)
    local m = load_craft_manager()
    if not m then return false end

    local entry, err = m.resolve_set('fishing', variant)
    if not entry then
        local MF = require('shared/utils/messages/message_formatter')
        MF.show_error('[Craft] ' .. (err or 'Unknown fishing set'))
        return false
    end

    equip_craft_gear(entry, 'fishing')
    m.mark_active(entry.description or 'fishing')
    return true
end

--- Handle //gs c uncraft (alias for //gs c craft off).
function CraftCommands.handle_uncraft()
    local m = load_craft_manager()
    if m then m.unequip(); return true end
    return false
end

return CraftCommands
