---============================================================================
--- BST Message Data - Beastmaster Messages
---============================================================================
--- Pure data file for BST job messages
--- Used by new message system (api/messages.lua)
---
--- @file data/jobs/bst_messages.lua
--- @author Tetsouo
--- @version 2.0 - Complete rebuild to BRD standard
--- @date Created: 2025-11-06 | Updated: 2025-11-17
---============================================================================

return {
    ---========================================================================
    --- JOB ABILITY MESSAGES
    ---========================================================================

    call_beast_used = {
        template = "{gray}[{lightblue}{job}{gray}] {yellow}Call Beast{gray} >> Summoning {green}{pet}{gray}",
        color = 1
    },

    bestial_loyalty_used = {
        template = "{gray}[{lightblue}{job}{gray}] {yellow}Bestial Loyalty{gray} >> Summoning {green}{pet}{gray} {gray}({orange}Consumes {jug}{gray})",
        color = 1
    },

    familiar_activated = {
        template = "{gray}[{lightblue}{job}{gray}] {yellow}Familiar{green} activated! {gray}Pet power boost! {gray}({orange}Pet HP drains to 10%{gray})",
        color = 1
    },

    familiar_active = {
        template = "{gray}[{lightblue}{job}{gray}] {yellow}Familiar{green} active {gray}({green}Pet damage increased{gray})",
        color = 1
    },

    spur_used = {
        template = "{gray}[{lightblue}{job}{gray}] {yellow}Spur{gray} >> {green}Pet TP boost{gray}",
        color = 1
    },

    run_wild_used = {
        template = "{gray}[{lightblue}{job}{gray}] {yellow}Run Wild{gray} >> {green}Pet evasion & speed boost{gray}",
        color = 1
    },

    tame_used = {
        template = "{gray}[{lightblue}{job}{gray}] {yellow}Tame{gray} >> {green}Attempting to charm {target}{gray}",
        color = 1
    },

    reward_used = {
        template = "{gray}[{lightblue}{job}{gray}] {yellow}Reward{gray} >> {green}Healing pet{gray} {gray}({green}+{hp} HP{gray})",
        color = 1
    },

    reward_no_food = {
        template = "{gray}[{lightblue}{job}{gray}] {yellow}Reward{orange} warning{gray}: {orange}No pet food equipped{gray}",
        color = 1
    },

    feral_howl_used = {
        template = "{gray}[{lightblue}{job}{gray}] {yellow}Feral Howl{gray} >> {green}AoE Intimidation{gray}",
        color = 1
    },

    killer_instinct_activated = {
        template = "{gray}[{lightblue}{job}{gray}] {yellow}Killer Instinct{green} activated! {gray}Ready Move damage boost!",
        color = 1
    },

    ---========================================================================
    --- ECOSYSTEM MESSAGES
    ---========================================================================

    ecosystem_change = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Ecosystem >> {green}{ecosystem}{gray} {gray}({green}{count} {species_text}{gray})",
        color = 1
    },

    species_change = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Species >> {yellow}{species}{gray} {gray}({green}{count} {jug_text}{gray})",
        color = 1
    },

    ---========================================================================
    --- BROTH/JUG MESSAGES
    ---========================================================================

    broth_equip = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Equipping {yellow}{broth}{gray} for {green}{pet}{gray}",
        color = 1
    },

    jug_equipped = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Jug Pet >> {yellow}{pet}{gray} {gray}({yellow}{broth}{gray})",
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

    broth_count_footer = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Use {yellow}//gs c broth{gray} to refresh",
        color = 1
    },

    ---========================================================================
    --- PET MANAGEMENT MESSAGES
    ---========================================================================

    pet_summoned = {
        template = "{gray}[{lightblue}{job}{gray}] {green}{pet}{gray} summoned! {gray}({yellow}{species}{gray} | {green}{ecosystem}{gray})",
        color = 1
    },

    pet_engage = {
        template = "{gray}[{lightblue}{job}{gray}] {green}{pet}{gray} >> {green}Engaging target{gray}",
        color = 1
    },

    pet_disengage = {
        template = "{gray}[{lightblue}{job}{gray}] {green}{pet}{gray} >> {orange}Disengaging{gray}",
        color = 1
    },

    pet_dismissed = {
        template = "{gray}[{lightblue}{job}{gray}] {orange}{pet} dismissed{gray}",
        color = 1
    },

    auto_engage_enabled = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Auto Pet Engage >> {green}ON{gray}",
        color = 1
    },

    auto_engage_disabled = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Auto Pet Engage >> {orange}OFF{gray}",
        color = 1
    },

    auto_engage_status = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Auto Pet Engage >> {status_color}{status}{gray}",
        color = 1
    },

    pet_tp_status = {
        template = "{gray}[{lightblue}{job}{gray}] {green}{pet}{gray} TP: {tp_color}{tp}{gray}",
        color = 1
    },

    pet_hp_status = {
        template = "{gray}[{lightblue}{job}{gray}] {green}{pet}{gray} HP: {hp_color}{hp}%{gray}",
        color = 1
    },

    ---========================================================================
    --- READY MOVE MESSAGES (Enhanced)
    ---========================================================================

    ready_move_precast = {
        template = "{gray}[{lightblue}{job}{gray}] {yellow}Ready{gray} >> {yellow}{move}{gray} {gray}({green}{category}{gray})",
        color = 1
    },

    ready_move_physical = {
        template = "{gray}[{lightblue}{job}{gray}] {yellow}Ready{gray} >> {yellow}{move}{gray} {gray}({green}Physical{gray} | {cyan}{potency}{gray})",
        color = 1
    },

    ready_move_magical = {
        template = "{gray}[{lightblue}{job}{gray}] {yellow}Ready{gray} >> {yellow}{move}{gray} {gray}({cyan}Magical{gray} | {cyan}{element}{gray})",
        color = 1
    },

    ready_move_breath = {
        template = "{gray}[{lightblue}{job}{gray}] {yellow}Ready{gray} >> {yellow}{move}{gray} {gray}({cyan}Breath{gray} | {cyan}{element}{gray})",
        color = 1
    },

    ready_move_tp_check = {
        template = "{gray}[{lightblue}{job}{gray}] {green}{pet}{gray} TP: {tp_color}{tp}{gray} {gray}(Ready Move requires TP{gray})",
        color = 1
    },

    ready_moves_header = {
        template = "{gray}[{lightblue}{job}{gray}] {lightblue}=== Ready Moves: {green}{pet}{lightblue} ==={gray}",
        color = 1
    },

    ready_move_item = {
        template = "{gray}[{lightblue}{job}{gray}]   {green}#{index}{gray} - {yellow}{move}{gray}",
        color = 1
    },

    ready_moves_usage = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Usage: {yellow}//gs c rdymove [1-{max}]{gray}",
        color = 1
    },

    ready_move_use = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Using Ready Move {yellow}#{index}{gray}: {yellow}{move}{gray}",
        color = 1
    },

    ready_move_auto_engage = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Auto-engage {green}#{index}{gray}: {green}{move}{gray} {gray}(Fight >> Ready >> Stay engaged{gray})",
        color = 1
    },

    ready_move_auto_sequence = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Auto-sequence {green}#{index}{gray}: {green}{move}{gray} {gray}(Fight >> Ready >> Heel{gray})",
        color = 1
    },

    ready_move_recast = {
        template = "{gray}[{lightblue}{job}{gray}] {yellow}{move}{gray} on cooldown {gray}({orange}{recast}s{gray})",
        color = 1
    },

    ---========================================================================
    --- PET STATUS MESSAGES
    ---========================================================================

    pet_charmed = {
        template = "{gray}[{lightblue}{job}{gray}] {green}Successfully charmed{gray}: {yellow}{target}{gray}",
        color = 1
    },

    pet_charm_failed = {
        template = "{gray}[{lightblue}{job}{gray}] {red}Charm failed{gray} on {orange}{target}{gray}",
        color = 1
    },

    pet_died = {
        template = "{gray}[{lightblue}{job}{gray}] {red}{pet} defeated{gray}",
        color = 1
    },

    pet_despawned = {
        template = "{gray}[{lightblue}{job}{gray}] {orange}{pet} despawned{gray}",
        color = 1
    },

    ---========================================================================
    --- ERROR MESSAGES
    ---========================================================================

    no_pet = {
        template = "{gray}[{lightblue}{job}{gray}] {red}No pet active{gray}",
        color = 1
    },

    no_ready_moves = {
        template = "{gray}[{lightblue}{job}{gray}] {red}No Ready Moves available{gray}",
        color = 1
    },

    invalid_index = {
        template = "{gray}[{lightblue}{job}{gray}] {red}Invalid index{gray}: {orange}{index}{gray}",
        color = 1
    },

    index_out_of_range = {
        template = "{gray}[{lightblue}{job}{gray}] {red}Index {orange}{index}{red} out of range{gray} {gray}(max: {green}{max}{gray})",
        color = 1
    },

    module_not_loaded = {
        template = "{gray}[{lightblue}{job}{gray}] {red}Module not loaded{gray}: {orange}{module}{gray}",
        color = 1
    },

    no_target = {
        template = "{gray}[{lightblue}{job}{gray}] {red}No target selected{gray}",
        color = 1
    },

    pet_too_far = {
        template = "{gray}[{lightblue}{job}{gray}] {orange}Pet out of range{gray}",
        color = 1
    },

    no_jug_equipped = {
        template = "{gray}[{lightblue}{job}{gray}] {red}No jug pet equipped{gray}",
        color = 1
    },

    insufficient_hp = {
        template = "{gray}[{lightblue}{job}{gray}] {red}Insufficient HP{gray} for {yellow}{ability}{gray}",
        color = 1
    }
}
