---============================================================================
--- RDM Message Data - Red Mage Messages
---============================================================================
--- Pure data file for RDM job messages
--- Used by new message system (api/messages.lua)
---
--- @file data/jobs/rdm_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- DEBUFF WARNING MESSAGES
    ---========================================================================

    doom_warning = {
        template = "{lightblue}[{job}] {red}DOOM! Use Cursna or Holy Water!",
        color = 1
    },

    doom_removed = {
        template = "{lightblue}[{job}] {green}Doom removed",
        color = 1
    },

    ---========================================================================
    --- SPELL CASTING MESSAGES
    ---========================================================================

    spell_casting = {
        template = "{lightblue}[{job}] {gray}Casting: {cyan}{spell}",
        color = 1
    },

    element_list = {
        template = "{lightblue}[{job}] {gray}Valid elements: fire, ice, wind, earth, thunder, water",
        color = 1
    },

    ---========================================================================
    --- STATE DISPLAY MESSAGES
    ---========================================================================

    enspell_current = {
        template = "{lightblue}[{job}] {gray}Enspell: {cyan}{value}",
        color = 1
    },

    storm_current = {
        template = "{lightblue}[{job}] {gray}Storm: {cyan}{value}",
        color = 1
    },

    ---========================================================================
    --- ERROR MESSAGES
    ---========================================================================

    no_enspell_selected = {
        template = "{lightblue}[{job}] {orange}No Enspell selected (cycle with Alt+8)",
        color = 1
    },

    gain_spell_not_configured = {
        template = "{lightblue}[{job}] {orange}Gain spell state not configured",
        color = 1
    },

    bar_element_not_configured = {
        template = "{lightblue}[{job}] {orange}Bar Element state not configured",
        color = 1
    },

    bar_ailment_not_configured = {
        template = "{lightblue}[{job}] {orange}Bar Ailment state not configured",
        color = 1
    },

    spike_not_configured = {
        template = "{lightblue}[{job}] {orange}Spike state not configured",
        color = 1
    },

    storm_requires_sch = {
        template = "{lightblue}[{job}] {orange}Storm spells require SCH subjob",
        color = 1
    }
}
