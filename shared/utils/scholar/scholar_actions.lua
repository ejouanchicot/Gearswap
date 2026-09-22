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

--- How often the pending cast re-checks whether its stratagems have landed.
local POLL_INTERVAL = 0.5

--- How long to keep checking after the last stratagem should have fired.
--- Generous: the whole point is to survive a cast issued while the previous
--- action still holds the lock, which is exactly when a stratagem takes longest
--- to go out.
local POLL_GRACE = 6.0

--- Invalidates a pending cast when the command is issued again.
--- Kept on `windower`, which outlives the sandbox, so a reload cannot leave two
--- generations of pending casts believing they are both current.
windower._sch_cast_seq = windower._sch_cast_seq or 0

--- @param name string Buff name as it appears in buffactive
--- @return boolean
local function buff_up(name)
    return (buffactive and buffactive[name]) and true or false
end

--- Cast once every required buff is actually up, or give up and say so.
---
--- The stratagems are sent as a Windower chain, which is fire-and-forget: the
--- game refuses a job ability issued during an action lock, and nothing in the
--- chain notices. Waiting on the buff instead of on a fixed delay is what makes
--- the spell leave accessioned whatever the timing - and what lets us cancel
--- rather than cast a lone Sneak the player did not ask for.
---
--- @param spell_name string Spell to cast
--- @param target string Target token
--- @param required table Buff names that must be up first
--- @param deadline number os.clock() value past which we give up
--- @param my_seq number Generation this cast belongs to
--- @return void
local cast_when_ready
cast_when_ready = function(spell_name, target, required, deadline, my_seq)
    if my_seq ~= windower._sch_cast_seq or not player then
        return
    end

    for _, name in ipairs(required) do
        if not buff_up(name) then
            if os.clock() >= deadline then
                get_formatter().show_warning(
                    ('%s cancelled: %s never came up'):format(spell_name, name))
                return
            end
            coroutine.schedule(function()
                cast_when_ready(spell_name, target, required, deadline, my_seq)
            end, POLL_INTERVAL)
            return
        end
    end

    send_command('input /ma "' .. spell_name .. '" ' .. target)
end

--- Cast one of the party utility spells, stratagems first
--- AOE On  : Accession, cast on <me> so the burst is centred on the player.
--- AOE Off : no Accession, cast on <stal> to pick a single ally.
--- A spell the subjob only reaches through Addendum: White gets that
--- stratagem first: without it the cast is refused outright, while Accession
--- only decides whether the cast reaches the party. So when one charge is
--- left, Addendum takes it and Accession is the one dropped.
--- Light Arts is prepended only when a stratagem will actually run - it costs
--- no charge, but switching Arts buys nothing for a lone cast.
--- @param spell_name string Spell to cast
--- @param aoe_state table|nil Mote On/Off state (missing counts as On)
--- @param needs_addendum boolean|nil True when /SCH needs Addendum: White for it
--- @return void
function ScholarActions.cast_with_stratagems(spell_name, aoe_state, needs_addendum)
    local target = ScholarActions.is_on(aoe_state) and '<me>' or '<stal>'
    local budget = StratagemCharges.available()

    -- Addendum: White replaces Light Arts in buffactive, so it also proves the
    -- Arts are up. Checking it first is what keeps Light Arts from being recast
    -- over an addendum that is already running.
    local addendum_up = buff_up('Addendum: White')
    local arts_up     = addendum_up or buff_up('Light Arts')

    local stratagems = {}
    local required = {}

    if needs_addendum and not addendum_up then
        if budget > 0 then
            table.insert(stratagems, 'input /ja "Addendum: White" <me>')
            table.insert(required, 'Addendum: White')
            budget = budget - 1
        else
            ScholarActions.warn_no_charge('Addendum: White')
        end
    end

    -- An Accession already running covers this cast; spending a second charge
    -- would only re-apply a buff that is up.
    if target == '<me>' and not buff_up('Accession') then
        if budget > 0 then
            table.insert(stratagems, 'input /ja "Accession" <me>')
            table.insert(required, 'Accession')
            budget = budget - 1
        else
            ScholarActions.warn_no_charge('Accession')
        end
    end

    windower._sch_cast_seq = windower._sch_cast_seq + 1

    -- Nothing to wait for: no stratagem was queued, either because the buffs
    -- are already up or because no charge was left. Cast straight away.
    if #required == 0 then
        send_command('input /ma "' .. spell_name .. '" ' .. target)
        return
    end

    local steps = {}
    if not arts_up then
        table.insert(steps, 'input /ja "Light Arts" <me>')
    end
    for _, stratagem in ipairs(stratagems) do
        table.insert(steps, stratagem)
    end
    send_command(ScholarActions.chain(steps))

    -- The chain spaces its own steps, so the last one fires that much later.
    local chain_time = STEP_SPACING * (#steps - 1)
    cast_when_ready(spell_name, target, required,
        os.clock() + chain_time + POLL_GRACE, windower._sch_cast_seq)
end

--- Cast a spell the subjob only reaches under Addendum: Black
---
--- Dark Arts then Addendum: Black then the spell, skipping whichever is
--- already up. Each step waits on the buff it needs rather than on a fixed
--- delay: without the addendum the cast is simply refused by the game, so
--- firing it early achieves nothing at all.
---
--- Addendum shares recast 231 with the other stratagems, so "still off
--- cooldown" proves nothing about it - AbilityHelper knows this and falls back
--- to watching the buff.
---
--- @param spell_name string Spell to cast
--- @param target string Target token
--- @return void
function ScholarActions.cast_under_black_addendum(spell_name, target)
    local cast = 'input /ma "' .. spell_name .. '" ' .. target

    if buff_up('Addendum: Black') then
        send_command(cast)
        return
    end

    local AbilityHelper = require('shared/utils/precast/ability_helper')

    if buff_up('Dark Arts') then
        send_command('input /ja "Addendum: Black" <me>')
        AbilityHelper.follow_up('Addendum: Black', cast, STEP_SPACING)
        return
    end

    send_command('input /ja "Dark Arts" <me>')
    AbilityHelper.follow_up('Dark Arts', function()
        send_command('input /ja "Addendum: Black" <me>')
        AbilityHelper.follow_up('Addendum: Black', cast, STEP_SPACING)
    end, STEP_SPACING)
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

    ScholarActions.cast_with_stratagems(
        entry.spell, entry.toggle and aoe_state or nil, entry.addendum)
    return true
end

return ScholarActions
