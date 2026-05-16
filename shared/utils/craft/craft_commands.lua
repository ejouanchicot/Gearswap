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

-- Default lockstyle numbers (overridden by per-character CRAFT_CONFIG.lua if present)
local DEFAULT_CRAFT_LOCKSTYLE = 19
local DEFAULT_FISH_LOCKSTYLE  = 17

--- Resolve the lockstyle number from per-character config, with fallback.
--- @param key string 'craft_lockstyle' or 'fish_lockstyle'
--- @param fallback number Default value if config missing
--- @return number
local function get_configured_lockstyle(key, fallback)
    local char_name = player and player.name
    if not char_name then return fallback end

    local ok, CraftConfig = pcall(require, char_name .. '/config/CRAFT_CONFIG')
    if ok and CraftConfig and type(CraftConfig[key]) == 'number' then
        return CraftConfig[key]
    end
    return fallback
end

--- Apply a specific lockstyle (DressUp-aware).
--- @param style number Lockstyle number to apply
local function apply_lockstyle(style)
    local ok, LockstyleManager = pcall(require, 'shared/utils/lockstyle/lockstyle_manager')
    if ok and LockstyleManager and LockstyleManager.apply_style then
        LockstyleManager.apply_style(style)
    end
end

--- Restore the current job's default lockstyle (via factory-exported global).
local function restore_job_lockstyle()
    if type(_G.select_default_lockstyle) == 'function' then
        _G.select_default_lockstyle()
    end
end

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
    -- Refill consumables after the lock has settled. Refill moves items
    -- between bags only (no gear swaps), so it's safe to run while slots
    -- are disabled.
    coroutine.schedule(function()
        windower.send_command('gs c rf')
    end, 2.5)
end

--- Handle //gs c craft [variant]   (default = bonecraft, hq variant).
function CraftCommands.handle_craft(variant)
    local m = load_craft_manager()
    if not m then return false end

    if variant and (variant:lower() == 'off' or variant:lower() == 'stop'
                    or variant:lower() == 'uncraft') then
        m.unequip()
        restore_job_lockstyle()
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
    apply_lockstyle(get_configured_lockstyle('craft_lockstyle', DEFAULT_CRAFT_LOCKSTYLE))
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
    apply_lockstyle(get_configured_lockstyle('fish_lockstyle', DEFAULT_FISH_LOCKSTYLE))
    return true
end

--- Handle //gs c uncraft (alias for //gs c craft off).
function CraftCommands.handle_uncraft()
    local m = load_craft_manager()
    if m then
        m.unequip()
        restore_job_lockstyle()
        return true
    end
    return false
end

return CraftCommands
