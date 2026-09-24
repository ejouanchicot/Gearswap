---  ═══════════════════════════════════════════════════════════════════════════
---   PLD Refill Config
---   See WAR_REFILL.lua for the format reference.
---  ═══════════════════════════════════════════════════════════════════════════
---   PLD typical subjobs: /RUN, /SCH, /BLU.
---   Default = full kit + tank food.
---   /SCH and /RDM overrides = default minus Powder/Oil (user preference).
---   /RUN override = same list as the default.

local M = {}

M.store_bag = 'case'

M.default = {
    {name = 'Panacea', target = 12},
    {name = 'Echo Drops', target = 12},
    {name = 'Antacid', target = 12},
    {name = 'Holy Water', target = 12},
    {name = 'Remedy', target = 12},
    {name = 'Prism Powder', target = 12},
    {name = 'Silent Oil', target = 12},
    {name = {'Omelette Sandwich +1', 'Omelette Sandwich'}, target = 12}
}

M.subjobs = {
    SCH = {
        {name = 'Panacea', target = 12},
        {name = 'Echo Drops', target = 12},
        {name = 'Antacid', target = 12},
        {name = 'Holy Water', target = 12},
        {name = 'Remedy', target = 12},
        {name = {'Omelette Sandwich +1', 'Omelette Sandwich'}, target = 12}
    },
    RDM = {
        {name = 'Panacea', target = 12},
        {name = 'Echo Drops', target = 12},
        {name = 'Antacid', target = 12},
        {name = 'Holy Water', target = 12},
        {name = 'Remedy', target = 12},
        {name = {'Omelette Sandwich +1', 'Omelette Sandwich'}, target = 12}
    },
    RUN = {
        {name = 'Panacea', target = 12},
        {name = 'Echo Drops', target = 12},
        {name = 'Antacid', target = 12},
        {name = 'Holy Water', target = 12},
        {name = 'Remedy', target = 12},
        {name = 'Prism Powder', target = 12},
        {name = 'Silent Oil', target = 12},
        {name = {'Omelette Sandwich +1', 'Omelette Sandwich'}, target = 12}
    }
}

return M
