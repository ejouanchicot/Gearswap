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

-- Slot names accepted in set files, mapped to the names `player.equipment` uses.
local SLOT_ALIASES = {
    ranged   = 'range',
    ear1     = 'left_ear',  ear2     = 'right_ear',
    lear     = 'left_ear',  rear     = 'right_ear',
    learring = 'left_ear',  rearring = 'right_ear',
    ring1    = 'left_ring', ring2    = 'right_ring',
    lring    = 'left_ring', rring    = 'right_ring',
}

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

---  ═══════════════════════════════════════════════════════════════════════════
---   GEAR DIFFING
---  ═══════════════════════════════════════════════════════════════════════════

--- Rewrite a gear table with the slot names `player.equipment` uses, so a set
--- written with ear1/ring2 can be compared against what is actually worn.
--- @param gear table Slot -> item table from a craft set file
--- @return table Normalized copy
local function canonical_gear(gear)
    local out = {}
    if type(gear) ~= 'table' then return out end
    for slot, item in pairs(gear) do
        if type(slot) == 'string' then
            out[SLOT_ALIASES[slot:lower()] or slot:lower()] = item
        end
    end
    return out
end

--- Item name of a set entry (an entry may be a plain name or an augment table).
--- @param entry string|table|nil Set entry
--- @return string|nil Item name
local function item_name(entry)
    if type(entry) == 'table' then return entry.name end
    return entry
end

--- Compare two set entries by item name (FFXI item names are case-insensitive).
--- @param a string|table|nil First entry
--- @param b string|table|nil Second entry
--- @return boolean True when both name the same piece
local function same_item(a, b)
    a, b = item_name(a), item_name(b)
    if type(a) ~= 'string' or type(b) ~= 'string' then return false end
    return a:lower() == b:lower()
end

--- Slots that have to move to go from `previous` to `target`.
--- A slot is left untouched when the running craft session already put that
--- exact piece there and it is still worn: taking a piece out and putting it
--- back is not free in FFXI (an Escutcheon loses its synthesis support the
--- moment it leaves the slot), so switching variant must swap only what
--- actually differs.
--- @param previous table Canonical gear applied by the running session
--- @param target table Canonical gear of the variant being applied
--- @return table changed Slot -> item, the pieces to equip
--- @return table release List of slots the new variant no longer covers
local function diff_gear(previous, target)
    local worn = (player and player.equipment) or {}
    local changed, release = {}, {}

    for slot, item in pairs(target) do
        if not (same_item(previous[slot], item) and same_item(worn[slot], item)) then
            changed[slot] = item
        end
    end

    for slot in pairs(previous) do
        if target[slot] == nil then
            table.insert(release, slot)
        end
    end

    return changed, release
end

--- Count the entries of a gear table.
--- @param gear table Gear table
--- @return number Number of slots it covers
local function count_pieces(gear)
    local count = 0
    for _ in pairs(gear) do count = count + 1 end
    return count
end

---  ═══════════════════════════════════════════════════════════════════════════
---   EQUIP / LOCK
---  ═══════════════════════════════════════════════════════════════════════════

--- Re-lock the craft slots once FFXI has processed the swaps (~2s), then top up
--- consumables. Refill only moves items between bags (no gear swap), so it is
--- safe to run while the slots are locked.
--- @param slots table|nil Slots to lock again, nil to lock every slot
--- @param description string Set description, for the "ready" line
local function lock_after_delay(slots, description)
    coroutine.schedule(function()
        if slots then
            disable(slots)
        else
            windower.send_command('gs disable all')
        end
        MessageCommands.show_craft_ready(description)
    end, 2.0)
    coroutine.schedule(function()
        windower.send_command('gs c rf')
    end, 2.5)
end

--- Equip a resolved craft set.
---
--- With no session running, every slot is unlocked and the whole set goes on.
--- With one, only the slots whose piece changes are unlocked, swapped and
--- locked again - every other slot keeps the piece it already holds, so a
--- variant switch never drops the shield. Only //gs c uncraft releases the set.
---
--- @param entry table Resolved set, with .description and .gear
--- @param label string Fallback name for messaging
--- @param previous_gear table|nil Canonical gear of the running session
--- @return table Canonical gear now applied
local function equip_craft_gear(entry, label, previous_gear)
    local target      = canonical_gear(entry.gear)
    local description = entry.description or label

    if not previous_gear then
        -- Defensive: unlock all slots in case a previous //gs c wo or craft
        -- session left them disabled (equip respects gs disable, would no-op).
        --
        -- IMPORTANT: use the synchronous GearSwap `enable(...)` function, not
        -- `windower.send_command('gs enable all')`. The send_command path goes
        -- through Windower's command queue and lands AFTER `equip()` runs, so a
        -- chained `gs c craft` -> `gs c craft nq` would do equip() while slots
        -- were still disabled by the first session's `gs disable all`, making
        -- the second equip a silent no-op. The list mirrors gearswap.lua's
        -- `disenable(...,'all',...)` handler in user_functions.lua.
        enable('main', 'sub', 'range', 'ammo',
               'head', 'neck', 'ear1', 'ear2',
               'body', 'hands', 'ring1', 'ring2',
               'back', 'waist', 'legs', 'feet')

        MessageCommands.show_craft_equipping(description, count_pieces(target))
        equip(target)
        lock_after_delay(nil, description)
        return target
    end

    local changed, release = diff_gear(previous_gear, target)
    local touched = {}
    for slot in pairs(changed) do table.insert(touched, slot) end
    for _, slot in ipairs(release) do table.insert(touched, slot) end

    if #touched == 0 then
        -- Same pieces already on: nothing to swap, just re-assert the lock in
        -- case something (a zone, a manual `gs enable`) freed the slots.
        local held = {}
        for slot in pairs(target) do table.insert(held, slot) end
        lock_after_delay(held, description)
        return target
    end

    -- `enable()` flushes the gear GearSwap wanted to equip while the slot was
    -- locked; the `equip()` right after overrides it for the slots the new
    -- variant covers, and the released slots keep that normal gear.
    enable(touched)
    MessageCommands.show_craft_equipping(description, #touched)
    equip(changed)
    lock_after_delay(touched, description)
    return target
end

---  ═══════════════════════════════════════════════════════════════════════════
---   COMMAND HANDLERS
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle //gs c craft [variant]   (default = bonecraft, hq variant).
--- @param variant string|nil Variant key or alias, nil for the file default
--- @return boolean True when the set was applied
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

    local applied = equip_craft_gear(entry, 'bonecraft', m.active_gear())
    m.mark_active(entry.description or 'bonecraft', applied)
    apply_lockstyle(get_configured_lockstyle('craft_lockstyle', DEFAULT_CRAFT_LOCKSTYLE))
    return true
end

--- Handle //gs c fish [variant]    (loads fishing_sets.lua).
--- @param variant string|nil Variant key or alias, nil for the file default
--- @return boolean True when the set was applied
function CraftCommands.handle_fish(variant)
    local m = load_craft_manager()
    if not m then return false end

    local entry, err = m.resolve_set('fishing', variant)
    if not entry then
        local MF = require('shared/utils/messages/message_formatter')
        MF.show_error('[Craft] ' .. (err or 'Unknown fishing set'))
        return false
    end

    local applied = equip_craft_gear(entry, 'fishing', m.active_gear())
    m.mark_active(entry.description or 'fishing', applied)
    apply_lockstyle(get_configured_lockstyle('fish_lockstyle', DEFAULT_FISH_LOCKSTYLE))
    return true
end

--- Handle //gs c uncraft (alias for //gs c craft off).
--- @return boolean True when the session was closed
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
