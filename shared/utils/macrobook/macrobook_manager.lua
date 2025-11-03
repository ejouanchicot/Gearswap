---============================================================================
--- Macrobook Manager - Centralized Macrobook Management Factory
---============================================================================
--- Factory pattern that creates job-specific macrobook modules.
--- Eliminates 124-line duplication across WAR/PLD/DNC (372 lines → 124 lines).
---
--- @file utils/macrobook/macrobook_manager.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-05
---============================================================================

local MacrobookManager = {}

--- Create a macrobook module configured for a specific job
--- @param job_code string Job code (e.g., 'WAR', 'PLD', 'DNC')
--- @param config_path string Path to job macrobook config (e.g., 'config/war/WAR_MACROBOOK')
--- @param default_subjob string Default subjob for this job (e.g., 'SAM', 'RUN', 'NIN')
--- @param default_book number Default macro book number
--- @param default_page number Default macro page number
--- @return table Macrobook module with all functions
function MacrobookManager.create(job_code, config_path, default_subjob, default_book, default_page)

    -- Load message formatter
    local MessageFormatter = require('shared/utils/messages/message_formatter')

    -- Load macro book configuration from user config file
    local macro_config_success, MacroConfig = pcall(require, config_path)

    local MACROBOOKS
    if macro_config_success and MacroConfig then
        -- Support both old structure (macrobooks) and new structure (solo/dualbox)
        if MacroConfig.solo or MacroConfig.dualbox then
            -- New dual-boxing structure
            MACROBOOKS = {
                solo = MacroConfig.solo or {},
                dualbox = MacroConfig.dualbox or {}
            }
        else
            -- Legacy structure (macrobooks)
            MACROBOOKS = {
                solo = MacroConfig.macrobooks or {},
                dualbox = {}
            }
        end

        -- Add default configuration
        if MacroConfig.default then
            MACROBOOKS.solo['default'] = MacroConfig.default
        else
            MACROBOOKS.solo['default'] = { book = default_book, page = default_page }
        end
    else
        -- Config file not found - use fallback
        MACROBOOKS = {
            solo = {
                [default_subjob] = { book = default_book, page = default_page },
                ['default'] = { book = default_book, page = default_page }
            },
            dualbox = {}
        }
    end

    ---============================================================================
    --- MACRO BOOK FUNCTIONS WITH DELAY
    ---============================================================================

    --- Select macro book with delay to prevent FFXI erasure bug
    --- @param book number Macro book number
    --- @param page number Macro page number
    --- @param delay number Optional delay in seconds (default: 1.5)
    local function set_macro_with_delay(book, page, delay)
        delay = delay or 1.5

        coroutine.schedule(function()
            set_macro_page(page, book)
        end, delay)
    end

    --- Select default macro book based on current sub-job and dual-boxing status
    local function select_default_macro_book()
        if not player then
            coroutine.schedule(select_default_macro_book, 0.5)
            return
        end

        local sub_job = player.sub_job or default_subjob
        local config = nil

        -- Check if dual-boxing is active
        local dualbox_success, DualBoxManager = pcall(require, 'shared/utils/dualbox/dualbox_manager')
        if dualbox_success and DualBoxManager and DualBoxManager.is_alt_online() then
            local alt_job = DualBoxManager.get_alt_job()

            -- Try dualbox config first: dualbox[alt_job][subjob]
            if alt_job and MACROBOOKS.dualbox and MACROBOOKS.dualbox[alt_job] then
                config = MACROBOOKS.dualbox[alt_job][sub_job]
            end
        end

        -- Fallback to solo config if no dualbox config found
        if not config and MACROBOOKS.solo then
            config = MACROBOOKS.solo[sub_job] or MACROBOOKS.solo['default']
        end

        -- Final fallback (should never reach here)
        if not config then
            config = { book = default_book, page = default_page }
        end

        set_macro_with_delay(config.book, config.page, 1.5)
    end

    --- Manually set macro book for specific subjob
    --- @param subjob string Subjob code
    local function set_macro_book(subjob)
        if not subjob then return end

        subjob = string.upper(subjob)
        local config = MACROBOOKS.solo and MACROBOOKS.solo[subjob]

        if not config then
            MessageFormatter.show_error(string.format("%s: Unknown subjob '%s' for macro book", job_code, subjob))
            return
        end

        set_macro_with_delay(config.book, config.page, 0.5)
    end

    --- Get current macro book info for display
    --- @return table Macro book info {book, page, subjob}
    local function get_macro_info()
        if not player then return nil end

        local sub_job = player.sub_job or default_subjob
        local config = MACROBOOKS.solo and (MACROBOOKS.solo[sub_job] or MACROBOOKS.solo['default'])

        if not config then
            config = { book = default_book, page = default_page }
        end

        return {
            book = config.book,
            page = config.page,
            subjob = sub_job
        }
    end

    --- Display available macro book configurations
    local function show_macro_configs()
        MessageFormatter.show_success(string.format("%s Macro Book Configurations:", job_code))

        -- Display solo configs
        if MACROBOOKS.solo then
            MessageFormatter.show_info("  Solo Configurations:")
            for subjob, config in pairs(MACROBOOKS.solo) do
                if subjob ~= 'default' then
                    MessageFormatter.show_info(string.format("    %s/%s: Book %d Page %d",
                        job_code, subjob, config.book, config.page))
                end
            end
        end

        -- Display dualbox configs
        if MACROBOOKS.dualbox and next(MACROBOOKS.dualbox) then
            MessageFormatter.show_info("  Dual-Boxing Configurations:")
            for alt_job, subjob_configs in pairs(MACROBOOKS.dualbox) do
                for subjob, config in pairs(subjob_configs) do
                    MessageFormatter.show_info(string.format("    %s/%s + Alt %s: Book %d Page %d",
                        job_code, subjob, alt_job, config.book, config.page))
                end
            end
        end
    end

    ---============================================================================
    --- MODULE EXPORT
    ---============================================================================

    -- Export functions globally for include() compatibility
    _G.select_default_macro_book = select_default_macro_book
    _G['set_' .. string.lower(job_code) .. '_macro_book'] = set_macro_book
    _G['get_' .. string.lower(job_code) .. '_macro_info'] = get_macro_info
    _G['show_' .. string.lower(job_code) .. '_macro_configs'] = show_macro_configs

    -- Also return as module for require() usage
    return {
        -- Public API
        select_default_macro_book = select_default_macro_book,
        set_macro_book = set_macro_book,
        get_macro_info = get_macro_info,
        show_macro_configs = show_macro_configs,

        -- Legacy function names for compatibility
        ['set_' .. string.lower(job_code) .. '_macro_book'] = set_macro_book,
        ['get_' .. string.lower(job_code) .. '_macro_info'] = get_macro_info,
        ['show_' .. string.lower(job_code) .. '_macro_configs'] = show_macro_configs
    }
end

return MacrobookManager
