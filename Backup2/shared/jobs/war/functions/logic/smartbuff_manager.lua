---============================================================================
--- Smartbuff Manager - Subjob Buff Application (WAR)
---============================================================================
--- Manages automatic buff application for WAR main job with various subjobs.
--- Provides intelligent automation for:
---   • WAR core abilities (Berserk, Aggressor, Warcry, etc.)
---   • SAM subjob automation (Hasso/Seigan + Third Eye)
---
--- Features:
---   • Mutual exclusion handling (Berserk vs Defender)
---   • Cooldown tracking and status display
---   • Sequential casting with delays to avoid conflicts
---   • Subjob-specific logic routing
---
--- @file    jobs/war/functions/logic/smartbuff_manager.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================
local SmartbuffManager = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Load recast configuration for cooldown tolerance
local RECAST_CONFIG = _G.RECAST_CONFIG or {}  -- Loaded from character main file

-- Safe wrappers for RECAST_CONFIG methods (with fallback if config not loaded)
local function is_recast_ready(recast)
    if RECAST_CONFIG and RECAST_CONFIG.is_ready then
        return RECAST_CONFIG.is_ready(recast)
    else
        return (recast == 0)
    end
end

local function is_on_cooldown(recast)
    if RECAST_CONFIG and RECAST_CONFIG.on_cooldown then
        return RECAST_CONFIG.on_cooldown(recast)
    else
        return (recast > 0)
    end
end

---============================================================================
--- WARRIOR ABILITY AUTOMATION
---============================================================================

--- Buff the player with key WAR job abilities automatically
--- Handles mutual exclusion between Berserk and Defender.
---
--- Abilities managed:
---   • Berserk     (ID: 1) - Attack+, Defense- | Excludes Defender
---   • Defender    (ID: 3) - Defense+, Attack- | Excludes Berserk
---   • Aggressor   (ID: 4) - Accuracy+
---   • Retaliation (ID: 8) - Counter attacks
---   • Restraint   (ID: 9) - Weaponskill damage+
---   • Warcry      (ID: 2) - Attack boost (party)
---   • Blood Rage  (ID: 11) - Attack boost fallback (mutually exclusive with Warcry)
---
--- @param param string Optional mutual exclusion: 'Berserk' (exclude Defender) or 'Defender' (exclude Berserk)
--- @return void
function SmartbuffManager.buff_war(param)
    local recasts = windower.ffxi.get_ability_recasts()
    local buffs = buffactive

    -- Ability definitions
    local abilities = {{
        name = 'Berserk',
        buff = 'Berserk',
        id = 1
    }, {
        name = 'Defender',
        buff = 'Defender',
        id = 3
    }, {
        name = 'Aggressor',
        buff = 'Aggressor',
        id = 4
    }, {
        name = 'Retaliation',
        buff = 'Retaliation',
        id = 8
    }, {
        name = 'Restraint',
        buff = 'Restraint',
        id = 9
    }}

    -- Handle mutually exclusive abilities
    local exclude = {}
    if param == 'Berserk' then
        exclude['Defender'] = true
    elseif param == 'Defender' then
        exclude['Berserk'] = true
    end

    -- Collect abilities to cast and status to display
    local abilities_to_cast = {}
    local status_data = {}

    -- Check each ability
    for _, ability in ipairs(abilities) do
        local recast = recasts[ability.id] or 0
        local isActive = buffs[ability.buff]
        local isExcluded = exclude[ability.name]

        if not isExcluded then
            if isActive then
                table.insert(status_data, {
                    name = ability.name,
                    status = 'active'
                })
            elseif is_on_cooldown(recast) then
                table.insert(status_data, {
                    name = ability.name,
                    status = 'cooldown',
                    time = math.ceil(recast)
                })
            else
                table.insert(abilities_to_cast, ability)
            end
        end
    end

    -- Handle Warcry / Blood Rage (mutual exclusion)
    local warcry_recast = recasts[2] or 0
    local bloodrage_recast = recasts[11] or 0
    local warcry_active = buffs['Warcry']
    local bloodrage_active = buffs['Blood Rage']

    -- Warcry status
    if warcry_active then
        table.insert(status_data, {
            name = 'Warcry',
            status = 'active'
        })
    elseif is_recast_ready(warcry_recast) and not bloodrage_active then
        table.insert(abilities_to_cast, {
            name = 'Warcry',
            id = 2
        })
    elseif is_on_cooldown(warcry_recast) then
        table.insert(status_data, {
            name = 'Warcry',
            status = 'cooldown',
            time = math.ceil(warcry_recast)
        })
    end

    -- Blood Rage status (only use if Warcry on cooldown)
    if bloodrage_active then
        table.insert(status_data, {
            name = 'Blood Rage',
            status = 'active'
        })
    elseif is_recast_ready(bloodrage_recast) and not warcry_active and is_on_cooldown(warcry_recast) then
        table.insert(abilities_to_cast, {
            name = 'Blood Rage',
            id = 11
        })
    elseif is_on_cooldown(bloodrage_recast) then
        table.insert(status_data, {
            name = 'Blood Rage',
            status = 'cooldown',
            time = math.ceil(bloodrage_recast)
        })
    end

    -- Display buff status (using global function if available)
    if #status_data > 0 and show_war_buff_status then
        show_war_buff_status(status_data)
    end

    -- Cast abilities sequentially (2 second spacing)
    for i, ability in ipairs(abilities_to_cast) do
        local command = 'input /ja "' .. ability.name .. '" <me>'
        if i == 1 then
            send_command(command)
        else
            send_command('wait ' .. ((i - 1) * 2) .. '; ' .. command)
        end
    end
end

---============================================================================
--- SAM SUBJOB ABILITIES
---============================================================================

--- Activate Samurai subjob abilities: Hasso/Seigan + Third Eye
--- Uses Seigan if Defender is active, otherwise uses Hasso.
---
--- Abilities:
---   • Hasso/Seigan (ID: 138/139) - Stance (Hasso: offense, Seigan: defense)
---   • Third Eye    (ID: 133)     - Anticipate physical attack
---
--- @return void
function SmartbuffManager.buff_sam_sub()
    -- Safety checks
    if not player or not player.sub_job then
        return
    end
    if player.sub_job ~= 'SAM' then
        return
    end

    local recasts = windower.ffxi.get_ability_recasts()
    local buffs = buffactive

    -- Ability IDs
    local seigan_id = 139
    local hasso_id = 138
    local thirdeye_id = 133

    -- Choose stance based on Defender status
    local usingDefender = buffs['Defender'] ~= nil
    local stance_name = usingDefender and 'Seigan' or 'Hasso'
    local stance_buff = usingDefender and 'Seigan' or 'Hasso'
    local stance_id = usingDefender and seigan_id or hasso_id

    -- Collect abilities to cast and status to display
    local abilities_to_cast = {}
    local status_data = {}

    -- Check stance (Hasso/Seigan)
    local stance_recast = recasts[stance_id] or 0
    if buffs[stance_buff] then
        table.insert(status_data, {
            name = stance_name,
            status = 'active'
        })
    elseif is_on_cooldown(stance_recast) then
        table.insert(status_data, {
            name = stance_name,
            status = 'cooldown',
            time = math.ceil(stance_recast)
        })
    else
        table.insert(abilities_to_cast, {
            name = stance_name
        })
    end

    -- Check Third Eye
    local thirdeye_recast = recasts[thirdeye_id] or 0
    if buffs['Third Eye'] then
        table.insert(status_data, {
            name = 'Third Eye',
            status = 'active'
        })
    elseif is_on_cooldown(thirdeye_recast) then
        table.insert(status_data, {
            name = 'Third Eye',
            status = 'cooldown',
            time = math.ceil(thirdeye_recast)
        })
    else
        table.insert(abilities_to_cast, {
            name = 'Third Eye'
        })
    end

    -- Display buff status
    if #status_data > 0 and show_war_buff_status then
        show_war_buff_status(status_data)
    end

    -- Cast abilities sequentially (1 second spacing)
    for i, ability in ipairs(abilities_to_cast) do
        local command = 'input /ja "' .. ability.name .. '" <me>'
        if i == 1 then
            send_command(command)
        else
            send_command('wait ' .. (i - 1) .. '; ' .. command)
        end
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SmartbuffManager
