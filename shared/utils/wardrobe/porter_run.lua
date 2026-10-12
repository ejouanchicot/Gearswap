---============================================================================
--- Porter Run - one command for the Porter Moogle, the wardrobes and the refill
---============================================================================
--- //gs c po (also asked by the Atelier page, POST /porter_run) chains what a
--- job change needs:
---   1. PorterPacker (addons/PorterPacker, a separate addon) swaps to the job
---      loaded: `//po`, which stores the other jobs' pieces at the Porter
---      Moogle and takes this job's out. Only with a Porter Moogle within reach.
---   2. //gs c wo tidies the wardrobes, then asks the lockstyle and the refill
---      itself (wardrobe_organizer.lua, schedule_lockstyle).
--- PorterPacker starts step 2 when it has finished (`//po then gs c wo`, its
--- own option); this file moves nothing and talks to no NPC.
---
--- Without a Porter Moogle within reach, step 2 alone is run.
---
--- @file    shared/utils/wardrobe/porter_run.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-12
---============================================================================

local PorterRun = {}

local NEXT = 'gs c wo'

local function say(title, fields, lines)
    require('shared/utils/messages/info_block').show({tag = 'PORTER', title = title, fields = fields, lines = lines})
end

--- Whether PorterPacker is installed (its folder: whether it is loaded cannot be known from here).
local function installed()
    return windower.dir_exists(windower.windower_path .. 'addons/PorterPacker')
end

--- Why nothing may start now, or nil: the character must stand idle.
local function busy()
    local me = windower.ffxi.get_player()
    if not me then return 'not in game' end
    if me.status ~= 0 then return 'you are not idle (fighting, resting, in an event or dead)' end
    return nil
end

--- Start the chain.
--- @return table {ok, porter (PorterPacker asked), error}
function PorterRun.start()
    local not_now = busy()
    if not_now then
        say('Job gear', {{'Cannot start', not_now, 'bad'}})
        return {ok = false, error = not_now}
    end
    local near = require('shared/utils/atelier/atelier_place').near('Porter Moogle')
    if not (installed() and near) then
        say('Job gear', {{'Porter Moogle', installed() and 'none within reach' or 'PorterPacker is not installed', 'warn'}},
            {'Wardrobes and refill only (//gs c wo).'})
        windower.send_command(NEXT)
        return {ok = true, porter = false}
    end
    -- the pieces the job's sets use and PorterPacker's list misses are added first (porter_lists.lua)
    pcall(function() require('shared/utils/atelier/porter_lists').sync(player.main_job) end)
    say('Job gear', {{'Porter Moogle', 'within reach', 'good'}},
        {'PorterPacker (//po), then the wardrobes (//gs c wo), the lockstyle and the refill.',
         'You will be undressed meanwhile. //po reset stops PorterPacker.'})
    -- loaded if it was not; PorterPacker runs what follows `then` once its run has finished
    windower.send_command('lua load PorterPacker; wait 1; po then ' .. NEXT)
    return {ok = true, porter = true}
end

return PorterRun
