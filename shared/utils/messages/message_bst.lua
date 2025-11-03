---============================================================================
--- BST Message Module - Professional Multi-Color Messages
---============================================================================
--- BST-specific message handling with dynamic job tags and multi-color formatting.
--- Displays ecosystem, species, broth, and pet management messages.
---
--- @file utils/messages/message_bst.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-10-17 | Updated: 2025-10-17
---============================================================================

local MessageBST = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Message core (for job tag and color codes)
local MessageCore = require('shared/utils/messages/message_core')
local Colors = MessageCore.COLORS  -- Centralized color configuration

---============================================================================
--- ECOSYSTEM MESSAGES (MULTI-COLOR)
---============================================================================

--- Display ecosystem change message with professional multi-color formatting
--- @param ecosystem string Ecosystem name ("Aquan", "Beast", etc.)
--- @param num_species number Number of species in this ecosystem
--- @return void
function MessageBST.show_ecosystem_change(ecosystem, num_species)
    local job_tag = MessageCore.get_job_tag()
    local species_text = num_species == 1 and "species" or "species"

    -- Color codes
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)
    local colorAction = MessageCore.create_color_code(Colors.SUCCESS)  -- Green for ecosystem
    local colorInfo = MessageCore.create_color_code(Colors.INFO)       -- Light blue for count

    -- Build message: [JOB/SUBJOB] Ecosystem -> Aquan (2 species)
    local message = string.format(
        '%s[%s%s%s] %sEcosystem%s -> %s%s%s (%s%d %s%s)',
        colorGray,
        colorJob, job_tag, colorGray,
        colorGray,
        colorGray,
        colorAction, ecosystem, colorGray,
        colorInfo, num_species, species_text, colorGray
    )

    add_to_chat(1, message)
end

--- Display species change message with professional multi-color formatting
--- @param species string Species name ("Fish", "Tiger", etc.)
--- @param num_jugs number Number of jugs in inventory
--- @return void
function MessageBST.show_species_change(species, num_jugs)
    local job_tag = MessageCore.get_job_tag()
    local jug_text = num_jugs == 1 and "jug" or "jugs"

    -- Color codes
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)
    local colorAction = MessageCore.create_color_code(Colors.JA)       -- Yellow for species
    local colorInfo = MessageCore.create_color_code(Colors.INFO)       -- Light blue for count

    -- Build message: [JOB/SUBJOB] Species -> Crab (12 jugs)
    local message = string.format(
        '%s[%s%s%s] %sSpecies%s -> %s%s%s (%s%d %s%s)',
        colorGray,
        colorJob, job_tag, colorGray,
        colorGray,
        colorGray,
        colorAction, species, colorGray,
        colorInfo, num_jugs, jug_text, colorGray
    )

    add_to_chat(1, message)
end

---============================================================================
--- BROTH MESSAGES (MULTI-COLOR)
---============================================================================

--- Display broth equip message with professional multi-color formatting
--- @param pet_name string Pet name ("Amiable Roche (Fish)")
--- @param broth_name string Broth name ("Airy Broth")
--- @return void
function MessageBST.show_broth_equip(pet_name, broth_name)
    local job_tag = MessageCore.get_job_tag()

    -- Color codes
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)
    local colorBroth = MessageCore.create_color_code(Colors.ITEM_COLOR)  -- Tan for broth
    local colorPet = MessageCore.create_color_code(Colors.JA)            -- Yellow for pet

    -- Build message: [JOB/SUBJOB] Equipping Airy Broth for Amiable Roche (Fish)
    local message = string.format(
        '%s[%s%s%s] %sEquipping %s%s%s for %s%s%s',
        colorGray,
        colorJob, job_tag, colorGray,
        colorGray,
        colorBroth, broth_name, colorGray,
        colorPet, pet_name, colorGray
    )

    add_to_chat(1, message)
end

--- Display broth inventory header with separator
--- @return void
function MessageBST.show_broth_count_header()
    local job_tag = MessageCore.get_job_tag()

    -- Color codes
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)
    local colorHeader = MessageCore.create_color_code(Colors.HEADER)

    -- Top separator
    local separator = string.rep("=", 50)
    add_to_chat(1, colorGray .. separator)

    -- Header: [JOB/SUBJOB] === Broth Inventory ===
    local message = string.format(
        '%s[%s%s%s] %s=== Broth Inventory ===%s',
        colorGray,
        colorJob, job_tag, colorGray,
        colorHeader, colorGray
    )

    add_to_chat(1, message)
end

--- Display broth count line with multi-color formatting
--- @param broth_name string Broth name
--- @param count number Broth count
--- @return void
function MessageBST.show_broth_count_line(broth_name, count)
    local job_tag = MessageCore.get_job_tag()

    -- Color codes
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)
    local colorBroth = MessageCore.create_color_code(Colors.ITEM_COLOR)
    local colorCount = MessageCore.create_color_code(Colors.SUCCESS)

    -- Build message: [JOB/SUBJOB]   * Airy Broth: 12
    local message = string.format(
        '%s[%s%s%s]   %s*%s %s%s%s: %s%d%s',
        colorGray,
        colorJob, job_tag, colorGray,
        colorGray, colorGray,
        colorBroth, broth_name, colorGray,
        colorCount, count, colorGray
    )

    add_to_chat(1, message)
end

--- Display broth inventory footer with separator
--- @return void
function MessageBST.show_broth_count_footer()
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local separator = string.rep("=", 50)
    add_to_chat(1, colorGray .. separator)
end

--- Display no broths message
--- @return void
function MessageBST.show_no_broths()
    local job_tag = MessageCore.get_job_tag()

    -- Color codes
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)
    local colorWarning = MessageCore.create_color_code(Colors.WARNING)

    -- Build message: [JOB/SUBJOB] No broths in inventory
    local message = string.format(
        '%s[%s%s%s] %sNo broths in inventory%s',
        colorGray,
        colorJob, job_tag, colorGray,
        colorWarning, colorGray
    )

    add_to_chat(1, message)
end

---============================================================================
--- PET MANAGEMENT MESSAGES (MULTI-COLOR)
---============================================================================

--- Display pet engage message
--- @return void
function MessageBST.show_pet_engage()
    local job_tag = MessageCore.get_job_tag()

    -- Color codes
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)
    local colorSuccess = MessageCore.create_color_code(Colors.SUCCESS)

    -- Build message: [JOB/SUBJOB] Pet engaging target
    local message = string.format(
        '%s[%s%s%s] %sPet engaging target%s',
        colorGray,
        colorJob, job_tag, colorGray,
        colorSuccess, colorGray
    )

    add_to_chat(1, message)
end

--- Display pet disengage message
--- @return void
function MessageBST.show_pet_disengage()
    local job_tag = MessageCore.get_job_tag()

    -- Color codes
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)
    local colorInfo = MessageCore.create_color_code(Colors.INFO)

    -- Build message: [JOB/SUBJOB] Pet disengaging
    local message = string.format(
        '%s[%s%s%s] %sPet disengaging%s',
        colorGray,
        colorJob, job_tag, colorGray,
        colorInfo, colorGray
    )

    add_to_chat(1, message)
end

--- Display auto-engage status message
--- @param enabled boolean True if auto-engage is enabled
--- @return void
function MessageBST.show_auto_engage_status(enabled)
    local job_tag = MessageCore.get_job_tag()
    local status = enabled and "ON" or "OFF"

    -- Color codes
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)
    local colorStatus = enabled and MessageCore.create_color_code(Colors.SUCCESS) or MessageCore.create_color_code(Colors.WARNING)

    -- Build message: [JOB/SUBJOB] Auto Pet Engage -> ON
    local message = string.format(
        '%s[%s%s%s] %sAuto Pet Engage%s -> %s%s%s',
        colorGray,
        colorJob, job_tag, colorGray,
        colorGray,
        colorGray,
        colorStatus, status, colorGray
    )

    add_to_chat(1, message)
end

---============================================================================
--- READY MOVE MESSAGES (MULTI-COLOR)
---============================================================================

--- Display ready move precast message
--- @param move_name string Ready move name
--- @param category string Ready move category
--- @return void
function MessageBST.show_ready_move_precast(move_name, category)
    local job_tag = MessageCore.get_job_tag()

    -- Color codes
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)
    local colorMove = MessageCore.create_color_code(Colors.JA)      -- Yellow for move name
    local colorCategory = MessageCore.create_color_code(Colors.INFO) -- Light blue for category

    -- Build message: [JOB/SUBJOB] Ready Move -> Foot Kick (Physical)
    local message = string.format(
        '%s[%s%s%s] %sReady Move%s -> %s%s%s (%s%s%s)',
        colorGray,
        colorJob, job_tag, colorGray,
        colorGray,
        colorGray,
        colorMove, move_name, colorGray,
        colorCategory, category, colorGray
    )

    add_to_chat(1, message)
end

--- Display ready moves list header
--- @param pet_name string Pet name
--- @return void
function MessageBST.show_ready_moves_header(pet_name)
    MessageCore.section_header(string.format("Ready Moves (%s)", pet_name))
end

--- Display ready move list item
--- @param index number Move index
--- @param move_name string Move name
--- @return void
function MessageBST.show_ready_move_item(index, move_name)
    local job_tag = MessageCore.get_job_tag()

    -- Color codes
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)
    local colorIndex = MessageCore.create_color_code(Colors.INFO)
    local colorMove = MessageCore.create_color_code(Colors.SUCCESS)

    -- Build message: [JOB/SUBJOB]   #1 - Sheep Song
    local message = string.format(
        '%s[%s%s%s]   %s#%d%s - %s%s%s',
        colorGray,
        colorJob, job_tag, colorGray,
        colorIndex, index, colorGray,
        colorMove, move_name, colorGray
    )

    add_to_chat(159, message)
end

--- Display ready moves usage hint
--- @param max_index number Maximum index
--- @return void
function MessageBST.show_ready_moves_usage(max_index)
    MessageCore.info(string.format("Usage: //gs c RdyMove [1-%d]", max_index))
end

--- Display ready move execution (direct)
--- @param index number Move index
--- @param move_name string Move name
--- @return void
function MessageBST.show_ready_move_use(index, move_name)
    local job_tag = MessageCore.get_job_tag()

    -- Color codes
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)
    local colorAction = MessageCore.create_color_code(Colors.JA)

    -- Build message: [JOB/SUBJOB] Using Ready Move #1: Sheep Song
    local message = string.format(
        '%s[%s%s%s] %sUsing Ready Move%s %s#%d%s: %s%s%s',
        colorGray,
        colorJob, job_tag, colorGray,
        colorGray, colorGray,
        colorAction, index, colorGray,
        colorAction, move_name, colorGray
    )

    add_to_chat(159, message)
end

--- Display ready move auto-engage (player engaged, pet idle)
--- @param index number Move index
--- @param move_name string Move name
--- @return void
function MessageBST.show_ready_move_auto_engage(index, move_name)
    local job_tag = MessageCore.get_job_tag()

    -- Color codes
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)
    local colorAction = MessageCore.create_color_code(Colors.SUCCESS)

    -- Build message: [JOB/SUBJOB] Auto-engage Ready Move #1: Sheep Song
    local message = string.format(
        '%s[%s%s%s] %sAuto-engage Ready Move%s %s#%d%s: %s%s%s',
        colorGray,
        colorJob, job_tag, colorGray,
        colorGray, colorGray,
        colorAction, index, colorGray,
        colorAction, move_name, colorGray
    )

    add_to_chat(159, message)
end

--- Display ready move auto-sequence (both idle)
--- @param index number Move index
--- @param move_name string Move name
--- @return void
function MessageBST.show_ready_move_auto_sequence(index, move_name)
    local job_tag = MessageCore.get_job_tag()

    -- Color codes
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)
    local colorAction = MessageCore.create_color_code(Colors.INFO)

    -- Build message: [JOB/SUBJOB] Auto-sequence Ready Move #1: Sheep Song
    local message = string.format(
        '%s[%s%s%s] %sAuto-sequence Ready Move%s %s#%d%s: %s%s%s',
        colorGray,
        colorJob, job_tag, colorGray,
        colorGray, colorGray,
        colorAction, index, colorGray,
        colorAction, move_name, colorGray
    )

    add_to_chat(159, message)
end

---============================================================================
--- ERROR MESSAGES (MULTI-COLOR)
---============================================================================

--- Display no pet active error
--- @return void
function MessageBST.error_no_pet()
    MessageCore.error("No pet active")
end

--- Display no ready moves available error
--- @return void
function MessageBST.error_no_ready_moves()
    MessageCore.error("No Ready Moves available")
end

--- Display invalid index error
--- @param index string Invalid index value
--- @return void
function MessageBST.error_invalid_index(index)
    MessageCore.error(string.format("Invalid index: %s", tostring(index)))
end

--- Display index out of range error
--- @param index number Given index
--- @param max number Maximum index
--- @return void
function MessageBST.error_index_out_of_range(index, max)
    MessageCore.error(string.format("Index %d out of range (max: %d)", index, max))
end

--- Display module not loaded error
--- @param module_name string Module name
--- @return void
function MessageBST.error_module_not_loaded(module_name)
    MessageCore.error(string.format("%s not loaded", module_name))
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageBST
