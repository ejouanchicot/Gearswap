---  ═══════════════════════════════════════════════════════════════════════════
---   Tetsouo - Wardrobe Organizer Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Per-character bag layout used by `//gs c wo` and `//gs c wo alt`.
---   Loaded automatically by the organizer when this character is active.
---
---   FFXI bag IDs (for reference):
---     0 = inventory      5 = satchel        6 = sack          7 = case
---     8 = wardrobe1     10 = wardrobe2     11 = wardrobe3    12 = wardrobe4
---    13 = wardrobe5     14 = wardrobe6     15 = wardrobe7    16 = wardrobe8
---
---   @file Tetsouo/config/WARDROBE_CONFIG.lua
---  ═══════════════════════════════════════════════════════════════════════════

return {
    -- Fifteen jobs do not fit in eight wardrobes at once, so the organizer
    -- works on the job currently loaded and rotates: run it again after a job
    -- change. (The other value, 'all_jobs', suits a character whose whole
    -- collection fits - see Kaories.)
    SCOPE = 'active_job',

    -- ─── REGULAR MODE  (//gs c wo)  ─────────────────────────────────────────
    -- Where the active job's gear lives (fast-load slots).
    PRIMARY_BAGS  = {8, 10},                    -- W1, W2

    -- Where unused gear gets pushed. Order = push priority.
    -- W8 first (reserve, usually emptiest), then W6 > W5 > W4 > W3.
    OVERFLOW_BAGS = {16, 14, 13, 12, 11},       -- W8, W6, W5, W4, W3

    -- Wardrobes the algorithm NEVER touches.
    PROTECTED     = {15},                       -- W7 (craft gear)

    -- All wardrobes scanned by the algorithm (must include primary + overflow).
    ALL_WARDROBES = {8, 10, 11, 12, 13, 14, 16},

    -- ─── ALT MODE  (//gs c wo alt)  ─────────────────────────────────────────
    -- For Tetsouo this isn't needed (full 8-wardrobe setup), but provided
    -- for parity. If you ever want a "minimal" layout, uncomment.
    -- ALT_PRIMARY_BAGS  = {8, 10, 11, 12},
    -- ALT_OVERFLOW_BAGS = {6, 7, 5},
}
