---  ═══════════════════════════════════════════════════════════════════════════
---   Live TP - the TP the game shows now
---  ═══════════════════════════════════════════════════════════════════════════
---   GearSwap's player.tp / player.vitals.tp is a copy re-read from the game
---   only when the last read is over 0.5 s old (GearSwap refresh.lua
---   refresh_player), and never inside a coroutine.schedule callback. A TP
---   check made from it can see 900 when the game already has 1000, or the TP
---   from before a Jump that just landed. windower.ffxi.get_player() reads
---   the game itself; GearSwap's copy is only the fallback.
---
---   local live_tp = require('shared/utils/core/live_tp')
---   if live_tp() >= 1000 then ... end
---
---   @file    shared/utils/core/live_tp.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-27
---  ═══════════════════════════════════════════════════════════════════════════

--- TP read from the game, GearSwap's copy as a fallback.
--- @return number
local function live_tp()
    local ok, me = pcall(windower.ffxi.get_player)
    if ok and me and me.vitals and me.vitals.tp then
        return me.vitals.tp
    end
    return player and player.vitals and player.vitals.tp or 0
end

return live_tp
