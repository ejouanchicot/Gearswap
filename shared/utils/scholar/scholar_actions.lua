---============================================================================
--- Scholar Actions - /SCH utility chains shared across jobs
---============================================================================
--- Light Arts / Addendum: White toggling and the party Sneak/Invisible chain
--- (Light Arts + Accession + spell), for any job that subs Scholar.
---
--- @file shared/utils/scholar/scholar_actions.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-17
---============================================================================

local ScholarActions = {}

local StratagemCharges = require('shared/utils/scholar/stratagem_charges')

--- Spacing between chained actions, long enough for each JA to land.
local STEP_SPACING = 2

--- MessageFormatter is loaded on first use: it is heavy and most sessions
--- never send a stratagem command.
local MessageFormatter = nil

local function get_formatter()
    if not MessageFormatter then
        MessageFormatter = require('shared/utils/messages/message_formatter')
    end
    return MessageFormatter
end

--- Chain actions with the standard spacing
--- @param steps table List of `input /ja ...` / `input /ma ...` strings
--- @return string Command ready for send_command
function ScholarActions.chain(steps)
    return table.concat(steps, '; wait ' .. STEP_SPACING .. '; ')
end

--- Report that a stratagem cannot be used right now
--- @param stratagem string Stratagem that was skipped
function ScholarActions.warn_no_charge(stratagem)
    get_formatter().show_stratagem_no_charges(stratagem, StratagemCharges.next_charge_minutes())
end

--- Whether a toggle state is set to 'On' (missing state counts as On)
--- @param mode table|nil Mote state
--- @return boolean
function ScholarActions.is_on(mode)
    return not mode or mode.value ~= 'Off'
end

--- Light Arts, then Addendum: White on the next press
--- Addendum: White replaces the Light Arts buff in buffactive, so it has to be
--- checked first or Light Arts would be recast over it.
function ScholarActions.light_arts()
    if buffactive and buffactive['Addendum: White'] then
        get_formatter().show_arts_already_active('Light Arts + Addendum: White')
    elseif buffactive and buffactive['Light Arts'] then
        send_command('input /ja "Addendum: White" <me>')
    else
        send_command('input /ja "Light Arts" <me>')
    end
end

--- Dark Arts, then Addendum: Black on the next press
function ScholarActions.dark_arts()
    if buffactive and buffactive['Addendum: Black'] then
        get_formatter().show_arts_already_active('Dark Arts + Addendum: Black')
    elseif buffactive and buffactive['Dark Arts'] then
        send_command('input /ja "Addendum: Black" <me>')
    else
        send_command('input /ja "Dark Arts" <me>')
    end
end

--- Build the Sneak/Invisible chain for an AOE toggle state
--- AOE On  : Light Arts (if needed) + Accession, cast on <me> so the burst
---           is centred on the player.
--- AOE Off : no stratagem at all, cast on <stal> to pick a single ally.
--- With AOE On but no charge left, Accession cannot fire and the Arts switch
--- is dropped with it, since changing Arts buys nothing for a lone cast.
--- @param spell_name string Spell to cast
--- @param aoe_state table|nil Mote On/Off state (missing counts as On)
--- @return string Command ready for send_command
function ScholarActions.build_accession_chain(spell_name, aoe_state)
    local steps = {}
    local target = '<stal>'

    if ScholarActions.is_on(aoe_state) then
        target = '<me>'

        if StratagemCharges.has_charge() then
            local light_active = buffactive and (buffactive['Light Arts'] or buffactive['Addendum: White'])
            if not light_active then
                table.insert(steps, 'input /ja "Light Arts" <me>')
            end
            table.insert(steps, 'input /ja "Accession" <me>')
        else
            ScholarActions.warn_no_charge('Accession')
        end
    end

    table.insert(steps, 'input /ma "' .. spell_name .. '" ' .. target)

    return ScholarActions.chain(steps)
end

--- Spells reachable through the `aoe <name>` subcommand.
--- They are not commands of their own: the alt-command configs already claim
--- 'sneak', 'invi' and 'erase', and CommonCommands answers before the job
--- block, so those names cast on the dual-box partner instead of here.
--- `toggle` says whether the job's SneakInviAOE state applies; Erase has none
--- of its own and takes Accession whenever a charge is left.
local AOE_SPELLS = {
    sneak     = { spell = 'Sneak',     toggle = true },
    invi      = { spell = 'Invisible', toggle = true },
    invisible = { spell = 'Invisible', toggle = true },
    erase     = { spell = 'Erase',     toggle = false },
}

--- Send the Scholar chain for an `aoe <name>` subcommand
--- @param subcommand string|nil Word typed after `aoe`
--- @param aoe_state table|nil Mote On/Off state for the toggled spells
--- @return boolean True when a chain was sent, false when the word is not ours
function ScholarActions.try_aoe_subcommand(subcommand, aoe_state)
    local entry = AOE_SPELLS[(subcommand or ''):lower()]
    if not entry then return false end

    send_command(ScholarActions.build_accession_chain(
        entry.spell, entry.toggle and aoe_state or nil))
    return true
end

return ScholarActions
