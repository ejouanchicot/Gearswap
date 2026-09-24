---============================================================================
--- ALTGROUP Message Data - //gs c alts and //gs c main (box group)
---============================================================================
--- Pure data file, used through formatters/system/message_altgroup.lua.
--- Names white, ON green / OFF red, problems red.
---
--- @file data/systems/altgroup_messages.lua
--- @author Tetsouo
--- @date Created: 2026-09-24
---============================================================================

return {
    auto_on = { template = "{gray}[{lightblue}ALTS{gray}] {white}{names}{gray} : {green}ON", color = 1 },
    auto_off = { template = "{gray}[{lightblue}ALTS{gray}] {white}{names}{gray} : {red}OFF", color = 1 },
    follow_on = { template = "{gray}[{lightblue}ALTS{gray}] {white}{names}{gray} follow {white}{leader}", color = 1 },
    follow_off = { template = "{gray}[{lightblue}ALTS{gray}] {white}{names}{gray} : follow {red}OFF", color = 1 },
    sent = { template = "{gray}[{lightblue}ALTS{gray}] {white}{names}{gray} > {white}{command}", color = 1 },
    mirror = { template = "{gray}[{lightblue}ALTS{gray}] Mirror sent", color = 1 },
    role_main = { template = "{gray}[{lightblue}DUALBOX{gray}] {white}{name}{gray} : {green}MAIN{gray} - alts : {white}{alts}", color = 1 },
    role_alt = { template = "{gray}[{lightblue}DUALBOX{gray}] {white}{name}{gray} : {yellow}ALT{gray} of {white}{main}", color = 1 },
    no_alts = { template = "{gray}[{lightblue}ALTS{gray}] {red}No alt set in config/DUALBOX_CONFIG.lua", color = 1 },
    usage = { template = "{gray}[{lightblue}ALTS{gray}] {white}//gs c alts on | off | toggle | follow [name|off] | do <command> | mirror", color = 1 },
}
