--============================================================================
-- GeoRange - LOCAL ADDITION, not part of the original addon
--============================================================================
-- A shorter casting range for the Geo- spells, as the desktop program sees it.
--
-- The program decides a spell is in range with Calc.Range_Calc: the game's
-- range value (12 for every Geo-) times a table (1.7 for 12), plus both sizes,
-- minus 0.5: about 20-21 yalms. The game refuses a Geo- well before that (seen
-- at 18.6 yalms, 2026-11-13; the player puts the limit near 17). A trigger
-- answering with a Geo- (the bubble at the pull) then tries too far, is
-- refused, waits 3 s, and tries again a little closer.
--
-- This file rewrites the range of the Geo- spells in the spell list the addon
-- sends to the program (lib/Spells.lua get_all_spells, sent once at the sync):
--   GEO_RANGE 10 -> 10 x 1.45 + sizes - 0.5 = about 15 yalms (15.6 on Degei)
--   GEO_RANGE  9 -> about 13 yalms        GEO_RANGE 11 -> about 17 yalms
-- The Geomancy page keeps its own fixed 21-yalm check; nothing else changes.
-- The program asks for the spell list once per run of the desktop program (Global_Sync):
-- a change here takes //lua r silmaril on every box, then closing and starting the program again.
-- The list is shared by all its characters (a GEO Tetsouo gets the same range).
--
-- After an addon update: python scripts/addon_patches/silmaril/install.py
-- (in the GearSwap data folder) puts this file and its require line back.
--============================================================================

do
    local GEO_RANGE = 12   -- 12 = the game's own value, no change: 10 (~15 yalms) only once a pull bubble needs it (2026-11-13)

    local addon_get_all_spells = get_all_spells
    function get_all_spells()
        local text = addon_get_all_spells()
        -- one entry per spell: id|name|cast_time|mp_cost|range|type|targets|status, entries split by ','
        local out = text:gsub('(%d+|Geo%-[^|,]+|[^|,]*|[^|,]*|)%d+(|)', '%1' .. GEO_RANGE .. '%2')
        return out
    end
end
