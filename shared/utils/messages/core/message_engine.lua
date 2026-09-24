---============================================================================
--- Message Engine - Template compilation and formatting
---============================================================================
--- Loads a namespace's template file on first use (data/jobs/ for 3-letter
--- all-caps namespaces, data/systems/ otherwise), compiles each template once
--- and caches the compiled function.
---
--- @file shared/utils/messages/core/message_engine.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-06
---============================================================================

local MessageEngine = {}

-- Only used for the region-specific orange.
local MessageColors = require('shared/utils/messages/message_colors')

-- Compiled templates, keyed by template string. Like every module local, this
-- is rebuilt each time GearSwap loads a job: require is cached per sandbox.
local _template_cache = {}

-- Loaded namespace tables, keyed by namespace
local _message_data = {}

-- The two tables above are always empty at this point, so this reset changes
-- nothing; kept because _G.MESSAGE_ENGINE_LOADED is listed by global_probe.
if _G.MESSAGE_ENGINE_LOADED then
    _template_cache = {}
    _message_data = {}
end
_G.MESSAGE_ENGINE_LOADED = true

-- Color tag -> inline FFXI color code (0x1F followed by the code byte).
-- These codes are this engine's own: they do not all match MessageColors
-- (e.g. cyan is 13 here, MessageColors.SPELL is 205). Only orange and
-- warningcolor are read from MessageColors.
local COLOR_CODES = {
    -- Main colors
    cyan = string.char(0x1F, 13),     -- Cyan (spells) - SPELL color
    lightblue = string.char(0x1F, 207), -- Light Blue (job tags)
    white = string.char(0x1F, 1),     -- White (spells/abilities)
    gray = string.char(0x1F, 160),    -- Gray (descriptions/arrows)
    darkgray = string.char(0x1F, 8),  -- Dark Gray (debug headers)

    -- Status colors
    green = string.char(0x1F, 158),   -- Green (success/buffs)
    red = string.char(0x1F, 167),     -- Red (errors/debuffs)
    yellow = string.char(0x1F, 50),   -- Yellow (JA)
    pink = string.char(0x1F, 11),     -- Pink/Rose (WS/Damage - code 011)
    healgreen = string.char(0x1F, 6), -- Heal Green (Healing spells - code 006)
    enhancing = string.char(0x1F, 206), -- Enhancing Magic (buffs - code 206)
    enfeebling = string.char(0x1F, 4), -- Enfeebling Magic (debuffs - code 004)
    divine = string.char(0x1F, 22),   -- Divine Magic (holy dmg - code 022)
    dark = string.char(0x1F, 15),     -- Dark Magic (drains/aspirs - code 015)
    bluemagic = string.char(0x1F, 219), -- Blue Magic (BLU spells - code 219)
    orange = string.char(0x1F, MessageColors.get_warning_color()),   -- Orange (warnings) - region-specific
    blue = string.char(0x1F, 122),    -- Blue (info)
    purple = string.char(0x1F, 208),  -- Purple (debuffs)

    -- Semantic aliases. Tag names must not collide with template parameter
    -- names: a parameter named like a tag is rendered as that color.
    jobtag = string.char(0x1F, 207),  -- Same as lightblue (job tags)
    separatorcolor = string.char(0x1F, 160), -- Same as gray (separators) - renamed to avoid conflict
    spellcolor = string.char(0x1F, 13),    -- Same as cyan (spells) - renamed to avoid conflict
    itemcolor = string.char(0x1F, 63),     -- Pale yellow (items) - code 063
    warningcolor = string.char(0x1F, MessageColors.get_warning_color()),  -- Same as orange (warnings) - region-specific
}

---============================================================================
--- TEMPLATE COMPILATION (Performance Critical)
---============================================================================

--- Compile a template into an optimized function
--- Parse once, reuse N times
--- Supports {param} for parameters and {color} for inline colors. A color
--- runs until the next color tag; {/} is not recognized and is printed as is.
--- @param template string Template with {placeholders} and {color} tags
--- @return function Compiled template function
local function compile_template(template)
    -- Cache check (hot path)
    if _template_cache[template] then
        return _template_cache[template]
    end

    -- Split the template into literal / color / param parts
    local parts = {}
    local placeholders = {}
    local pos = 1

    while pos <= #template do
        -- Next {color} or {param}
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

    -- Generate the compiled function (closure)
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

    -- Cache for performance
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
    if namespace:upper() == namespace and #namespace == 3 then
        -- Job (3-letter uppercase: BLM, BRD, etc.)
        path = 'shared/utils/messages/data/jobs/' .. namespace:lower() .. '_messages'
    else
        -- System (COMBAT, MAGIC, UI, etc.)
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
    for _, data in pairs(_message_data) do
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
