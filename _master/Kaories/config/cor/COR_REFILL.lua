---  ═══════════════════════════════════════════════════════════════════════════
---   COR Refill Config (Kaories)
---   See Tetsouo/config/war/WAR_REFILL.lua for the format reference.
---  ═══════════════════════════════════════════════════════════════════════════
---   COR: never needs Powder/Oil (per user spec) - uses ranged play, less need.

local M = {}

M.store_bag = 'case'

M.default = {
    { name = 'Panacea',                                    target = 12 },
    { name = 'Antacid',                                    target = 12 },
    { name = 'Holy Water',                                 target = 12 },
    { name = 'Remedy',                                     target = 12 },
    { name = {'Sublime Sushi +1',  'Sublime Sushi'},         target = 12 },
    { name = {'R. Curry Bun +1',  'Red Curry Bun'},       target = 12 },
    -- Bronze Bullet refills. Must sit in INVENTORY: /item only works there,
    -- which is what lets the quiver manager open one automatically.
    { name = 'Brz. Bull. Pouch',                           target = 2 },
}

return M
