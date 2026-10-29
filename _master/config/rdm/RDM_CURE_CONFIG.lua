---============================================================================
--- RDM Cure Configuration - Auto-Tier System
---============================================================================
--- The WHM's Cure tier choice, on RDM: a Cure cast on someone missing few HP
--- goes out as the smallest tier that covers them (Cure IV into 150 missing HP
--- becomes Cure II), and a tier on recast is swapped for the next ready one.
---
--- Examples (the thresholds below, margin 50):
---   • the target misses 120 HP, you cast Cure IV  -> Cure II  (120 + 50 = 170)
---   • the target misses 900 HP, you cast Cure III -> Cure IV  (900 + 50 = 950)
---   • the target at full HP, you cast Cure IV     -> Cure     (lowest tier)
---   • Cure IV on recast                           -> Cure III (then lower, then higher)
---
--- On / Off in game: state.CureAutoTier (Apps+Numpad2 in RDM_KEYBINDS.lua). Off
--- keeps the tier you cast; a tier on recast is still swapped for a ready one.
--- Without this file the character's RDM never changes a Cure.
---
--- Usage:
---   • Loaded by shared/utils/whm/cure_manager.lua (from RDM_PRECAST.lua and
---     shared/entry/rdm.lua, which makes the mode)
---   • The thresholds are HP MISSING on the target, plus safety_margin
---
--- @file    config/rdm/RDM_CURE_CONFIG.lua
--- @author  ejouanchicot
--- @version 1.0.0
--- @date    Created: 2026-10-29
---============================================================================

local RDMCureConfig = {}

---============================================================================
--- CURE TIER THRESHOLDS
---============================================================================

--- HP missing (+ safety_margin) -> the Cure cast. RDM casts Cure to Cure IV.
--- Heals measured on a RDM Cure set (Cure IV 1056 HP in game, 2026-10-29;
--- the others from the same potency): Cure ~105, Cure II ~240, Cure III ~560.
--- Lower the maxima if your Cure set heals less.
RDMCureConfig.cure_tiers = {
    {min = 0, max = 150, spell = 'Cure'},
    {min = 150, max = 290, spell = 'Cure II'},
    {min = 290, max = 610, spell = 'Cure III'},
    {min = 610, max = 99999, spell = 'Cure IV'},
}

--- Curaga with /WHM (Curaga, Curaga II). Delete this table to leave Curagas as cast.
RDMCureConfig.curaga_tiers = {
    {min = 0, max = 300, spell = 'Curaga'},
    {min = 300, max = 99999, spell = 'Curaga II'},
}

---============================================================================
--- AUTO-TIER SETTINGS
---============================================================================

--- The Cure Auto-Tier mode when the job loads: true = On, false = Off. Its key
--- turns it on and off afterwards (a subjob change keeps your choice).
RDMCureConfig.auto_tier_enabled = true

--- Extra HP added to the HP missing before choosing (prevents near-miss heals)
RDMCureConfig.safety_margin = 50

---============================================================================
--- MP ECONOMY
---============================================================================

--- Under this MP percent, sets.midcast.CureMPConservation (your rdm_sets.lua)
--- goes on top of your Cure set. Nothing happens without that set, or with it
--- empty: the code names no item, your sets say what is worn.
--- Example: main = 'Raetic Rod +1' in sets.midcast.Cure, and
---   sets.midcast.CureMPConservation = { main = 'Daybreak' }
--- Delete the line (or set it to 0) to turn it off.
RDMCureConfig.mp_conservation_below = 40

---============================================================================
--- DEBUG SETTINGS
---============================================================================

--- true: the HP read on the target is shown in chat for every Cure
--- (the tier change itself is always shown)
RDMCureConfig.debug_messages = false

return RDMCureConfig
