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
--- Why: attack delay cannot go under 20 % ((1 - DW) x (1 - haste) >= 0.2), and
--- Dual Wield past that only lowers the TP per hit. Each tier holds only the DW
--- pieces you still need; what you take off becomes damage gear.
---
--- Dual Wield to wear in GEAR, by your job's trait and magic haste (BG Wiki,
--- Dual_Wield cheatsheet, capped gear haste 25 %, no Haste Samba; read
--- 2026-11-06):
---
---   trait (where from)                 no haste  15 %  30 %  cap
---   DW I    10 % (THF main 83)            60      50    33     0
---   DW II   15 % (/DNC, DNC main 40)      55      45    28     0
---   DW III  25 % (/NIN, NIN main 45)      45      35    18     0
---   DW IV   30 % (NIN 65, DNC 80, THF)  40      30    13     0
---   DW V    35 % (NIN 85)                 35      25     8     0
---
--- A subjob is level 49 at 99, one more each 5 Master Levels (59 at ML 50):
--- /NIN keeps DW III and /DNC DW II up to ML 50. BLU gets the trait from the
--- Blue Magic it sets (tier IV from spells, V and VI with job point gifts).
--- Haste Samba on you lowers these numbers (BG Wiki's own columns).
--- A set file serves both subjobs: fill it for the one needing more (/DNC).
---
--- Put the tiers in your job's set file (<Character>/sets/<job>_sets.lua):
---   sets.DW = {}
---   sets.DW.NoHaste  = { left_ear = "Suppanomimi", waist = "Reiki Yotai", ... }
---   sets.DW.HasteII  = { waist = "Reiki Yotai" }
---   sets.DW.MaxHaste = {}      (empty: the HasteII pieces stay)
--- A tier left out or empty uses the one below it (more Dual Wield: the safe
--- side). No tier filled in a job file: nothing changes on that job.
---
--- Settings below: enabled, and the % each buff counts for. They are
--- estimates: Haste, Haste II and Geo-Haste at their written value, a March
--- depends on the Bard's gear (counting less keeps a little more Dual Wield,
--- the safe side). Slow and Elegy on you are
--- not counted (their strength cannot be known): while slowed, force more
--- Dual Wield with //gs c dw none, then //gs c dw auto.
---
--- Auto DW job by job: in `jobs` below, false turns the tiers off on that job
--- alone (its engaged sets decide alone there); true or a job left out: on.
--- `enabled = false` turns them off on every job. MNK and PUP fight with hand
--- to hand weapons, no off hand: not listed.
---
--- In game:
---   //gs c dw                          estimated haste, tier, set used
---   //gs c dw none|haste|haste2|max    force a tier (the estimate is wrong)
---   //gs c dw auto                     back to the estimate
--- After editing this file: //gs reload.
---
--- @file    _common/gear/DW_CONFIG.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-28
---============================================================================

return {
    enabled = true,          -- false = never, on every job (your engaged sets decide alone)

    -- Auto DW on each job (false = off on that job)
    jobs = {
        BLM = true, BLU = true, BRD = true, BST = true, COR = true, DNC = true, DRG = true,
        DRK = true, GEO = true, NIN = true, PLD = true, RDM = true, RNG = true, RUN = true,
        SAM = true, SCH = true, SMN = true, THF = true, WAR = true, WHM = true,
    },

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
