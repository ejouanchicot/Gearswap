---  ═══════════════════════════════════════════════════════════════════════════
---   SCH Grimoire - Arts in force and the stratagem gear layers
---  ═══════════════════════════════════════════════════════════════════════════
---   Which Arts is up, whether a spell is of that Arts, and the sets laid on
---   top of the precast / midcast set Mote or MidcastManager chose:
---
---   Precast (cast start):
---     sets.precast.FC.Grimoire   spell of the Arts in force (white magic
---                                under Light Arts / Addendum: White, black
---                                magic under Dark Arts / Addendum: Black):
---                                "Grimoire: spellcasting time" pieces only
---                                work then
---     sets.buff.Celerity         Celerity up, white magic
---     sets.buff.Alacrity         Alacrity up, black magic
---   Midcast (as the spell lands):
---     sets.buff.Perpetuance      Perpetuance up, Enhancing Magic
---     sets.buff.Rapture          Rapture up, white magic
---     sets.buff.Ebullience       Ebullience up, black magic
---     sets.buff.Immanence        Immanence up, Elemental Magic
---     sets.buff.Klimaform        Klimaform up, Elemental Magic of the
---                                weather's element
---     sets.buff.Celerity / .Alacrity again (their gear also cuts the recast,
---                                which is set when the spell lands)
---
---   Addendum: White / Black replaces Light / Dark Arts in buffactive, so the
---   addendum is checked first (CODE_QUALITY §7.5).
---
---   @file    shared/jobs/sch/functions/logic/grimoire.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local Grimoire = {}

--- @param name string Buff name
--- @return boolean
local function buff(name)
    return buffactive ~= nil and buffactive[name] ~= nil and buffactive[name] ~= false
end

--- The Arts in force.
--- @return string|nil 'Light', 'Dark' or nil
function Grimoire.arts()
    if buff('Addendum: White') or buff('Light Arts') then return 'Light' end
    if buff('Addendum: Black') or buff('Dark Arts') then return 'Dark' end
    return nil
end

--- Name of the Arts buff shown to the player (addendum first).
--- @return string
function Grimoire.arts_label()
    for _, name in ipairs({'Addendum: White', 'Light Arts', 'Addendum: Black', 'Dark Arts'}) do
        if buff(name) then return name end
    end
    return 'none'
end

--- Whether the spell is of the Arts in force.
--- @param spell table
--- @return boolean
function Grimoire.matches(spell)
    local arts = Grimoire.arts()
    return (arts == 'Light' and spell.type == 'WhiteMagic')
        or (arts == 'Dark' and spell.type == 'BlackMagic')
end

--- sets.buff[name] when the buff is up and the set exists.
--- @param name string
--- @return table|nil
local function buff_set(name)
    if not buff(name) then return nil end
    local set = sets.buff and sets.buff[name]
    return type(set) == 'table' and set or nil
end

--- Celerity (white) / Alacrity (black) set for this spell.
--- @param spell table
--- @return table|nil
local function speed_set(spell)
    if spell.type == 'WhiteMagic' then return buff_set('Celerity') end
    if spell.type == 'BlackMagic' then return buff_set('Alacrity') end
    return nil
end

--- Sets to lay at precast, in order.
--- @param spell table
--- @return table list of sets
function Grimoire.precast_layers(spell)
    local layers = {}
    if spell.action_type ~= 'Magic' then return layers end
    local fc = sets.precast and sets.precast.FC
    if Grimoire.matches(spell) and fc and type(fc.Grimoire) == 'table' then
        layers[#layers + 1] = fc.Grimoire
    end
    local speed = speed_set(spell)
    if speed then layers[#layers + 1] = speed end
    return layers
end

--- Klimaform set: Klimaform up and the spell of the weather's element.
--- @param spell table
--- @return table|nil
local function klimaform_set(spell)
    local weather = world and world.weather_element
    if not weather or spell.element ~= weather then return nil end
    return buff_set('Klimaform')
end

--- Sets to lay at midcast, in order.
--- @param spell table
--- @return table list of sets
function Grimoire.midcast_layers(spell)
    local layers = {}
    if spell.action_type ~= 'Magic' then return layers end
    local function add(set) if set then layers[#layers + 1] = set end end
    if spell.skill == 'Enhancing Magic' then add(buff_set('Perpetuance')) end
    if spell.type == 'WhiteMagic' then add(buff_set('Rapture')) end
    if spell.type == 'BlackMagic' then add(buff_set('Ebullience')) end
    if spell.skill == 'Elemental Magic' then
        add(buff_set('Immanence'))
        add(klimaform_set(spell))
    end
    add(speed_set(spell))
    return layers
end

--- Equip a list of sets, in order.
--- @param layers table
function Grimoire.equip_layers(layers)
    for _, set in ipairs(layers) do
        equip(set)
    end
end

return Grimoire
