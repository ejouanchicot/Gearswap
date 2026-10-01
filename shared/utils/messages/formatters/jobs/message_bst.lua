---============================================================================
--- BST Messages Module - Beastmaster Job Message Formatting
---============================================================================
--- Job ability, ecosystem, broth/jug, pet and Ready move lines for BST.
--- Templates: data/jobs/bst_messages.lua, sent through M.job.
---
--- @file shared/utils/messages/formatters/jobs/message_bst.lua
--- @author ejouanchicot
--- @version 3.0
--- @date Created: 2025-10-17 | Rebuilt: 2025-11-17
---============================================================================

local MessageBST = {}

local M = require('shared/utils/messages/api/messages')

-- Only used for the broth count separators
local MessageCore = require('shared/utils/messages/message_core')

-- Job tag with subjob ("BST/WHM"). Same logic as MessageCore.get_job_tag,
-- except the fallback is 'BST' instead of 'JOB'.
local function get_job_tag()
    local main_job = player and player.main_job or 'BST'
    local sub_job = player and player.sub_job or ''
    if sub_job and sub_job ~= '' and sub_job ~= 'NON' then
        return main_job .. '/' .. sub_job
    end
    return main_job
end

---============================================================================
--- ECOSYSTEM MESSAGES
---============================================================================

--- Display ecosystem change message
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

--- Display species change message
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
--- BROTH/JUG MESSAGES
---============================================================================

--- Display broth equip message
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

--- //gs c broth: broths in the inventory, as a data block.
--- @param broth_counts table broth name -> count
function MessageBST.show_broth_list(broth_counts)
    local fields = {}
    for name, count in pairs(broth_counts) do fields[#fields + 1] = {name, count, 'good'} end
    table.sort(fields, function(x, y) return x[1] < y[1] end)
    require('shared/utils/messages/info_block').show({
        tag = 'BST', title = 'Broth inventory', fields = fields,
        lines = #fields == 0 and {{'No broth in inventory.', 'dim'}} or nil,
    })
end

---============================================================================
--- PET MANAGEMENT MESSAGES
---============================================================================

--- Display pet engage message
--- @param pet_name string|nil Pet name (defaults to "Pet")
--- @return void
function MessageBST.show_pet_engage(pet_name)
    M.job('BST', 'pet_engage', {
        job = get_job_tag(),
        pet = pet_name or "Pet"
    })
end

--- Display pet disengage message
--- @param pet_name string|nil Pet name (defaults to "Pet")
--- @return void
function MessageBST.show_pet_disengage(pet_name)
    M.job('BST', 'pet_disengage', {
        job = get_job_tag(),
        pet = pet_name or "Pet"
    })
end

---============================================================================
--- READY MOVE MESSAGES (Enhanced)
---============================================================================

--- //gs c rdylist: the pet's ready moves, numbered for //gs c rdymove.
--- @param pet_name string
--- @param moves table Array of {name = ...}
function MessageBST.show_ready_moves_list(pet_name, moves)
    local fields = {}
    for i, move in ipairs(moves) do fields[#fields + 1] = {'#' .. i, move.name} end
    require('shared/utils/messages/info_block').show({
        tag = 'BST', title = 'Ready moves: ' .. tostring(pet_name), fields = fields,
        lines = {{('Use: //gs c rdymove <1-%d>'):format(#moves), 'dim'}},
    })
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
--- ERROR MESSAGES
---============================================================================

--- Display no pet active error
--- @return void
function MessageBST.show_error_no_pet()
    M.job('BST', 'no_pet', {
        job = get_job_tag()
    })
end

--- Display no ready moves available error
--- @return void
function MessageBST.show_error_no_ready_moves()
    M.job('BST', 'no_ready_moves', {
        job = get_job_tag()
    })
end

--- Display invalid index error
--- @param index string Invalid index value
--- @return void
function MessageBST.show_error_invalid_index(index)
    M.job('BST', 'invalid_index', {
        job = get_job_tag(),
        index = tostring(index)
    })
end

--- Display index out of range error
--- @param index number Given index
--- @param max number Maximum index
--- @return void
function MessageBST.show_error_index_out_of_range(index, max)
    M.job('BST', 'index_out_of_range', {
        job = get_job_tag(),
        index = index,
        max = max
    })
end

--- Display module not loaded error
--- @param module_name string Module name
--- @return void
function MessageBST.show_error_module_not_loaded(module_name)
    M.job('BST', 'module_not_loaded', {
        job = get_job_tag(),
        module = module_name
    })
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageBST
