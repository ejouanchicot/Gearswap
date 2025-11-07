---============================================================================
--- BST Message Data - Beastmaster Messages
---============================================================================
--- Pure data file for BST job messages
--- Used by new message system (api/messages.lua)
---
--- @file data/jobs/bst_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- ECOSYSTEM MESSAGES
    ---========================================================================

    ecosystem_change = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Ecosystem{gray} -> {green}{ecosystem}{gray} ({green}{count} {species_text}{gray})",
        color = 1
    },

    species_change = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Species{gray} -> {yellow}{species}{gray} ({green}{count} {jug_text}{gray})",
        color = 1
    },

    ---========================================================================
    --- BROTH MESSAGES
    ---========================================================================

    broth_equip = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Equipping {yellow}{broth}{gray} for {yellow}{pet}{gray}",
        color = 1
    },

    broth_count_header = {
        template = "{gray}[{lightblue}{job}{gray}] {lightblue}=== Broth Inventory ==={gray}",
        color = 1
    },

    broth_count_line = {
        template = "{gray}[{lightblue}{job}{gray}]   {gray}*{gray} {yellow}{broth}{gray}: {green}{count}{gray}",
        color = 1
    },

    no_broths = {
        template = "{gray}[{lightblue}{job}{gray}] {orange}No broths in inventory{gray}",
        color = 1
    },

    ---========================================================================
    --- PET MANAGEMENT MESSAGES
    ---========================================================================

    pet_engage = {
        template = "{gray}[{lightblue}{job}{gray}] {green}Pet engaging target{gray}",
        color = 1
    },

    pet_disengage = {
        template = "{gray}[{lightblue}{job}{gray}] {green}Pet disengaging{gray}",
        color = 1
    },

    auto_engage_status = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Auto Pet Engage{gray} -> {status_color}{status}{gray}",
        color = 1
    },

    ---========================================================================
    --- READY MOVE MESSAGES
    ---========================================================================

    ready_move_precast = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Ready Move{gray} -> {yellow}{move}{gray} ({green}{category}{gray})",
        color = 1
    },

    ready_move_item = {
        template = "{gray}[{lightblue}{job}{gray}]   {green}#{index}{gray} - {green}{move}{gray}",
        color = 159
    },

    ready_move_use = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Using Ready Move{gray} {yellow}#{index}{gray}: {yellow}{move}{gray}",
        color = 159
    },

    ready_move_auto_engage = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Auto-engage Ready Move{gray} {green}#{index}{gray}: {green}{move}{gray}",
        color = 159
    },

    ready_move_auto_sequence = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Auto-sequence Ready Move{gray} {green}#{index}{gray}: {green}{move}{gray}",
        color = 159
    }
}
