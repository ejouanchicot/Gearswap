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
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-09-25
---============================================================================

local WeaponResolver = {}

local config_loaded, plain_enabled = false, false

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
    return require('shared/utils/equipment/item_index').is_weapon(name)
end

--- Main jobs with Dual Wield of their own, and the subjobs that grant it
--- with the level their trait comes at.
local DW_MAIN = {NIN = true, DNC = true, THF = true, BLU = true}
local DW_SUB = {NIN = 10, DNC = 20}

--- Can the player hold a weapon in the off hand right now? The subjob name
--- is not enough: Sheol Gaol and other events that set the subjob to level 0
--- keep /NIN or /DNC and take the trait away.
--- @return boolean
function WeaponResolver.can_dual_wield()
    if not player or not player.main_job then return true end  -- unknown: strip nothing
    if DW_MAIN[player.main_job] then return true end
    local needed = DW_SUB[player.sub_job]
    return needed ~= nil and (player.sub_job_level or 0) >= needed
end

--- An off-hand weapon the player cannot hold is swapped for the sub of
--- sets.SingleWield (the set file's, e.g. {sub = 'Nusku Shield'}), or left
--- out when there is none. Shields and grips are kept.
--- @param set table|nil
--- @return table|nil
local function single_wield(set)
    if type(set) ~= 'table' or set.sub == nil then return set end
    local sub = type(set.sub) == 'table' and set.sub.name or set.sub
    if WeaponResolver.is_offhand_weapon(sub) ~= true or WeaponResolver.can_dual_wield() then
        return set
    end
    local copy = {}
    for k, v in pairs(set) do copy[k] = v end
    copy.sub = type(sets.SingleWield) == 'table' and sets.SingleWield.sub or nil
    return copy
end

--- The set a value names, before the off-hand check.
--- @param slot string
--- @param value string
--- @return table|nil
local function lookup(slot, value)
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

--- The set to lay for a weapon state's value (see the header), with an
--- off-hand weapon the player cannot hold replaced (single_wield).
--- @param slot string 'main' or 'sub'
--- @param value string|nil The state's current value
--- @return table|nil
function WeaponResolver.set_for(slot, value)
    if value == nil then return nil end
    return single_wield(lookup(slot, value))
end

--- Whether an off-hand item makes the player dual wield, from the game's
--- item list: a weapon with a combat skill does; a shield (shield_size) or a
--- grip (skill 0) does not. Short and long item names, any case. The lookup
--- is built once per session (item_index.lua).
--- @param name string|nil Item name
--- @return boolean|nil nil when the name is not a known item
function WeaponResolver.is_offhand_weapon(name)
    return require('shared/utils/equipment/item_index').dual_wields(name)
end

return WeaponResolver
