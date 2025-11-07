---============================================================================
--- Message Engine - Template compilation and formatting
---============================================================================
--- Design Pattern: Template Engine + Registry + Cache
--- Performance: Template compilation cached, O(1) lookup after first compile
--- Thread-safe: Yes (read-only cache after initialization)
---
--- @file core/message_engine.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-06
---============================================================================

local MessageEngine = {}

-- Cache des templates compilés (performance)
-- IMPORTANT: This cache persists across GearSwap reloads unless module is fully unloaded
local _template_cache = {}

-- Cache des données de messages chargées
local _message_data = {}

-- FORCE: Clear caches on module reload (prevents stale cached templates)
if _G.MESSAGE_ENGINE_LOADED then
    _template_cache = {}
    _message_data = {}
end
_G.MESSAGE_ENGINE_LOADED = true

-- Mapping de noms de couleurs vers codes FFXI (inline color codes)
-- Format: string.char(0x1F, color_code) où 0x1F = caractère de contrôle FFXI
-- Codes basés sur message_colors.lua (tous <= 255)
local COLOR_CODES = {
    -- Main colors
    cyan = string.char(0x1F, 13),     -- Cyan (spells) - SPELL color
    lightblue = string.char(0x1F, 207), -- Light Blue (job tags)
    white = string.char(0x1F, 1),     -- White (spells/abilities)
    gray = string.char(0x1F, 160),    -- Gray (descriptions/arrows)

    -- Status colors
    green = string.char(0x1F, 158),   -- Green (success/buffs)
    red = string.char(0x1F, 167),     -- Red (errors/debuffs)
    yellow = string.char(0x1F, 50),   -- Yellow (JA/WS)
    orange = string.char(0x1F, 57),   -- Orange (warnings)
    blue = string.char(0x1F, 122),    -- Blue (info)
    purple = string.char(0x1F, 208),  -- Purple (debuffs)

    -- Semantic color aliases (map to message_core COLORS)
    -- Note: Use unique names that don't conflict with template parameters
    jobtag = string.char(0x1F, 207),  -- Same as lightblue (job tags)
    separatorcolor = string.char(0x1F, 160), -- Same as gray (separators) - renamed to avoid conflict
    spellcolor = string.char(0x1F, 13),    -- Same as cyan (spells) - renamed to avoid conflict
    itemcolor = string.char(0x1F, 158),    -- Same as green (items) - renamed to avoid conflict
    warningcolor = string.char(0x1F, 57),  -- Same as orange (warnings) - renamed to avoid conflict
}

---============================================================================
--- TEMPLATE COMPILATION (Performance Critical)
---============================================================================

--- Compile un template en fonction optimisée
--- Parse une seule fois, réutilise N fois
--- Supports: {param} for parameters, {color}...{/} for inline colors
--- @param template string Template avec {placeholders} et {color}...{/}
--- @return function Compiled template function
local function compile_template(template)
    -- Cache check (hot path)
    if _template_cache[template] then
        return _template_cache[template]
    end

    -- Parse le template en parties
    local parts = {}
    local placeholders = {}
    local pos = 1

    while pos <= #template do
        -- Check for {/} (color end)
        local close_start, close_end = template:find("{/}", pos, true)

        -- Check for {color} or {param}
        local open_start, open_end, content = template:find("{([%w_]+)}", pos)

        -- Determine next token
        if not open_start then
            -- No more tokens, rest is literal
            if pos <= #template then
                table.insert(parts, {
                    type = "literal",
                    value = template:sub(pos)
                })
            end
            break
        end

        -- Literal text before token
        if open_start > pos then
            table.insert(parts, {
                type = "literal",
                value = template:sub(pos, open_start - 1)
            })
        end

        -- Check if it's a color or parameter
        if COLOR_CODES[content] then
            -- It's a color code
            table.insert(parts, {
                type = "color",
                color = content
            })
        else
            -- It's a parameter
            table.insert(parts, {
                type = "param",
                key = content
            })
            table.insert(placeholders, content)
        end

        pos = open_end + 1
    end

    -- Générer la fonction compilée (closure)
    local compiled_fn = function(params)
        local result_parts = {}

        for _, part in ipairs(parts) do
            if part.type == "literal" then
                table.insert(result_parts, part.value)
            elseif part.type == "color" then
                -- Insert color code
                local code = COLOR_CODES[part.color]
                if code then
                    table.insert(result_parts, code)
                end
            else -- param
                local value = params[part.key]

                if value == nil then

                    -- Error: missing parameter
                    error(string.format(
                        "MessageEngine: Missing parameter '%s' in template",
                        part.key
                    ))
                end
                table.insert(result_parts, tostring(value))
            end
        end

        return table.concat(result_parts)
    end

    -- Cache pour performance
    _template_cache[template] = compiled_fn

    return compiled_fn
end

---============================================================================
--- DATA LOADING (Lazy Loading Pattern)
---============================================================================

--- Load message data from file (lazy loading)
--- @param namespace string "BLM", "COMBAT", etc.
--- @return boolean success
function MessageEngine.load(namespace)
    -- Already loaded?
    if _message_data[namespace] then
        return true
    end

    -- Determine path based on namespace
    local path
    if namespace:upper() == namespace and #namespace <= 3 then
        -- Job (3-letter uppercase: BLM, BRD, etc.)
        path = 'shared/utils/messages/data/jobs/' .. namespace:lower() .. '_messages'
    else
        -- System (COMBAT, MAGIC, etc.)
        path = 'shared/utils/messages/data/systems/' .. namespace:lower() .. '_messages'
    end

    -- Try to load
    local success, data = pcall(require, path)

    if not success then
        error(string.format(
            "MessageEngine: Failed to load namespace '%s' from '%s'\nError: %s",
            namespace, path, tostring(data)
        ))
        return false
    end

    -- Validate data structure
    if type(data) ~= "table" then
        error(string.format(
            "MessageEngine: Invalid data for namespace '%s' - expected table, got %s",
            namespace, type(data)
        ))
        return false
    end

    -- Store in cache
    _message_data[namespace] = data

    return true
end

---============================================================================
--- FORMATTING API
---============================================================================

--- Format a message from template
--- @param namespace string "BLM", "COMBAT", etc.
--- @param key string Message key
--- @param params table Parameters to inject
--- @return string message, number color
function MessageEngine.format(namespace, key, params)
    params = params or {}

    -- Ensure data is loaded (lazy loading)
    if not _message_data[namespace] then
        local ok = MessageEngine.load(namespace)
        if not ok then
            return "[ERROR] Failed to load " .. namespace, 167
        end
    end

    -- Get template data
    local template_data = _message_data[namespace][key]
    if not template_data then
        error(string.format(
            "MessageEngine: Unknown message '%s.%s'",
            namespace, key
        ))
    end

    -- Validate template data structure
    if not template_data.template then
        error(string.format(
            "MessageEngine: Missing 'template' field for '%s.%s'",
            namespace, key
        ))
    end

    -- Compile template (cached)
    local compiled = compile_template(template_data.template)

    -- Format message
    local message = compiled(params)
    local color = template_data.color or 1

    return message, color
end

---============================================================================
--- UTILITY FUNCTIONS
---============================================================================

--- Check if a namespace is loaded
--- @param namespace string
--- @return boolean
function MessageEngine.is_loaded(namespace)
    return _message_data[namespace] ~= nil
end

--- Get all keys in a namespace (for debugging)
--- @param namespace string
--- @return table keys
function MessageEngine.list_keys(namespace)
    if not _message_data[namespace] then
        MessageEngine.load(namespace)
    end

    local keys = {}
    for key, _ in pairs(_message_data[namespace] or {}) do
        table.insert(keys, key)
    end
    table.sort(keys)

    return keys
end

--- Clear cache (for testing/reloading)
function MessageEngine.clear_cache()
    _template_cache = {}
    _message_data = {}
end

--- Get cache stats (for debugging)
--- @return table stats
function MessageEngine.get_stats()
    local template_count = 0
    for _ in pairs(_template_cache) do
        template_count = template_count + 1
    end

    local namespace_count = 0
    local message_count = 0
    for ns, data in pairs(_message_data) do
        namespace_count = namespace_count + 1
        for _ in pairs(data) do
            message_count = message_count + 1
        end
    end

    return {
        compiled_templates = template_count,
        loaded_namespaces = namespace_count,
        total_messages = message_count
    }
end

return MessageEngine
