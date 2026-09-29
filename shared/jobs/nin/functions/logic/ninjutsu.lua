---  ═══════════════════════════════════════════════════════════════════════════
---   NIN Ninjutsu - spell family and midcast routing
---  ═══════════════════════════════════════════════════════════════════════════
---   Every Ninjutsu spell is "<Name>: Ichi|Ni|San". Its family is the name
---   before the colon:
---     Utsusemi                                       -> 'Utsusemi'
---     Migawari                                       -> 'Migawari'
---     Katon Suiton Raiton Doton Huton Hyoton         -> 'Elemental'
---     Kurayami Hojo Dokumori Jubaku Aisha Yurin      -> 'Enfeebling'
---     anything else (Tonko Monomi Myoshu Kakka
---     Gekka Yain)                                    -> 'Enhancing'
---
---   MidcastManager gets the family as the spell type, so with the P0-P9
---   chain (shared/utils/midcast/midcast_manager.lua) the sets are:
---     sets.midcast.Utsusemi / sets.midcast.Migawari   (type at the root)
---     sets.midcast.Ninjutsu.Elemental / .Enfeebling / .Enhancing
---     sets.midcast.Ninjutsu.Elemental.MagicBurst      (MagicBurstMode On)
---     sets.midcast.Ninjutsu                           (anything else)
---   A spell's own set (sets.midcast['Katon: San']) still wins over them.
---
---   @file    shared/jobs/nin/functions/logic/ninjutsu.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local Ninjutsu = {}

local OWN_SET = {Utsusemi = 'Utsusemi', Migawari = 'Migawari'}
local ELEMENTAL = {Katon = true, Suiton = true, Raiton = true, Doton = true, Huton = true, Hyoton = true}
local ENFEEBLING = {Kurayami = true, Hojo = true, Dokumori = true, Jubaku = true, Aisha = true, Yurin = true}

--- Family of a Ninjutsu spell (see header).
--- @param name string|nil Spell name ("Katon: San")
--- @return string|nil 'Utsusemi', 'Migawari', 'Elemental', 'Enfeebling', 'Enhancing', or nil
function Ninjutsu.family(name)
    if type(name) ~= 'string' then return nil end
    local base = name:match('^([^:]+):')
    if not base then return nil end
    if OWN_SET[base] then return OWN_SET[base] end
    if ELEMENTAL[base] then return 'Elemental' end
    if ENFEEBLING[base] then return 'Enfeebling' end
    return 'Enhancing'
end

--- @return boolean True when MagicBurstMode is On
local function burst_on()
    return state ~= nil and state.MagicBurstMode ~= nil and state.MagicBurstMode.current == 'On'
end

--- MidcastManager.select_set config for a Ninjutsu spell.
--- @param spell table Spell from GearSwap
--- @return table config, string|nil family
function Ninjutsu.midcast_config(spell)
    local family = Ninjutsu.family(spell and spell.english)
    local config = {skill = 'Ninjutsu', spell = spell, database_func = Ninjutsu.family}
    if family == 'Elemental' and burst_on() then
        config.mode_value = 'MagicBurst'
    end
    return config, family
end

--- The Futae layer: sets.buff.Futae on an elemental ninjutsu while Futae is
--- up (Futae ends with that spell, so buffactive still holds it at midcast).
--- @param family string|nil Family from midcast_config
--- @return table|nil Set to lay on top, or nil
function Ninjutsu.futae_layer(family)
    if family ~= 'Elemental' then return nil end
    if not (buffactive and buffactive['Futae']) then return nil end
    local set = sets and sets.buff and sets.buff.Futae
    return type(set) == 'table' and set or nil
end

return Ninjutsu
