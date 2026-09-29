---  ═══════════════════════════════════════════════════════════════════════════
---   SCH Spell Commands - nuke / helix / storm from the Element mode, strat
---  ═══════════════════════════════════════════════════════════════════════════
---   One Element mode drives three commands:
---     nuke    the element's nuke at NukeTier (Fire V, Blizzard IV...) on <t>
---     helix   the element's helix II on <t> (Pyrohelix II...)
---     storm   the element's storm II on <me> (Firestorm II...)
---   The spell is sent at the tier asked; precast then drops it to the
---   highest tier that can go out (logic/spell_tiers.lua + TierRefiner), so a
---   Scholar without the tier II gifts casts tier I.
---   Light and Dark have no nuke: `nuke` says so.
---
---   strat   stratagem block: Arts in force, charges, next charge, the
---           stratagem effects up.
---
---   @file    shared/jobs/sch/functions/logic/spell_commands.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local SpellCommands = {}

--- Spell names of each element (Element mode values).
SpellCommands.ELEMENTS = {
    Fire      = {nuke = 'Fire',    helix = 'Pyrohelix',   storm = 'Firestorm'},
    Ice       = {nuke = 'Blizzard', helix = 'Cryohelix',  storm = 'Hailstorm'},
    Wind      = {nuke = 'Aero',    helix = 'Anemohelix',  storm = 'Windstorm'},
    Earth     = {nuke = 'Stone',   helix = 'Geohelix',    storm = 'Sandstorm'},
    Lightning = {nuke = 'Thunder', helix = 'Ionohelix',   storm = 'Thunderstorm'},
    Water     = {nuke = 'Water',   helix = 'Hydrohelix',  storm = 'Rainstorm'},
    Light     = {helix = 'Luminohelix', storm = 'Aurorastorm'},
    Dark      = {helix = 'Noctohelix',  storm = 'Voidstorm'},
}

--- Stratagem effects listed by `strat` (res/buffs.lua names).
local STRATAGEM_BUFFS = {
    'Penury', 'Celerity', 'Rapture', 'Accession', 'Perpetuance',
    'Parsimony', 'Alacrity', 'Ebullience', 'Manifestation', 'Immanence',
    'Klimaform', 'Sublimation: Activated', 'Sublimation: Complete',
}

--- Target of each command.
local TARGETS = {nuke = '<t>', helix = '<t>', storm = '<me>'}

--- Spell name of a command for an element and nuke tier.
--- @param command string 'nuke', 'helix' or 'storm'
--- @param element string Element mode value
--- @param tier string|nil NukeTier value ('V'...'I')
--- @return string|nil name, nil when the element has none
function SpellCommands.spell_name(command, element, tier)
    local names = SpellCommands.ELEMENTS[element]
    local base = names and names[command]
    if not base then return nil end
    if command == 'nuke' then
        if not tier or tier == 'I' then return base end
        return base .. ' ' .. tier
    end
    return base .. ' II'
end

--- Cast the spell of a command from the Element / NukeTier modes.
--- @param command string 'nuke', 'helix' or 'storm'
--- @return boolean True when a spell was sent
function SpellCommands.cast(command)
    local element = state.Element and state.Element.current
    local tier = state.NukeTier and state.NukeTier.current
    local name = SpellCommands.spell_name(command, element, tier)
    if not name then
        require('shared/utils/messages/message_formatter').show_warning(
            ('No %s for %s: use helix or storm'):format(command, tostring(element)))
        return false
    end
    send_command(('input /ma "%s" %s'):format(name, TARGETS[command]))
    return true
end

--- The stratagem effects up now.
--- @return string
local function buffs_up()
    local up = {}
    for _, name in ipairs(STRATAGEM_BUFFS) do
        if buffactive and buffactive[name] then up[#up + 1] = name end
    end
    return #up > 0 and table.concat(up, ', ') or 'none'
end

--- //gs c strat: the stratagem block.
function SpellCommands.show_stratagems()
    local Charges = require('shared/utils/scholar/stratagem_charges')
    local Grimoire = require('shared/jobs/sch/functions/logic/grimoire')
    local available, max = Charges.available(), Charges.get_max()
    local next_min = Charges.next_charge_minutes()
    require('shared/utils/messages/info_block').show({
        tag = 'SCH', title = 'Stratagems',
        fields = {
            {'Arts', Grimoire.arts_label(), Grimoire.arts() and 'good' or 'warn'},
            {'Charges', available .. ' / ' .. max, available > 0 and 'good' or 'bad'},
            {'Next charge', next_min > 0 and ('%.1f min'):format(next_min) or 'full', next_min > 0 and 'dim' or nil},
            {'Up', buffs_up()},
        },
        lines = {{'Charges are estimated from the full-pool recast (240 s); with the 550 JP gift they can read high', 'dim'}},
    })
end

return SpellCommands
