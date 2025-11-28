---============================================================================
--- BLM Elemental Match Configuration
---============================================================================
--- Configure automatic Hachirin-no-obi equipping based on elemental conditions.
--- When spell element matches storm/day/weather, waist is overridden with
--- Hachirin-no-obi for bonus magic damage.
---
--- @file BLM_ELEMENTAL_CONFIG.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-25
---============================================================================

local BLMElementalConfig = {}

---============================================================================
--- HACHIRIN-NO-OBI AUTO-EQUIP CONFIGURATION
---============================================================================

--- Enable automatic Hachirin-no-obi equipping when elemental conditions match
--- @type boolean
BLMElementalConfig.auto_hachirin = true

--- Check if active storm matches spell element
--- Storm buffs: Firestorm, Hailstorm, Windstorm, Sandstorm, Thunderstorm, Rainstorm
--- @type boolean
BLMElementalConfig.check_storm = true

--- Check if day element matches spell element
--- Days: Firesday, Iceday, Windsday, Earthsday, Lightningday, Watersday, Lightsday, Darksday
--- @type boolean
BLMElementalConfig.check_day = true

--- Check if weather element matches spell element
--- Weather: Heat waves, Blizzards, Gales, Sand storms, Thunderstorms, Squalls, Auroras, Darkness
--- Note: Only considers weather with intensity > 0 (real elemental weather)
--- @type boolean
BLMElementalConfig.check_weather = true

---============================================================================
--- USAGE NOTES
---============================================================================
--- How Elemental Matching Works:
---   1. When casting Elemental Magic, elemental conditions are checked
---   2. If ANY enabled condition matches spell element:
---      - Hachirin-no-obi is equipped (overrides waist slot)
---      - Bonus: +10% magic damage (single weather/day/storm)
---      - Bonus: +25% magic damage (double weather, e.g., Blizzards on Iceday)
---   3. If no conditions match:
---      - Base set waist is used (no override)
---
--- To disable auto-Hachirin completely:
---   BLMElementalConfig.auto_hachirin = false
---
--- To check only storms (ignore day/weather):
---   BLMElementalConfig.check_storm = true
---   BLMElementalConfig.check_day = false
---   BLMElementalConfig.check_weather = false
---
--- To check day AND storm (both must match):
---   Modify BLM_MIDCAST.lua to use AND logic instead of OR
---============================================================================

return BLMElementalConfig
