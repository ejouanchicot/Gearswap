---============================================================================
--- STEALTH Message Data - //gs c stealth (Sneak / Invisible)
---============================================================================
--- Pure data file, used through formatters/system/message_stealth.lua.
---
--- @file shared/utils/messages/data/systems/stealth_messages.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-26
---============================================================================

return {
    skipped_unknown = { template = "{gray}[{lightblue}STEALTH{gray}] {white}{buff}{gray} : {green}up{gray} (time unknown), not cast again", color = 1 },
    skipped = { template = "{gray}[{lightblue}STEALTH{gray}] {white}{buff}{gray} : {green}{left}{gray} left, not cast again", color = 1 },
    covered = { template = "{gray}[{lightblue}STEALTH{gray}] {white}{buff}{gray} : Accession from {white}{name}", color = 1 },
    no_way = { template = "{gray}[{lightblue}STEALTH{gray}] {white}{buff}{gray} : {red}no way of your own{gray} (spell, jig, ninjutsu or item)", color = 1 },
    asked = { template = "{gray}[{lightblue}STEALTH{gray}] {white}{buff}{gray} : no way of your own, asked the others", color = 1 },
    wearing_off = { template = "{gray}[{lightblue}STEALTH{gray}] {yellow}{buff}{gray} wears off in {yellow}{left}", color = 1 },
    wearing_off_other = { template = "{gray}[{lightblue}STEALTH{gray}] {white}{name}{gray} : {yellow}{buff}{gray} wears off in {yellow}{left}", color = 1 },
    setting = { template = "{gray}[{lightblue}STEALTH{gray}] {white}{key}{gray} : {green}{value}", color = 1 },
    setting_unsaved = { template = "{gray}[{lightblue}STEALTH{gray}] {white}{key}{gray} : {green}{value}{gray} - {red}not saved{gray} (config/STEALTH_CONFIG.lua missing)", color = 1 },
    usage = { template = "{gray}[{lightblue}STEALTH{gray}] {white}//gs c stealth{gray} sneak | invi | both [self] | status | check | refresh <s> | alert <s> | overwrite on|off | alerts on|off | delay <s>", color = 1 },
}
