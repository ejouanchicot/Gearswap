---============================================================================
--- HP Priority - the order your pieces go on in
---============================================================================
--- When a set changes, GearSwap puts the pieces on one by one. At each
--- change (idle or engaged > precast > midcast > aftercast...) this system
--- ranks the pieces by the HP they gain over the ones you wear right then:
--- the pieces that raise your max HP go on first, those that lower it last,
--- so your max HP never dips in the middle of a swap (which would cost HP).
--- It changes the order only, never what you wear. A `priority` you write
--- yourself on a piece in your sets is kept as it is.
---
--- HP and MP of each piece come from the game data, plus the augments your
--- set names. For a piece your sets name without augments (a unique piece),
--- run //gs c gearscan once: it reads the real augments in all your bags and
--- keeps them in saved/gear_augments.lua. Run it again after new gear.
---
--- Examples:
---   unity = 'max'             your Unity leader is rank 1 (top Unity bonus)
---   mp_jobs = {'BLM', 'SCH'}  on these jobs MP counts too (after HP)
---   skip_jobs = {'PLD'}       leave PLD alone (write your own priorities)
---   enabled = false           turn it off
---
--- @file _common/combat/HP_PRIORITY.lua
--- @author ejouanchicot
--- @date Created: 2026-09-30
---============================================================================

return {
    enabled = true,
    -- Rank of your Unity leader: 'max' for rank 1, 'min' otherwise
    unity = 'min',
    -- Jobs where MP counts after HP
    mp_jobs = {'BLM', 'RDM', 'GEO'},
    -- Jobs left alone (their sets give their own priorities)
    skip_jobs = {},
}
