---============================================================================
--- Stealth - Sneak / Invisible settings (//gs c stealth)
---============================================================================
--- Alt+Z / Alt+X (or //gs c stealth sneak | invi | both) put Sneak or
--- Invisible on this character and on the other characters of the box group,
--- each with the best way it has: Spectral Jig > spell > ninjutsu > item
--- (Silent Oil / Prism Powder, then Evanessence) > a partner with the spell.
---
--- Change these values here, or in game (saved in this file):
---   //gs c stealth refresh 180     //gs c stealth alert 60
---   //gs c stealth overwrite on    //gs c stealth alerts off
---   //gs c stealth delay 2.5
---
--- @file config/STEALTH_CONFIG.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-26
---============================================================================

return {
    -- A buff with more seconds left than this is not cast again. Spectral Jig
    -- is skipped only when both Sneak and Invisible have that much left.
    refresh_below = 180,

    -- Warn this many seconds before Sneak or Invisible wears off (0 = never).
    alert_before = 60,

    -- true: cast again whatever time is left.
    overwrite = false,

    -- false: no wear-off warning in chat.
    alerts = true,

    -- Seconds after an action ends before the next one (the game refuses an
    -- action sent too soon after the previous one).
    delay = 2.5,
}
