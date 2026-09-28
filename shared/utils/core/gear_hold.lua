---============================================================================
--- Gear Hold - whether the idle / engaged gear must not change right now
---============================================================================
--- A COR roll keeps its gear until the roll lands (roll_hold.lua writes
--- _G.cor_roll_hold, at most 5 s): the "Phantom Roll +" piece must be worn
--- when the roll takes effect. roll_hold marks Mote's own gear update
--- handled; the layers wrapped around handle_equipping_gear (Dual Wield
--- tiers, the Treasure Hunter engaged overlay, the player's CUSTOM gear) ask
--- here and stay out of the way too.
---
--- @file    shared/utils/core/gear_hold.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-28
---============================================================================

local GearHold = {}

--- @return boolean True while a roll holds the gear
function GearHold.active()
    local hold = rawget(_G, 'cor_roll_hold')
    return hold ~= nil and os.clock() < (hold.until_time or 0)
end

return GearHold
