---============================================================================
--- Weapon Resolver - the set a MainWeapon / SubWeapon value equips
---============================================================================
--- Every job's set_builder asks here for sets[state.MainWeapon.current] or
--- sets[state.SubWeapon.current]. By default the answer is exactly that
--- lookup, so nothing changes.
---
--- A character that turns on `equip_without_set` in
--- <Character>/config/WEAPON_CONFIG.lua gets, per slot:
---   1. sets[value], when it exists and names that slot (main / sub);
---   2. else {main = value} / {sub = value}, when value is a weapon name in
---      the game's item list: no set to write for a plain weapon;
---   3. else nothing.
--- Rule 1's slot check is what lets the same weapon sit in main or sub: a
--- set written for the main hand is no longer applied as the off hand.
---
--- Off by default because a job may rely on a weapon state WITHOUT a set:
--- Tetsouo's BLM keeps Hvergelmir set-less so its idle and engaged sets can
--- hold other staves.
---
--- @file shared/utils/equipment/weapon_resolver.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-25
---============================================================================

local WeaponResolver = {}

local config_loaded, plain_enabled = false, false
local weapon_names = nil

--- The character's choice, read once per load (config/WEAPON_CONFIG.lua).
--- @return boolean
local function enabled()
    if not config_loaded then
        config_loaded = true
        local ok, cfg = pcall(require, 'config/WEAPON_CONFIG')
        plain_enabled = ok and type(cfg) == 'table' and cfg.equip_without_set == true
    end
    return plain_enabled
end

--- Is `name` a weapon (grips included) in the game's item list?
--- @param name string
--- @return boolean
local function is_weapon(name)
    if not weapon_names then
        weapon_names = {}
        local ok, res = pcall(require, 'resources')
        if ok and res and res.items then
            for _, item in pairs(res.items) do
                if item.category == 'Weapon' and item.en then weapon_names[item.en] = true end
            end
        end
    end
    return weapon_names[name] == true
end

--- The set to lay for a weapon state's value.
--- @param slot string 'main' or 'sub'
--- @param value string|nil The state's current value
--- @return table|nil
function WeaponResolver.set_for(slot, value)
    if value == nil then return nil end
    local set = sets and sets[value]
    if not enabled() then return set end
    if type(set) == 'table' and set[slot] ~= nil then
        -- An off-hand pick never moves the main hand, even from a set that
        -- carries both (a main set with its grip, chosen as the sub)
        if slot == 'sub' and set.main ~= nil then return {sub = set.sub} end
        return set
    end
    if type(value) == 'string' and is_weapon(value) then return {[slot] = value} end
    return nil
end

local offhand_kinds = nil

--- Whether an off-hand item makes the player dual wield, from the game's
--- item list: a weapon with a combat skill does; a shield (shield_size) or a
--- grip (skill 0) does not. Short and long item names, any case.
--- @param name string|nil Item name
--- @return boolean|nil nil when the name is not a known item
function WeaponResolver.is_offhand_weapon(name)
    if type(name) ~= 'string' or name == '' then return nil end
    if not offhand_kinds then
        offhand_kinds = {}
        local ok, res = pcall(require, 'resources')
        if ok and res and res.items then
            for _, item in pairs(res.items) do
                local dual = item.category == 'Weapon' and (item.skill or 0) > 0
                for _, n in ipairs({item.en, item.enl}) do
                    if type(n) == 'string' then
                        local key = n:lower()
                        offhand_kinds[key] = offhand_kinds[key] or dual
                    end
                end
            end
        end
    end
    return offhand_kinds[name:lower()]
end

return WeaponResolver
