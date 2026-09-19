---  ═══════════════════════════════════════════════════════════════════════════
---   BRD Weapons - Main / Sub Weapon Set Definitions
---  ═══════════════════════════════════════════════════════════════════════════
---   Each entry returns a partial gear set (main or sub slot only) so it can
---   be combined with engaged / WS sets via set_combine.
---
---   Usage:
---     local Weapons = require('Tetsouo/sets/brd/weapons')
---     for name, weapon_set in pairs(Weapons) do
---         sets[name] = weapon_set
---     end
---
---   @file    Tetsouo/sets/brd/weapons.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-10
---  ═══════════════════════════════════════════════════════════════════════════

local Weapons = {}

-- • Daggers (main)
Weapons['Carnwenhan']  = {main = 'Carnwenhan'}    -- Mythic
Weapons['Twashtar']    = {main = 'Twashtar'}      -- Empyrean dagger
Weapons['Mpu Gandring'] = {main = 'Mpu Gandring'} -- Magical dagger

-- • Daggers (sub)
Weapons['Centovente']  = {sub = 'Centovente'}     -- Dual wield sub

-- • Swords (main)
Weapons['Naegling']    = {main = 'Naegling'}      -- Savage Blade focus

-- • Swords (sub)
Weapons['Demersal']    = {sub = 'Demers. Degen +1'}

-- • Clubs (sub)
Weapons['Kraken']      = {sub = 'Kraken Club'}    -- Multi-attack

-- • Shields (sub)
Weapons['Genmei']      = {sub = 'Genmei Shield'}  -- Tank shield

return Weapons
