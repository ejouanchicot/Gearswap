---============================================================================
--- Utsusemi Shadows - let Utsusemi: Ichi replace the shadows already up
---============================================================================
--- Ichi cannot overwrite existing shadows (Copy Image, from any Utsusemi):
--- cast over them, it lands and does nothing. The shadows are cancelled
--- 2.3 s into the cast so it takes over. Needs Windower's Cancel addon.
---
--- Runs for every job, from the universal spell hook
--- (shared/hooks/init_spell_messages.lua). DNC did it on its own before.
---
--- @file    shared/utils/midcast/utsusemi_shadows.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local UtsusemiShadows = {}

-- Copy Image, Copy Image (2), (3), (4+)
local SHADOW_BUFF_IDS = {66, 444, 445, 446}
local CANCEL_DELAY = 2.3

--- Schedule the shadow cancel when the spell is Utsusemi: Ichi.
--- @param spell table Spell object from GearSwap
function UtsusemiShadows.on_midcast(spell)
    if not spell or spell.english ~= 'Utsusemi: Ichi' then return end
    for _, id in ipairs(SHADOW_BUFF_IDS) do
        send_command(('wait %.1f; cancel %d'):format(CANCEL_DELAY, id))
    end
end

return UtsusemiShadows
