---============================================================================
--- Utsusemi Shadows - let Utsusemi: Ichi replace the shadows already up
---============================================================================
--- Ichi cannot overwrite existing shadows (Copy Image, from any Utsusemi):
--- cast over them, it lands and does nothing. The shadows are cancelled during
--- the cast so it takes over. Needs Windower's Cancel addon.
---
--- When: 2.3 s into the cast at most, and always MARGIN s before its end, from
--- the cast time the precast worked out for this spell (_G._precast_cast_time,
--- shared/utils/precast/cast_time.lua). Ichi is 4 s before Fast Cast
--- (res/spells.lua): a fixed 2.3 s fell after the end past ~42 % of Fast Cast,
--- so Ichi landed on the shadows, did nothing, and the shadows were then
--- cancelled, none left (audit 2026-10-28 D).
---
--- Runs for every job, from the universal spell hook
--- (shared/hooks/init_spell_messages.lua). DNC did it on its own before.
---
--- @file    shared/utils/midcast/utsusemi_shadows.lua
--- @author  ejouanchicot
--- @version 1.1
--- @date    Created: 2026-09-25
---============================================================================

local UtsusemiShadows = {}

-- Copy Image, Copy Image (2), (3), (4+)
local SHADOW_BUFF_IDS = {66, 444, 445, 446}
local CANCEL_DELAY, MARGIN, EARLIEST = 2.3, 0.8, 0.2

--- Seconds into the cast to cancel the shadows: before its end by MARGIN, never
--- later than CANCEL_DELAY, never before EARLIEST.
--- @param spell table
--- @return number
function UtsusemiShadows.delay(spell)
    local cast = rawget(_G, '_precast_cast_time')
    local seconds = type(cast) == 'table' and cast.id == spell.id and tonumber(cast.seconds) or nil
    if not seconds then return CANCEL_DELAY end
    return math.max(EARLIEST, math.min(CANCEL_DELAY, seconds - MARGIN))
end

--- Schedule the shadow cancel when the spell is Utsusemi: Ichi.
--- @param spell table Spell object from GearSwap
function UtsusemiShadows.on_midcast(spell)
    if not spell or spell.english ~= 'Utsusemi: Ichi' then return end
    local delay = UtsusemiShadows.delay(spell)
    for _, id in ipairs(SHADOW_BUFF_IDS) do
        send_command(('wait %.1f; cancel %d'):format(delay, id))
    end
end

return UtsusemiShadows
