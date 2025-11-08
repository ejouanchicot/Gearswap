---============================================================================
--- BST Messages Module - Beastmaster Job Message Formatting
---============================================================================
--- Uses NEW message system with inline colors
--- Delegates to api/messages.lua for all formatting
---
--- @file utils/messages/message_bst.lua
--- @author Tetsouo
--- @version 2.0 (NEW SYSTEM)
--- @date Created: 2025-10-17 | Migrated: 2025-11-06
---============================================================================

local MessageBST = {}

-- NEW message system
local M = require('shared/utils/messages/api/messages')

-- Message core (for legacy functions: section_header, info, error)
local MessageCore = require('shared/utils/messages/message_core')

-- Get job tag (for subjob support: BST/WHM >> "BST/WHM")
local function get_job_tag()
    local main_job = player and player.main_job or 'BST'
    local sub_job = player and player.sub_job or ''
    if sub_job and sub_job ~= '' and sub_job ~= 'NON' then
        return main_job .. '/' .. sub_job
    end
    return main_job
end

---============================================================================
--- ECOSYSTEM MESSAGES (NEW SYSTEM)
---============================================================================

--- Display ecosystem change message with professional multi-color formatting
--- @param ecosystem string Ecosystem name ("Aquan", "Beast", etc.)
--- @param num_species number Number of species in this ecosystem
--- @return void
function MessageBST.show_ecosystem_change(ecosystem, num_species)
    local species_text = num_species == 1 and "species" or "species"

    M.job('BST', 'ecosystem_change', {
        job = get_job_tag(),
        ecosystem = ecosystem,
        count = num_species,
        species_text = species_text
    })
end

--- Display species change message with professional multi-color formatting
--- @param species string Species name ("Fish", "Tiger", etc.)
--- @param num_jugs number Number of jugs in inventory
--- @return void
function MessageBST.show_species_change(species, num_jugs)
    local jug_text = num_jugs == 1 and "jug" or "jugs"

    M.job('BST', 'species_change', {
        job = get_job_tag(),
        species = species,
        count = num_jugs,
        jug_text = jug_text
    })
end

---============================================================================
--- BROTH MESSAGES (NEW SYSTEM)
---============================================================================

--- Display broth equip message with professional multi-color formatting
--- @param pet_name string Pet name ("Amiable Roche (Fish)")
--- @param broth_name string Broth name ("Airy Broth")
--- @return void
function MessageBST.show_broth_equip(pet_name, broth_name)
    M.job('BST', 'broth_equip', {
        job = get_job_tag(),
        broth = broth_name,
        pet = pet_name
    })
end

--- Display broth inventory header with separator
--- @return void
function MessageBST.show_broth_count_header()
    -- Top separator
    MessageCore.show_separator(50)

    -- Header using new system
    M.job('BST', 'broth_count_header', {
        job = get_job_tag()
    })
end

--- Display broth count line with multi-color formatting
--- @param broth_name string Broth name
--- @param count number Broth count
--- @return void
function MessageBST.show_broth_count_line(broth_name, count)
    M.job('BST', 'broth_count_line', {
        job = get_job_tag(),
        broth = broth_name,
        count = count
    })
end

--- Display broth inventory footer with separator
--- @return void
function MessageBST.show_broth_count_footer()
    MessageCore.show_separator(50)
end

--- Display no broths message
--- @return void
function MessageBST.show_no_broths()
    M.job('BST', 'no_broths', {
        job = get_job_tag()
    })
end

---============================================================================
--- PET MANAGEMENT MESSAGES (NEW SYSTEM)
---============================================================================

--- Display pet engage message
--- @return void
function MessageBST.show_pet_engage()
    M.job('BST', 'pet_engage', {
        job = get_job_tag()
    })
end

--- Display pet disengage message
--- @return void
function MessageBST.show_pet_disengage()
    M.job('BST', 'pet_disengage', {
        job = get_job_tag()
    })
end

--- Display auto-engage status message
--- @param enabled boolean True if auto-engage is enabled
--- @return void
function MessageBST.show_auto_engage_status(enabled)
    local status = enabled and "ON" or "OFF"
    local status_color = enabled and "{green}" or "{orange}"

    M.job('BST', 'auto_engage_status', {
        job = get_job_tag(),
        status = status,
        status_color = status_color
    })
end

---============================================================================
--- READY MOVE MESSAGES (NEW SYSTEM)
---============================================================================

--- Display ready move precast message
--- @param move_name string Ready move name
--- @param category string Ready move category
--- @return void
function MessageBST.show_ready_move_precast(move_name, category)
    M.job('BST', 'ready_move_precast', {
        job = get_job_tag(),
        move = move_name,
        category = category
    })
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
    M.job('BST', 'ready_move_item', {
        job = get_job_tag(),
        index = index,
        move = move_name
    })
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
    M.job('BST', 'ready_move_use', {
        job = get_job_tag(),
        index = index,
        move = move_name
    })
end

--- Display ready move auto-engage (player engaged, pet idle)
--- @param index number Move index
--- @param move_name string Move name
--- @return void
function MessageBST.show_ready_move_auto_engage(index, move_name)
    M.job('BST', 'ready_move_auto_engage', {
        job = get_job_tag(),
        index = index,
        move = move_name
    })
end

--- Display ready move auto-sequence (both idle)
--- @param index number Move index
--- @param move_name string Move name
--- @return void
function MessageBST.show_ready_move_auto_sequence(index, move_name)
    M.job('BST', 'ready_move_auto_sequence', {
        job = get_job_tag(),
        index = index,
        move = move_name
    })
end

---============================================================================
--- ERROR MESSAGES (LEGACY - using MessageCore)
---============================================================================

--- Display no pet active error
--- @return void
function MessageBST.show_error_no_pet()
    MessageCore.error("No pet active")
end

--- Display no ready moves available error
--- @return void
function MessageBST.show_error_no_ready_moves()
    MessageCore.error("No Ready Moves available")
end

--- Display invalid index error
--- @param index string Invalid index value
--- @return void
function MessageBST.show_error_invalid_index(index)
    MessageCore.error(string.format("Invalid index: %s", tostring(index)))
end

--- Display index out of range error
--- @param index number Given index
--- @param max number Maximum index
--- @return void
function MessageBST.show_error_index_out_of_range(index, max)
    MessageCore.error(string.format("Index %d out of range (max: %d)", index, max))
end

--- Display module not loaded error
--- @param module_name string Module name
--- @return void
function MessageBST.show_error_module_not_loaded(module_name)
    MessageCore.error(string.format("%s not loaded", module_name))
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageBST
