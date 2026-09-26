---  ═══════════════════════════════════════════════════════════════════════════
---   BLU AzureSets - the AzureSets addon loaded while playing BLU
---  ═══════════════════════════════════════════════════════════════════════════
---   AzureSets saves and sets Blue Magic spell lists (//aset). It is loaded
---   when a BLU file loads and unloaded once the character is no longer BLU.
---
---   A subjob change or //gs reload unloads the job file and loads it again:
---   the unload is therefore checked 2 s later, from the game's own job, and
---   skipped while the character is still BLU; the load is skipped when this
---   module already loaded it (`windower` outlives the job sandbox).
---
---   @file    shared/jobs/blu/functions/logic/azure_sets.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-26
---  ═══════════════════════════════════════════════════════════════════════════

local BLUAzureSets = {}

local ADDON = 'AzureSets'
-- Long enough for the game to report the new main job after a job change
local UNLOAD_CHECK_DELAY = 2
local HINT_DELAY = 3

--- Load the addon unless this module already did.
function BLUAzureSets.load()
    if windower._blu_azuresets_loaded then return end
    windower._blu_azuresets_loaded = true
    send_command('lua load ' .. ADDON)
    coroutine.schedule(function()
        local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if ok and MessageFormatter then
            MessageFormatter.show_info(ADDON .. ': //aset setlist | //aset spellset <name>')
        end
    end, HINT_DELAY)
end

--- Unload the addon once the character is no longer BLU.
function BLUAzureSets.unload()
    if not windower._blu_azuresets_loaded then return end
    coroutine.schedule(function()
        local me = windower.ffxi.get_player()
        if me and me.main_job == 'BLU' then return end
        windower._blu_azuresets_loaded = false
        windower.send_command('lua unload ' .. ADDON)
    end, UNLOAD_CHECK_DELAY)
end

return BLUAzureSets
