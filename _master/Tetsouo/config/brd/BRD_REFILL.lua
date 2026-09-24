---  ═══════════════════════════════════════════════════════════════════════════
---   BRD Refill Config
---   See WAR_REFILL.lua for the format reference.
---  ═══════════════════════════════════════════════════════════════════════════

local M = {}

M.store_bag = 'case'

-- Default: any subjob other than DNC -> include Powder/Oil + DD food.
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
