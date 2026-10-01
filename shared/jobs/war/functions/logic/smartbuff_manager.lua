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
---     (/DNC Haste Samba was in the chain until 2026-09-30; the player did
---     not want it sent with every berserk)
---
---   Features:
---   • Mutual exclusion handling (Berserk vs Defender)
---   • Cooldown tracking and status display
---   • Sequential casting with delays to avoid conflicts
---   • Subjob-specific logic routing
---
---   @file    shared/jobs/war/functions/logic/smartbuff_manager.lua
---   @author  ejouanchicot
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

--- The Berserk / Defender chains: war_berserk / war_defender of
--- _common/combat/SMARTBUFF_CONFIG.lua (smartbuff_config.lua; defaults Berserk
--- or Defender, then Aggressor, Retaliation, Restraint, Warcry - Blood Rage
--- while Warcry is on cooldown). Names and rules: shared/utils/smartbuff/buff_list.lua.
local BuffList = require('shared/utils/smartbuff/buff_list')

--- SAM stance paired with each WAR mode: Berserk goes with Hasso (offense),
--- Defender with Seigan (defense).
local SAM_STANCE = {
    Berserk  = { name = 'Hasso',  id = 138 },
    Defender = { name = 'Seigan', id = 139 },
}

local THIRD_EYE   = { name = 'Third Eye',   id = 133 }
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
--- @param param   string 'Berserk' or 'Defender'
--- @param recasts table get_ability_recasts() output
--- @param buffs   table buffactive snapshot
--- @param to_cast table abilities_to_cast (mutated)
--- @param status  table status_data (mutated)
local function collect_subjob_abilities(param, recasts, buffs, to_cast, status)
    local sub = player and player.sub_job

    if sub == 'SAM' then
        collect_ability(SAM_STANCE[param] or SAM_STANCE.Berserk, recasts, buffs, to_cast, status)
        collect_ability(THIRD_EYE, recasts, buffs, to_cast, status)
    end
end

--- Cast collected abilities sequentially with 2-second spacing.
--- @param abilities_to_cast table List of { name, id } entries
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

---   Buff the player with the WAR chain of the mode: war_berserk or
---   war_defender of SMARTBUFF_CONFIG.lua (each list holds one of Berserk /
---   Defender), then, with war_add_sam, the /SAM stance and Third Eye
---   (see collect_subjob_abilities).
---
---   Default lists: Berserk or Defender (they do not go together: Berserk
---   lowers Defense, Defender Attack), Aggressor, Retaliation, Restraint,
---   Warcry (Blood Rage while Warcry is on cooldown).
---
---   @param param string 'Berserk' (default) or 'Defender': which list
---   @return void
function SmartbuffManager.buff_war(param)
    local cfg = require('shared/utils/smartbuff/smartbuff_config').get()
    local list = param == 'Defender' and cfg.war_defender or cfg.war_berserk
    local to_cast, status = BuffList.collect(list)
    if cfg.war_add_sam then
        collect_subjob_abilities(param, windower.ffxi.get_ability_recasts(), buffactive, to_cast, status)
    end
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
        -- //gs c thirdeye on another subjob used to do nothing, silently
        local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if ok and MessageFormatter then MessageFormatter.show_warning('thirdeye: needs /SAM') end
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
