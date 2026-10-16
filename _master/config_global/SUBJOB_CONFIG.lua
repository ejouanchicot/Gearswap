---============================================================================
--- Subjob - what a subjob brings to any job
---============================================================================
--- The values below are the defaults. Change what you want; a line removed
--- (or commented out) goes back to its default, and in a table the keys you
--- give are enough.
---
--- @file _common/combat/SUBJOB_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-10-10
---============================================================================

return {
    -- Curing Waltz tier from the missing HP of the target (main DNC or /DNC):
    -- each tier starts at this many HP missing
    waltz_from = {['Curing Waltz II'] = 200, ['Curing Waltz III'] = 600, ['Curing Waltz IV'] = 1100, ['Curing Waltz V'] = 1500},

    -- Stratagems (main SCH or /SCH): seconds for the whole pool to come back (the
    -- charges shown are read from it; lower with the job-point gift)
    stratagem_full_recharge = 240,

    -- //gs c ja1, ja2... (or //gs c ja 1): one macro per place, the ability of the subjob you
    -- have now. By main job (or `all` for every main job), then by subjob; the target is the
    -- ability's own (<me> or <t>), or write {name = 'Jump', target = '<bt>'}. Example:
    --   abilities = {
    --       DRK = { SAM = {'Hasso', 'Meditate', 'Sekkanoki', 'Seigan'},
    --               WAR = {'Aggressor', 'Berserk', 'Warcry'} },
    --   },
    abilities = {},
}
