---============================================================================
--- BST Messages Module - Beastmaster Job Message Formatting
---============================================================================
--- Job ability, ecosystem, broth/jug, pet and Ready move lines for BST.
--- Templates: data/jobs/bst_messages.lua, sent through M.job.
---
--- @file shared/utils/messages/formatters/jobs/message_bst.lua
--- @author Tetsouo
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
--- JOB ABILITY MESSAGES
---============================================================================

--- @param pet_name string Pet called
function MessageBST.show_call_beast_used(pet_name)
    M.job('BST', 'call_beast_used', {
        job = get_job_tag(),
        pet = pet_name
    })
end

--- @param pet_name string Pet called
--- @param jug_name string Jug used
function MessageBST.show_bestial_loyalty_used(pet_name, jug_name)
    M.job('BST', 'bestial_loyalty_used', {
        job = get_job_tag(),
        pet = pet_name,
        jug = jug_name
    })
end

--- Show the BST.familiar_activated message
function MessageBST.show_familiar_activated()
    M.job('BST', 'familiar_activated', {
        job = get_job_tag()
    })
end

--- Show the BST.familiar_active message
function MessageBST.show_familiar_active()
    M.job('BST', 'familiar_active', {
        job = get_job_tag()
    })
end

--- Show the BST.spur_used message
function MessageBST.show_spur_used()
    M.job('BST', 'spur_used', {
        job = get_job_tag()
    })
end

--- Show the BST.run_wild_used message
function MessageBST.show_run_wild_used()
    M.job('BST', 'run_wild_used', {
        job = get_job_tag()
    })
end

--- @param target_name string Tame target
function MessageBST.show_tame_used(target_name)
    M.job('BST', 'tame_used', {
        job = get_job_tag(),
        target = target_name
    })
end

--- @param hp_amount number HP restored
function MessageBST.show_reward_used(hp_amount)
    M.job('BST', 'reward_used', {
        job = get_job_tag(),
        hp = hp_amount
    })
end

--- Show the BST.reward_no_food message
function MessageBST.show_reward_no_food()
    M.job('BST', 'reward_no_food', {
        job = get_job_tag()
    })
end

--- Show the BST.feral_howl_used message
function MessageBST.show_feral_howl_used()
    M.job('BST', 'feral_howl_used', {
        job = get_job_tag()
    })
end

--- Show the BST.killer_instinct_activated message
function MessageBST.show_killer_instinct_activated()
    M.job('BST', 'killer_instinct_activated', {
        job = get_job_tag()
    })
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

--- @param pet_name string Pet name
--- @param broth_name string Jug/broth name
function MessageBST.show_jug_equipped(pet_name, broth_name)
    M.job('BST', 'jug_equipped', {
        job = get_job_tag(),
        pet = pet_name,
        broth = broth_name
    })
end

--- Display broth inventory header with separator
--- @return void
function MessageBST.show_broth_count_header()
    MessageCore.show_separator(50)

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
    M.job('BST', 'broth_count_footer', {
        job = get_job_tag()
    })
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
--- PET MANAGEMENT MESSAGES
---============================================================================

--- @param pet_name string Pet name
--- @param species string Species
--- @param ecosystem string Ecosystem
function MessageBST.show_pet_summoned(pet_name, species, ecosystem)
    M.job('BST', 'pet_summoned', {
        job = get_job_tag(),
        pet = pet_name,
        species = species,
        ecosystem = ecosystem
    })
end

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

--- @param pet_name string Pet name
function MessageBST.show_pet_dismissed(pet_name)
    M.job('BST', 'pet_dismissed', {
        job = get_job_tag(),
        pet = pet_name
    })
end

--- Show the BST.auto_engage_enabled message
function MessageBST.show_auto_engage_enabled()
    M.job('BST', 'auto_engage_enabled', {
        job = get_job_tag()
    })
end

--- Show the BST.auto_engage_disabled message
function MessageBST.show_auto_engage_disabled()
    M.job('BST', 'auto_engage_disabled', {
        job = get_job_tag()
    })
end

--- Display auto-engage status message
--- Note: status_color is passed as a parameter, so the engine prints the
--- text "{green}"/"{orange}" instead of a color. No caller today.
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

--- Note: tp_color is printed as text ("{green}"...), not as a color. No caller today.
--- @param pet_name string Pet name
--- @param tp number Pet TP
function MessageBST.show_pet_tp_status(pet_name, tp)
    local tp_color = "{white}"
    if tp >= 3000 then
        tp_color = "{green}"
    elseif tp >= 2000 then
        tp_color = "{cyan}"
    end

    M.job('BST', 'pet_tp_status', {
        job = get_job_tag(),
        pet = pet_name,
        tp = tp,
        tp_color = tp_color
    })
end

--- Note: hp_color is printed as text ("{green}"...), not as a color. No caller today.
--- @param pet_name string Pet name
--- @param hp_percent number Pet HP %
function MessageBST.show_pet_hp_status(pet_name, hp_percent)
    local hp_color = "{green}"
    if hp_percent < 25 then
        hp_color = "{red}"
    elseif hp_percent < 50 then
        hp_color = "{orange}"
    end

    M.job('BST', 'pet_hp_status', {
        job = get_job_tag(),
        pet = pet_name,
        hp = hp_percent,
        hp_color = hp_color
    })
end

---============================================================================
--- READY MOVE MESSAGES (Enhanced)
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

--- @param move_name string Ready move
--- @param potency string|nil Potency label (defaults to "Standard")
function MessageBST.show_ready_move_physical(move_name, potency)
    M.job('BST', 'ready_move_physical', {
        job = get_job_tag(),
        move = move_name,
        potency = potency or "Standard"
    })
end

--- @param move_name string Ready move
--- @param element string|nil Element (defaults to "Non-elemental")
function MessageBST.show_ready_move_magical(move_name, element)
    M.job('BST', 'ready_move_magical', {
        job = get_job_tag(),
        move = move_name,
        element = element or "Non-elemental"
    })
end

--- @param move_name string Ready move
--- @param element string|nil Element (defaults to "Non-elemental")
function MessageBST.show_ready_move_breath(move_name, element)
    M.job('BST', 'ready_move_breath', {
        job = get_job_tag(),
        move = move_name,
        element = element or "Non-elemental"
    })
end

--- Note: tp_color is printed as text ("{green}"...), not as a color. No caller today.
--- @param pet_name string Pet name
--- @param tp number Pet TP
function MessageBST.show_ready_move_tp_check(pet_name, tp)
    local tp_color = "{white}"
    if tp >= 3000 then
        tp_color = "{green}"
    elseif tp >= 2000 then
        tp_color = "{cyan}"
    end

    M.job('BST', 'ready_move_tp_check', {
        job = get_job_tag(),
        pet = pet_name,
        tp = tp,
        tp_color = tp_color
    })
end

--- Display ready moves list header
--- @param pet_name string Pet name
--- @return void
function MessageBST.show_ready_moves_header(pet_name)
    M.job('BST', 'ready_moves_header', {
        job = get_job_tag(),
        pet = pet_name
    })
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
    M.job('BST', 'ready_moves_usage', {
        job = get_job_tag(),
        max = max_index
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

--- @param move_name string Ready move
--- @param recast any Recast shown as is
function MessageBST.show_ready_move_recast(move_name, recast)
    M.job('BST', 'ready_move_recast', {
        job = get_job_tag(),
        move = move_name,
        recast = recast
    })
end

---============================================================================
--- PET STATUS MESSAGES
---============================================================================

--- @param target_name string Charmed target
function MessageBST.show_pet_charmed(target_name)
    M.job('BST', 'pet_charmed', {
        job = get_job_tag(),
        target = target_name
    })
end

--- @param target_name string Charm target
function MessageBST.show_pet_charm_failed(target_name)
    M.job('BST', 'pet_charm_failed', {
        job = get_job_tag(),
        target = target_name
    })
end

--- @param pet_name string Pet name
function MessageBST.show_pet_died(pet_name)
    M.job('BST', 'pet_died', {
        job = get_job_tag(),
        pet = pet_name
    })
end

--- @param pet_name string Pet name
function MessageBST.show_pet_despawned(pet_name)
    M.job('BST', 'pet_despawned', {
        job = get_job_tag(),
        pet = pet_name
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

--- Show the BST.no_target message
function MessageBST.show_error_no_target()
    M.job('BST', 'no_target', {
        job = get_job_tag()
    })
end

--- Show the BST.pet_too_far message
function MessageBST.show_error_pet_too_far()
    M.job('BST', 'pet_too_far', {
        job = get_job_tag()
    })
end

--- Show the BST.no_jug_equipped message
function MessageBST.show_error_no_jug_equipped()
    M.job('BST', 'no_jug_equipped', {
        job = get_job_tag()
    })
end

--- @param ability_name string Ability refused
function MessageBST.show_error_insufficient_hp(ability_name)
    M.job('BST', 'insufficient_hp', {
        job = get_job_tag(),
        ability = ability_name
    })
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageBST
