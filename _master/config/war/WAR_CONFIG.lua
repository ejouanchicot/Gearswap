---============================================================================
--- Warrior - the job's own switches and thresholds
---============================================================================
--- The values below are the defaults. Change what you want; a line removed
--- (or commented out) goes back to its default, and in a table the keys you
--- give are enough.
---
--- @file war/combat/WAR_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-10-10
---============================================================================

return {
    -- Retaliation cancelled after 5 s of running
    retaliation_cancel = true,

    -- //gs c berserk: what it uses, in order (a name removed is no longer used;
    -- Warcry: Blood Rage instead while Warcry is on cooldown)
    berserk = {'Berserk', 'Aggressor', 'Retaliation', 'Restraint', 'Warcry'},

    -- //gs c defender: the same with Defender
    defender = {'Defender', 'Aggressor', 'Retaliation', 'Restraint', 'Warcry'},

    -- With a SAM subjob: add the stance (Hasso with berserk, Seigan with defender)
    -- and Third Eye to those two commands
    add_sam = true,
}
