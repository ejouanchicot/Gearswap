---============================================================================
--- Gear Commands - the common commands about gear and wardrobes
---============================================================================
--- checksets, wardrobeaudit, wardrobeorganize, refill, automedicine, testcolors,
--- naked, lockstyle, dressup: moved as they were out of COMMON_COMMANDS.lua
--- (2026-11-14: over 800 lines), which routes the words and re-exposes these as
--- CommonCommands.handle_*.
---
--- @file    shared/utils/core/GEAR_COMMANDS.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-11-14 (moved out of COMMON_COMMANDS.lua)
---============================================================================

local GearCommands = {}

local MessageCommands  = require('shared/utils/messages/formatters/ui/message_commands')
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- CHECKSETS COMMAND

--- Compare the job's sets with the items actually owned.
--- @param job_name string Job code passed to EquipmentChecker
--- @return boolean True if the checker loaded
function GearCommands.handle_checksets(job_name)
    local equipment_success, EquipmentChecker = pcall(require, 'shared/utils/equipment/equipment_checker')
    if equipment_success and EquipmentChecker then
        EquipmentChecker.check_job_equipment(job_name)
        return true
    else
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load equipment checker")
        return false
    end
end

-- WARDROBE AUDIT COMMAND

--- Scan every job's sets and list wardrobe items none of them use.
--- @return boolean True if the auditor loaded
function GearCommands.handle_wardrobeaudit()
    local audit_success, WardrobeAuditor = pcall(require, 'shared/utils/equipment/wardrobe_auditor')
    if audit_success and WardrobeAuditor then
        WardrobeAuditor.audit()
        return true
    else
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load wardrobe auditor: " .. tostring(WardrobeAuditor))
        return false
    end
end

-- WARDROBE ORGANIZE COMMAND

--- Reorganize wardrobes. Modes (arguments are case-sensitive; anything
--- unrecognised runs the default organize):
---   `//gs c wo`                  - move the active job's items to W1/W2
---                                  (every job's when the character's
---                                  WARDROBE_CONFIG sets SCOPE = 'all_jobs')
---   `//gs c wo preview|dry`      - dry-run of the same
---   `//gs c wo global [preview]` - same as `wo` / `wo preview` (aliases)
---   `//gs c wo verify|check`     - check every item is where the config puts it
---   `//gs c wo scan|scanwarp`    - record owned warp items
---   `//gs c wo keep|kept|items`  - list what overflow keeps (read only)
---   `//gs c wo reset`, `recover|unlock`, `alt|kaories`
--- The bags come from the character's WARDROBE_CONFIG.lua (wardrobe/lib/
--- config.lua); its NEVER_TOUCH bags are taken out of every bag list.
--- @param arg string|nil Mode
--- @param arg2 string|nil 'preview' / 'dry' after 'global'
--- @return boolean False only if the organizer failed to load
function GearCommands.handle_wardrobeorganize(arg, arg2)
    local ok, WardrobeOrganizer = pcall(require, 'shared/utils/wardrobe/wardrobe_organizer')
    if not ok or not WardrobeOrganizer then
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load wardrobe organizer: " .. tostring(WardrobeOrganizer))
        return false
    end
    if arg == 'scan' or arg == 'scanwarp' then
        -- Record which warp items this character owns, and write the list.
        if WardrobeOrganizer.scan_warp_items then
            WardrobeOrganizer.scan_warp_items()
        end
    elseif arg == 'keep' or arg == 'kept' or arg == 'items' then
        -- What survives overflow beyond what the sets name. Reads only.
        if WardrobeOrganizer.show_kept then
            WardrobeOrganizer.show_kept()
        end
    elseif arg == 'verify' or arg == 'check' then
        WardrobeOrganizer.verify_global()
    elseif arg == 'reset' then
        if WardrobeOrganizer.reset then WardrobeOrganizer.reset() end
    elseif arg == 'recover' or arg == 'unlock' then
        if WardrobeOrganizer.recover then WardrobeOrganizer.recover() end
    elseif arg == 'alt' or arg == 'kaories' then
        -- Every job at once (USED_WHEN_ALL / UNUSED_WHEN_ALL, else USED / UNUSED)
        if WardrobeOrganizer.organize_alt then
            WardrobeOrganizer.organize_alt()
        else
            local MessageFormatter = require('shared/utils/messages/message_formatter')
            MessageFormatter.show_error("organize_alt not available in this version.")
        end
    elseif arg == 'global' then
        if arg2 == 'preview' or arg2 == 'dry' then
            WardrobeOrganizer.preview_global()
        else
            WardrobeOrganizer.organize_global()
        end
    elseif arg == 'preview' or arg == 'dry' then
        WardrobeOrganizer.preview()
    else
        WardrobeOrganizer.organize()
    end
    return true
end

-- REFILL COMMAND

--- Handle inventory refill command (pull consumables from Case/Sack).
--- Also broadcasts via DualBoxSyncIPC so the paired character refills its
--- own consumables in parallel (each instance reads its own Case/Sack).
--- @return boolean True if the refill manager loaded
function GearCommands.handle_refill()
    local refill_success, RefillManager = pcall(require, 'shared/utils/inventory/refill_manager')
    if not refill_success or not RefillManager then
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load refill manager: " .. tostring(RefillManager))
        return false
    end

    RefillManager.refill()

    -- Mirror to paired instance (no-op when solo).
    pcall(function()
        local SyncIPC = require('shared/utils/dualbox/dualbox_sync_ipc')
        SyncIPC.broadcast('rf')
    end)
    return true
end

-- AUTO MEDICINE COMMAND

--- Toggle automatic use of debuff cure items (Echo Drops / Remedy).
--- Off keeps the debuff block in place, it only stops consuming items - which
--- is what you want against unremovable debuff auras.
--- @param arg string|nil Optional explicit value ('on' / 'off')
--- @return boolean Success status
function GearCommands.handle_automedicine(arg)
    local ok, AutoMedicine = pcall(require, 'shared/utils/debuff/auto_medicine')
    if not ok or not AutoMedicine then
        MessageFormatter.show_error("Failed to load auto medicine module: " .. tostring(AutoMedicine))
        return false
    end
    return AutoMedicine.handle_command(arg)
end

-- TESTCOLORS COMMAND

--- Display the FFXI chat color codes 1-509, skipping those that corrupt chat
--- output, 14 samples per row.
--- @return boolean Always true
function GearCommands.handle_testcolors()
    MessageCommands.show_color_test_header()

    local valid_codes = {}
    for code = 1, 509 do
        -- Skip problematic codes:
        --   10, 13: LF/CR (line breaks)
        --   30, 31: Conflict with color prefixes (0x1E, 0x1F)
        --   253-279: Bugged/redundant range (source: battlemod color_redundant)
        --   507-508: High codes with bugged offsets
        local is_problematic = (code >= 253 and code <= 279) or (code >= 507 and code <= 508) or code == 10 or code ==
            13 or code == 30 or code == 31

        if not is_problematic then
            table.insert(valid_codes, code)
        end
    end

    local row_count = 0
    for i = 1, #valid_codes, 14 do
        if row_count > 0 then
            MessageCommands.show_color_test_separator()
        end
        MessageCommands.show_color_sample_row(valid_codes[i], valid_codes[i + 1], valid_codes[i + 2],
            valid_codes[i + 3], valid_codes[i + 4], valid_codes[i + 5], valid_codes[i + 6], valid_codes[i + 7],
            valid_codes[i + 8], valid_codes[i + 9], valid_codes[i + 10], valid_codes[i + 11], valid_codes[i + 12],
            valid_codes[i + 13])
        row_count = row_count + 1
    end

    MessageCommands.show_color_test_footer()
    return true
end

-- NAKED COMMAND (Strip all equipment)

--- The slots naked unlocks before emptying them. equip() skips a disabled slot: Combat Mode, WHM Melee ON or a
--- custom lock kept the weapons on, and PorterPacker then fell back on the client's `/equip <slot> empty`, which
--- crashed the game (a double free in its item-name table, full dump of 2026-11-13). Those locks come back by
--- themselves at the next update (combat_mode.lua apply, reassert_holds). Two stay: a craft session keeps all its
--- gear (craft_manager.lua), and Doom keeps its pieces (doom_manager.lua locks them until the Doom is gone).
--- @param all_slots table Every slot naked empties
--- @return table The slots to enable
local function naked_unlock_slots(all_slots)
    local ok_c, crafting = pcall(function() return require('shared/utils/craft/craft_manager').is_active() end)
    if ok_c and crafting then return {} end
    local doom_kept = buffactive and buffactive['doom'] and {neck = true, ring1 = true, ring2 = true, waist = true} or {}
    local unlock = {}
    for _, slot in ipairs(all_slots) do
        if not doom_kept[slot] then unlock[#unlock + 1] = slot end
    end
    return unlock
end

--- Strip all equipment slots (//gs c naked or //gs c equip naked).
--- @return boolean Always true
function GearCommands.handle_naked()
    -- PorterPacker sends `gs c naked` before its //po moves: the bags are about to move while their counts are still
    -- the same, so an action that reads them waits (shared/utils/equipment/bags_quiet.lua mark_busy; Kaories crashed
    -- on a lockstyle sent 4 s after the naked of a //po, 2026-10-29)
    pcall(function() require('shared/utils/equipment/bags_quiet').mark_busy() end)
    local all_slots = {
        'main', 'sub', 'range', 'ammo',
        'head', 'neck', 'ear1', 'ear2',
        'body', 'hands', 'ring1', 'ring2',
        'back', 'waist', 'legs', 'feet'
    }
    local naked_set = {}
    for _, slot in ipairs(all_slots) do
        naked_set[slot] = empty
    end
    local unlock = naked_unlock_slots(all_slots)
    if #unlock > 0 then enable((table.unpack or unpack)(unlock)) end
    equip(naked_set)
    local MessageFormatter = require('shared/utils/messages/message_formatter')
    MessageFormatter.show_info('All slots cleared.')
    return true
end

-- LOCKSTYLE COMMAND

--- Handle lockstyle reapply command (useful after dressup reload).
--- Also broadcasts to other Windower instances via DualBoxSyncIPC so the
--- paired character (e.g. Kaories when Tetsouo runs //gs c ls) re-applies
--- ITS OWN lockstyle. Each instance runs its local select_default_lockstyle,
--- so no gear/lockstyle data is shared across the wire - only the trigger.
--- @return boolean False when the job has no select_default_lockstyle
function GearCommands.handle_lockstyle()
    if not select_default_lockstyle then
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Lockstyle function not available")
        return false
    end

    MessageCommands.show_lockstyle_reapplying()
    select_default_lockstyle()

    -- Mirror to paired instance (no-op when solo: harmless if no listener).
    -- pcall: IPC is best-effort, never let it break the local lockstyle path.
    pcall(function()
        local SyncIPC = require('shared/utils/dualbox/dualbox_sync_ipc')
        SyncIPC.broadcast('ls')
    end)
    return true
end

-- DRESSUP TOGGLE COMMAND (Persistent)

--- Toggle DressUp management on/off (LockstyleManager.toggle_dressup owns
--- the persisted value). When OFF, lockstyle commands do not unload/reload
--- the DressUp addon; useful for players who do not have DressUp installed.
--- Usage: //gs c dressup
--- @return boolean True if the toggle was applied
function GearCommands.handle_dressup()
    local lockstyle_success, LockstyleManager = pcall(require, 'shared/utils/lockstyle/lockstyle_manager')
    if lockstyle_success and LockstyleManager and LockstyleManager.toggle_dressup then
        local enabled = LockstyleManager.toggle_dressup()
        MessageCommands.show_dressup_toggled(enabled)
        return true
    else
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load lockstyle manager")
        return false
    end
end

_G.GearCommands = GearCommands

return GearCommands
