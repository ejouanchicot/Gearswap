---  ═══════════════════════════════════════════════════════════════════════════
---   Smartbuff Manager - Subjob Buff Application (WAR)
---  ═══════════════════════════════════════════════════════════════════════════
---   WAR main: //gs c berserk and //gs c defender (the chains war_berserk /
---   war_defender of _common/combat/BUFF_CONFIG.lua, plus the /SAM stance and
---   Third Eye with war_add_sam), //gs c thirdeye, and TP building (/SAM
---   Meditate, /DRG jumps). The lists go through the one buff engine,
---   shared/utils/buffs/self_buff_manager.lua. (/DNC Haste Samba was in the
---   chain until 2026-09-30; the player did not want it sent with every
---   berserk.)
---
---   @file    shared/jobs/war/functions/logic/smartbuff_manager.lua
---   @author  ejouanchicot
---   @version 2.0 - lists from BUFF_CONFIG.lua, the shared buff engine
---   @date    Created: 2025-10-06 | Updated: 2026-10-01
---  ═══════════════════════════════════════════════════════════════════════════
local SmartbuffManager = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   WARRIOR ABILITY AUTOMATION
---  ═══════════════════════════════════════════════════════════════════════════

--- One engine for every buff list: shared/utils/buffs/self_buff_manager.lua
--- (names, the rules of Warcry / Blood Rage, Hasso / Seigan, the shared
--- action queue). The lists: _common/combat/BUFF_CONFIG.lua (buff_config.lua).
local Engine = require('shared/utils/buffs/self_buff_manager')

--- Collect lists, show what is not cast, cast the rest.
--- @param ... table Lists of names
local function run(...)
    local to_cast, status = {}, {}
    for _, list in ipairs({...}) do
        local a, s = Engine.collect(list)
        for _, v in ipairs(a) do to_cast[#to_cast + 1] = v end
        for _, v in ipairs(s) do status[#status + 1] = v end
    end
    Engine.show_status(status)
    Engine.cast(to_cast)
end

--- The /SAM part: the stance of the mode (Hasso with Berserk, Seigan with
--- Defender) and Third Eye, or nothing on another or a disabled subjob.
--- The stance follows `mode`, not buffactive: in the chain the Berserk or
--- Defender cast is still queued, its buff is not up yet.
--- @param mode string 'Berserk' or 'Defender'
--- @return table names
local function sam_part(mode)
    if not (player and player.sub_job == 'SAM' and (player.sub_job_level or 0) > 0) then return {} end
    return {mode == 'Defender' and 'Seigan' or 'Hasso', 'Third Eye'}
end

---   Buff the player with the WAR chain of the mode: war_berserk or
---   war_defender of BUFF_CONFIG.lua (each list holds one of Berserk /
---   Defender: Berserk lowers Defense, Defender Attack), then, with
---   war_add_sam, the /SAM stance and Third Eye.
---   @param param string 'Berserk' (default) or 'Defender': which list
---   @return void
function SmartbuffManager.buff_war(param)
    local cfg = require('shared/utils/buffs/buff_config').get()
    local list = param == 'Defender' and cfg.war_defender or cfg.war_berserk
    run(list, cfg.war_add_sam and sam_part(param) or {})
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SAM SUBJOB ABILITIES
---  ═══════════════════════════════════════════════════════════════════════════

---   //gs c thirdeye: the /SAM stance (Seigan while Defender is up, else
---   Hasso) and Third Eye
---   @return void
function SmartbuffManager.buff_sam_sub()
    if not player or player.sub_job ~= 'SAM' then
        -- //gs c thirdeye on another subjob used to do nothing, silently
        local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if ok and MessageFormatter then MessageFormatter.show_warning('thirdeye: needs /SAM') end
        return
    end
    -- Standalone call: nothing is queued ahead of it, so buffactive tells the mode
    run(sam_part(buffactive['Defender'] and 'Defender' or 'Berserk'))
end

---  ═══════════════════════════════════════════════════════════════════════════
---   TP BUILDING (SUBJOB DEPENDENT)
---  ═══════════════════════════════════════════════════════════════════════════
---   Build TP with whatever the current subjob offers
---   • /SAM -> Meditate
---   • /DRG -> the shared DRG jump manager (Jump / High Jump rotation)
---   Any other subjob has no TP-building ability worth automating.
---
---   @return void
function SmartbuffManager.build_tp()
    local sub = player and player.sub_job
    if sub == 'SAM' then
        run({'Meditate'})
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
