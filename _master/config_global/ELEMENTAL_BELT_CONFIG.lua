---============================================================================
--- Elemental Belt - Hachirin-no-Obi / Orpheus's Sash picked automatically
---============================================================================
--- On an elemental damage action (nukes, Banish / Holy, elemental ninjutsu,
--- Blue Magic of a Magical category, elemental weaponskills such as Aeolian
--- Edge, Sanguine Blade, Leaden Salute, and Quick Draw), GearSwap puts on the
--- belt that adds the most, if you have it in your inventory or wardrobes:
---
---   Orpheus's Sash    by distance to the target: +15 % up to about 2
---                     yalms, down to +1 % from 13 yalms
---   Hachirin-no-Obi   by day and weather: +10 % day of the element, +10 %
---                     single weather (or a SCH storm), +25 % double weather
---                     (or Storm II), added up; the same as a PENALTY on the
---                     opposing element's day or weather
---
--- In short: Orpheus close to the target, the Obi when the day or weather
--- matches, and neither far away with nothing matching (then the belt of your
--- set stays on).
---
--- Settings:
---   enabled    true = automatic, false = never (your sets decide)
---   min_bonus  the belt goes on only when it adds at least this many %;
---              below that, the belt of your set keeps its own stats
---
--- Examples:
---   return { enabled = true, min_bonus = 5 }     -- standard
---   return { enabled = true, min_bonus = 10 }    -- only a clear gain
---   return { enabled = false }                   -- off
---
--- In game: //gs c belt shows the belts found, today's day / weather and
--- what each belt would add now. After editing this file: //gs reload.
---
--- @file    _common/gear/ELEMENTAL_BELT_CONFIG.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-28
---============================================================================

return {
    enabled = true,
    min_bonus = 5,
}
