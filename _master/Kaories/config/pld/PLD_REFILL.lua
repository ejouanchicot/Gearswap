---  ═══════════════════════════════════════════════════════════════════════════
---   PLD Refill Config
---   See WAR_REFILL.lua for the format reference.
---  ═══════════════════════════════════════════════════════════════════════════
---   PLD typical subjobs: /RUN, /SCH, /BLU.
---   Default = full kit + tank food.
---   /SCH override = drop Powder/Oil (Sublimation/Stratagems unrelated, just user pref),
---                    add Echo Drops for Silence on /SCH cures.

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
        {name = 'Antacid', target = 12},
        {name = 'Holy Water', target = 12},
        {name = 'Remedy', target = 12},
        {name = {'Omelette Sandwich +1', 'Omelette Sandwich'}, target = 12}
    },
    RDM = {
        {name = 'Panacea', target = 12},
        {name = 'Antacid', target = 12},
        {name = 'Holy Water', target = 12},
        {name = 'Remedy', target = 12},
        {name = {'Omelette Sandwich +1', 'Omelette Sandwich'}, target = 12}
    }
}

return M
