---============================================================================
--- Mount Manager - Mount / Dismount toggle for every job
---============================================================================
--- Centralized mount handling exposed to all jobs through COMMON_COMMANDS as
--- `//gs c mount`: dismounts when already riding, otherwise summons a random
--- mount among those the character actually owns.
---
--- Ownership resolution is deliberately layered, because the shape of the
--- Windower API differs between versions:
---   1. windower.ffxi.get_abilities().mounts  (list of ids OR id-keyed map)
---   2. bitfield carried by the last incoming 0x0AE packet (one bit per id)
---   3. Chocobo, granted to every character, as a last resort
--- A failure at any layer falls through instead of erroring, so the command
--- can never break a job load.
---
--- @file shared/utils/mount/mount_manager.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-07-28
---============================================================================

local MountManager = {}

local MessageFormatter = require('shared/utils/messages/message_formatter')
local res = require('resources')

--- Granted to every character, used when ownership cannot be resolved.
local FALLBACK_MOUNT = 'Chocobo'

--- Packet carrying the ownership bitfield; data starts at byte OWNERSHIP_OFFSET.
local OWNERSHIP_PACKET = 0x0AE
local OWNERSHIP_OFFSET = 5

--- Player statuses that mean "currently riding".
--- Chocobo predates the mount system and still reports its own status.
local MOUNTED_STATUSES = {
    ['Mount']   = true,
    ['Chocobo'] = true,
}

math.randomseed(os.time())
math.random()  -- first draw after seeding is weak on some Lua builds

---============================================================================
--- STATE DETECTION
---============================================================================

--- Check whether the player is currently riding a mount
--- @return boolean True when mounted
function MountManager.is_mounted()
    if player and player.status and MOUNTED_STATUSES[player.status] then
        return true
    end

    return (buffactive and buffactive['Mounted']) and true or false
end

---============================================================================
--- OWNERSHIP RESOLUTION
---============================================================================

--- Read owned mounts from windower.ffxi.get_abilities()
--- Absorbs both shapes: a list of ids, or a map keyed by id.
--- @return table|nil List of mount names, nil when the API exposes nothing
local function owned_from_api()
    local ok, abilities = pcall(windower.ffxi.get_abilities)
    if not ok or type(abilities) ~= 'table' or type(abilities.mounts) ~= 'table' then
        return nil
    end

    local owned = {}
    for key, value in pairs(abilities.mounts) do
        -- List shape stores the id as the value, map shape stores it as the key
        local id = (type(value) == 'number') and value or key
        local mount = (type(id) == 'number') and res.mounts[id] or nil
        if mount and value ~= false then
            table.insert(owned, mount.en)
        end
    end

    return owned
end

--- Read owned mounts from the 0x0AE ownership bitfield
--- @return table|nil List of mount names, nil when the packet is unavailable
local function owned_from_packet()
    local ok, data = pcall(windower.packets.last_incoming, OWNERSHIP_PACKET)
    if not ok or type(data) ~= 'string' then
        return nil
    end

    local owned = {}
    for id, mount in pairs(res.mounts) do
        local byte = data:byte(math.floor(id / 8) + OWNERSHIP_OFFSET)
        if byte and math.floor((byte % 2 ^ (id % 8 + 1)) / 2 ^ (id % 8)) == 1 then
            table.insert(owned, mount.en)
        end
    end

    return owned
end

--- Resolve every mount the character owns
--- @return table List of mount names, never empty
function MountManager.get_owned_mounts()
    local owned = owned_from_api()

    if not owned or #owned == 0 then
        owned = owned_from_packet()
    end

    if not owned or #owned == 0 then
        return { FALLBACK_MOUNT }
    end

    return owned
end

---============================================================================
--- ACTIONS
---============================================================================

--- Pick a random mount among those owned
--- @return string Mount name
function MountManager.pick_random_mount()
    local owned = MountManager.get_owned_mounts()
    return owned[math.random(#owned)]
end

--- Dismount
--- @return boolean Always true
function MountManager.dismount()
    send_command('input /dismount')
    return true
end

--- Summon a random owned mount
--- @return boolean Always true
function MountManager.mount()
    local mount_name = MountManager.pick_random_mount()

    MessageFormatter.show_info('Mounting: ' .. mount_name)
    send_command('input /mount "' .. mount_name .. '"')

    return true
end

--- Toggle: dismount when riding, otherwise summon a random owned mount
--- Zone and combat restrictions are left to the server, which already rejects
--- the command with its own message.
--- @return boolean Always true
function MountManager.toggle()
    if MountManager.is_mounted() then
        return MountManager.dismount()
    end

    return MountManager.mount()
end

return MountManager
