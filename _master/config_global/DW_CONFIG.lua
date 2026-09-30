---============================================================================
--- Dual Wield tiers - less Dual Wield gear as magic haste goes up
---============================================================================
--- While you hold two weapons and are engaged, GearSwap lays the Dual Wield
--- pieces of one tier on top of your engaged set. The tier follows the magic
--- haste you have (estimated from your buffs):
---
---   sets.DW.NoHaste    under 15 %      (no haste)
---   sets.DW.Haste      15 % or more    (Haste, one March, Mighty Guard)
---   sets.DW.HasteII    30 % or more    (Haste II, Geo-Haste, two Marches)
---   sets.DW.MaxHaste   43.75 % (cap)   (Haste II + a March...)
---
--- Why: attack delay cannot go under 20 %. With capped gear haste, the Dual
--- Wield needed (job trait included) is 74 % with no haste, 67 % at 15 %,
--- 56 % at 30 %, 36 % at the cap. Each tier holds only the DW pieces you
--- still need; what you take off becomes damage gear.
---
--- Put the tiers in your job's set file (<Character>/sets/<job>_sets.lua):
---   sets.DW = {}
---   sets.DW.NoHaste  = { left_ear = "Suppanomimi", waist = "Reiki Yotai", ... }
---   sets.DW.HasteII  = { waist = "Reiki Yotai" }
---   sets.DW.MaxHaste = {}
--- A tier left out uses the one below it (more Dual Wield: the safe side).
--- No sets.DW in a job file: nothing changes on that job.
---
--- Settings below: enabled, and the % each buff counts for. They are
--- estimates, a little low on purpose (a March depends on the Bard's gear;
--- counting less keeps a little more Dual Wield). Slow and Elegy on you are
--- not counted (their strength cannot be known): while slowed, force more
--- Dual Wield with //gs c dw none, then //gs c dw auto.
---
--- In game:
---   //gs c dw                          estimated haste, tier, set used
---   //gs c dw none|haste|haste2|max    force a tier (the estimate is wrong)
---   //gs c dw auto                     back to the estimate
--- After editing this file: //gs reload.
---
--- @file    common/combat/DW_CONFIG.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-28
---============================================================================

return {
    enabled = true,          -- false = never (your engaged sets decide alone)

    haste = 15,              -- Haste
    haste2 = 30,             -- Haste II, Erratic Flutter
    geo_haste = 30,          -- Geo-Haste / Indi-Haste bubble
    mighty_guard = 15,
    embrava = 25,
    honor_march = 13,
    victory_march = 15,
    advancing_march = 10,
    unknown_march = 10,      -- a March whose song was not seen
}
