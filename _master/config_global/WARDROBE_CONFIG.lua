---============================================================================
--- Wardrobe Organizer - where your gear goes (//gs c wo)
---============================================================================
--- //gs c wo moves your gear between your bags: what your sets use goes to
--- the USED bags, the rest to the UNUSED bags, and the rules below place
--- whatever you want wherever you want. //gs c wo preview shows what would
--- move without moving anything; //gs c wo check tells what is misplaced.
---
--- Every key is optional. With nothing set (the lines below are comments),
--- the organizer uses the wardrobes you have unlocked: Wardrobe 1 and 2 for
--- the gear of the job you play, your other wardrobes for the rest, and it
--- touches every wardrobe.
---
--- Bags by name: 'inventory', 'wardrobe', 'wardrobe 2' ... 'wardrobe 8'
--- (or 'W1' ... 'W8'), 'satchel', 'sack', 'case'. The game equips only from
--- the inventory and the wardrobes: gear stored in Satchel, Sack or Case must
--- come back before you can wear it.
---
--- Rules, strongest first:
---   NEVER_TOUCH / NEVER_MOVE   left alone
---   PLACE                      that item in that bag
---   bag = 'wardrobe N'         written on a piece in your sets
---   JOBS                       that job's gear in its bags
---   TYPES                      used gear of that type in its bags
---   USED                       the rest of the used gear
---   UNUSED                     everything else
---
--- @file _common/inventory/WARDROBE_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-09-30
---============================================================================

return {
    -- Which gear counts as used:
    --   'active_job'  the job you play (run //gs c wo again after a job change)
    --   'all_jobs'    every job at once (when all your gear fits)
    -- //gs c wo alt always does every job once, whatever is set here.
    -- SCOPE = 'active_job',

    -- Where the used gear goes, filled in this order.
    -- USED = {'wardrobe', 'wardrobe 2'},

    -- Where everything else goes, in this order. Wardrobes, or storage bags.
    -- UNUSED = {'wardrobe 8', 'wardrobe 6', 'wardrobe 5', 'wardrobe 4', 'wardrobe 3'},
    -- UNUSED = {'wardrobe 3', 'wardrobe 4', 'case', 'sack'},

    -- Bags the organizer never touches (craft gear kept in W7, for example).
    -- NEVER_TOUCH = {'wardrobe 7'},

    -- Items counted as used although no set names them (they stay in USED).
    -- KEEP = {'Nexus Cape', 'Warp Ring'},

    -- Items never moved: left in whatever bag they are.
    -- NEVER_MOVE = {'Emporium Ring'},

    -- One item always in one bag. A list puts one copy in each bag.
    -- PLACE = {
    --     ['Trizek Ring'] = 'wardrobe 8',
    --     ['Moonlight Ring'] = {'wardrobe', 'wardrobe 2'},
    -- },

    -- The gear of a job in its own bags (from its set files, whatever SCOPE
    -- says). A piece several jobs use goes to one of their bags.
    -- JOBS = {
    --     WAR = {'wardrobe 3'},
    --     PLD = {'wardrobe 4'},
    -- },

    -- Used gear of a type in its own bags.
    -- Types: weapons (main, sub, range), ammo, armor (head, body, hands,
    -- legs, feet), accessories (neck, ears, rings, back, waist).
    -- TYPES = {
    --     weapons = {'wardrobe 5'},
    -- },

    -- Bags for //gs c wo alt (every job at once), when they differ from
    -- USED / UNUSED above.
    -- USED_WHEN_ALL = {'wardrobe', 'wardrobe 2', 'wardrobe 3', 'wardrobe 4'},
    -- UNUSED_WHEN_ALL = {'case', 'sack'},
}
