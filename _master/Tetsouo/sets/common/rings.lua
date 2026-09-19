---  ═══════════════════════════════════════════════════════════════════════════
---   Common Wardrobe Rings - Cross-Job Definitions
---  ═══════════════════════════════════════════════════════════════════════════
---   Centralized ring definitions used across multiple jobs (BLM, BRD, BST,
---   COR, DNC, PLD, THF, etc.). Wardrobe bag is specified to avoid conflicts
---   when the same ring is equipped in both slots (e.g. Chirich +1 dual).
---
---   Usage:
---     local Rings = require('Tetsouo/sets/common/rings')
---     sets.idle = { ring1 = Rings.Moonlight1, ring2 = Rings.Moonlight2 }
---
---   @file    Tetsouo/sets/common/rings.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-10
---  ═══════════════════════════════════════════════════════════════════════════

local Rings = {
    -- Stikini Ring +1 (Refresh / Stats)
    Stikini1   = {name = 'Stikini Ring +1', bag = 'wardrobe 1'},
    Stikini2   = {name = 'Stikini Ring +1', bag = 'wardrobe 2'},

    -- Chirich Ring +1 (Haste / Store TP)
    Chirich1   = {name = 'Chirich Ring +1', bag = 'wardrobe 1'},
    Chirich2   = {name = 'Chirich Ring +1', bag = 'wardrobe 2'},

    -- Moonlight Ring (Damage Taken)
    Moonlight1 = {name = 'Moonlight Ring', bag = 'wardrobe 1'},
    Moonlight2 = {name = 'Moonlight Ring', bag = 'wardrobe 2'},
}

return Rings
