---  ═══════════════════════════════════════════════════════════════════════════
---   Kaories - Wardrobe Organizer Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   The game reads wardrobes in order, so the job being played belongs in W1
---   and W2. Everything else goes to W4 and W3, which are still wardrobes -
---   whatever lands there stays equippable.
---
---   This means `//gs c wo` must be re-run after a job change, which is already
---   the habit here.
---
---   Sizing (measured 2026-08-10 with //gs c wo scan, not guessed from the
---   sets, which name 238 pieces of which 139 are actually owned):
---     biggest job held  = RDM, 63 pieces   -> W1+W2 hold 160
---     largest surplus   = COR active, 91   -> W4+W3 hold 160
---
---   FFXI bag IDs (for reference):
---     0 = inventory      5 = satchel        6 = sack          7 = case
---     8 = wardrobe1     10 = wardrobe2     11 = wardrobe3    12 = wardrobe4
---
---   @file Kaories/config/WARDROBE_CONFIG.lua
---   @author Tetsouo
---  ═══════════════════════════════════════════════════════════════════════════

return {
    -- The job currently loaded, so W1/W2 hold what the game reads first.
    SCOPE = 'active_job',

    -- Where the active job's gear goes, in load order.
    PRIMARY_BAGS  = {8, 10},                    -- W1, W2

    -- Everything else. W4 before W3 so W3 stays the emptier of the two.
    --
    -- Sack, Case and Satchel are listed last on purpose. They are NOT meant to
    -- be used: FFXI cannot equip from them. They are here so the organizer
    -- still LOOKS there and can bring back gear that earlier runs exiled -
    -- there were 161 items sitting in them when this was written. Once the
    -- wardrobes have taken everything back, nothing should reach them again.
    OVERFLOW_BAGS = {12, 11, 6, 7, 5},          -- W4, W3, then Sack, Case, Satchel

    -- Nothing protected (Kaories doesn't use a craft wardrobe).
    PROTECTED     = {},

    -- All wardrobes Kaories has unlocked.
    ALL_WARDROBES = {8, 10, 11, 12},

    -- ─── OBJETS A GARDER EN WARDROBE  ───────────────────────────────────────
    -- Items no gear set names, kept where they can be equipped.
    --
    -- Her three warp items (Warp Ring, Dim. Ring (Holla), Nexus Cape) are
    -- handled without being listed: the organizer reads them from the warp
    -- database. It does so because the overflow list above still ends in bags
    -- FFXI cannot equip from - three pinned items out of 160 primary slots.
    --
    -- Use this for anything else. Names must match the game exactly.
    KEEP_ITEMS = {
        -- 'Emporer Hairpin',
    },
}
