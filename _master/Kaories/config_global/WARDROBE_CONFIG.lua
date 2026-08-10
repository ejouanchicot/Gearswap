---  ═══════════════════════════════════════════════════════════════════════════
---   Kaories - Wardrobe Organizer Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Kaories plays four jobs and has four wardrobes, so her whole collection
---   fits at once: `//gs c wo` places the gear of EVERY job with a set file in
---   Kaories/sets/ (COR, GEO, PLD, RDM) across W1-W4, and moves out only what
---   no job of hers asks for.
---
---   That is what SCOPE = 'all_jobs' means. Without it the organizer would
---   consider the current job alone, fill W1 and part of W2, and treat the
---   rest as storage - which is why W3 and W4 used to come out empty.
---
---   FFXI bag IDs (for reference):
---     0 = inventory      5 = satchel        6 = sack          7 = case
---     8 = wardrobe1     10 = wardrobe2     11 = wardrobe3    12 = wardrobe4
---
---   @file Kaories/config/WARDROBE_CONFIG.lua
---   @author Tetsouo
---  ═══════════════════════════════════════════════════════════════════════════

return {
    -- Every job's gear, not just the one currently loaded.
    SCOPE = 'all_jobs',

    -- Where the used gear lives.
    PRIMARY_BAGS  = {8, 10, 11, 12},            -- W1, W2, W3, W4

    -- Where the rest goes: Sack > Case > Satchel.
    OVERFLOW_BAGS = {6, 7, 5},                  -- Sack, Case, Satchel

    -- Nothing protected (Kaories doesn't use a craft wardrobe).
    PROTECTED     = {},

    -- All wardrobes Kaories has unlocked.
    ALL_WARDROBES = {8, 10, 11, 12},

    -- ─── OBJETS A GARDER EN WARDROBE  ───────────────────────────────────────
    -- Items no gear set names, but that must stay somewhere equippable.
    -- Without this they count as unused and go to Sack/Case/Satchel, which
    -- FFXI cannot equip from - so they become unreachable, not just tidied.
    --
    -- The warp and teleport rings are already handled: the organizer reads
    -- them from the warp database on its own, because her overflow is
    -- unequippable. Nothing to list here for those.
    --
    -- Use this for the rest. Names must match the game exactly.
    KEEP_ITEMS = {
        -- 'Nexus Cape',
        -- 'Emporer Hairpin',
    },
}
