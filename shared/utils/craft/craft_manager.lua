---  ═══════════════════════════════════════════════════════════════════════════
---   Craft Manager - Equip craft / fishing sets across any job
---  ═══════════════════════════════════════════════════════════════════════════
---   File layout (per character):
---     <charname>/sets/<name>_sets.lua  -> one file per craft kind
---       e.g. Tetsouo/sets/bonecraft_sets.lua
---            Tetsouo/sets/fishing_sets.lua
---
---   Two file shapes are supported:
---
---     A) Single set (fishing_sets.lua):
---        return {
---            description = 'Fishing',
---            gear = { range='Ebisu F. Rod +1', head='Tlahtlamah Glasses', ... },
---        }
---
---     B) Multi-variant set (bonecraft_sets.lua):
---        return {
---            default  = 'hq',                -- variant used when no arg
---            variants = {
---                hq = { description=..., aliases={...}, gear={...} },
---                nq = { ... },
---            },
---        }
---
---   Commands (wired in COMMON_COMMANDS):
---     //gs c craft           -> default variant of bonecraft_sets.lua
---     //gs c craft nq        -> the 'nq' variant of bonecraft_sets.lua
---     //gs c craft success   -> the 'success' variant of bonecraft_sets.lua
---     //gs c fish            -> fishing_sets.lua (single set)
---     //gs c uncraft         -> unlock slots, normal gear resumes
---
---   @file shared/utils/craft/craft_manager.lua
---  ═══════════════════════════════════════════════════════════════════════════

local CraftManager = {}

local _MessageFormatter = nil
local function formatter()
    if not _MessageFormatter then
        _MessageFormatter = require('shared/utils/messages/message_formatter')
    end
    return _MessageFormatter
end

-- State stored on _G so it survives module re-requires (GearSwap may invalidate
-- the package.loaded cache between command invocations, which would reset
-- a module-local table).
_G.__CraftManagerState = _G.__CraftManagerState or { active = false, active_name = nil }
local _state = _G.__CraftManagerState

---  ═══════════════════════════════════════════════════════════════════════════
---   FILE LOADING
---  ═══════════════════════════════════════════════════════════════════════════

--- Load a single craft set file by name (e.g. 'bonecraft', 'fishing').
--- Path: <charname>/sets/<name>_sets.lua
--- Returns the file's table or nil.
local function load_craft_file(name)
    local p = windower.ffxi.get_player()
    if not p or not p.name then return nil end
    local mod_path = p.name .. '/sets/' .. name:lower() .. '_sets'
    local ok, cfg = pcall(require, mod_path)
    if not ok or type(cfg) ~= 'table' then return nil end
    return cfg
end

--- Resolve a (file, variant) pair into a gear set + description.
--- @param file_name  string  e.g. 'bonecraft', 'fishing'
--- @param variant    string|nil  e.g. 'hq', 'nq', 'success' (or nil for default)
--- @return table|nil entry  with .description and .gear
local function resolve(file_name, variant)
    local cfg = load_craft_file(file_name)
    if not cfg then
        local p = windower.ffxi.get_player()
        return nil, ('No set file %s/sets/%s_sets.lua'):format(
            (p and p.name) or '?', file_name:lower())
    end

    -- Multi-variant shape (cfg.variants table)
    if type(cfg.variants) == 'table' then
        -- No variant given -> use cfg.default
        if not variant or variant == '' then
            variant = cfg.default
        end
        if not variant then
            return nil, ('%s has no `default` variant set'):format(file_name)
        end
        -- Direct lookup
        local entry = cfg.variants[variant:lower()]
        if entry then return entry end
        -- Alias scan
        for _, v in pairs(cfg.variants) do
            if type(v.aliases) == 'table' then
                for _, a in ipairs(v.aliases) do
                    if a:lower() == variant:lower() then return v end
                end
            end
        end
        local available = {}
        for k, _ in pairs(cfg.variants) do table.insert(available, k) end
        table.sort(available)
        return nil, ('Unknown variant "%s" for %s. Available: %s'):format(
            variant, file_name, table.concat(available, ', '))
    end

    -- Single-set shape
    if type(cfg.gear) == 'table' then
        return cfg
    end

    return nil, ('%s/%s.lua: invalid format (no .gear or .variants)'):format(
        'config/craft', file_name)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ACTIONS
---  ═══════════════════════════════════════════════════════════════════════════

--- Resolve a set entry by file + variant. Public so COMMON_COMMANDS (which
--- has access to the GearSwap-injected `equip()` function) can call it then
--- perform the actual equip itself.
--- @return table|nil entry  with .description and .gear
--- @return string|nil error_message
function CraftManager.resolve_set(file_name, variant)
    return resolve(file_name, variant)
end

--- Mark the manager as active so uncraft knows there's a session to close.
function CraftManager.mark_active(name)
    _state.active      = true
    _state.active_name = name
end

--- Unlock slots, allowing the idle/engaged hook to resume normal gear.
function CraftManager.unequip()
    if not _state.active then
        formatter().show_info('[Craft] No craft set is currently active.')
        return
    end
    windower.send_command('gs enable all')
    local was = _state.active_name
    _state.active      = false
    _state.active_name = nil
    formatter().show_success(('[Craft] Unlocked %s. Normal gear will resume.'):format(was or '?'))
    -- Refill consumables after exiting craft mode (parity with gs c craft).
    coroutine.schedule(function()
        windower.send_command('gs c rf')
    end, 0.5)
end

return CraftManager
