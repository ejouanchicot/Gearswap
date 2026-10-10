---============================================================================
--- HP Priority - the order your pieces go on in
---============================================================================
--- When a set changes, GearSwap puts the pieces on one by one. At each
--- change (idle or engaged > precast > midcast > aftercast...) this system
--- ranks the pieces by the HP they gain over the ones you wear right then:
--- the pieces that raise your max HP go on first, those that lower it last,
--- so your max HP never dips in the middle of a swap (which would cost HP).
--- MP comes next, the same way, among the pieces that change HP alike: all
--- the HP first, the MP after, on every job.
--- It changes the order only, never what you wear. A `priority` you wrote
--- yourself on a piece in your sets is replaced by this order (a job that
--- must keep its own goes in skip_jobs). Pieces giving HP or MP in percent
--- (HP+10 %) count for that share of your own HP / MP.
---
--- HP and MP of each piece come from the game data, plus the augments your
--- set names. For a piece your sets name without augments (a unique piece),
--- run //gs c gearscan once: it reads the real augments in all your bags and
--- keeps them in saved/gear_augments.lua. Run it again after new gear.
---
--- Examples:
---   unity = 'max'             your Unity leader is rank 1 (top Unity bonus)
---   skip_jobs = {'PLD'}       leave PLD alone (write your own priorities)
---   enabled = false           turn it off
---
--- @file _common/gear/HP_PRIORITY_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-09-30
---============================================================================

return {
    enabled = true,
    -- Rank of your Unity leader: 'max' for rank 1, 'min' otherwise
    unity = 'min',
    -- Jobs left alone (their sets give their own priorities)
    skip_jobs = {},
}
