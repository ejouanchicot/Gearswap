---  ═══════════════════════════════════════════════════════════════════════════
---   WAR Refill Config - per-character / per-subjob inventory restock list
---  ═══════════════════════════════════════════════════════════════════════════
---   Read by shared/utils/inventory/refill_manager.lua via //gs c refill.
---
---   Item entries:
---     { name = 'Item',          target = N }   -- single item, target N
---     { name = {'A +1', 'A'},   target = N }   -- variants: prefer +1, fallback A
---
---   For variants, the manager pulls the preferred form first, then fills the
---   gap with the fallback so the TOTAL across variants equals target.
---
---   `store_bag` controls where SURPLUS items are pushed back when inv > target.
---   Values: 'case' (default) | 'sack' | 'satchel'
---  ═══════════════════════════════════════════════════════════════════════════

local M = {}

M.store_bag = 'case'

-- Default list (used for any subjob other than the ones in M.subjobs below).
-- WAR /SAM, /NIN, /WAR, /BLU, etc. -> full melee kit including Powder/Oil.
M.default = {
    {name = 'Panacea', target = 12},
    {name = 'Antacid', target = 12},
    {name = 'Holy Water', target = 12},
    {name = 'Remedy', target = 12},
    {name = 'Prism Powder', target = 12},
    {name = 'Silent Oil', target = 12},
    {name = {'Sublime Sushi +1', 'Sublime Sushi'}, target = 12},
    {name = {'R. Curry Bun +1', 'Red Curry Bun'}, target = 12},
    {name = {'Gyudon +1', 'Gyudon'}, target = 12}
}

M.subjobs = {
    -- WAR/DNC -> DNC subjob has Spectral Jig, no need for Powder/Oil.
    DNC = {
        {name = 'Panacea', target = 12},
        {name = 'Antacid', target = 12},
        {name = 'Holy Water', target = 12},
        {name = 'Remedy', target = 12},
        {name = {'Sublime Sushi +1', 'Sublime Sushi'}, target = 12},
        {name = {'R. Curry Bun +1', 'Red Curry Bun'}, target = 12},
        {name = {'Gyudon +1', 'Gyudon'}, target = 12}
    }
}

return M
