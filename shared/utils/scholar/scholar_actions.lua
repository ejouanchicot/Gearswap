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

--- Build the chain for one of the party utility spells
--- AOE On  : Accession, cast on <me> so the burst is centred on the player.
--- AOE Off : no Accession, cast on <stal> to pick a single ally.
--- A spell the subjob only reaches through Addendum: White gets that
--- stratagem first: without it the cast is refused outright, while Accession
--- only decides whether the cast reaches the party. So when one charge is
--- left, Addendum takes it and Accession is the one dropped.
--- Light Arts is prepended only when a stratagem will actually run - it costs
--- no charge, but switching Arts buys nothing for a lone cast.
--- The spell itself is always the last step, charge or no charge.
--- @param spell_name string Spell to cast
--- @param aoe_state table|nil Mote On/Off state (missing counts as On)
--- @param needs_addendum boolean|nil True when /SCH needs Addendum: White for it
--- @return string Command ready for send_command
function ScholarActions.build_accession_chain(spell_name, aoe_state, needs_addendum)
    local target = ScholarActions.is_on(aoe_state) and '<me>' or '<stal>'
    local budget = StratagemCharges.available()

    -- Addendum: White replaces Light Arts in buffactive, so it also proves the
    -- Arts are up. Checking it first is what keeps Light Arts from being recast
    -- over an addendum that is already running.
    local addendum_up  = (buffactive and buffactive['Addendum: White']) and true or false
    local arts_up      = addendum_up or ((buffactive and buffactive['Light Arts']) and true or false)
    local accession_up = (buffactive and buffactive['Accession']) and true or false

    local stratagems = {}

    if needs_addendum and not addendum_up then
        if budget > 0 then
            table.insert(stratagems, 'input /ja "Addendum: White" <me>')
            budget = budget - 1
        else
            ScholarActions.warn_no_charge('Addendum: White')
        end
    end

    -- An Accession already running covers this cast; spending a second charge
    -- would only re-apply a buff that is up.
    if target == '<me>' and not accession_up then
        if budget > 0 then
            table.insert(stratagems, 'input /ja "Accession" <me>')
            budget = budget - 1
        else
            ScholarActions.warn_no_charge('Accession')
        end
    end

    local steps = {}
    if #stratagems > 0 and not arts_up then
        table.insert(steps, 'input /ja "Light Arts" <me>')
    end
    for _, stratagem in ipairs(stratagems) do
        table.insert(steps, stratagem)
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
--- `addendum` marks the spells a /SCH only reaches under Addendum: White.
--- Sneak and Invisible are Scholar's own spells and need nothing; Erase comes
--- from the white addendum, and without it the cast is simply refused.
local AOE_SPELLS = {
    sneak     = { spell = 'Sneak',     toggle = true },
    invi      = { spell = 'Invisible', toggle = true },
    invisible = { spell = 'Invisible', toggle = true },
    erase     = { spell = 'Erase',     toggle = false, addendum = true },
}

--- Send the Scholar chain for an `aoe <name>` subcommand
--- @param subcommand string|nil Word typed after `aoe`
--- @param aoe_state table|nil Mote On/Off state for the toggled spells
--- @return boolean True when a chain was sent, false when the word is not ours
function ScholarActions.try_aoe_subcommand(subcommand, aoe_state)
    local entry = AOE_SPELLS[(subcommand or ''):lower()]
    if not entry then return false end

    send_command(ScholarActions.build_accession_chain(
        entry.spell, entry.toggle and aoe_state or nil, entry.addendum))
    return true
end

return ScholarActions
