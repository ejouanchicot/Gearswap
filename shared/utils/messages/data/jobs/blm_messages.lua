---============================================================================
--- BLM Message Data - Black Mage Messages
---============================================================================
--- Pure data file for BLM job messages
--- Loaded by the message engine when a formatter sends a key from it (api/messages.lua)
---
--- @file shared/utils/messages/data/jobs/blm_messages.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- ELEMENT CYCLE MESSAGES
    ---========================================================================

    element_cycle = {
        template = "{gray}[{lightblue}{job}{gray}]{gray} Current {state_type}: {element_color}{element}",
        color = 1
    },

    ---========================================================================
    --- SPELL CYCLE MESSAGES
    ---========================================================================

    aja_cycle = {
        template = "{gray}[{lightblue}{job}{gray}]{gray} Current Aja: {element_color}{aja}",
        color = 1
    },

    storm_cycle = {
        template = "{gray}[{lightblue}{job}{gray}]{gray} Current Storm: {element_color}{storm}",
        color = 1
    },

    tier_cycle = {
        template = "{gray}[{lightblue}{job}{gray}]{gray} Current Tier: {yellow}{tier}",
        color = 1
    },

    ---========================================================================
    --- BUFF MESSAGES
    ---========================================================================

    buff_activated = {
        template = "{gray}[{lightblue}{job}{gray}]{gray} Self-buffing: {green}Stoneskin > Blink > Aquaveil > Ice Spikes",
        color = 1
    },

    buff_cast = {
        template = "{gray}[{lightblue}{job}{gray}]{gray} Casting {cyan}{buff}",
        color = 1
    },

    ---========================================================================
    --- CASTING MODE MESSAGES
    ---========================================================================

    magic_burst_on = {
        template = "{gray}[{lightblue}{job}{gray}] {green}Magic Burst Mode{gray}: {yellow}ON",
        color = 1
    },

    magic_burst_off = {
        template = "{gray}[{lightblue}{job}{gray}] {orange}Magic Burst Mode{gray}: {gray}OFF",
        color = 1
    },

    free_nuke_on = {
        template = "{gray}[{lightblue}{job}{gray}] {green}Free Nuke Mode{gray}: {yellow}ON",
        color = 1
    },

    ---========================================================================
    --- SPELL REFINEMENT MESSAGES
    ---========================================================================

    spell_refinement = {
        template = "{gray}[{lightblue}{job}{gray}] {cyan}{original}{gray} on cooldown {gray}({orange}{recast}s{gray}) > Downgrading to {cyan}{downgrade}",
        color = 1
    },

    spell_refinement_failed = {
        template = "{gray}[{lightblue}{job}{gray}] {cyan}{spell}{gray} on cooldown {gray}({orange}{recast}s{gray}) - {red}No downgrade available",
        color = 1
    },

    ---========================================================================
    --- MP CONSERVATION MESSAGES
    ---========================================================================

    mp_conservation = {
        template = "{gray}[{lightblue}{job}{gray}]{gray} MP {mp_color}{status}{gray} > Using {cyan}{gear_type}{gray} gear",
        color = 1
    },

    ---========================================================================
    --- DARK ARTS MESSAGES (SCH SUBJOB)
    ---========================================================================

    dark_arts_activated = {
        template = "{gray}[{lightblue}{job}{gray}] {yellow}Dark Arts{gray} activated for {cyan}{spell}",
        color = 1
    },

    arts_already_active = {
        template = "{gray}[{lightblue}{job}{gray}]{gray} {green}{arts}{gray} already active",
        color = 1
    },

    stratagem_no_charges = {
        template = "{gray}[{lightblue}{job}{gray}]{gray} {yellow}{stratagem}{gray} - {orange}No charges available{gray} {gray}(next charge: {orange}{recast}m{gray})",
        color = 1
    },

    ---========================================================================
    --- ERROR MESSAGES
    ---========================================================================

    buffself_error = {
        template = "{gray}[{lightblue}{job}{gray}] {red}Error: BuffSelf function not loaded",
        color = 1
    },

    spell_replacement_error = {
        template = "{gray}[{lightblue}{job}{gray}] {red}Error: Invalid parameters for spell replacement",
        color = 1
    },

    spell_refinement_error = {
        template = "{gray}[{lightblue}{job}{gray}] {red}Error: Invalid parameters for spell refinement",
        color = 1
    },

    spell_recasts_error = {
        template = "{gray}[{lightblue}{job}{gray}] {red}Error: Failed to get spell recasts",
        color = 1
    },

    insufficient_mp_error = {
        template = "{gray}[{lightblue}{job}{gray}]{gray} Not enough Mana {gray}({red}{mp} MP{gray})",
        color = 1
    },

    breakga_blocked = {
        template = "{gray}[{lightblue}{job}{gray}]{gray} {gray}({orange}Breakga replacement blocked - lag protection{gray})",
        color = 1
    },

    ---========================================================================
    --- BUFF MANAGEMENT MESSAGES
    ---========================================================================

    buff_casting = {
        template = "{gray}[{lightblue}{job}{gray}]{gray} Casting {cyan}{spell}",
        color = 1
    },

    buff_status = {
        template = "{gray}[{lightblue}{job}{gray}]{gray} Buff Status: {status}",
        color = 1
    }
}
