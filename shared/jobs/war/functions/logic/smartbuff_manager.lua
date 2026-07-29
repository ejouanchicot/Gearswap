---  ═══════════════════════════════════════════════════════════════════════════
---   Smartbuff Manager - Subjob Buff Application (WAR)
---  ═══════════════════════════════════════════════════════════════════════════
---   Manages automatic buff application for WAR main job with various subjobs.
---   Provides intelligent automation for:
---   • WAR core abilities (Berserk, Aggressor, Warcry, etc.)
---   • SAM subjob automation (Hasso/Seigan + Third Eye)
---   • Subjob abilities folded into the main chain, so //gs c berserk and
---     //gs c defender are the only two macros needed:
---       /SAM -> Hasso + Third Eye  (Seigan + Third Eye under Defender)
---       /DNC -> Haste Samba
---
---   Features:
---   • Mutual exclusion handling (Berserk vs Defender)
---   • Cooldown tracking and status display
---   • Sequential casting with delays to avoid conflicts
---   • Subjob-specific logic routing
---
---   @file    jobs/war/functions/logic/smartbuff_manager.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-06
---  ═══════════════════════════════════════════════════════════════════════════
local SmartbuffManager = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES
---  ═══════════════════════════════════════════════════════════════════════════

-- Buff status display (was the global show_war_buff_status wrapper before)
local MessageBuffs = require('shared/utils/messages/formatters/magic/message_buffs')

-- is_recast_ready / is_on_cooldown resolved as globals from RECAST_CONFIG.lua
-- (loaded by entry point before job functions). Do not redeclare locally.

---  ═══════════════════════════════════════════════════════════════════════════
---   WARRIOR ABILITY AUTOMATION
---  ═══════════════════════════════════════════════════════════════════════════

---   Buff the player with key WAR job abilities automatically
---   Handles mutual exclusion between Berserk and Defender.
---
---   Abilities managed:
---   • Berserk     (ID: 1) - Attack+, Defense- | Excludes Defender
---   • Defender    (ID: 3) - Defense+, Attack- | Excludes Berserk
---   • Aggressor   (ID: 4) - Accuracy+
---   • Retaliation (ID: 8) - Counter attacks
---   • Restraint   (ID: 9) - Weaponskill damage+
---   • Warcry      (ID: 2) - Attack boost (party)
---   • Blood Rage  (ID: 11) - Attack boost fallback (mutually exclusive with Warcry)
---
---   @param param string Optional mutual exclusion: 'Berserk' (exclude Defender) or 'Defender' (exclude Berserk)
---   @return void
--- Main WAR abilities (Berserk/Defender/Aggressor/Retaliation/Restraint).
--- Berserk and Defender are mutually exclusive via the `exclude` table.
local MAIN_ABILITIES = {
    { name = 'Berserk',     buff = 'Berserk',     id = 1 },
    { name = 'Defender',    buff = 'Defender',    id = 3 },
    { name = 'Aggressor',   buff = 'Aggressor',   id = 4 },
    { name = 'Retaliation', buff = 'Retaliation', id = 8 },
    { name = 'Restraint',   buff = 'Restraint',   id = 9 },
}

--- Collect main 5 WAR abilities into cast queue + status display.
--- @param recasts table windower.ffxi.get_ability_recasts() output
--- @param buffs   table buffactive snapshot
--- @param exclude table { [name] = true } abilities to skip (mutual exclusion)
--- @return table abilities_to_cast, table status_data
local function collect_main_abilities(recasts, buffs, exclude)
    local to_cast = {}
    local status = {}
    for _, ability in ipairs(MAIN_ABILITIES) do
        if not exclude[ability.name] then
            local recast = recasts[ability.id] or 0
            if buffs[ability.buff] then
                table.insert(status, { name = ability.name, status = 'active' })
            elseif is_on_cooldown(recast) then
                table.insert(status, { name = ability.name, status = 'cooldown', time = math.ceil(recast) })
            else
                table.insert(to_cast, ability)
            end
        end
    end
    return to_cast, status
end

--- Append Warcry / Blood Rage entries to existing cast queue + status.
--- Warcry is preferred; Blood Rage is used only if Warcry is on cooldown.
--- @param recasts table get_ability_recasts() output
--- @param buffs   table buffactive snapshot
--- @param to_cast table abilities_to_cast (mutated)
--- @param status  table status_data (mutated)
local function collect_warcry_bloodrage(recasts, buffs, to_cast, status)
    local warcry_recast    = recasts[2]  or 0
    local bloodrage_recast = recasts[11] or 0
    local warcry_active    = buffs['Warcry']
    local bloodrage_active = buffs['Blood Rage']

    if warcry_active then
        table.insert(status, { name = 'Warcry', status = 'active' })
    elseif is_recast_ready(warcry_recast) and not bloodrage_active then
        table.insert(to_cast, { name = 'Warcry', id = 2 })
    elseif is_on_cooldown(warcry_recast) then
        table.insert(status, { name = 'Warcry', status = 'cooldown', time = math.ceil(warcry_recast) })
    end

    if bloodrage_active then
        table.insert(status, { name = 'Blood Rage', status = 'active' })
    elseif is_recast_ready(bloodrage_recast) and not warcry_active and is_on_cooldown(warcry_recast) then
        table.insert(to_cast, { name = 'Blood Rage', id = 11 })
    elseif is_on_cooldown(bloodrage_recast) then
        table.insert(status, { name = 'Blood Rage', status = 'cooldown', time = math.ceil(bloodrage_recast) })
    end
end

--- SAM stance paired with each WAR mode: Berserk goes with Hasso (offense),
--- Defender with Seigan (defense).
local SAM_STANCE = {
    Berserk  = { name = 'Hasso',  id = 138 },
    Defender = { name = 'Seigan', id = 139 },
}

local THIRD_EYE   = { name = 'Third Eye',   id = 133 }
local HASTE_SAMBA = { name = 'Haste Samba', id = 216, tp_cost = 350 }
local MEDITATE    = { name = 'Meditate',    id = 134 }

--- Queue one ability unless it is already up or still on cooldown.
--- @param ability table { name, id }
--- @param recasts table get_ability_recasts() output
--- @param buffs   table buffactive snapshot
--- @param to_cast table abilities_to_cast (mutated)
--- @param status  table status_data (mutated)
local function collect_ability(ability, recasts, buffs, to_cast, status)
    local recast = recasts[ability.id] or 0

    if buffs[ability.name] then
        table.insert(status, { name = ability.name, status = 'active' })
    elseif is_on_cooldown(recast) then
        table.insert(status, { name = ability.name, status = 'cooldown', time = math.ceil(recast) })
    else
        table.insert(to_cast, { name = ability.name, id = ability.id })
    end
end

--- Append subjob abilities so one macro covers main job + subjob.
--- The SAM stance follows `param`, NOT buffactive: at this point the Berserk or
--- Defender cast is still queued, so its buff is not up yet and reading
--- buffactive would always pick Hasso.
--- Haste Samba is skipped silently below its 350 TP cost - it is a bonus on top
--- of the WAR chain, and a warning on every macro press would be noise.
--- @param param string 'Berserk' or 'Defender'
local function collect_subjob_abilities(param, recasts, buffs, to_cast, status)
    local sub = player and player.sub_job

    if sub == 'SAM' then
        collect_ability(SAM_STANCE[param] or SAM_STANCE.Berserk, recasts, buffs, to_cast, status)
        collect_ability(THIRD_EYE, recasts, buffs, to_cast, status)
    elseif sub == 'DNC' and (player.tp or 0) >= HASTE_SAMBA.tp_cost then
        collect_ability(HASTE_SAMBA, recasts, buffs, to_cast, status)
    end
end

--- Cast collected abilities sequentially with 2-second spacing.
local function cast_sequentially(abilities_to_cast)
    for i, ability in ipairs(abilities_to_cast) do
        local command = 'input /ja "' .. ability.name .. '" <me>'
        if i == 1 then
            send_command(command)
        else
            send_command('wait ' .. ((i - 1) * 2) .. '; ' .. command)
        end
    end
end

function SmartbuffManager.buff_war(param)
    local recasts = windower.ffxi.get_ability_recasts()
    local buffs = buffactive

    -- Mutual exclusion between Berserk and Defender (caller-driven via param).
    local exclude = {}
    if param == 'Berserk' then
        exclude['Defender'] = true
    elseif param == 'Defender' then
        exclude['Berserk'] = true
    end

    local to_cast, status = collect_main_abilities(recasts, buffs, exclude)
    collect_warcry_bloodrage(recasts, buffs, to_cast, status)
    collect_subjob_abilities(param, recasts, buffs, to_cast, status)

    if #status > 0 then
        MessageBuffs.show_buff_status(status)
    end

    cast_sequentially(to_cast)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SAM SUBJOB ABILITIES
---  ═══════════════════════════════════════════════════════════════════════════

---   Activate Samurai subjob abilities: Hasso/Seigan + Third Eye
---   Uses Seigan if Defender is active, otherwise uses Hasso.
---
---   Abilities:
---   • Hasso/Seigan (ID: 138/139) - Stance (Hasso: offense, Seigan: defense)
---   • Third Eye    (ID: 133)     - Anticipate physical attack
---
---   @return void
function SmartbuffManager.buff_sam_sub()
    if not player or player.sub_job ~= 'SAM' then
        return
    end

    local recasts = windower.ffxi.get_ability_recasts()
    local buffs = buffactive
    local to_cast, status = {}, {}

    -- Standalone call: nothing is queued ahead of it, so buffactive is the
    -- authoritative source for the stance (unlike the chained path in buff_war).
    local mode = buffs['Defender'] and 'Defender' or 'Berserk'
    collect_ability(SAM_STANCE[mode], recasts, buffs, to_cast, status)
    collect_ability(THIRD_EYE, recasts, buffs, to_cast, status)

    if #status > 0 then
        MessageBuffs.show_buff_status(status)
    end

    cast_sequentially(to_cast)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   TP BUILDING (SUBJOB DEPENDENT)
---  ═══════════════════════════════════════════════════════════════════════════

---   Build TP with whatever the current subjob offers
---   • /SAM -> Meditate (ID: 134, Lv30, 3min recast)
---   • /DRG -> the shared DRG jump manager (Jump / High Jump rotation)
---   Any other subjob has no TP-building ability worth automating.
---
---   @return void
function SmartbuffManager.build_tp()
    local sub = player and player.sub_job

    if sub == 'SAM' then
        local recasts = windower.ffxi.get_ability_recasts()
        local to_cast, status = {}, {}

        collect_ability(MEDITATE, recasts, buffactive, to_cast, status)

        if #status > 0 then
            MessageBuffs.show_buff_status(status)
        end

        cast_sequentially(to_cast)
        return
    end

    if sub == 'DRG' then
        -- execute_jump() does its own /DRG and Sheol Gaol checks
        local ok, DRGJumpManager = pcall(require, 'shared/utils/drg/DRG_JUMP_MANAGER')
        if ok and DRGJumpManager then
            DRGJumpManager.execute_jump()
        end
        return
    end

    local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    if ok and MessageFormatter then
        MessageFormatter.show_warning('No TP ability for /' .. tostring(sub or '???'))
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return SmartbuffManager
