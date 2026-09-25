---============================================================================
--- RDM Message Data - Red Mage Messages
---============================================================================
--- Pure data file for RDM job messages
--- Loaded by the message engine when a formatter sends a key from it (api/messages.lua)
---
--- @file shared/utils/messages/data/jobs/rdm_messages.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- DEBUFF WARNING MESSAGES
    ---========================================================================

    doom_warning = {
        template = "{gray}[{lightblue}{job}{gray}] {red}DOOM! Use Cursna or Holy Water!",
        color = 1
    },

    doom_removed = {
        template = "{gray}[{lightblue}{job}{gray}] {green}Doom removed",
        color = 1
    },

    ---========================================================================
    --- SPELL CASTING MESSAGES
    ---========================================================================

    spell_casting = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Casting: {cyan}{spell}",
        color = 1
    },

    element_list = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Valid elements: fire, ice, wind, earth, thunder, water",
        color = 1
    },

    ---========================================================================
    --- STATE DISPLAY MESSAGES
    ---========================================================================

    enspell_current = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Enspell: {cyan}{value}",
        color = 1
    },

    storm_current = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}Storm: {cyan}{value}",
        color = 1
    },

    ---========================================================================
    --- ERROR MESSAGES
    ---========================================================================

    no_enspell_selected = {
        template = "{gray}[{lightblue}{job}{gray}] {orange}No Enspell selected (cycle with Alt+8)",
        color = 1
    },

    gain_spell_not_configured = {
        template = "{gray}[{lightblue}{job}{gray}] {orange}Gain spell state not configured",
        color = 1
    },

    bar_element_not_configured = {
        template = "{gray}[{lightblue}{job}{gray}] {orange}Bar Element state not configured",
        color = 1
    },

    bar_ailment_not_configured = {
        template = "{gray}[{lightblue}{job}{gray}] {orange}Bar Ailment state not configured",
        color = 1
    },

    spike_not_configured = {
        template = "{gray}[{lightblue}{job}{gray}] {orange}Spike state not configured",
        color = 1
    },

    storm_requires_sch = {
        template = "{gray}[{lightblue}{job}{gray}] {orange}Storm spells require SCH subjob",
        color = 1
    },

    ---========================================================================
    --- SPELL OPTIMIZATION MESSAGES
    ---========================================================================

    phalanx_detected = {
        template = "{lightblue}[{job} Phalanx] {gray}Detected: {cyan}{spell} {gray}>> Target: {yellow}{target}",
        color = 122
    },

    phalanx_downgrade = {
        template = "{lightblue}[{job} Phalanx] {yellow}Downgrading {cyan}Phalanx II {gray}>> {green}Phalanx {gray}(self-cast)",
        color = 158
    },

    phalanx_upgrade = {
        template = "{lightblue}[{job} Phalanx] {yellow}Upgrading {cyan}Phalanx {gray}>> {green}Phalanx II {gray}(party-cast)",
        color = 158
    }
}
